package MathPipelines;

import FixedPoint::*;
import FIFOF::*;
import SpecialFIFOs::*;
import SquareRoot::*;
import Vector::*;

`include "DEFNS.defines"

typedef FixedPoint#(`FixPointSizes) FXP;

interface FXPPipeline;
   method Action put(FXP x);
   method ActionValue#(FXP) get();
   method Bool putReady;
   method Bool getReady;
endinterface

interface Divider;
   method Action put(Tuple2#(FXP, FXP) operands);
   method ActionValue#(Tuple2#(FXP, FXP)) get();
   method Bool putReady;
   method Bool getReady;
endinterface

module mkNewtonDividerPipeline(Divider);
   FIFOF#(Tuple2#(FXP,FXP)) stage1 <- mkPipelineFIFOF;
   FIFOF#(Tuple3#(FXP,FXP, FXP)) stage2 <- mkPipelineFIFOF;
   FIFOF#(Tuple2#(FXP,FXP)) stage3 <- mkPipelineFIFOF;
   FIFOF#(Tuple2#(FXP,FXP)) outputFifo <- mkPipelineFIFOF;

   rule div_stage1 (stage1.notEmpty && stage2.notFull);
      match {.x, .y} = stage1.first;
      stage1.deq;
      stage2.enq(tuple3(x, y, x / y));
   endrule
   
   rule div_stage2 (stage2.notEmpty && stage3.notFull);
      match {.x, .y, .n} = stage2.first;
      stage2.deq;
      stage3.enq(tuple2(x, y + n));
   endrule
   
   rule div_stage3 (stage3.notEmpty && outputFifo.notFull);
      match {.x, .y} = stage3.first;
      stage3.deq;
      outputFifo.enq(tuple2(x, y / 2));
   endrule

   method Action put(Tuple2#(FXP, FXP) operands) if (stage1.notFull);
      stage1.enq(operands);
   endmethod

   method ActionValue#(Tuple2#(FXP, FXP)) get() if (outputFifo.notEmpty);
      outputFifo.deq;
      return outputFifo.first;
   endmethod

   method Bool putReady = stage1.notFull;
   method Bool getReady = outputFifo.notEmpty;
endmodule

module mkSqrtPipeline(FXPPipeline);
   FIFOF#(FXP) inputFifo <- mkPipelineFIFOF;
   Vector#(`SqrtPipeN, FIFOF#(Tuple2#(FXP,FXP))) stages <- replicateM(mkPipelineFIFOF);
   Vector#(`SqrtPipeN, Divider) sqrtVals <- replicateM(mkNewtonDividerPipeline);
   FIFOF#(FXP) outputFifo <- mkPipelineFIFOF;

   rule input_rule (inputFifo.notEmpty && stages[0].notFull);
      inputFifo.deq;
      let x = inputFifo.first;
      stages[0].enq(tuple2(x, x < 1 ? 0.5 : x / 1.414213562));
   endrule

   for (int i = 0; i < `SqrtPipeN-1; i = i + 1) begin
      rule newton_step (stages[i].notEmpty && sqrtVals[i].putReady);
         match {.x, .y} = stages[i].first;
         stages[i].deq;
         sqrtVals[i].put(tuple2(x, y));
      endrule

      rule newton_step_output (sqrtVals[i].getReady && stages[i+1].notFull);
         match {.x, .y} <- sqrtVals[i].get;
         stages[i+1].enq(tuple2(x, y));
      endrule
   end

   rule output_rule (stages[`SqrtPipeN-1].notEmpty && outputFifo.notFull);
      stages[`SqrtPipeN-1].deq;
      match {.x, .y} = stages[`SqrtPipeN-1].first;
      outputFifo.enq(y);
   endrule

   method Action put (FXP x) if (inputFifo.notFull);
      inputFifo.enq(x);
   endmethod

   method ActionValue#(FXP) get if (outputFifo.notEmpty);
      outputFifo.deq;
      return outputFifo.first;
   endmethod

   method Bool putReady = inputFifo.notFull;
   method Bool getReady = outputFifo.notEmpty;

endmodule

function FXP cos(FXP x);
   let x2 = x * x;
   let x4 = x2 * x2;
   let x6 = x4 * x2;
   return 1 - (x2 / 2) + (x4 / 24) - (x6 / 720);
endfunction

function FXP sin(FXP x);
   let x2 = x * x;
   let x3 = x2 * x;
   let x4 = x2 * x2;
   let x5 = x4 * x;
   let x6 = x3 * x3;
   let x7 = x6 * x;
   return x - (x3 / 6) + (x5 / 120) - (x7 / 5040);
endfunction

module mkLnPipeline(FXPPipeline);
   FIFOF#(FXP) stage0 <- mkPipelineFIFOF;
   FIFOF#(FXP) stage1 <- mkPipelineFIFOF;
   FIFOF#(Tuple2#(FXP, FXP)) stage2 <- mkPipelineFIFOF;
   FIFOF#(Tuple3#(FXP, FXP, FXP)) stage3 <- mkPipelineFIFOF;
   FIFOF#(Tuple4#(FXP, FXP, FXP, FXP)) stage4 <- mkPipelineFIFOF;
   FIFOF#(Tuple4#(FXP, FXP, FXP, FXP)) stage5 <- mkPipelineFIFOF;
   FIFOF#(FXP) stage6 <- mkPipelineFIFOF;

   rule compute_t (stage0.notEmpty && stage1.notFull);
      let x = stage0.first;
      stage0.deq;
      stage1.enq((x - 1) / (x + 1));
   endrule

   rule compute_t2 (stage1.notEmpty && stage2.notFull);
      let t = stage1.first;
      stage1.deq;
      stage2.enq(tuple2(t, t * t));
   endrule

   rule compute_t3_t4 (stage2.notEmpty && stage3.notFull);
      match {.t, .t2} = stage2.first;
      stage2.deq;
      stage3.enq(tuple3(t, t2 * t, t2 * t2));
   endrule

   rule compute_t5_t6 (stage3.notEmpty && stage4.notFull);
      match {.t, .t3, .t4} = stage3.first;
      stage3.deq;
      stage4.enq(tuple4(t, t3, t4 * t, t3 * t3));
   endrule

   rule compute_t7 (stage4.notEmpty && stage5.notFull);
      match {.t, .t3, .t5, .t6} = stage4.first;
      stage4.deq;
      stage5.enq(tuple4(t, t3, t5, t6 * t));
   endrule

   rule compute_result (stage5.notEmpty && stage6.notFull);
      match {.t, .t3, .t5, .t7} = stage5.first;
      stage5.deq;
      let sum = t + (t3 / 3) + (t5 / 5) + (t7 / 7);
      stage6.enq(sum * 2);
   endrule

   method Action put(FXP x) if (stage0.notFull);
      stage0.enq(x);
   endmethod

   method ActionValue#(FXP) get() if (stage6.notEmpty);
      stage6.deq;
      return stage6.first;
   endmethod

   method Bool putReady = stage0.notFull;
   method Bool getReady = stage6.notEmpty;
endmodule

function FXP exp(FXP x);
   let x2 = x * x;
   let x3 = x2 * x;
   let x4 = x3 * x;
   return 1 + x + (x2 / 2) + (x3 / 6) + (x4 / 24);
endfunction

// function FXP boxMuller(FXP u);
//    let r = 0.5 * (sqrt(-2 * ln(u)));
//    return r * cos(6.28318530718 * u);
// endfunction

// typedef Tuple4#(UInt#(32), UInt#(32), UInt#(32), UInt#(32)) State;

// function State initialState(UInt#(32) seed);
//    return tuple4(seed, seed ^ 32'h01234567, seed ^ 32'h89ABCDEF, seed ^ 32'hDEADBEEF);
// endfunction

// function Tuple2#(UInt#(32), State) xoshiro128Plus(State t);
//    match {.s0, .s1, .s2, .s3} = t;
//    let result = s0 + s3;
//    let s0_ = s0 ^ (s3 << 4);
//    let s1_ = s1 ^ (s0 << 9);
//    let s2_ = s2 ^ (s1 << 13);
//    let s3_ = s3 ^ unpack(rotateBitsBy(pack(s2), 7));
//    return tuple2(result, tuple4(s0_, s1_, s2_, s3_));
// endfunction

// interface RandomStream;
//    method ActionValue#(FXP) next;
// endinterface

// module mkRandomStream (RandomStream);
//    let initState = initialState(32'hC0FFEE42);
//    match {._, .s} = xoshiro128Plus(initState);
//    Reg#(State) state <- mkReg(s);
//    function ActionValue#(FXP) stepRNG(State st);
//       actionvalue
//          match {.v, .s} = xoshiro128Plus(st);
//          state <= s;
//          return FXP { i: pack(v)[31:16], f: 0 } / 32767;
//       endactionvalue
//    endfunction
//    method ActionValue#(FXP) next;
//       let ret <- stepRNG(state);
//       return boxMuller(ret);
//    endmethod
// endmodule
endpackage
