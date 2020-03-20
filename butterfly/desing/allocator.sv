 // allocator: assigns output port to input port based on type
// of input phit and current field of routing header
// once assigned, holds a port for the duration of a packet
// (as long as payload phits are on input).
// uses fixed priority arbitration (r0 is highest).

module allocator
  (
   output wire [3:0] o_select,
   output wire       o_shift,

   input logic [1:0] i_this_port, // identifies this output port
   input logic [3:0] i_r0, // top four bits of each input phit
   input logic [3:0] i_r1, // directs shifter to discard upper two bits
   input logic [3:0] i_r2,
   input logic [3:0] i_r3,
   input wire        i_rst,
   input wire        i_clk // chip clock
   ) ;

   localparam HEAD    = 3;
   localparam PAYLOAD = 2;

   wire [3:0]        grant;
   wire [3:0]        head;
   wire [3:0]        payload;
   wire [3:0]        match;
   wire [3:0]        request;
   wire [3:0]        hold;
   wire [2:0]        pass;
   wire              avail;

   reg [3:0]         last;

   initial begin
      last = 0;
   end

   // Decode section
   assign head    = {i_r3[3:2] == HEAD, i_r2[3:2] == HEAD,
                     i_r1[3:2] == HEAD, i_r0[3:2] == HEAD};

   assign payload = {i_r3[3:2] == PAYLOAD, i_r2[3:2] == PAYLOAD,
                     i_r1[3:2] == PAYLOAD, i_r0[3:2] == PAYLOAD};


   assign match   = {i_r3[1:0] == i_this_port,
                     i_r2[1:0] == i_this_port,
                     i_r1[1:0] == i_this_port,
                     i_r0[1:0] == i_this_port};

   // use of the output port to route the packets starting whit this head phit
   assign request = head & match;
   // powwwws
   assign pass    = {pass[1:0], avail} & ~request[2:0];

   // Arbitrer section
   // accepts 4 request signasl y generetare 4 grant signals
   // if output port is available -> avail.
   // Arbitrer grants port to the first upper input port making request.
   assign grant   = request & {pass, avail} ;
   assign avail   = ~(|hold) ;

   // Hold section
   // mantiene la salida para una entrada para toda la duracion del paquete.
   // si el pkt es un payload last mantiene la misma asignacion input -> output.
   assign hold    = last & payload ;

   always @(posedge i_clk) begin
      if(i_rst)
        last <= 0;
      else
        last <= o_select;
   end

   assign o_select  = grant | hold ;
   assign o_shift   = |grant ;

endmodule // allocator


