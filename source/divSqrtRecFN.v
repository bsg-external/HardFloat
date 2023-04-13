`include "HardFloat_consts.vi"
`include "HardFloat_specialize.vi"

module
    divSqrtRecFN#(
        parameter expWidth = 8, parameter sigWidth = 24, 
		parameter options = 0, parameter bits_per_iter_p = 1
    ) (
        /*--------------------------------------------------------------------
        *--------------------------------------------------------------------*/
        input nReset,
        input clock,
        /*--------------------------------------------------------------------
        *--------------------------------------------------------------------*/
        input [(`floatControlWidth - 1):0] control,
        /*--------------------------------------------------------------------
        *--------------------------------------------------------------------*/
        output inReady,
        input inValid,
        input sqrtOp,
        input [(expWidth + sigWidth):0] a,
        input [(expWidth + sigWidth):0] b,
        input [2:0] roundingMode,
        /*--------------------------------------------------------------------
        *--------------------------------------------------------------------*/
        output outValid,
        output sqrtOpOut,
        output [(expWidth + sigWidth):0] out,
        output [4:0] exceptionFlags
    );
	
	generate
	if(bits_per_iter_p == 2) 
		begin: divSqrtTwoBitPerIter
			     divSqrtRecFN_medium#(expWidth,sigWidth,0) 
					divSqrtRecFN_2bit(
						nReset,
						clock,
						control,
						inReady,
						inValid,
						sqrtOp,
						a,
						b,
						roundingMode,
						outValid,
						sqrtOpOut,
						out,
						exceptionFlags
					);
		end 
	else
		begin: divSqrtOneBitPerIter
				 divSqrtRecFN_small#(expWidth,sigWidth,0) 
					divSqrtRecFN_1bit(
						nReset,
						clock,
						control,
						inReady,
						inValid,
						sqrtOp,
						a,
						b,
						roundingMode,
						outValid,
						sqrtOpOut,
						out,
						exceptionFlags
					);
		end
	endgenerate
		
endmodule