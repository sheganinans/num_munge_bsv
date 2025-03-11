package TestbenchSqrt;

import FixedPoint::*;
import MathPipelines::*;

`include "DEFNS.defines"

function FixedPoint#(f,i) cosine_fixed (FixedPoint#(f,i) x)
  provisos (Min#(TAdd#(f, i), 2, 2), Min#(f, 1, 1));
  let x2 = x * x;
  let x4 = x2 * x2;
  let x6 = x4 * x2;
  return 1 - (x2 / 2) + (x4 / 24) - (x6 / 720);
endfunction

module mkTestbenchCos (Empty);
  Pipeline cos <- mkCosPipeline;
  Reg#(Int#(16)) count_put <- mkReg(0);
  Reg#(Int#(16)) count_get <- mkReg(0);
  Reg#(Int#(16)) mul <- mkReg(1);

  Int#(16) total = 16;

  rule do_put (count_put < total);
    $display($time, ": Putting cos(0.25 * %d)", mul);
    cos.put(0.25 * FixedPoint { i: pack(mul), f: 0 });
    mul <= mul + 1;
    count_put <= count_put + 1;
  endrule

  rule do_get (cos.outputReady);
    let v <- cos.get;
    let c = count_get + 1;
    let mul = FixedPoint { i: pack(c), f: 0 };
    $display($time, ": sqrt(0.25 * %d) = 0x%x. Eq?: %b", c, v, v == cos_fixed(0.25 * mul));
    count_get <= count_get + 1;
  endrule

  rule finish (count_put != 0 && count_get == count_put && !cos.outputReady);
    $display($time, ": Test complete");
    $finish(0);
  endrule

endmodule

endpackage
