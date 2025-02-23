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
    -g mkTestbenchRng  \
    ./nm_bsv/test/TestbenchRng.bsv && \
bsc -e mkTestbenchRng -sim \
    -o testbenchrng \
    -simdir nm_bsv/build_bsim \
    -bdir nm_bsv/build_bsim \
    -info-dir nm_bsv/build_bsim \
    -p nm_bsv/src:%/Libraries && \
echo "" && ./testbenchrng
