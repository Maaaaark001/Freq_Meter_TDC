`timescale 1ns / 1ns

module tb_frequency_meter;

    // 输入
    reg clk_ref;    // 参考时钟 10MHz
    reg clk_meas;    // 待测时钟 1MHz
    reg sys_rstn;   // 系统复位信号，低电平有效

    // 输出
    wire [31:0] ref_out;
    wire [31:0] meas_out;
    wire start_ext;
    wire stop_ext;

    // 实例化被测试模块
    frequency_meter uut (
        .sys_rstn(sys_rstn),
        .clk_ref(clk_ref),
        .clk_meas(clk_meas),
        .ref_out(ref_out),
        .meas_out(meas_out),
        .start_ext(start_ext),
        .stop_ext(stop_ext)
    );

    // 生成参考时钟 10MHz
    initial begin
        clk_ref = 0;
        forever #50 clk_ref = ~clk_ref; // 10MHz 时钟周期为 100ns
    end
    // 生成系统复位信号，低电平有效
    initial begin
        sys_rstn = 0;
        #100 sys_rstn = 1;
    end
    // 生成待测时钟 1MHz
    initial begin
        clk_meas = 0;
        #25;
        forever #500 clk_meas = ~clk_meas; // 1MHz 时钟周期为 1000ns
    end

    // 测试过程
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_frequency_meter );
    #61_000_000 $finish;
    end

endmodule

