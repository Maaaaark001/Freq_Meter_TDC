module frequency_meter (
    input wire sys_rstn,  // 系统复位
    input wire clk_ref,  // 参考时钟 10MHz
    input wire clk_meas,  // 待测时钟
    output reg [31:0] ref_out,
    output reg [31:0] meas_out,
    output reg start_ext,
    output reg stop_ext
);

  reg  [31:0] counter_ref;  // 参考时钟计数器
  reg  [31:0] counter_meas;  // 待测时钟计数器
  reg         gate;  // 闸门信号
  reg         gate_real;  // 真实闸门信号
  reg  [31:0] gate_counter;  // 闸门计数器
  reg  [ 3:0] state;  // 状态机状态
  reg  [ 3:0] state_count;
  wire        gate_edge;
  assign gate_edge = gate_real;

  // 闸门生成
  always @(posedge clk_ref) begin
    if (gate_counter <= 100_000) begin
      gate_counter <= gate_counter + 1;
      gate <= 1;  // 打开闸门
    end else if (gate_counter > 100_000 && gate_counter <= 150_000) begin
      gate_counter <= gate_counter + 1;
      gate <= 0;  // 关闭闸门
    end else begin
      gate_counter <= 0;
      gate <= 0;  // 关闭闸门
    end
  end

  // 根据待测信号产生真实闸门
  always @(posedge clk_meas) begin
    if (gate) begin
      gate_real <= 1;
    end else begin
      gate_real <= 0;
    end
  end

  // 在真实闸门打开的情况下，对待测时钟和参考时钟计数
  always @(posedge clk_meas) begin
    if (gate_real) begin
      counter_meas <= counter_meas + 1;
    end else begin
      counter_meas <= 0;
    end
  end
  always @(negedge gate_edge) begin
    meas_out <= counter_meas;
  end

  always @(posedge clk_ref) begin
    if (gate_real) begin
      counter_ref <= counter_ref + 1;
    end else begin
      counter_ref <= 0;
    end
  end
  always @(negedge gate_edge) begin
    ref_out <= counter_ref;
  end

  //状态变换
  always @(posedge clk_ref) begin
    //初始化状态
    if (sys_rstn == 0) begin
      state <= 0;
      state_count <= 0;
      start_ext <= 0;
      stop_ext <= 0;
      counter_ref <= 0;
      counter_meas <= 0;
    end
  end
  always @(posedge gate_edge) begin
    //real_gate上升沿开始计时，出start_ext脉冲
    if (state == 0) begin
      start_ext <= 1;
      stop_ext  <= 0;
      state <= 1;  //转移状态
    end
  end
  always @(posedge clk_ref) begin
    if (state == 1 && state_count < 4) begin
      state_count <= state_count + 1;
    end
    if (state == 1 && state_count == 4) begin
      state_count <= 0;
      state <= 2;
      start_ext <= 0;
      stop_ext <= 1;
    end
    if (state == 2 && state_count < 4) begin
      state_count <= state_count + 1;
    end
    if (state == 2 && state_count == 4) begin
      state_count <= 0;
      state <= 3;
      start_ext <= 0;
      stop_ext <= 0;
    end
  end
  always @(negedge gate_edge) begin
    //real_gate下降沿开始计时，出第二次start_ext脉冲
    if (state == 3) begin
      start_ext <= 1;
      stop_ext  <= 0;
      state <= 4;  //转移状态
    end
  end
  always @(posedge clk_ref) begin
    if (state == 4 && state_count < 4) begin
      state_count <= state_count + 1;
    end
    if (state == 4 && state_count == 4) begin
      state_count <= 0;
      state <= 5;
      start_ext <= 0;
      stop_ext <= 1;
    end
    if (state == 5 && state_count < 4) begin
      state_count <= state_count + 1;
    end
    if (state == 5 && state_count == 4) begin
      state_count <= 0;
      state <= 0;
      start_ext <= 0;
      stop_ext <= 0;
    end
  end
endmodule
