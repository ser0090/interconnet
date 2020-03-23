`timescale 1ns/1ps

module tb_router();

   wire [17:0]  o_outputs [0:3];  // output phits
   reg [17:0]   i_inputs [0:3];   // input phits
   reg          i_rst;
   reg          i_clk; // chip clock

   integer      index;
   initial begin
      i_clk = 1;
      i_rst = 1;

      for(index=0; index < 4; index = index + 1)
        i_inputs[index] = {18{1'b0}};

      i_inputs[0] = 18'b11_000000_0000000011;
      i_inputs[1] = 18'b11_010001_0000001010;


      i_inputs[2] = 18'b11_000000_0000000111;

      #10 i_rst = 0;

      #5 i_inputs[0] = 18'b10_000000_0000000100;
      #5 i_inputs[0] = 18'b10_000000_0000000101;
      #5 i_inputs[0] = 18'b10_000000_0000000110;

      #5 i_inputs[0] = 18'b11_110000_0000000011;

      # 20 $finish;
   end

   always #2.5 i_clk = ~i_clk;

   router
     inst_router
       (
        .o_outputs (o_outputs), // output phits
        .i_inputs  (i_inputs),  // input phits
        .i_rst     (i_rst),     // chip reset
        .i_clk     (i_clk)      // chip clock
        );

endmodule // tb_router

