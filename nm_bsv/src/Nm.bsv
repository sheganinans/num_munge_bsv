import Axi4LDefines::*;

import DmaController::*;

`include "TLM.defines"

(* synthesize, always_enabled *)
module nm (Axi4LRdWrMaster#(`TLM_PRM_STD));
   Axi4LRdWrMaster#(`TLM_PRM_STD) dma <- mkDmaController;
   interface write = dma.write;
   interface read = dma.read;
endmodule
