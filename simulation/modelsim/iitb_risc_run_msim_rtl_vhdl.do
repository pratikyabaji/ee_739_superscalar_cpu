transcript on
if ![file isdirectory vhdl_libs] {
	file mkdir vhdl_libs
}

vlib vhdl_libs/altera
vmap altera ./vhdl_libs/altera
vcom -93 -work altera {/home/pratikyabaji/intelFPGA_lite/22.1std/quartus/eda/sim_lib/altera_syn_attributes.vhd}
vcom -93 -work altera {/home/pratikyabaji/intelFPGA_lite/22.1std/quartus/eda/sim_lib/altera_standard_functions.vhd}
vcom -93 -work altera {/home/pratikyabaji/intelFPGA_lite/22.1std/quartus/eda/sim_lib/alt_dspbuilder_package.vhd}
vcom -93 -work altera {/home/pratikyabaji/intelFPGA_lite/22.1std/quartus/eda/sim_lib/altera_europa_support_lib.vhd}
vcom -93 -work altera {/home/pratikyabaji/intelFPGA_lite/22.1std/quartus/eda/sim_lib/altera_primitives_components.vhd}
vcom -93 -work altera {/home/pratikyabaji/intelFPGA_lite/22.1std/quartus/eda/sim_lib/altera_primitives.vhd}

vlib vhdl_libs/lpm
vmap lpm ./vhdl_libs/lpm
vcom -93 -work lpm {/home/pratikyabaji/intelFPGA_lite/22.1std/quartus/eda/sim_lib/220pack.vhd}
vcom -93 -work lpm {/home/pratikyabaji/intelFPGA_lite/22.1std/quartus/eda/sim_lib/220model.vhd}

vlib vhdl_libs/sgate
vmap sgate ./vhdl_libs/sgate
vcom -93 -work sgate {/home/pratikyabaji/intelFPGA_lite/22.1std/quartus/eda/sim_lib/sgate_pack.vhd}
vcom -93 -work sgate {/home/pratikyabaji/intelFPGA_lite/22.1std/quartus/eda/sim_lib/sgate.vhd}

vlib vhdl_libs/altera_mf
vmap altera_mf ./vhdl_libs/altera_mf
vcom -93 -work altera_mf {/home/pratikyabaji/intelFPGA_lite/22.1std/quartus/eda/sim_lib/altera_mf_components.vhd}
vcom -93 -work altera_mf {/home/pratikyabaji/intelFPGA_lite/22.1std/quartus/eda/sim_lib/altera_mf.vhd}

vlib vhdl_libs/altera_lnsim
vmap altera_lnsim ./vhdl_libs/altera_lnsim
vlog -sv -work altera_lnsim {/home/pratikyabaji/intelFPGA_lite/22.1std/quartus/eda/sim_lib/mentor/altera_lnsim_for_vhdl.sv}
vcom -93 -work altera_lnsim {/home/pratikyabaji/intelFPGA_lite/22.1std/quartus/eda/sim_lib/altera_lnsim_components.vhd}

vlib vhdl_libs/fiftyfivenm
vmap fiftyfivenm ./vhdl_libs/fiftyfivenm
vlog -vlog01compat -work fiftyfivenm {/home/pratikyabaji/intelFPGA_lite/22.1std/quartus/eda/sim_lib/mentor/fiftyfivenm_atoms_ncrypt.v}
vcom -93 -work fiftyfivenm {/home/pratikyabaji/intelFPGA_lite/22.1std/quartus/eda/sim_lib/fiftyfivenm_atoms.vhd}
vcom -93 -work fiftyfivenm {/home/pratikyabaji/intelFPGA_lite/22.1std/quartus/eda/sim_lib/fiftyfivenm_components.vhd}

if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {/home/pratikyabaji/Desktop/iitb_risc/iitb_risc_lib.vhd}
vcom -93 -work work {/home/pratikyabaji/Desktop/iitb_risc/components/arith_logic_pipeline/alu.vhd}
vcom -93 -work work {/home/pratikyabaji/Desktop/iitb_risc/components/bit16_adder.vhd}
vcom -93 -work work {/home/pratikyabaji/Desktop/iitb_risc/components/reservation_station.vhd}
vcom -93 -work work {/home/pratikyabaji/Desktop/iitb_risc/components/reorder_buffer.vhd}
vcom -93 -work work {/home/pratikyabaji/Desktop/iitb_risc/components/register_file.vhd}
vcom -93 -work work {/home/pratikyabaji/Desktop/iitb_risc/components/load_store_pipeline.vhd}
vcom -93 -work work {/home/pratikyabaji/Desktop/iitb_risc/components/ir_memory.vhd}
vcom -93 -work work {/home/pratikyabaji/Desktop/iitb_risc/components/ir_fetch_buffer.vhd}
vcom -93 -work work {/home/pratikyabaji/Desktop/iitb_risc/components/ir_decoder_buffer.vhd}
vcom -93 -work work {/home/pratikyabaji/Desktop/iitb_risc/components/ir_decoder.vhd}
vcom -93 -work work {/home/pratikyabaji/Desktop/iitb_risc/components/data_memory.vhd}
vcom -93 -work work {/home/pratikyabaji/Desktop/iitb_risc/components/arith_logic_pipeline.vhd}
vcom -93 -work work {/home/pratikyabaji/Desktop/iitb_risc/iitb_risc.vhd}

vcom -93 -work work {/home/pratikyabaji/Desktop/iitb_risc/iitb_risc_tb.vhd}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L fiftyfivenm -L rtl_work -L work -voptargs="+acc"  iitb_risc_tb

add wave *
view structure
view signals
run -all
