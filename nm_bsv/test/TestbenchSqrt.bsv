package TestbenchSqrt;

import FixedPoint::*;
import SqrtPipeline::*;

module mkTestbenchSqrt (Empty);
  SqrtPipeline sqrt <- mkSqrtPipeline;
  Reg#(Bool) pushed <- mkReg(False);
  Reg#(Bool) done <- mkReg(False);

  rule do_put (!pushed);
    $display($time, ": Putting sqrt(0.25)");
    sqrt.put(0.25);
    pushed <= True;
  endrule

  rule do_get (pushed && !done && sqrt.outputReady);
    let v <- sqrt.get;
    $display($time, ": sqrt(0.25) = 0x%x", v);
    done <= True;
  endrule

  rule finish (done);
    $display($time, ": Test complete");
    $finish(0);
  endrule

endmodule

endpackage
