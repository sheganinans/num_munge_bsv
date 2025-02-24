package TestbenchSqrt;

import FixedPoint::*;
import SqrtPipeline::*;

module mkTestbenchSqrt (Empty);
  SqrtPipeline sqrt <- mkSqrtPipeline;
  Reg#(Bool) pushed <- mkReg(False);
  Reg#(Bool) done <- mkReg(False);

  rule do_push (!pushed);
    $display($time, ": Pushing sqrt(0.25)");
    sqrt.push(0.25);
    pushed <= True;
  endrule

  rule do_get (pushed && !done && sqrt.outputValid);
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
