//     %%%%%%%%%%%%      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//  %%%%%%%%%%%%%%%%%%                      
// %%%%%%%%%%%%%%%%%%%% %%                
//    %% %%%%%%%%%%%%%%%%%%                
//        % %%%%%%%%%%%%%%%                 
//           %%%%%%%%%%%%%%                 ////    O P E N - S O U R C E     ////////////////////////////////////////////////////////////
//           %%%%%%%%%%%%%      %%          _________________________________////
//           %%%%%%%%%%%       %%%%                ________    _                             __      __                _     
//          %%%%%%%%%%        %%%%%%              / ____/ /_  (_)___  ____ ___  __  ______  / /__   / /   ____  ____ _(_)____ TM 
//         %%%%%%%    %%%%%%%%%%%%*%%%           / /   / __ \/ / __ \/ __ `__ \/ / / / __ \/ //_/  / /   / __ \/ __ `/ / ___/
//        %%%%% %%%%%%%%%%%%%%%%%%%%%%%         / /___/ / / / / /_/ / / / / / / /_/ / / / / ,<    / /___/ /_/ / /_/ / / /__  
//       %%%%*%%%%%%%%%%%%%  %%%%%%%%%          \____/_/ /_/_/ .___/_/ /_/ /_/\__,_/_/ /_/_/|_|  /_____/\____/\__, /_/\___/
//       %%%%%%%%%%%%%%%%%%%    %%%%%%%%%                   /_/                                              /____/  
//       %%%%%%%%%%%%%%%%                                                             ___________________________________________________               
//       %%%%%%%%%%%%%%                    //////////////////////////////////////////////       c h i p m u n k l o g i c . c o m    //// 
//         %%%%%%%%%                       
//           %%%%%%%%%%%%%%%%               
//    
//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//----%%
//----%% File Name        : stack.sv
//----%% Module Name      : Stack                                
//----%% Developer        : Mitu Raj, chip@chipmunklogic.com
//----%% Vendor           : Chipmunk Logic ™ , https://chipmunklogic.com
//----%%
//----%% Description      : Stack that follows LIFO (Last-In-First-Out) scheme.
//----%%
//----%% Tested on        : Basys-3 Artix-7 FPGA board, Vivado 2019.2 Synthesiser
//----%% Last modified on : May-2025
//----%% Notes            : -
//----%%                  
//----%% Copyright        : Open-source license, see LICENSE.
//----%%                                                                                             
//----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

//###################################################################################################################################################
//                                                                   S T A C K                                     
//###################################################################################################################################################
// Module definition
module stack #(
   parameter  DPT   = 4  ,         // Stack depth
   parameter  DW    = 32 ,         // Data size
   localparam PTRW  = $clog2(DPT)  // Pointer size
)(
   // Clock and Reset
   input  logic           clk         ,  // Clock
   input  logic           aresetn     ,  // Asynchronous Reset; active-low

   // Push interface
   input  logic           i_push_en   ,  // Push enable
   input  logic [DW-1:0]  i_push_data ,  // Push data
   output logic           o_full      ,  // Full flag

   // Pop interface
   input  logic           i_pop_en    ,  // Pop enable
   output logic [DW-1:0]  o_pop_data  ,  // Pop data
   output logic           o_empty        // Empty flag
);

// Internal Registers/Signals
logic [DW-1:0]   stack_arr [DPT];  // Stack array
logic [PTRW:0]   top_ptr_ff;       // Stack pointer @top --> points to next free slot [0-DPT]
logic [PTRW-1:0] top_ptr_m1;       // Stack pointer-1
logic [PTRW-1:0] wr_ptr;           // Write pointer
logic            push_en, pop_en;  // Conditioned push & pop enable
logic            exc_push_en, exc_pop_en;  // Exclusive push/pop enable

// Logic to push data
always_ff @(posedge clk or negedge aresetn) begin
   // Reset
   if (!aresetn) begin
      top_ptr_ff <= '0 ;
   end  
   // Out of reset
   else begin
      // Push to stack
      if (push_en) stack_arr[wr_ptr] <= i_push_data ;  

      // Pointer update on push & pop
      if      (exc_push_en) top_ptr_ff <= top_ptr_ff + 1 ;  // Increment pointer only on exclusive push
      else if (exc_pop_en)  top_ptr_ff <= top_ptr_ff - 1 ;  // Decrement pointer only on exclusive pop
   end
end

// Write pointer
assign wr_ptr = pop_en? top_ptr_m1 : top_ptr_ff[PTRW-1:0];  // On simultaneous push & pop, overwrite the top item, instead of writing to next free slot

// Pop data
assign top_ptr_m1 = top_ptr_ff-1 ;
assign o_pop_data = stack_arr[top_ptr_m1]  ;

// Conditioned push & pop enable
assign push_en     = i_push_en & ~o_full  ;  // Push is allowed only if not full
assign pop_en      = i_pop_en  & ~o_empty ;  // Pop is allowed only if not empty
assign exc_push_en =  push_en  & !pop_en  ;
assign exc_pop_en  = !push_en  &  pop_en  ; 

// Full & Empty flags
generate
if (2**PTRW == DPT)  // 2^N Stack
   assign o_full  = (top_ptr_ff[PTRW] == 1'b1);
else
   assign o_full  = (top_ptr_ff == DPT);
endgenerate

assign o_empty = (top_ptr_ff == 0);

endmodule
//###################################################################################################################################################
//                                                                   S T A C K                                     
//###################################################################################################################################################
