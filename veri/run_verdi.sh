#!/bin/bash

# clean
rm -rf novas*

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Verdi start"
echo ""

# GUI debugging
verdi -2001 -f  list.f \
			-ssf TB.fsdb &

#
echo ""
echo "Verdi stop"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
