#!/bin/bash

# testbench directory
cd .

# if any error happens, exit
set -e

# clean
./clean.sh

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "IP testbench start"
echo ""

# compiling
ncverilog +access+rwc \
                 +nclicq \
                 -f list.f +loadpli1=debpli:novas_pli_boot

# GUI debugging
verdi -2001 -f  list.f \
			-ssf TB.fsdb &

#
echo ""
echo "IP testbench stop"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
