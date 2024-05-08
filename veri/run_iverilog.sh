#!/bin/bash

# testbench directory
cd .

# if any error, exit
set -e

# clean
#rm -rf simv* crsc* *.log novas* VeriLog
#rm -rf *fsdb VeriLog INCA_Libs ncveriLog*
# rm -rf *vvp
# rm -rf *vcd
./clean.sh

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "IP testbench start"
echo ""

# compiling by ncverilog
#ncverilog +access+rwc \
#                 +nclicq \
#                 -f list.f

#GUI debugging by Verdi
#Verdi -f list.f

# compiling by iverilog
iverilog -o TB.vvp TB.v
# Running simulation, needed for iverilog
vvp TB.vvp > run_log.txt 2>&1

#GUI debugging by gtwave
gtkwave TB.vcd

#
echo ""
echo "IP testbench stop"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
