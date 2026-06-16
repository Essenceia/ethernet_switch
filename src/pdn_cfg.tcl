# source librelane pdf config before applying custom sram power straps
source $::env(SCRIPTS_DIR)/openroad/common/pdn_cfg.tcl
source $::env(DESIGN_DIR)/pdn_3v3_sram.tcl
