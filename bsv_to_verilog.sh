bsc -u -verilog \
    -simdir nm_bsv/build_bsim \
    -bdir nm_bsv/build_bsim \
    -info-dir nm_bsv/build_bsim \
    -elab -keep-fires -aggressive-conditions -no-warn-action-shadowing \
    -p ./bsc-contrib/Libraries/Bus:./bsc-contrib/Libraries/AMBA_TLM3/TLM3:./bsc-contrib/Libraries/AMBA_TLM3/Axi:./bsc-contrib/Libraries/AMBA_TLM3/Axi4:%/Libraries \
    ./nm_bsv/src/Nm.bsv && \
mv nm_bsv/src/nm.v ./num_munge.srcs/sources_1/new/nm.v && \
echo "done!"
