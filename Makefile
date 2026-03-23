
export HOST_SYSTEM := Linux-x86_64-GCC
export TEST_SYSTEM := Verilator-GCC
export SPECIALIZE_TYPE := RISCV

export SOFTFLOAT_BUILD := berkeley-softfloat-3/build/$(HOST_SYSTEM)
export TESTFLOAT_BUILD := berkeley-testfloat-3/build/$(HOST_SYSTEM)
export HARDFLOAT_BUILD := test/build/$(TEST_SYSTEM)

export SOFTFLOAT_LIB := $(SOFTFLOAT_BUILD)/softfloat.a
export TESTFLOAT_BIN := $(TESTFLOAT_BUILD)/testfloat_gen

export PATH := $(abspath $(dir $(TESTFLOAT_BIN))):$(PATH)

checkout:
	@git submodule update --init --checkout berkeley-softfloat-3
	@git submodule update --init --checkout berkeley-testfloat-3

$(SOFTFLOAT_LIB):
	@$(MAKE) -C $(@D)

$(TESTFLOAT_BIN): $(SOFTFLOAT_LIB)
	@$(MAKE) -C $(@D)

run-testfloat-level1: $(TESTFLOAT_BIN)
	@$(MAKE) -C $(HARDFLOAT_BUILD) test-level1

run-testfloat-level2: $(TESTFLOAT_BIN)
	@$(MAKE) -C $(HARDFLOAT_BUILD) test-level2

clean:
	@$(MAKE) -C $(HARDFLOAT_BUILD) clean
	@rm -f $(SOFTFLOAT_LIB)
	@rm -f $(TESTFLOAT_BIN)

