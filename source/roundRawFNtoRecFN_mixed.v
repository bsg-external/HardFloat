
// This module is used for mixed-precision operations
// The input is a RAW FP value which is then
//   - round to the max precision
//   or
//   - rounded to an intermediate precision and upconverted back to a higher precision
// output is a recoded version of the maximum precision input

`include "HardFloat_consts.vi"
`include "HardFloat_specialize.vi"

module
    roundRawFNtoRecFN_mixed#(
      parameter inExpWidth = 3,
      parameter inSigWidth = 3,
      parameter midExpWidth = 3,
      parameter midSigWidth = 3,
      parameter outExpWidth = 3,
      parameter outSigWidth = 3
  ) (
      input precision, // 0 = precision is mid, 1 = precision is full
      input [(`floatControlWidth - 1):0] control,
      input invalidExc,     // overrides 'infiniteExc' and 'in_*' inputs
      input infiniteExc,    // overrides 'in_*' inputs except 'in_sign'
      input in_isNaN,
      input in_isInf,
      input in_isZero,
      input in_sign,
      input signed [(inExpWidth + 1):0] in_sExp,   // limited range allowed
      input [(inSigWidth + 2):0] in_sig,
      input [2:0] roundingMode,
      output [(outExpWidth + outSigWidth):0] out,
      output [4:0] exceptionFlags
  );

  // synopsys translate_off
  if ((midExpWidth > inExpWidth) || (midSigWidth > inSigWidth))
    $error("Intermediate rounding must be smaller than input");

  if ((midExpWidth > outExpWidth) || (midSigWidth > outSigWidth))
    $error("Intermediate rounding must be smaller than output");
  // synopsys translate_on

  logic [(inExpWidth + inSigWidth):0] inResult;
  logic [4:0] inFlags;
  roundAnyRawFNToRecFN
   #(.inExpWidth(inExpWidth)
     ,.inSigWidth(inSigWidth+2)
     ,.outExpWidth(outExpWidth)
     ,.outSigWidth(outSigWidth)
     )
   round64
    (.control(control)
     ,.invalidExc(invalidExc)
     ,.infiniteExc(infiniteExc)
     ,.in_isNaN(in_isNaN)
     ,.in_isInf(in_isInf)
     ,.in_isZero(in_isZero)
     ,.in_sign(in_sign)
     ,.in_sExp(in_sExp)
     ,.in_sig(in_sig)
     ,.roundingMode(roundingMode)

     ,.out(inResult)
     ,.exceptionFlags(inFlags)
     );

  logic [(midExpWidth + midSigWidth):0] midResult;
  logic [4:0] midFlags;
  roundAnyRawFNToRecFN
   #(.inExpWidth(inExpWidth)
     ,.inSigWidth(inSigWidth+2)
     ,.outExpWidth(midExpWidth)
     ,.outSigWidth(midSigWidth)
     )
   round32
    (.control(control)
     ,.invalidExc(invalidExc)
     ,.infiniteExc(infiniteExc)
     ,.in_isNaN(in_isNaN)
     ,.in_isInf(in_isInf)
     ,.in_isZero(in_isZero)
     ,.in_sign(in_sign)
     ,.in_sExp(in_sExp)
     ,.in_sig(in_sig)
     ,.roundingMode(roundingMode)

     ,.out(midResult)
     ,.exceptionFlags(midFlags)
     );

  //
  // "Unsafe" upconvert (Made safe because we've already rounded)
  //
  localparam biasAdj = (1 << outExpWidth) - (1 << midExpWidth);
  wire [outExpWidth:0] nanExp = {outExpWidth+1{1'b1}};
  wire [outExpWidth:0] infExp = 2'b11 << (outExpWidth-1);
  wire [outExpWidth:0] zeroExp = {outExpWidth+1{1'b0}};

  wire [inSigWidth-2:0] inFract = inResult[0+:inSigWidth-1];
  wire [inExpWidth:0] inExp = inResult[inSigWidth-1+:inExpWidth+1];
  wire inSign = inResult[inSigWidth+inExpWidth];

  wire [midSigWidth-2:0] midFract = midResult[0+:midSigWidth-1];
  wire [midExpWidth:0] midExp = midResult[midSigWidth-1+:midExpWidth+1];
  wire midSign = midResult[midSigWidth+midExpWidth];

  wire outSign = precision ? inSign : midSign;
  wire [outExpWidth:0] outExp = precision ? inExp : in_isNaN ? nanExp : in_isInf ? infExp : in_isZero ? zeroExp : (midExp + biasAdj);
  wire [outSigWidth-2:0] outFract = precision ? inFract : (midFract << (outSigWidth - midSigWidth));

  assign out = {outSign, outExp, outFract};
  assign exceptionFlags = precision ? inFlags : midFlags;

endmodule

