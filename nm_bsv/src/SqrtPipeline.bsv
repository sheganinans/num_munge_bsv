package SqrtPipeline;

import FIFOF::*;
import FixedPoint::*;
import Vector::*;

`include "DEFNS.defines"

typedef enum { Ready, Processing } PipelineState deriving (Bits, Eq);

interface SqrtPipeline;
  method ActionValue#(FixedPoint#(`FixPointSizes)) get;
  method Action put (FixedPoint#(`FixPointSizes) x);
  method Bool outputReady;
endinterface

(* synthesize *)
module mkSqrtPipeline (SqrtPipeline);
  Vector#(`SqrtPipeN, Reg#(Maybe#(FixedPoint#(`FixPointSizes)))) xs <- replicateM(mkReg(tagged Invalid));
  Vector#(`SqrtPipeN, Reg#(FixedPoint#(`FixPointSizes))) ys <- replicateM(mkReg(1));

  FIFOF#(FixedPoint#(`FixPointSizes)) input_fifo <- mkFIFOF;
  FIFOF#(FixedPoint#(`FixPointSizes)) output_fifo <- mkFIFOF;

  rule go;
    if (input_fifo.notEmpty) begin
      input_fifo.deq;
      let x = input_fifo.first;
      xs[0] <= tagged Valid x;
      ys[0] <= x < 1 ? fromRational(1, 2) : (x >> 1);
    end else begin
      xs[0] <= tagged Invalid;
      ys[0] <= 1;
    end

    for (int i = 0; i < `SqrtPipeN-1; i = i + 1) begin
      if (isValid(xs[i])) begin
        let x = fromMaybe(?, xs[i]);
        xs[i+1] <= tagged Valid x;
        ys[i+1] <= (ys[i] + (x / ys[i])) >> 1;
      end else begin
        xs[i+1] <= tagged Invalid;
        ys[i+1] <= 1;
      end
    end

    if (isValid(xs[`SqrtPipeN-1]))
      output_fifo.enq(ys[`SqrtPipeN-1]);
  endrule

  method ActionValue#(FixedPoint#(`FixPointSizes)) get;
    output_fifo.deq;
    return output_fifo.first;
  endmethod

  method Action put (FixedPoint#(`FixPointSizes) x);
    input_fifo.enq(x);
  endmethod

  method Bool outputReady; return output_fifo.notEmpty; endmethod
endmodule

endpackage