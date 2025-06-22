`timescale 1ns / 1ps

module tb_sm4;

    // 定义信号
    reg clk;
    reg rst_n;
    reg en;
    reg mode;
    reg [127:0] intext;
    reg [127:0] key;
    wire [127:0] outtext;
    wire done;
    
    // 实例化被测模块
    sm4_top uut (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .mode(mode),
        .intext(intext),
        .key(key),
        .outtext(outtext),
        .done(done)
    );
    
    // 生成时钟信号
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns周期，即100MHz
    end
    reg [127:0]  file_mi_temp;
    // 测试序列
    initial begin
        // 初始化信号
        rst_n = 0;
        en = 0;
        mode = 1; // 默认为加密模式
        intext = 128'h0123456789ABCDEFFEDCBA9876543210;
        key    = 128'h0123456789ABCDEFFEDCBA9876543210;

        // 复位
        #20 rst_n = 1;
        #20;
        
        // 测试1：加密
        $display("Start encryption test...");		   //开始加密测试
        @(posedge clk);
        en = 1;
		  @(posedge clk);
        en = 0;
        @(posedge done);
		   file_mi_temp<=outtext;
        $display("Encryption completed!");				//加密完成
        $display("Plaintext: %h", intext);				//显示明文
        $display("Key: %h", key);							//显示密钥
        $display("Ciphertext: %h", outtext);				//显示密文
        
        // 验证加密结果
        if (outtext === 128'h681edf34d206965e86b3e94f536e4246) begin
            $display("Encryption test passed!");	//加密测试通过
        end else begin
            $display("Encryption test failure!");	//加密测试失败
        end
        
        // 测试2：解密
        $display("\nBegin decryption test...");	//开始解密测试
        mode = 0; // 切换到解密模式
        
        @(posedge clk);
		  intext = file_mi_temp; // 将之前的密文作为输入
        en = 1;
		  @(posedge clk);
        en = 0;
        @(posedge done); 
        $display("Decryption completed!");				//解密完成
        $display("Ciphertext: %h", intext );	//显示密文
        $display("Key: %h", key);				//显示密钥
        $display("Plaintext: %h", outtext);	//显示明文
        
        // 验证解密结果
        if (outtext === 128'h0123456789ABCDEFFEDCBA9876543210) begin
            $display("Decryption test passed!");	//解密测试通过
        end else begin
            $display("Decryption test failure!");	//解密测试失败
        end
        
        // 结束仿真
        #100 $stop;
    end
    
    // 自动检查
    reg [127:0] original_plaintext;
    
    always @(posedge done) begin
        if (mode == 1) begin
            // 加密完成后保存原始明文
            original_plaintext <= intext;
        end else begin
            // 解密完成后检查结果
            if (outtext !== original_plaintext) 
                $display("ERROR: Decrypted result does not match the original plaintext!");	//解密结果与原始明文不匹配
				 else 
					 $display("YES: Decrypted result  match the original plaintext!");	//解密结果与原始明文不匹配
            
        end
    end

endmodule    