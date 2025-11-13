// tb/tb_mem_ctrl.sv
`timescale 1ns/1ps
module tb_mem_ctrl;
  localparam int DATA_W=32, ADDR_W=32;
  logic clk=0, rst_n=0;
  // AR/R
  logic ar_valid, ar_ready; logic [ADDR_W-1:0] ar_addr; logic [7:0] ar_len;
  logic r_valid, r_ready; logic [DATA_W-1:0] r_data; logic r_last; logic [1:0] r_resp;
  // AW/W/B
  logic aw_valid, aw_ready; logic [ADDR_W-1:0] aw_addr; logic [7:0] aw_len;
  logic w_valid, w_ready; logic [DATA_W-1:0] w_data; logic w_last;
  logic b_valid, b_ready; logic [1:0] b_resp;

  mem_ctrl #(.MEM_WORDS(2048),.RD_LAT(2),.WR_LAT(2)) dut (
    .clk,.rst_n,
    .ar_valid,.ar_ready,.ar_addr,.ar_len,
    .r_valid,.r_ready,.r_data,.r_last,.r_resp,
    .aw_valid,.aw_ready,.aw_addr,.aw_len,
    .w_valid,.w_ready,.w_data,.w_last,
    .b_valid,.b_ready,.b_resp
  );

  always #5 clk=~clk;
  int writes=0, reads=0, errors=0;

  task automatic write_burst(input int addr, input int beats, input int start_val);
    aw_valid<=1; aw_addr<=addr; aw_len<=beats-1; @(posedge clk); while(!aw_ready) @(posedge clk); aw_valid<=0;
    for (int i=0;i<beats;i++) begin
      w_valid<=1; w_data<=start_val+i; w_last<=(i==beats-1);
      @(posedge clk); while(!w_ready) @(posedge clk);
      $display("WRITE,ADDR=0x%08x,BEAT=%0d,DATA=0x%08x", addr, i+1, w_data);
      w_valid<=0; w_last<=0; writes++;
    end
    b_ready<=1; @(posedge clk); while(!b_valid) @(posedge clk);
    $display("WRITE_RESP,RESP=%0d", b_resp); b_ready<=0;
  endtask

  task automatic read_burst_check(input int addr, input int beats, input int expected_start);
    ar_valid<=1; ar_addr<=addr; ar_len<=beats-1; @(posedge clk); while(!ar_ready) @(posedge clk); ar_valid<=0;
    int beat=0; r_ready<=1;
    do begin
      @(posedge clk);
      if (r_valid) begin
        beat++;
        $display("READ,ADDR=0x%08x,BEAT=%0d,DATA=0x%08x,RESP=%0d,LAST=%0d", addr, beat, r_data, r_resp, r_last);
        if (r_resp==2'b00) begin
          int expected = expected_start + (beat-1);
          if (r_data !== expected) begin
            errors++; $display("CHECK_FAIL,ADDR=0x%08x,BEAT=%0d,EXP=0x%08x,GOT=0x%08x", addr, beat, expected, r_data);
          end
        end else begin
          errors++;
        end
        reads++;
      end
    end while (!(r_valid && r_last && r_ready));
    r_ready<=0;
  endtask

  initial begin
    ar_valid=0; aw_valid=0; w_valid=0; r_ready=0; b_ready=0;
    repeat(5) @(posedge clk); rst_n=1;

    write_burst('h0000_0100,4,100);
    read_burst_check('h0000_0100,4,100);

    write_burst('h0000_0200,8,200);
    read_burst_check('h0000_0200,8,200);

    // Out-of-range single-beat error test
    ar_valid<=1; ar_addr<='hFFFF_F000; ar_len<=0; @(posedge clk); while(!ar_ready) @(posedge clk); ar_valid<=0;
    r_ready<=1; @(posedge clk); do @(posedge clk); while(!(r_valid && r_ready)); $display("READ_OOR,RESP=%0d,LAST=%0d", r_resp, r_last); r_ready<=0;

    $display("SUMMARY,READS=%0d,WRITES=%0d,ERRORS=%0d", reads, writes, errors);
    $finish;
  end
endmodule
