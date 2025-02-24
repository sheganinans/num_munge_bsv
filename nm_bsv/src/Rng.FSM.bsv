package Rng;

import GetPut::*;
import FIFOF::*;
import LFSR::*;
import FixedPoint::*;
import StmtFSM::*;

export mkGaussianRNG;
export show;

function FixedPoint#(f,i) sqrt_fixed (FixedPoint#(f,i) x)
  provisos (Min#(TAdd#(f, i), 2, 2), Min#(f, 1, 1));
  if (x == 0) begin return 0; end
  else begin
    FixedPoint#(f,i) y = x;
    for (Int#(4) i = 0; i < 5; i = i + 1) begin
      y = (y + (x / y)) / 2;
    end
    return y;
  end
endfunction

function FixedPoint#(f,i) cosine_fixed (FixedPoint#(f,i) x)
  provisos (Min#(TAdd#(f, i), 2, 2), Min#(f, 1, 1));
  let x2 = x * x;
  let x4 = x2 * x2;
  let x6 = x4 * x2;
  return 1 - (x2 / 2) + (x4 / 24) - (x6 / 720);
endfunction

function FixedPoint#(f,i) ln_fixed (FixedPoint#(f,i) x)
  provisos (Min#(f, 1, 1), Min#(TAdd#(f, i), 2, 2));
  if (x <= 0) begin return 0; end
  else begin
    let t = (x - 1) / (x + 1);
    let term = t;
    let result = term / 1;
    term = term * t * t;
    result = result + term / 3;
    term = term * t * t;
    result = result + term / 5;
    term = term * t * t;
    result = result + term / 7;
    return result * 2;
  end
endfunction

function Fmt show (FixedPoint#(i,f) value);
  Int#(i) i_part = fxptGetInt(value);
  UInt#(f) f_part = fxptGetFrac(value);
  return $format("%d.%d", i_part, f_part);
endfunction

(* synthesize *)
module mkGaussianRNG (Get#(FixedPoint#(16,16)));
  LFSR#(Bit#(16)) lfsr1 <- mkLFSR_16;
  LFSR#(Bit#(16)) lfsr2 <- mkLFSR_16;
  FIFOF#(FixedPoint#(16,16)) fi <- mkFIFOF;
  FIFOF#(FixedPoint#(16,16)) buffer <- mkFIFOF;

  Reg#(Maybe#(FixedPoint#(16,16))) u1 <- mkReg(tagged Invalid);
  Reg#(Maybe#(FixedPoint#(16,16))) u2 <- mkReg(tagged Invalid);
  Reg#(Maybe#(FixedPoint#(16,16))) ln_val <- mkReg(tagged Invalid);
  Reg#(Maybe#(FixedPoint#(16,16))) sqrt_val <- mkReg(tagged Invalid);
  Reg#(Maybe#(FixedPoint#(16,16))) cos_val <- mkReg(tagged Invalid);

  let two_pi = fromRational(628318, 100000);
  let scale = maxBound;

  function step1;
    action
      FixedPoint#(16,16) v1 = FixedPoint { i:lfsr1.value, f:0 } / scale;
      FixedPoint#(16,16) v2 = FixedPoint { i:lfsr2.value, f:0 } / scale;
      if (v1 > 0 && v1 < 1 && v2 > 0 && v2 < 1) begin
        u1 <= tagged Valid v1;
        u2 <= tagged Valid v2;
      end
      lfsr1.next;
      lfsr2.next;
    endaction
  endfunction

  function step2;
    action
      let ln_tmp = ln_fixed(fromMaybe(?, u1));
      if (ln_tmp != 0)
        ln_val <= tagged Valid ln_tmp;
      else
        u1 <= tagged Invalid;
    endaction
  endfunction

  function step3;
    action
      let sqrt_tmp = sqrt_fixed(-2.0 * fromMaybe(?, ln_val));
      if (sqrt_tmp > 0)
        sqrt_val <= tagged Valid sqrt_tmp;
      else begin
        u1 <= tagged Invalid;
        ln_val <= tagged Invalid;
      end
    endaction
  endfunction

  function step4;
    action
      let cos_tmp = cosine_fixed(two_pi * fromMaybe(?, u2));
      if (cos_tmp >= -1 && cos_tmp <= 1)
        cos_val <= tagged Valid cos_tmp;
      else
        u2 <= tagged Invalid;
    endaction
  endfunction

  function push_result;
    action
      let result = fromMaybe(?, sqrt_val) * fromMaybe(?, cos_val);
        buffer.enq(result);
      u1 <= tagged Invalid;
      u2 <= tagged Invalid;
      ln_val <= tagged Invalid;
      sqrt_val <= tagged Invalid;
      cos_val <= tagged Invalid;
    endaction
  endfunction

  Stmt gaussian_fsm = seq
    action
      lfsr1.seed(16'hACE1);
      lfsr2.seed(16'h1B7F);
    endaction

    while (True) seq
      await (buffer.notFull);
      step1;
      if (isValid(u1) && isValid(u2)) seq
        step2;
        if (isValid(ln_val)) seq
          step3;
          step4;
          if (isValid(sqrt_val) && isValid(cos_val))
            push_result;
          endseq endseq endseq endseq;

  FSM gaussian_gen <- mkFSM(gaussian_fsm);

  rule start_fsm;
    gaussian_gen.start;
  endrule

  rule buffer_to_output;
    if (buffer.notEmpty && fi.notFull) begin
      fi.enq(buffer.first);
      buffer.deq;
    end
  endrule

  return toGet(fi);
endmodule

endpackage