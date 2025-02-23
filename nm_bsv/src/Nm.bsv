import AxiDefines::*;
import Axi4LDefines::*;
import Axi4LMaster::*;
import TLM3::*;

`include "TLM.defines"

typedef enum { DONE, WRITE } State deriving (Bits, Eq);

(* synthesize, always_enabled *)
module nm (Axi4LRdWrMaster#(`TLM_PRM_STD));
   Reg#(State) state <- mkReg(DONE);
   Reg#(Bool) awready <- mkReg(False);
   Reg#(Bool) wready <- mkReg(False);
   Reg#(Bool) bvalid <- mkReg(False);

   rule update_state;
      if (state == DONE)
         state <= WRITE;
      else if (state == WRITE && awready && wready && bvalid)
         state <= WRITE;
   endrule

   let prot = AxiProt { access: DATA, security: SECURE, privilege: NORMAL };

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
         return 0;
      endmethod
      method AxiProt awPROT;
         return prot;
      endmethod
      method Bool awVALID;
         return state == DONE || !awready;
      endmethod
      method Action awREADY (Bool ready);
         awready <= ready;
      endmethod
      method AxiData#(`TLM_PRM_STD) wDATA;
         return 32'hDEADBEEF;
      endmethod
      method AxiByteEn#(`TLM_PRM_STD) wSTRB;
         return 4'b1111;
      endmethod
      method Bool wVALID;
         return state == DONE || !wready;
      endmethod
      method Action wREADY (Bool ready);
         wready <= ready;
      endmethod
      method Bool bREADY;
         return state == WRITE && !bvalid;
      endmethod
      method Action bRESP (AxiResp resp);
      endmethod
      method Action bVALID (Bool valid);
         bvalid <= valid;
      endmethod
   endinterface

endmodule
