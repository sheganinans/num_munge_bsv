bsc -u -verilog \
    -simdir build_bsim \
    -bdir build_bsim \
    -info-dir build_bsim \
    -elab -keep-fires -aggressive-conditions -no-warn-action-shadowing \
    -p ../bsc-contrib/Libraries/Bus:../bsc-contrib/Libraries/AMBA_TLM3/TLM3:../bsc-contrib/Libraries/AMBA_TLM3/Axi:../bsc-contrib/Libraries/AMBA_TLM3/Axi4:%/Libraries \
    ./src/Nm.bsv && \
mv src/nm.v ../num_munge.srcs/sources_1/new/nm.v && \
echo "done!"
