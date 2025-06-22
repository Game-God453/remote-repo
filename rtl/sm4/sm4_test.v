
module  sm4_test
(
        input               sw1,
        input               sw2,
        input               clk_in,         // 系统时钟
        input               reset,          // 复位信号，低电平有效         
        input                  key_in,         // 低电平有效按键输入
        input                rx,
        output                tx,
        output                led,
        output[7:0]         o_seg,
        output[7:0]         o_sel

);
wire        done_v1;
wire        done_v2;
wire        clk;
wire        locked;
wire        rst_n;
assign      rst_n = ~reset;
wire                        key_press;
wire                           en;             // 使能信号
wire                           mode;           // 模式选择:1-加密 0-解密

wire       [127:0]             intext;         // 明文/密文输入
wire       [127:0]             key  ;          // 密钥输入
assign                         key    = 128'h0123456789abcdeffedcba9876543210;
wire         [127:0]             outtext;         // 明文/密文输出
wire                          done;           // 处理完成标志

wire                        no;
wire                         wr_clk;
assign wr_clk  =              clk ; 
wire        [127:0]            wrdata;
assign wrdata = outtext;
wire                         full;
    
wire                         rd_clk;
assign rd_clk  =              clk ; 
wire                         rd_en;
wire                         empty;
wire [127:0]                 rddata;
assign  intext =             rddata;

reg        [1:0]                 cnt;
reg                             flag_mode_sel;

always                          @(posedge    clk    or    negedge    rst_n)
                             if(~rst_n)
                                    flag_mode_sel<= 1'b0;
                             else  if(key_press)
                                    flag_mode_sel<= 1'b1;
                             else  if(no & (cnt==0) )
                                    flag_mode_sel  <= 1'b0;    

reg                             mode_sel;//0：加密，1解密

always                          @(posedge    clk    or    negedge    rst_n)
                             if(~rst_n)
                                    mode_sel  <=  1'b1;
                             else  if(flag_mode_sel  &  (cnt==0) )
                                    mode_sel  <=~mode_sel;
                                                                        
always                          @(posedge    clk    or    negedge    rst_n)
                             if(~rst_n)    
                                cnt  <=  2'd0;
                             else  case(cnt)
                                0:if(done_v2)cnt  <= cnt +  1'b1;
                                3:if(done)cnt  <=  2'd0;
                                default:cnt  <= cnt +  1'b1;
                             endcase
                             
assign                          rd_en  =  (cnt==0 && ~empty);
assign                          en     =  (cnt==2); 
assign                       mode   =   mode_sel;    
assign                         led    =   ~mode_sel;    

my_pll  my_pll_dut
(
  .clk_out1(clk),
  .reset(reset),
  .locked(locked),
  .clk_in1(clk_in)
);                        
                            
///////////////////////////////////////////////////////////////////////////////////////
key_debounce #(
   .CLK_FREQ(50_000_000),   // 50MHz时钟
   .DEBOUNCE_MS(20   )        // 默认消抖时间20ms
)
key_debounce_ins
(
    .clk(clk),
    .rst_n(rst_n),
    .key_in(~key_in),         // 低电平有效按键输入
    .key_press(key_press),  // 有效按下脉冲
    .key_hold()               // 持续按下状态
);

sm4_top   sm4_top_ins
(
    .clk(clk),                // 系统时钟
    .rst_n(rst_n),          // 复位信号，低电平有效
    .en(en),                 // 使能信号
    .mode(mode),               // 模式选择:1-加密 0-解密
    .intext(intext),          // 明文输入
    .key(key),                // 密钥输入
    .outtext(outtext),         // 密文输出
    .done(done)                // 处理完成标志
);

uart      uart_ins
(
    .clk_50mhz(clk),
    .rst_n(rst_n),
    .tx(tx),
    .rx(rx),
    
    .done(done),
    .done_v1(done_v2),
    
    .no(no),
    .wr_clk(wr_clk),
    .wrdata(wrdata),
    .full(full),
    
    .rd_clk(rd_clk),
    .rd_en(rd_en),
    .empty(empty),
    .rddata(rddata)
);    
    
seg7x16 seg7x16_ins
(
    .sw1(sw1),
    .sw2(sw2),
    .clk(clk),
    .rst(reset),
    .i_data(wrdata),
    .o_seg(o_seg),
    .o_sel(o_sel)
);        
endmodule