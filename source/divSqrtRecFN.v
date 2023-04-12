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
	
    wire [2:0] roundingModeOut;
    wire invalidExc, infiniteExc, out_isNaN, out_isInf, out_isZero, out_sign;
    wire signed [(expWidth + 1):0] out_sExp;
    wire [(sigWidth + 2):0] out_sig;
	
	generate
	if(bits_per_iter_p == 2) 
		begin: divSqrtTwoBitPerIter
			 divSqrtRecFNToRaw_medium#(expWidth, sigWidth, 0)
				divSqrtRecFNToRaw_medium(
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
					roundingModeOut,
					invalidExc,
					infiniteExc,
					out_isNaN,
					out_isInf,
					out_isZero,
					out_sign,
					out_sExp,
					out_sig
				);
		end 
	else
		begin: divSqrtOneBitPerIter
			divSqrtRecFNToRaw_small#(expWidth, sigWidth, 0)
				divSqrtRecFNToRaw_small(
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
					roundingModeOut,
					invalidExc,
					infiniteExc,
					out_isNaN,
					out_isInf,
					out_isZero,
					out_sign,
					out_sExp,
					out_sig
				);
		end
	endgenerate

    /*------------------------------------------------------------------------
    *------------------------------------------------------------------------*/
    roundRawFNToRecFN#(expWidth, sigWidth, 0)
        roundRawOut(
            control,
            invalidExc,
            infiniteExc,
            out_isNaN,
            out_isInf,
            out_isZero,
            out_sign,
            out_sExp,
            out_sig,
            roundingModeOut,
            out,
            exceptionFlags
        );
		
endmodule