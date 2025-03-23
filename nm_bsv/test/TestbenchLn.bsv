package TestbenchLn;

import FixedPoint::*;
import MathPipelines::*;

`include "DEFNS.defines"

typedef FixedPoint#(`FixPointSizes) FXP;

function FXP ln_fixed(FXP x);
   function FXP go(FXP x_);
      let t = (x_ - 1) / (x_ + 1);
      let t2 = t * t;
      let t3 = t2 * t;
      let t4 = t2 * t2;
      let t5 = t4 * t;
      let t6 = t3 * t3;
      let t7 = t6 * t;
      return 2 * (t + (t3 / 3) + (t5 / 5) + (t7 / 7));
   endfunction
   return go(x);
endfunction

module mkTestbenchLn (Empty);
   FXPPipeline ln <- mkLnPipeline;
   Reg#(Int#(16)) count_put <- mkReg(0);
   Reg#(Int#(16)) count_get <- mkReg(0);
   Reg#(FXP) v <- mkReg(4);
   Reg#(FXP) ev <- mkReg(4);

   Int#(16) total = 16;

   rule do_put (count_put < total &&& ln.putReady);
      $display($time, ": Putting ln(0x%x)", v);
      ln.put(v);
      v <= v / 2;
      count_put <= count_put + 1;
   endrule

   rule do_get (ln.getReady);
      let vl <- ln.get;
      $display($time, ": ln.get = 0x%x, ln(0x%x) = 0x%x.   Eq?: %b", vl, ev, ln_fixed(ev), vl == ln_fixed(ev));
      ev <= ev / 2;
      count_get <= count_get + 1;
   endrule

   rule finish (count_put != 0 && count_get == count_put && !ln.getReady);
      $display($time, ": Test complete");
      $finish(0);
   endrule

endmodule
endpackage
