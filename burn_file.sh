#!/bin/bash
_tmp=`mktemp`
vivado_exec="/home/recolic/extraDisk/xilinx/Vivado/2018.1/bin/vivado"
`dirname $0`/gen_tcl.sh burn-file $1 > $_tmp
$vivado_exec -mode batch -source $_tmp
rm -f $_tmp
