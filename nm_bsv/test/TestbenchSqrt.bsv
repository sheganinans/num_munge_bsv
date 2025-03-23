package TestbenchSqrt;

import FixedPoint::*;
import MathPipelines::*;

`include "DEFNS.defines"

function FXP sqrt_fixed(FXP x);
  function FXP go(FXP i, FXP y);
     if (i == 0) return y;
     else        return go(i-1, (y + (x / y)) / 2);
  endfunction
  return go(`SqrtPipeN-1, x < 1 ? 0.5 : x / 1.414213562);
endfunction

module mkTestbenchSqrt (Empty);
  FXPPipeline sqrt <- mkSqrtPipeline;
  Reg#(Int#(16)) count_put <- mkReg(0);
  Reg#(Int#(16)) count_get <- mkReg(0);
  Reg#(Int#(16)) mul <- mkReg(1);

  Int#(16) total = 16;

  rule do_put (count_put < total && sqrt.putReady);
    $display($time, ": Putting sqrt(0.25 * %d)", mul);
    sqrt.put(0.25 * FixedPoint { i: pack(mul), f: 0 });
    mul <= mul + 1;
    count_put <= count_put + 1;
  endrule

  rule do_get (sqrt.getReady);
    let v <- sqrt.get;
    let c = count_get + 1;
    let mul = FixedPoint { i: pack(c), f: 0 };
    $display($time, ": sqrt(0.25 * %d) = 0x%x. Eq?: %b", c, v, v == sqrt_fixed(0.25 * mul));
    count_get <= count_get + 1;
  endrule

  rule finish (count_put != 0 && count_get == count_put && !sqrt.getReady);
    $display($time, ": Test complete");
    $finish(0);
  endrule

endmodule

endpackage
