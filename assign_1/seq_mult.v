//	file name: seq_mult.v
//	Description: Behavioural model of a sequential multiplier (Shift and add)
//	Author: Arjun Menon Vadakkeveedu (ee18b104)
//	Assignment 1 Computer Organisation EE2003, Fall 2020
//  Date: 26 August 2020

`define width 8                                                         // width of input signals a, b
`define ctrwidth 4                                                      // counter tracking number of shift and adds

module seq_mult(p, rdy,	                                                //output signals 
		clk, reset, a, b                                                    //input signals
		);
                                                                        //declare type and length of signals 
output reg [2*`width - 1: 0] p;                                         // product of two N bit numbers cannot exceed 2N bits
output reg rdy;                                                         
input clk, reset;
input [`width -1 : 0] a, b;
//
reg [`ctrwidth: 0] ctr;
reg [2*`width - 1: 0] mult_a, mult_b;
//
always @(posedge clk or posedge reset) begin
  if (reset) begin
    rdy <= 1'b0;
    ctr <= 0;
    p <= 0;
    mult_a <= {{`width{a[`width-1]}}, a}; 	// `width{vector} replicates vector `width times
    mult_b <= {{`width{b[`width-1]}}, b};	
  end	// end if	
  else begin
    if (ctr < {1'b1, {`ctrwidth{1'b0}}}) begin        
      if(mult_b[ctr] == 1'b1) p <= p + {mult_a<<ctr};
      ctr <= ctr + 1'b1; // increment counter  
   end //end if
   else rdy <= 1'b1; 
  end // end else begin...
end	//end always block
endmodule
