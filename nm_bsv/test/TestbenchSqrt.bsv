package TestbenchSqrt;

import FixedPoint::*;
import SqrtPipeline::*;

module mkTestbenchSqrt (Empty);
  SqrtPipeline sqrt <- mkSqrtPipeline;
  Reg#(Bool) pushed <- mkReg(False);
  Reg#(Int#(32)) count_put <- mkReg(0);
  Reg#(Int#(32)) count_get <- mkReg(0);

  Int#(32) total = 5;

  rule do_put (!pushed);
    $display($time, ": Putting sqrt(0.25)");
    sqrt.put(0.25);
    count_put <= count_put + 1;
    if (count_put == total)
      pushed <= True;
  endrule

  rule do_get (pushed && sqrt.outputReady);
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
