bsc -u -verilog \
    -simdir nm_bsv/build_bsim \
    -bdir nm_bsv/build_bsim \
    -info-dir nm_bsv/build_bsim \
    -opt-undetermined-vals \
    -remove-unused-modules \
    -aggressive-conditions \
    -show-schedule \
    -unspecified-to X \
    -p bsc-contrib/Libraries/Bus:bsc-contrib/Libraries/AMBA_TLM3/TLM3:bsc-contrib/Libraries/AMBA_TLM3/Axi:bsc-contrib/Libraries/AMBA_TLM3/Axi4:nm_bsv/src:%/Libraries \
    ./nm_bsv/src/SqrtPipeline.bsv