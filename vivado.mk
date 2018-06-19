vivado_exec = /home/recolic/extraDisk/xilinx/Vivado/2018.1/bin/vivado

_tmp := $(shell mktemp)

build: clean
	./gen_tcl.sh build $(xpr_path) synth_1 impl_1 write_bitstream $(top_module) 4 > $(_tmp)
	$(vivado_exec) -mode batch -source $(_tmp)
	rm -f $(_tmp)

burn: clean
	./gen_tcl.sh burn $(xpr_path) impl_1 $(top_module) > $(_tmp)
	$(vivado_exec) -mode batch -source $(_tmp)
	rm -f $(_tmp)

gui: clean
	./gen_tcl.sh gui $(xpr_path) > $(_tmp)
	$(vivado_exec) -mode batch -source $(_tmp)
	rm -f $(_tmp)

clean:
	rm -f *.jou *.log *.str
