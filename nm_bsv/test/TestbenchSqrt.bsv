package TestbenchSqrt;

import FixedPoint::*;
import SqrtPipeline::*;

`include "DEFNS.defines"

module mkTestbenchSqrt (Empty);
  SqrtPipeline sqrt <- mkSqrtPipeline;
  Reg#(Int#(32)) count_put <- mkReg(0);
  Reg#(Int#(32)) count_get <- mkReg(0);
  Reg#(FixedPoint#(`FixPointSizes)) mul <- mkReg(1);

  Int#(32) total = 15;

  rule do_put (count_put < total);
    $display($time, ": Putting sqrt(0.25)");
    sqrt.put(0.25 * mul);
    mul <= mul + 1;
    count_put <= count_put + 1;
  endrule

  rule do_get (sqrt.outputReady);
    let v <- sqrt.get;
    $display($time, ": sqrt(0.25) = 0x%x", v);
    count_get <= count_get + 1;
  endrule

  rule finish (count_put != 0 && count_get == count_put && !sqrt.outputReady);
    $display($time, ": Test complete");
    $finish(0);
  endrule

endmodule

endpackage
