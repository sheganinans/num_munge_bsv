package SqrtPipeline;

import FIFOF::*;
import FixedPoint::*;
import Vector::*;

`include "DEFNS.defines"

typedef enum { Ready, Processing } PipelineState deriving (Bits, Eq);

interface SqrtPipeline;
  method Action push (FixedPoint#(`FixPointSizes) x);
  method ActionValue#(FixedPoint#(`FixPointSizes)) get;
  method Bool inputReady;
  method Bool outputValid;
endinterface

(* synthesize *)
module mkSqrtPipeline (SqrtPipeline);
  Vector#(`SqrtPipeN, Reg#(Maybe#(FixedPoint#(`FixPointSizes)))) xs <- replicateM(mkRegU);
  Vector#(`SqrtPipeN, Reg#(FixedPoint#(`FixPointSizes))) ys <- replicateM(mkRegU);

  FIFOF#(FixedPoint#(`FixPointSizes)) input_fifo <- mkFIFOF;
  FIFOF#(FixedPoint#(`FixPointSizes)) output_fifo <- mkFIFOF;

  Reg#(PipelineState) state <- mkReg(Ready);

  let idx = valueOf(SizeOf#(FixedPoint#(`FixPointSizes)))-1;

  rule input_rule if (state == Ready && !isValid(xs[0]));
    let x = input_fifo.first;
    input_fifo.deq;
    xs[0] <= tagged Valid x;
    ys[0] <= x < 1 ? fromRational(1,2) : (unpack(pack(x)[idx:1])); // approximates x/2^0.5
    state <= Processing;
  endrule

  rule compute_rule if (state == Processing);
    Bool pipeline_done = True;
    for (int i = 0; i < `SqrtPipeN-1; i = i + 1) begin
      if (isValid(xs[i]) && !isValid(xs[i+1])) begin
        xs[i+1] <= xs[i];
        ys[i+1] <= ((ys[i] + (fromMaybe(?, xs[i]) / ys[i])) >> 1);
        pipeline_done = False;
      end
    end

    if (pipeline_done && isValid(xs[`SqrtPipeN-1])) begin
      output_fifo.enq(ys[`SqrtPipeN-1]);
      xs[`SqrtPipeN-1] <= tagged Invalid;
    end
  endrule

  method Action push(FixedPoint#(`FixPointSizes) x) if (state == Ready && !isValid(xs[0]));
    input_fifo.enq(x);
  endmethod

  method ActionValue#(FixedPoint#(`FixPointSizes)) get;
    output_fifo.deq;
    return output_fifo.first;
  endmethod

  method Bool inputReady;
    return state == Ready && !isValid(xs[0]);
  endmethod

  method Bool outputValid;
    return output_fifo.notEmpty;
  endmethod
endmodule

endpackage