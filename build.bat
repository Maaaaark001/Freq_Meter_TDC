echo "building..."
iverilog -g2012 -o sim.out tb_TDC.sv TDC.sv
echo "completed"
vvp sim.out
echo "open..."
gtkwave wave.vcd
