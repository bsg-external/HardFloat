Note: This is a Bespoke Silicon Group mirror of 
of https://www.jhauser.us/arithmetic/HardFloat.html

with modifications for PPA improvement. 

We've additionally wrapped the HardFloat/TestFloat/SoftFloat testing infrastructure in
a Makefile:

        make clean
        make checkout
        make run-testfloat-level1
        make run-testfloat-level2

Note: Our modifications are focused on RISCV, so we do not test other specializations.
However, we do not expect any major divergences.

---------------------------------

Package Overview for Berkeley HardFloat Release 1

John R. Hauser
2019 July 29

Berkeley HardFloat is a hardware implementation of binary floating-point
that conforms to the IEEE Standard for Floating-Point Arithmetic.  This
version of HardFloat is encoded in Verilog.  Additional sources are included
for testing HardFloat through simulation.

The HardFloat package is documented in the following files in the "doc"
subdirectory:

    HardFloat-Verilog.html         Documentation for the HardFloat modules.
    HardFloat-test-Verilog.html    Documentation for testing HardFloat using
                                    Verilog simulation
    HardFloat-test-Verilator.html  Documentation for testing HardFloat using
                                    Verilator

Other files in the package comprise the source code for HardFloat and
associated testing infrastructure.

