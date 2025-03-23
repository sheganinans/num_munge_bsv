import AxiDefines::*;
import Axi4LDefines::*;
import Axi4LMaster::*;
import TLM3::*;

import MathPipelines::*;
import LnPipeline::*;

`include "TLM.defines"
`include "DEFNS.defines"

(* synthesize, always_enabled *)
module nm (Axi4LRdWrMaster#(`TLM_PRM_STD));
   Reg#(Bool) awready <- mkReg(False);
   Reg#(Bool) wready <- mkReg(False);
   Reg#(Bool) bvalid <- mkReg(False);
   Reg#(AxiAddr#(`TLM_PRM_STD)) addr <- mkReg(0);
   //RandomStream rng <- mkRandomStream;
   //TestMath tm <- mkTestMath;
   FXPPipeline p <- mkSqrtPipeline;
   Reg#(FXP) val <- mkReg(0);

   let prot = AxiProt { access: DATA, security: SECURE, privilege: NORMAL };

   rule update_addr;
      if (addr == 32'h3FFF_FFF)
         addr <= 32'h0;
      else
         addr <= addr + 4;
   endrule

   rule put_val (p.putReady);
      p.put(32);
   endrule

   rule next_val (p.getReady);
      let v <- p.get;
      val <= v;
   endrule

   interface Axi4LRdMaster read;
      method AxiAddr#(`TLM_PRM_STD) arADDR;
         return 0;
      endmethod
      method AxiProt arPROT;
         return prot;
      endmethod
      method Bool arVALID;
         return True;
      endmethod
      method Bool rREADY;
         return True;
      endmethod
      method Action arREADY (Bool ready);
      endmethod
      method Action rDATA (AxiData#(`TLM_PRM_STD) data);
      endmethod
      method Action rRESP (AxiResp rsp);
      endmethod
      method Action rVALID (Bool valid);
      endmethod
   endinterface

   interface Axi4LWrMaster write;
      method AxiAddr#(`TLM_PRM_STD) awADDR;
         return addr;
      endmethod
      method AxiProt awPROT;
         return prot;
      endmethod
      method Bool awVALID;
         return True;
      endmethod
      method Action awREADY (Bool ready);
         awready <= ready;
      endmethod
      method AxiData#(`TLM_PRM_STD) wDATA;
         return pack(val);
      endmethod
      method AxiByteEn#(`TLM_PRM_STD) wSTRB;
         return 4'b1111;
      endmethod
      method Bool wVALID;
         return True;
      endmethod
      method Action wREADY (Bool ready);
         wready <= ready;
      endmethod
      method Bool bREADY;
         return True;
      endmethod
      method Action bRESP (AxiResp resp);
      endmethod
      method Action bVALID (Bool valid);
         bvalid <= valid;
      endmethod
   endinterface

endmodule
