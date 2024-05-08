#!/bin/bash
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "to clean project"
echo ""

rm -rf *.log INCA_libs VerdiLog novas* ncverilog* 
rm -rf *vvp *vcd *fsdb
rm -rf INCA*
rm -rf nc*
rm -rf no*
rm -rf .no*
rm -rf verdi*
rm -rf Verdi*
#rm -rf dump
#rm -rf list
rm -rf log
rm -rf output
rm -rf *.key
rm -rf *.args
rm -rf cds.lib
rm -rf hdl.var
rm -rf RUN_NC
#rm -rf tb_*.v
#rm -rf cov_work
rm -rf DAVINCI_*
rm -rf iccr.log
rm -rf summary.rpt
rm -rf *_merge_result
#rm -rf *.hex
rm -rf *.txt
rm -rf *.mif

#
echo ""
echo "clean stop"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"