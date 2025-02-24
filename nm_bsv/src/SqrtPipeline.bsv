package SqrtPipeline;

import FIFOF::*;
import FixedPoint::*;
import Vector::*;

`include "DEFNS.defines"

typedef enum { Ready, Processing } PipelineState deriving (Bits, Eq);

interface SqrtPipeline;
  method ActionValue#(FixedPoint#(`FixPointSizes)) get;
  method Action put (FixedPoint#(`FixPointSizes) x);
  method Bool inputReady;
  method Bool outputReady;
endinterface

(* synthesize *)
module mkSqrtPipeline (SqrtPipeline);
  Vector#(`SqrtPipeN, Reg#(Maybe#(FixedPoint#(`FixPointSizes)))) xs <- replicateM(mkRegU);
  Vector#(`SqrtPipeN, Reg#(FixedPoint#(`FixPointSizes))) ys <- replicateM(mkRegU);

  FIFOF#(FixedPoint#(`FixPointSizes)) input_fifo <- mkFIFOF;
  FIFOF#(FixedPoint#(`FixPointSizes)) output_fifo <- mkFIFOF;

  Reg#(PipelineState) state <- mkReg(Ready);

  let guess_slice = valueOf(SizeOf#(FixedPoint#(`FixPointSizes)))-1;

  rule input_rule if (state == Ready && !isValid(xs[0]));
    let x = input_fifo.first;
    input_fifo.deq;
    xs[0] <= tagged Valid x;
    ys[0] <= x < 1 ? fromRational(1,2) : unpack(pack(x)[guess_slice:1]); // approximates x/2^0.5
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
      state <= Ready;
    end
  endrule

  method ActionValue#(FixedPoint#(`FixPointSizes)) get;
    output_fifo.deq;
    return output_fifo.first;
  endmethod

  method Action put (FixedPoint#(`FixPointSizes) x);
    input_fifo.enq(x);
  endmethod

  method Bool inputReady;
    return state == Ready;
  endmethod

  method Bool outputReady;
    return output_fifo.notEmpty;
  endmethod
endmodule

endpackage