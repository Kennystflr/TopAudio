# ###################################################################################
#
# In this example Reveal Controller's Hard IP feature is used to write to specific
# registers in the design's PLL to tweak some of its settings. 
#
# Executing the first 3 TCL commands will put the PLL to sleep. Once the PLL is 
# asleep you can verify the registers were correctly written to, by testing the
# design on device, or by reading back the register values that were written to. 
#
# Executing the last 3 TCL commands will wake up the PLL so it is running again,
# and so the design is functional. You can confirm the design's functionality using
# Reveal Analyzer, by testing on device, or by reading back from the registers that
# were written to.
#
# ###################################################################################



# ############################### TURNING THE PLL OFF ###############################

# ########## Write to PLL shadow register, so we can tweak other settings ###########
rva_write_controller -addr 0x10000000 -data 0x0

# Write to PLL sleep register
rva_write_controller -addr 0x10000003 -data 0x0

# Set shadow register to 0, PLL should still be asleep
rva_write_controller -addr 0x10000000 -data 0x1

# ###################################################################################



# ############################### TURNING THE PLL ON ################################

# ########## Write to PLL shadow register, so we can tweak other settings ###########
rva_write_controller -addr 0x10000000 -data 0x0

# Write to PLL sleep register
rva_write_controller -addr 0x10000003 -data 0x8

# Set shadow register to 0, PLL should still be asleep
rva_write_controller -addr 0x10000000 -data 0x1

# ###################################################################################
