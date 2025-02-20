bsc -u -sim -show-range-conflict \
    -simdir nm_bsv/build_bsim \
    -bdir nm_bsv/build_bsim \
    -info-dir nm_bsv/build_bsim \
    -elab -keep-fires -aggressive-conditions -no-warn-action-shadowing \
    -p ./nm_bsv/src:./bsc-contrib/Libraries/AMBA_TLM3/TLM3:%/Libraries \
    -g mkTestbench  \
    ./nm_bsv/test/Testbench.bsv && \
bsc -e mkTestbench -sim \
    -o testbench \
    -simdir nm_bsv/build_bsim \
    -bdir nm_bsv/build_bsim \
    -info-dir nm_bsv/build_bsim \
    -keep-fires \
    -p ./nm_bsv/src:./bsc-contrib/Libraries/AMBA_TLM3/TLM3:%/Libraries && \
echo "" && ./testbench
