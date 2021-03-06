`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2021/07/06 09:05:17
// Design Name:
// Module Name: ID_EX
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


`include "define.v"

module ID_EX(
           input wire clk,
           input wire rst_n,
           input wire clear_i,
           input wire id_ex_w_i,

           /* reg files */
           input wire [31:0] A_i,
           input wire [31:0] B_i,
           output reg [31:0] A_o,
           output reg [31:0] B_o,


           /* rW select */
           input wire [4:0] rW_i,
           output reg [4:0] rW_o,

           /* imm extension */
           input wire [31:0] imm_ext_i,
           output reg [31:0] imm_ext_o,

           /* jump identifier */
           input wire [31:0] jal_i,
           output reg [31:0] jal_o,

           /* rs rt */
           input wire [4:0] rs_i,
           input wire [4:0] rt_i,
           output reg [4:0] rs_o,
           output reg [4:0] rt_o,

           /* control */
           // EX //
           input wire alu_src_i,
           input wire [3:0] alu_op_i,
           input wire isjump_i,

           output reg alu_src_o,
           output reg [3:0] alu_op_o,
           output reg isjump_o,

           // MEM //
           input wire [1:0] mode_i,
           input wire data_w_i,
           input wire data_r_i,
           input wire mem_reg_i,
           input wire is_jump_inst_i,

           output reg [1:0] mode_o,
           output reg data_w_o,
           output reg data_r_o,
           output reg mem_reg_o,
           output reg is_jump_inst_o,

           // WB //
           input wire reg_we_i,
           input wire jal_en_i,
           output reg reg_we_o,
           output reg jal_en_o
       );


always@(posedge clk or posedge rst_n)
begin
    if(rst_n == `rst_enable)
    begin
        /* reg files */
        A_o <= 0;
        B_o <= 0;

        /* rW select */
        rW_o <= 0;

        /* imm extension */
        imm_ext_o <= 0;

        /* jump identifier */
        jal_o <= 0;

        /* rs rt */
        rs_o <= 0;
        rt_o <= 0;

        /* control */
        // EX //
        alu_src_o <= `B_calculate;
        alu_op_o  <= `other_alu_op;
        isjump_o  <= `jump_disable;

        // MEM //
        mode_o      <= `byte_mode;
        data_w_o    <= `data_w_disable;
        data_r_o    <= `data_r_disable;
        mem_reg_o   <= `data_from_reg;
        is_jump_inst_o <= `is_not_jump_inst;

        // WB //
        reg_we_o <= `reg_write_disable;
        jal_en_o <= `jal_disable;
    end
    // ????????????
    else if(id_ex_w_i == `id_ex_write_enable && clear_i == `clear_disable)
    begin
        /* reg files */
        A_o <= A_i;
        B_o <= B_i;

        /* rW select */
        if(jal_en_i == `jal_disable)
        begin
            rW_o <= rW_i;
        end
        else
        begin
            rW_o <= 31; // jal?????????$31??????PC
        end
        /* imm extension */
        imm_ext_o <= imm_ext_i;

        /* jump identifier */
        jal_o <= jal_i;

        /* rs rt */
        rs_o <= rs_i;
        rt_o <= rt_i;

        /* control */
        // EX //
        alu_src_o <= alu_src_i;
        alu_op_o  <= alu_op_i;
        isjump_o  <= isjump_i;

        // MEM //
        mode_o      <= mode_i;
        data_w_o    <= data_w_i;
        data_r_o    <= data_r_i;
        mem_reg_o   <= mem_reg_i;
        is_jump_inst_o <= is_jump_inst_i;

        // WB //
        if(jal_en_i == `jal_disable)
        begin
            reg_we_o <= reg_we_i;
        end
        else
        begin
            reg_we_o <= jal_en_i;
        end
        jal_en_o <= jal_en_i;
    end
    // id_ex_w_i???????????????clear_i????????????
    // ?????? ?????????????????????????????????clear??????????????????????????????load??????????????????
    // ???????????????????????????clear????????????clear???????????????????????????
    // insert nop instruction
    else if(id_ex_w_i == `id_ex_write_enable && clear_i == `clear_enable)
    begin
        /* control */
        // EX //
        alu_src_o <= `B_calculate;
        alu_op_o  <= `other_alu_op;

        // MEM //
        mode_o      <= `byte_mode;
        data_w_o    <= `data_w_disable;
        data_r_o    <= `data_r_disable;
        mem_reg_o   <= `data_from_reg;
        // ????????????clear?????????????????????????????????
        // jump??????????????????????????????????????????
        is_jump_inst_o <= is_jump_inst_i; // NOTE!

        // clear?????????ID/EX?????????nop???????????????load_jump??????????????????????????????
        // ??????????????????isjump_i???????????????????????????????????????????????????????????????clear???
        // isjump_o <= isjump_i; // clear???????????????????????????????????????????????????

        // WB //
        reg_we_o <= `reg_write_disable;
        jal_en_o <= `jal_disable;
    end
    else
    begin
        ;
    end
end

endmodule
