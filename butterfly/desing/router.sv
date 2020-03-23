`timescale 1ns/1ps
// simple four-input four output router with dropping flow control

module router
  (
   output reg [17:0]  o_outputs [0:3], // output phits
   input logic [17:0] i_inputs [0:3], // input phits
   input wire         i_rst, // chip reset
   input wire         i_clk // chip clock
   );

   localparam PORT_0 = 2'b00;
   localparam PORT_1 = 2'b01;
   localparam PORT_2 = 2'b10;
   localparam PORT_3 = 2'b11;


   reg [17:0]          register [0:3]; // r0,r1,r2,r3; // outputs of input registers
   // reg [17:0]          outputs [0:3]; // output registers

   logic [17:0]        shifter [0:3]; // s0,s1,s2,s3; // output of shifters

   logic [17:0]        muxs [0:3]; // m0,m1,m2,m3; // output of multiplexers

   wire [3:0]          selector [0:3]; // sel0, sel1, sel2, sel3; // multiplexer
                                       // control

   wire                shift_sig [0:3]; // shift0, shift1, shift2, shift3; //
                                        // shifter sel

   allocator inst_a0
     (
      .o_select    (selector[0]),
      .o_shift     (shift_sig[0]),

      .i_this_port (PORT_0), // identifies this output port
      .i_r0        (register[0][17:14]), // top four bits of each input phit
      .i_r1        (register[1][17:14]), // directs shifter to discard upper two bits
      .i_r2        (register[2][17:14]),
      .i_r3        (register[3][17:14]),
      .i_rst       (i_rst),
      .i_clk       (i_clk) // chip clock
      );

   allocator inst_a1
     (
      .o_select    (selector[1]),
      .o_shift     (shift_sig[1]),

      .i_this_port (PORT_1), // identifies this output port
      .i_r0        (register[0][17:14]), // top four bits of each input phit
      .i_r1        (register[1][17:14]), // directs shifter to discard upper two bits
      .i_r2        (register[2][17:14]),
      .i_r3        (register[3][17:14]),
      .i_rst       (i_rst),
      .i_clk       (i_clk) // chip clock
      );

   allocator inst_a2
     (
      .o_select    (selector[2]),
      .o_shift     (shift_sig[2]),

      .i_this_port (PORT_2), // identifies this output port
      .i_r0        (register[0][17:14]), // top four bits of each input phit
      .i_r1        (register[1][17:14]), // directs shifter to discard upper two bits
      .i_r2        (register[2][17:14]),
      .i_r3        (register[3][17:14]),
      .i_rst       (i_rst),
      .i_clk       (i_clk) // chip clock
      );

   allocator inst_a3
     (
      .o_select    (selector[3]),
      .o_shift     (shift_sig[3]),

      .i_this_port (PORT_3), // identifies this output port
      .i_r0        (register[0][17:14]), // top four bits of each input phit
      .i_r1        (register[1][17:14]), // directs shifter to discard upper two bits
      .i_r2        (register[2][17:14]),
      .i_r3        (register[3][17:14]),
      .i_rst       (i_rst),
      .i_clk       (i_clk) // chip clock
      );

   // multiplexers

   always_comb begin
      case(selector[0])
        4'b0001: muxs[0] = register[0];
        4'b0010: muxs[0] = register[1];
        4'b0100: muxs[0] = register[2];
        4'b1000: muxs[0] = register[3];
        default: muxs[0] = 0;
      endcase // case (selector[0])
      case(selector[1])
        4'b0001: muxs[1] = register[0];
        4'b0010: muxs[1] = register[1];
        4'b0100: muxs[1] = register[2];
        4'b1000: muxs[1] = register[3];
        default: muxs[1] = 0;
      endcase // case (selector[1])
      case(selector[2])
        4'b0001: muxs[2] = register[0];
        4'b0010: muxs[2] = register[1];
        4'b0100: muxs[2] = register[2];
        4'b1000: muxs[2] = register[3];
        default: muxs[2] = 0;
      endcase // case (selector[2])
      case(selector[3])
        4'b0001: muxs[3] = register[0];
        4'b0010: muxs[3] = register[1];
        4'b0100: muxs[3] = register[2];
        4'b1000: muxs[3] = register[3];
        default: muxs[3] = 0;
      endcase // case (selector[3])
   end // always_comb

   // shifters
   always_comb begin
      if(shift_sig[0])
        shifter[0] = {muxs[0][17:16], muxs[0][15:10] << 2, muxs[0][9:0]};
      else
        shifter[0] = muxs[0];

      if(shift_sig[1])
        shifter[1] = {muxs[1][17:16], muxs[1][15:10] << 2, muxs[1][9:0]};
      else
        shifter[1] = muxs[1];

      if(shift_sig[2])
        shifter[2] = {muxs[2][17:16], muxs[2][15:10] << 2, muxs[2][9:0]};
      else
        shifter[2] = muxs[2];

      if(shift_sig[3])
        shifter[3] = {muxs[3][17:16], muxs[3][15:10] << 2, muxs[3][9:0]};
      else
        shifter[3] = muxs[3];
   end // always_comb

   // assign shifter[3] = (shift_sig[3])?
   //                     {muxs[3][17:16], muxs[3][13:10], 2'b00, muxs[3][9:0]}:
   //                     muxs[3];

   integer             index;

   always_ff @(posedge i_clk) begin
     if(i_rst) begin //reset valores de imagen y kernel
        for(index=0; index < 4; index = index + 1) begin
           register[index]  <= {18{1'b0}};
           o_outputs[index] <= {18{1'b0}};
        end
     end
     else begin
        for(index=0; index < 4; index = index + 1) begin
           register[index]  <= i_inputs[index];
           o_outputs[index] <= shifter[index];
        end
     end // else: !if(i_rst)
   end // always_ff @ (posedge i_clk)

endmodule // router

