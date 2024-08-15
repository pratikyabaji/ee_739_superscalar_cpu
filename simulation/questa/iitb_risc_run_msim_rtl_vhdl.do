transcript on
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
vcom -93 -work work {/home/pratikyabaji/Desktop/iitb_risc/components/arith_logic_pipeline.vhd}
vcom -93 -work work {/home/pratikyabaji/Desktop/iitb_risc/iitb_risc.vhd}

