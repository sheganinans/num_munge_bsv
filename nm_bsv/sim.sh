bsc -u -sim -show-range-conflict \
    -simdir build_bsim \
    -bdir build_bsim \
    -info-dir build_bsim \
    -elab -keep-fires -aggressive-conditions -no-warn-action-shadowing \
    -p ./src:./bsc-contrib/Libraries/AMBA_TLM3/TLM3:%/Libraries \
    -g mkTestbench  \
    ./test/Testbench.bsv && \
bsc -e mkTestbench -sim \
    -o testbench \
    -simdir build_bsim \
    -bdir build_bsim \
    -info-dir build_bsim \
    -keep-fires \
    -p ./src:./bsc-contrib/Libraries/AMBA_TLM3/TLM3:%/Libraries && \
echo "" && ./testbench
