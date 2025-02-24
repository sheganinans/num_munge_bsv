bsc -u -sim -show-range-conflict \
    -simdir nm_bsv/build_bsim \
    -bdir nm_bsv/build_bsim \
    -info-dir nm_bsv/build_bsim \
    -opt-undetermined-vals \
    -remove-unused-modules \
    -aggressive-conditions \
    -show-schedule \
    -unspecified-to X \
    -p nm_bsv/src:%/Libraries \
    -g mkTestbenchSqrt  \
    ./nm_bsv/test/TestbenchSqrt.bsv && \
bsc -e mkTestbenchSqrt -sim \
    -o testbenchsqrt \
    -simdir nm_bsv/build_bsim \
    -bdir nm_bsv/build_bsim \
    -info-dir nm_bsv/build_bsim \
    -keep-fires \
    -p nm_bsv/src:%/Libraries && \
echo "" && ./testbenchsqrt
