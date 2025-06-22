`timescale 1ns / 1ps

module sm4_top(
    input               clk,            // 系统时钟
    input               rst_n,          // 复位信号，低电平有效
    input               en,             // 使能信号
    input               mode,           // 模式选择:1-加密 0-解密
    input       [127:0] intext,      	// 明文输入
    input       [127:0] key,            // 密钥输入
    output reg  [127:0] outtext,     	// 密文输出
    output reg          done            // 处理完成标志
);

    // 内部信号定义
    wire 				key_exp_done;
	reg  				key_exp_en;
    wire 				encrypt_done;
	reg  				encrypt_en;
	reg  				mod_in;
    reg  		[4:0] 	state;
	 
	reg  		[127:0]	indatga ;
	wire  		[127:0] outdata;
	 
    //状态机状态变量定义
    localparam  IDLE        = 5'd0,
                KEY_EXP     = 5'd1,
                ENCRYPT     = 5'd2,
                OVER        = 5'd3;
    
    // 主状态机
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            key_exp_en <= 1'b0;
            encrypt_en <= 1'b0;
				mod_in    <= 1'b1;
            done <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 1'b0;
                    if (en) begin
                        state <= KEY_EXP;
                        key_exp_en <= 1'b1;
                    end
                end
                
                KEY_EXP: begin
                    key_exp_en <= 1'b0;
                    if (key_exp_done) begin
                        if (mode) begin  // 加密模式
							mod_in<= 1'b1;
                            state <= ENCRYPT;
                            encrypt_en <= 1'b1;
							indatga<=intext;
                        end else begin   // 解密模式
							mod_in<=1'b0;
							encrypt_en <= 1'b1;
                            state <= ENCRYPT;
							indatga<=intext;
                        end
                    end
                end

                
                ENCRYPT: begin
                    encrypt_en <= 1'b0;
                    if (encrypt_done) begin
						outtext<= outdata;
                        state <= OVER;
                    end
                end           
                
                OVER: begin
                    done <= 1'b1;
                    state <= IDLE;
                end
                
                default: state <= IDLE;
            endcase
        end
    end
	 
	 
	 //读取32轮轮密钥		
	 wire   [31:0]	 		rddata ;
	 wire	 				rd_clk;
	 wire[4:0]		 		rdaddr;
	 //保存32轮轮密钥
	 wire [31:0]	 		wrdata ;
	 wire	 				wr_clk;
	 wire					wr_en;
	 wire[4:0]				wraddr;
	 
	dram dram_inst(
		.clka (wr_clk),
		.ena  (wr_en),
		.wea  (1'b1),
		.addra(wraddr),
		.dina (wrdata),
		.clkb (rd_clk),
		.addrb(rdaddr),
		.doutb(rddata)
	);

	// 密钥扩展模块实例
	sm4_key_expansion key_exp(
		.clk(clk),
		.rst_n(rst_n),
		.en(key_exp_en),
		.key(key),
		.done(key_exp_done),
		 //保存32轮轮密钥
		.wrdata(wrdata) ,
		.wr_clk(wr_clk),
		.wr_en(wr_en),
		.wraddr(wraddr)
	 );
	 
	// 加密模块实例,解密模块实例
	sm4_encrypt encrypt(
		.clk(clk),
		.rst_n(rst_n),
		.en(encrypt_en),
		.mode(mod_in),
		.indatga(indatga),
		.outdata(outdata),
		.done(encrypt_done),
		.rddata(rddata) ,
		.rd_clk(rd_clk),
		.rdaddr(rdaddr)
	);

endmodule    