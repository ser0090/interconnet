`timescale 1ns/1ps

module tb_allocator();

   wire [3:0] o_select;
   wire       o_shift;

   reg [1:0]  i_this_port; // identifies this output port
   reg [3:0]  i_r0; // top four bits of each input phit
   reg [3:0]  i_r1; // directs shifter to discard upper two bits
   reg [3:0]  i_r2;
   reg [3:0]  i_r3;
   reg        i_rst;
   reg        i_clk; // chip clock

   initial begin
      i_clk = 1;
      i_rst = 1;

      i_r0 = 0;
      i_r1 = 0;
      i_r2 = 0;
      i_r3 = 0;

      i_this_port = 1;

      #5 i_rst = 0;
      i_r3 = 4'b1101;
      i_r2 = 4'b1101;
      i_r1 = 4'b1101;
      # 20 $finish;
   end

   always #2.5 i_clk = ~i_clk;

   allocator
     inst_allocator
       (
        .o_select    (o_select),
        .o_shift     (o_shift),

        .i_this_port (i_this_port), // identifies this output port
        .i_r0        (i_r0), // top four bits of each input phit
        .i_r1        (i_r1), // directs shifter to discard upper two bits
        .i_r2        (i_r2),
        .i_r3        (i_r3),
        .i_rst       (i_rst),
        .i_clk       (i_clk) // chip clock
        );
   
endmodule // tb_allocator
