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
    -g mkTestbenchMCMC  \
    ./nm_bsv/test/TestbenchMCMC.bsv && \
bsc -e mkTestbenchMCMC -sim \
    -o testbenchmcmc \
    -simdir nm_bsv/build_bsim \
    -bdir nm_bsv/build_bsim \
    -info-dir nm_bsv/build_bsim \
    -keep-fires \
    -p nm_bsv/src:%/Libraries && \
echo "" && ./testbenchmcmc
