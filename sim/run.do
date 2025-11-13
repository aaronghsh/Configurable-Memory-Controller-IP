vlib work
vlog +acc=rn ../rtl/mem_ctrl.sv ../tb/tb_mem_ctrl.sv
vsim -c tb_mem_ctrl -do "run -all; quit"
