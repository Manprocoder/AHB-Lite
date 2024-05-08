#!/bin/bash

# testbench directory
cd .

# if any error happens, exit
set -e

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Testbench start"
echo ""

# clean
#rm -rf simv* csrc* *.log novas.*
#rm -rf *fsdb VeriLog INCA_Libs ncverilog*

# compiling
ncverilog +access+rwc \
                 +nclicq \
                 -f list.f

# GUI debugging
#Verdi -f list.f

#
echo ""
echo "Testbench stop"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
