echo "building, see ./build.log." && \
vivado -mode batch -source build_project.tcl 1> build.log && \
echo "programming, see ./program.log." && \
vivado -mode batch -source program_board.tcl 1> program.log && \
echo "done programming."; echo "-------" && \
echo "rescanning pci bus." && \
./rescan.sh