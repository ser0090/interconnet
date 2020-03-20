 // allocator: assigns output port to input port based on type
// of input phit and current field of routing header
// once assigned, holds a port for the duration of a packet
// (as long as payload phits are on input).
// uses fixed priority arbitration (r0 is highest).

module allocator
  (
   input wire        clk,       // chip clock
   input logic [1:0] this_port, // identifies this output port
   input logic [3:0] r0,        // top four bits of each input phit
   input logic [3:0] r1,        // directs shifter to discard upper two bits
   input logic [3:0] r2,
   input logic [3:0] r3,
   output wire [3:0] select,
   output wire       shift
   ) ;

   wire [3:0]        grant;
   wire [3:0]        head;
   wire [3:0]        payload;
   wire [3:0]        match;
   wire [3:0]        request;
   wire [3:0]        hold;
   wire [2:0]        pass;
   wire              avail;

   reg [3:0]         last;

   assign head = {r3[3:2]==3, r2[3:2]==3, r1[3:2]==3, r0[3:2]==3};

   assign payload = {r3[3:2] == 2,r2[3:2] == 2,r1[3:2] == 2,r0[3:2] == 2};

   assign match = {r3[1:0] == this_port,
                   r2[1:0] == this_port,
                   r1[1:0] == this_port,
                   r0[1:0] == this_port};

   assign request = head&match ;
   assign pass    = {pass[1:0], avail} & ~request[2:0];

   assign grant   = request & {pass, avail} ;
   assign hold    = last & payload ;
   assign select  = grant | hold ;
   assign avail   = ~(|hold) ;
   assign shift   = |grant ;

   always @(posedge clk) begin
     last <= select ;
   end

endmodule // allocator


