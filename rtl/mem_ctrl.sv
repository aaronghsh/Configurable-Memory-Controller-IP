// rtl/mem_ctrl.sv
`timescale 1ns/1ps
module mem_ctrl #(
  parameter int DATA_W    = 32,
  parameter int ADDR_W    = 32,
  parameter int MEM_WORDS = 2048,
  parameter int RD_LAT    = 2,
  parameter int WR_LAT    = 2,
  parameter logic [ADDR_W-1:0] BASE_ADDR = 'h0000_0000
)(
  input  logic                     clk,
  input  logic                     rst_n,
  input  logic                     ar_valid,
  output logic                     ar_ready,
  input  logic [ADDR_W-1:0]        ar_addr,
  input  logic [7:0]               ar_len,
  output logic                     r_valid,
  input  logic                     r_ready,
  output logic [DATA_W-1:0]        r_data,
  output logic                     r_last,
  output logic [1:0]               r_resp,
  input  logic                     aw_valid,
  output logic                     aw_ready,
  input  logic [ADDR_W-1:0]        aw_addr,
  input  logic [7:0]               aw_len,
  input  logic                     w_valid,
  output logic                     w_ready,
  input  logic [DATA_W-1:0]        w_data,
  input  logic                     w_last,
  output logic                     b_valid,
  input  logic                     b_ready,
  output logic [1:0]               b_resp
);
  logic [DATA_W-1:0] mem [0:MEM_WORDS-1];
  function automatic logic in_range(input logic [ADDR_W-1:0] a);
    logic [ADDR_W-1:0] end_addr;
    end_addr = BASE_ADDR + (MEM_WORDS * (DATA_W/8));
    return (a >= BASE_ADDR) && (a < end_addr);
  endfunction
  function automatic int addr2idx(input logic [ADDR_W-1:0] a);
    return int'((a - BASE_ADDR) >> $clog2(DATA_W/8));
  endfunction

  typedef enum logic [1:0] {R_IDLE,R_WAIT,R_BURST} rstate_e;
  rstate_e rstate;
  logic [ADDR_W-1:0] r_addr;
  logic [7:0]        r_beats;
  int                r_lat;
  assign ar_ready = (rstate==R_IDLE);
  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      rstate<=R_IDLE; r_valid<=0; r_last<=0; r_resp<=2'b00;
      r_addr<='0; r_beats<='0; r_lat<=0; r_data<='0;
    end else begin
      if (r_valid && r_ready) r_valid<=0;
      unique case(rstate)
        R_IDLE: if (ar_valid && ar_ready) begin
          if (!in_range(ar_addr)) begin
            r_resp<=2'b10; r_data<='0; r_last<=1; r_valid<=1;
          end else begin
            r_addr<=ar_addr; r_beats<=ar_len; r_lat<=RD_LAT; r_resp<=2'b00; r_last<=0; rstate<=R_WAIT;
          end
        end
        R_WAIT: if (r_lat>0) r_lat<=r_lat-1; else rstate<=R_BURST;
        R_BURST: if (!r_valid || (r_valid && r_ready)) begin
          int idx = addr2idx(r_addr);
          r_data <= (idx>=0 && idx<MEM_WORDS) ? mem[idx] : '0;
          r_resp <= (idx>=0 && idx<MEM_WORDS) ? 2'b00 : 2'b10;
          r_valid<=1; r_last <= (r_beats==0);
          r_addr <= r_addr + (DATA_W/8);
          if (r_beats!=0) r_beats<=r_beats-1; else rstate<=R_IDLE;
        end
      endcase
    end
  end

  typedef enum logic [1:0] {W_IDLE,W_COLLECT,W_WAIT,W_RESP} wstate_e;
  wstate_e wstate;
  logic [ADDR_W-1:0] w_addr;
  logic [7:0]        w_beats;
  int                w_lat;
  assign aw_ready = (wstate==W_IDLE);
  assign w_ready  = (wstate==W_COLLECT);
  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      wstate<=W_IDLE; w_addr<='0; w_beats<='0; w_lat<=0; b_valid<=0; b_resp<=2'b00;
    end else begin
      if (b_valid && b_ready) b_valid<=0;
      unique case(wstate)
        W_IDLE: if (aw_valid && aw_ready) begin
          if (!in_range(aw_addr)) begin
            b_resp<=2'b10; b_valid<=1; wstate<=W_RESP;
          end else begin
            w_addr<=aw_addr; w_beats<=aw_len; w_lat<=WR_LAT; wstate<=W_COLLECT;
          end
        end
        W_COLLECT: if (w_valid && w_ready) begin
          int idx = addr2idx(w_addr);
          if (idx>=0 && idx<MEM_WORDS) mem[idx] <= w_data;
          if (w_beats==0) wstate<=W_WAIT;
          else begin w_beats<=w_beats-1; w_addr<=w_addr + (DATA_W/8); end
        end
        W_WAIT: if (w_lat>0) w_lat<=w_lat-1; else begin b_resp<=2'b00; b_valid<=1; wstate<=W_RESP; end
        W_RESP: if (b_ready) wstate<=W_IDLE;
      endcase
    end
  end
endmodule
