package MathPipelines;

import FIFOF::*;
import FixedPoint::*;
import Vector::*;

`include "DEFNS.defines"

typedef FixedPoint#(`FixPointSizes) FixedP;

function FixedP sqrtFixed(FixedP x);
   function FixedP go(FixedP i, FixedP y);
        if (i == 0) return y;
        else        return go(i-1, (y + (x / y)) / 2);
   endfunction
   if (x == 0) return 0;
   else        return go(5, (x < 1) ? 0.5 : x / 1.414213562);
endfunction

function FixedP cosFixed(FixedP x);
   let x2 = x * x;
   let x4 = x2 * x2;
   let x6 = x4 * x2;
   return 1 - (x2 / 2) + (x4 / 24) - (x6 / 720);
endfunction

function FixedP sinFixed(FixedP x);
   let x2 = x * x;
   let x3 = x2 * x;
   let x4 = x2 * x2;
   let x5 = x4 * x;
   let x6 = x3 * x3;
   let x7 = x6 * x;
   return x - (x3 / 6) + (x5 / 120) - (x7 / 5040);
endfunction

function FixedP lnFixed(FixedP x);
   function FixedP go(FixedP x_);
      let t = (x_ - 1) / (x_ + 1);
      let t2 = t * t;
      let t3 = t2 * t;
      let t4 = t2 * t2;
      let t5 = t4 * t;
      let t6 = t3 * t3;
      let t7 = t6 * t;
      return 2 * (t + (t3 / 3) + (t5 / 5) + (t7 / 7));
   endfunction
   if (x <= 0 || x == 1) return 0;
   else
      if (x < 1) return -go(1 / x);
      else       return go(x);
endfunction

function Tuple2#(FixedP, FixedP) boxMuller(FixedP u);
   let r = 0.5 * (sqrtFixed(-2 * lnFixed(u)));
   let theta = 6.28318530718 * u;
   let z0 = r * cosFixed(theta);
   let z1 = r * sinFixed(theta);
   return tuple2(z0, z1);
endfunction

typedef Tuple4#(UInt#(32), UInt#(32), UInt#(32), UInt#(32)) State;

function State initialState(UInt#(32) seed);
   return tuple4(seed, seed ^ 32'h01234567, seed ^ 32'h89ABCDEF, seed ^ 32'hDEADBEEF);
endfunction

function Tuple2#(UInt#(32), State) xoshiro128Plus(State t);
   match {.s0, .s1, .s2, .s3} = t;
   let result = s0 + s3;
   let s0_ = s0 ^ (s3 << 4);
   let s1_ = s1 ^ (s0 << 9);
   let s2_ = s2 ^ (s1 << 13);
   let s3_ = s3 ^ unpack(rotateBitsBy(pack(s2), 7));
   return tuple2(result, tuple4(s0_, s1_, s2_, s3_));
endfunction

interface RandomStream;
   method ActionValue#(Tuple2#(FixedP,FixedP)) next;
endinterface

(* synthesize *)
module mkRandomStream (RandomStream);
   let initState = initialState(32'hC0FFEE42);
   match {._, .s} = xoshiro128Plus(initState);
   Reg#(State) state <- mkReg(s);
   function ActionValue#(FixedP) toFixed(State st);
      actionvalue
         match {.v, .s} = xoshiro128Plus(st);
         state <= s;
         return FixedPoint { i: pack(v)[31:16], f: 0 } / 32767;
      endactionvalue
   endfunction
   method ActionValue#(Tuple2#(FixedP, FixedP)) next;
      let ret <- toFixed(state);
      return boxMuller(ret);
   endmethod
endmodule

endpackage
