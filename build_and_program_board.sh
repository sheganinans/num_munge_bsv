echo "bsv to verilog" && \
./bsv_to_verilog.sh && \
cp nm_bsv/src/nm.v ./num_munge.srcs/sources_1/new/nm.v && \
echo "building, see ./build.log." && \
vivado -mode batch -source build_project.tcl 1> build.log && \
echo "programming, see ./program.log." && \
vivado -mode batch -source program_board.tcl 1> program.log && \
echo "done programming."; echo "-------" && \
echo "rescanning pci bus." && \
./rescan.sh