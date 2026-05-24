/*
Copyright (c) 2026 Julia Desmazes 

This code was written by a human, authorization is explicitly not 
granted to use it to train any model. 
*/

/* verilator lint_off VARHIDDEN */

/* Shared project ethernet values definitions */

// physical interface
localparam PHY_W = 2; 

localparam MAC_W        = 48;
localparam ADDR_CNT_VAL = (MAC_W / (8/PHY_W)) - 1;
localparam ADDR_CNT_W   = $clog2(ADDR_CNT_VAL); 
/* verilator lint_off WIDTHTRUNC */
localparam [ADDR_CNT_W-1:0] ADDR_CNT = ADDR_CNT_VAL;
/* verilator lint_on WIDTHTRUNC */


localparam SFD_W = 8; 
localparam [SFD_W-1:0] SFD = 8'b10101011; 

localparam FRAME_TYPE_W       = 16;
localparam FRAME_TYPE_CNT_VAL = (FRAME_TYPE_W / (8/PHY_W)) - 1;
localparam FRAME_TYPE_CNT_W   = $clog2(FRAME_TYPE_CNT_VAL);
/* verilator lint_off WIDTHTRUNC */
localparam [FRAME_TYPE_CNT_W-1:0] FRAME_TYPE_CNT = FRAME_TYPE_CNT_VAL;
/* verilator lint_on WIDTHTRUNC */

localparam [FRAME_TYPE_W-1:0] TYPE_VLAN = 16'h8100;
localparam VID_W = 12;

// FCS 
localparam FCS_W = 32; 

localparam DELAY_DEPTH = FCS_W / (8/PHY_W);

/* verilator lint_on VARHIDDEN */

