/*===============================================================================================================================
   Design       : Single-clock Synchronous LIFO/Stack

   Description  : Fully synthesisable, configurable Single-clock Synchronous LIFO/Stack based on registers.
                  - Configurable Data width.
                  - Configurable Depth.
                  - Push and increment / decrement and pop -- pointer mode.
                  - All status signals have zero cycle latency.
                  
   Developer    : Mitu Raj, iammituraj@gmail.com
   Date         : Oct-02-2021
===============================================================================================================================*/

module my_stack #(
                    parameter DATA_W     = 4           ,        // Data width
                    parameter DEPTH      = 8                    // Depth of Stack                             
                 )

                (
                   input                   clk         ,        // Clock
                   input                   rstn        ,        // Active-low Synchronous Reset
                   
                   input                   i_push      ,        // Push
                   input  [DATA_W - 1 : 0] i_data      ,        // Write-data                   
                   output                  o_full      ,        // Full signal

                   input                   i_pop       ,        // Pop
                   output [DATA_W - 1 : 0] o_data      ,        // Read-data                   
                   output                  o_empty              // Empty signal
                );


/*-------------------------------------------------------------------------------------------------------------------------------
   Internal Registers/Signals
-------------------------------------------------------------------------------------------------------------------------------*/
logic [DATA_W - 1 : 0]        stack [DEPTH]           ;
logic [$clog2(DEPTH+1)-1 : 0] stack_ptr_rg            ;
logic                         push, pop, full, empty  ;


/*-------------------------------------------------------------------------------------------------------------------------------
   Synchronous logic to push and pop from Stack
-------------------------------------------------------------------------------------------------------------------------------*/
always @ (posedge clk) begin
   
   // Reset
   if (!rstn) begin       
      
      stack        <= '{default: 1'b0} ;
      stack_ptr_rg <= 0                ;

   end
   
   // Out of Reset
   else begin      
      
      // Push to Stack    
      if (push) begin
         stack [stack_ptr_rg] <= i_data    ;               
      end
      
      // Stack pointer update
      if (push & !pop) begin
         stack_ptr_rg <= stack_ptr_rg + 1  ;
      end
      else if (!push & pop) begin
         stack_ptr_rg <= stack_ptr_rg - 1  ;
      end

   end

end


/*-------------------------------------------------------------------------------------------------------------------------------
   Continuous Assignments
-------------------------------------------------------------------------------------------------------------------------------*/
assign full    = (stack_ptr_rg == DEPTH)               ;
assign empty   = (stack_ptr_rg == 0    )               ;

assign push    = i_push & !full                        ;
assign pop     = i_pop  & !empty                       ;

assign o_full  = full                                  ;
assign o_empty = empty                                 ;  

assign o_data  = empty ? '0 : stack [stack_ptr_rg - 1] ;   


endmodule

/*=============================================================================================================================*/