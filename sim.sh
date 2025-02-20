bsc -u -sim -show-range-conflict \
    -simdir nm_bsv/build_bsim \
    -bdir nm_bsv/build_bsim \
    -info-dir nm_bsv/build_bsim \
    -elab -keep-fires -aggressive-conditions -no-warn-action-shadowing \
    -p bsc-contrib/Libraries/Bus:bsc-contrib/Libraries/AMBA_TLM3/TLM3:bsc-contrib/Libraries/AMBA_TLM3/Axi:bsc-contrib/Libraries/AMBA_TLM3/Axi4:nm_bsv/src:%/Libraries \
    -g mkTestbench  \
    ./nm_bsv/test/Testbench.bsv && \
bsc -e mkTestbench -sim \
    -o testbench \
    -simdir nm_bsv/build_bsim \
    -bdir nm_bsv/build_bsim \
    -info-dir nm_bsv/build_bsim \
    -keep-fires \
    -p bsc-contrib/Libraries/Bus:bsc-contrib/Libraries/AMBA_TLM3/TLM3:bsc-contrib/Libraries/AMBA_TLM3/Axi:bsc-contrib/Libraries/AMBA_TLM3/Axi4:nm_bsv/src:%/Libraries && \
echo "" && ./testbench
