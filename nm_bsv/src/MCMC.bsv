package MCMC;

import GetPut::*;
import FixedPoint::*;

import Rng::*;

typedef FixedPoint#(16,16) State;

interface MCMCSimulator;
  method State getState();
  method Action runMCMCStep();
endinterface

module mkMCMCSimulator (MCMCSimulator);
  Get#(State) rng <- mkGaussianRNG;

  Reg#(State) state <- mkReg(0);

  method State getState;
    return state;
  endmethod

  method Action runMCMCStep;
    let randVal <- rng.get;
    state <= state + randVal;
  endmethod
endmodule

endpackage