import GetPut::*;
import FixedPoint::*;

import Rng::*;
import MCMC::*;

module mkTestbenchMCMC (Empty);
  Get#(FixedPoint#(16,16)) rng <- mkGaussianRNG;
  MCMCSimulator mcmc <- mkMCMCSimulator;

  let numCycles = 10000;
  Reg#(Int#(32)) cycleCount <- mkReg(0);

  rule runSimulation (cycleCount < numCycles);
    mcmc.runMCMCStep;
    $display("Cycle ", cycleCount, ": ", show(mcmc.getState));
    cycleCount <= cycleCount + 1;
  endrule

  rule finishSimulation (cycleCount == numCycles);
    $finish;
  endrule
endmodule