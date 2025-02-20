package Testbench;

import AxiDefines::*;
import Axi4LDefines::*;

import DmaController::*;

`include "TLM.defines"

(* synthesize, always_enabled *)
module mkTestbench (Empty);
   Axi4LRdWrMaster#(`TLM_PRM_STD) axi <- mkDmaController;
   Reg#(Int#(32)) count <- mkReg(0);
   Reg#(Bool) awREADY <- mkReg(False);
   Reg#(AxiResp) bRESP <- mkReg(?);
   Reg#(Bool) bVALID <- mkReg(False);
   Reg#(Bool) wREADY <- mkReg(False);
   Reg#(Bool) arREADY <- mkReg(False);
   Reg#(AxiData#(`TLM_PRM_STD)) rDATA <- mkReg(?);
   Reg#(AxiResp) rRESP <- mkReg(?);
   Reg#(Bool) rVALID <- mkReg(False);
   Reg#(Bool) done <- mkReg(False);

   rule go;
      axi.write.awREADY(awREADY);
      axi.write.bRESP(bRESP);
      axi.write.bVALID(bVALID);
      axi.write.wREADY(wREADY);
      axi.read.arREADY(arREADY);
      axi.read.rDATA(rDATA);
      axi.read.rRESP(rRESP);
      axi.read.rVALID(rVALID);
      if (count == 1) begin
         awREADY <= True;
      end
      if (count == 2) begin
         wREADY <= True;
      end
      if (count == 3) begin
         bVALID <= True;
      end
      if (count == 4) begin
         done <= True;
      end
      if (done) begin
         $display ("done!");
         $finish (0);
      end
      count <= count + 1;
   endrule

   rule disp;
      $display ("count: ", count);
      $display ("awREADY: ", awREADY,
              ", bRESP: ", bRESP,
              ", bVALID: ", bVALID,
              ", wREADY: ", wREADY);
      $display ("axi.write.awVALID: ", axi.write.awVALID,
              ", axi.write.wVALID: ", axi.write.wVALID,
              ", axi.write.bREADY: ", axi.write.bREADY);
      $display ("axi.write.awADDR: ", axi.write.awADDR);
      $display ("axi.write.wDATA: %x", axi.write.wDATA);
      $display ("");
   endrule

endmodule

endpackage
