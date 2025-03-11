package TestbenchSqrt;

import FixedPoint::*;
import MathPipelines::*;

`include "DEFNS.defines"

function FixedPoint#(f,i) sqrt_fixed (FixedPoint#(f,i) x)
  provisos (Min#(TAdd#(f, i), 2, 2), Min#(f, 1, 1));
  if (x == 0) begin return 0; end
  else begin
    FixedPoint#(f,i) y = x;
    for (Int#(4) i = 0; i < `SqrtPipeN; i = i + 1) begin
      y = (y + (x / y)) / 2;
    end
    return y;
  end
endfunction

module mkTestbenchSqrt (Empty);
  Pipeline sqrt <- mkSqrtPipeline;
  Reg#(Int#(16)) count_put <- mkReg(0);
  Reg#(Int#(16)) count_get <- mkReg(0);
  Reg#(Int#(16)) mul <- mkReg(1);

  Int#(16) total = 16;

  rule do_put (count_put < total);
    $display($time, ": Putting sqrt(0.25 * %d)", mul);
    sqrt.put(0.25 * FixedPoint { i: pack(mul), f: 0 });
    mul <= mul + 1;
    count_put <= count_put + 1;
  endrule

  rule do_get (sqrt.outputReady);
    let v <- sqrt.get;
    let c = count_get + 1;
    let mul = FixedPoint { i: pack(c), f: 0 };
    $display($time, ": sqrt(0.25 * %d) = 0x%x. Eq?: %b", c, v, v == sqrt_fixed(0.25 * mul));
    count_get <= count_get + 1;
  endrule

  rule finish (count_put != 0 && count_get == count_put && !sqrt.outputReady);
    $display($time, ": Test complete");
    $finish(0);
  endrule

endmodule

endpackage
