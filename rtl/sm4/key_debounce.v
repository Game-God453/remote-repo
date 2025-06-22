module key_debounce #(
    parameter CLK_FREQ   = 50_000_000,  // 50MHz主时钟
    parameter DEBOUNCE_MS = 20          // 默认消抖时间20ms
)(
    input  clk,
    input  rst_n,
    input  key_in,     // 低电平有效按键输入
    output key_press,  // 有效按下脉冲
    output key_hold    // 持续按下状态
);

	// 消抖周期计算
	localparam CYCLE_CNT = ((CLK_FREQ * DEBOUNCE_MS + 999)/1000);  // 四舍五入处理

	// 状态机定义(增加抖动过滤)
	reg [2:0] state;

	localparam S_IDLE = 3'h0; 
	localparam S_PRE_DOWN = 3'h1;
	localparam S_STABLE = 3'h2;
	localparam S_PRE_UP = 3'h3;
	localparam S_POST_UP = 3'h4;

	// 同步与滤波处理
	reg [2:0] sync_chain;  // 三级同步链
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) sync_chain <= 3'b111;
		else       sync_chain <= {sync_chain[1:0], key_in};
	end

	// 状态机核心逻辑
	reg [31:0] cnt;
	reg        key_reg;

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			state    <= S_IDLE;
			cnt      <= 0;
			key_reg  <= 0;
		end else begin
			case(state)
				S_IDLE: begin
					key_reg <= 0;
					if(sync_chain[2] == 0) begin
						state <= S_PRE_DOWN;
						cnt   <= CYCLE_CNT;  // 启动消抖倒计时[4](@ref)
					end
					end
				
				S_PRE_DOWN: begin
					if(sync_chain[2]) begin  // 抖动期间检测到释放
						state <= S_IDLE;
					end else if(cnt == 0) begin
						state <= S_STABLE;
						key_reg <= 1;        // 确认有效按下
					end else begin
						cnt <= cnt - 1;
					end
					end
				
				S_STABLE: begin
					if(sync_chain[2]) begin  // 检测到释放信号
						state <= S_PRE_UP;
						cnt   <= CYCLE_CNT;  // 释放消抖计时
					end
				
					end
				S_PRE_UP: begin
					if(!sync_chain[2]) begin // 抖动期间再次按下
						state <= S_STABLE;
					end else if(cnt == 0) begin
						state <= S_POST_UP;
					end else begin
						cnt <= cnt - 1;
					end
					end
				
				S_POST_UP: begin
					key_reg <= 0;
					state   <= S_IDLE;
				end
			endcase
		end
	end

	// 边沿检测逻辑
	reg key_reg_dly;
	
	always @(posedge clk) key_reg_dly <= key_reg;
	assign key_press = key_reg & ~key_reg_dly;  // 上升沿检测
	assign key_hold  = key_reg;

endmodule