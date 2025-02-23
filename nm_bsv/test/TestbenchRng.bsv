package TestbenchRng;

import GetPut::*;
import FixedPoint::*;
import Real::*;
import Rng::*;

(* synthesize, always_enabled *)
module mkTestbenchRng (Empty);
   Reg#(Int#(64)) cycle <- mkReg(0);
   Get#(FixedPoint#(16,16)) rng <- mkGaussianRNG;
   rule init (cycle == 0);
      let _init <- rng.get;
      cycle <= cycle + 1;
   endrule
   rule go (cycle != 0);
      cycle <= cycle + 1;
      let randVal <- rng.get;
      $display(show(randVal));
      if (cycle == 1000) begin
         $display("Number of cycles: %0d", cycle);
         $finish;
      end
   endrule
endmodule
endpackage
