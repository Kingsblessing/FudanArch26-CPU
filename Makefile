.DEFAULT_GOAL := no_arguments

no_arguments:
	@echo "Please specify a target to build"
	@echo "  - init: Initialize submodules"
	@echo "  - handin: Create a zip file for handin"
	@echo "  - test-lab1: Run lab1 test"

init:
	git submodule update --init --recursive

handin:
	@report_found=""; \
	if [ -d docs/report ]; then \
		if [ ! -f docs/report/report.md ] && [ ! -f docs/report/report.pdf ]; then \
			echo "Please put 'report.md' or 'report.pdf' in 'docs/report'"; \
			exit 1; \
		fi; \
		report_found=1; \
	else \
		if [ -f docs/report.md ]; then \
			report_found=1; \
		fi; \
		if [ -f docs/report.pdf ]; then \
			report_found=1; \
		fi; \
		if [ -z "$$report_found" ]; then \
			echo "Please put your report in 'docs/report/' or as 'docs/report.md' or 'docs/report.pdf'"; \
			exit 1; \
		fi; \
	fi; \
	echo "Please enter your 'student id-name' (e.g., 12345678910-someone)"; \
	read filename; \
	echo "Please enter lab number (e.g., 1)"; \
	read lab_n; \
	zip -q -r "docs/$$filename-lab$$lab_n.zip" \
	  include vsrc docs -x "docs/*.zip"

sim-verilog:
	@echo "I don't know why, just make difftest happy..."

# DIFFTEST_OPTS = DELAY=0 # remove on lab 2

emu:
	$(MAKE) -C ./difftest emu $(DIFFTEST_OPTS)

export NOOP_HOME=$(abspath .)
export NEMU_HOME=$(abspath ./ready-to-run)

REF_NEMU := riscv64-nemu-interpreter-so
ifeq ($(shell uname -s),Darwin)
REF_NEMU := riscv64-nemu-interpreter-so-apple
endif
REF_SO := $(NEMU_HOME)/$(REF_NEMU)

sim:
	rm -rf build
	mkdir -p build
	make EMU_TRACE=1 emu -j12 NOOP_HOME=$(NOOP_HOME) NEMU_HOME=$(NEMU_HOME)

test-lab1: sim
	TEST=$(TEST) ./build/emu --diff $(REF_SO) -i ./ready-to-run/lab1/lab1-test.bin $(VOPT) || true

test-lab1-extra: sim
	TEST=$(TEST) ./build/emu --diff $(REF_SO) -i ./ready-to-run/lab1/lab1-extra-test.bin $(VOPT) || true

test-lab2: sim
	TEST=$(TEST) ./build/emu --diff $(REF_SO) -i ./ready-to-run/lab2/lab2-test.bin $(VOPT) || true

test-lab3: sim
	TEST=$(TEST) ./build/emu --diff $(REF_SO) -i ./ready-to-run/lab3/lab3-test.bin $(VOPT) || true

test-lab3-extra: sim
	TEST=$(TEST) ./build/emu --diff $(REF_SO) -i ./ready-to-run/lab3/lab3-extra-test.bin $(VOPT) || true

test-lab4: sim
	TEST=$(TEST) ./build/emu --diff $(REF_SO) -i ./ready-to-run/lab4/lab4-test.bin $(VOPT) || true

test-lab5: sim
	TEST=$(TEST) ./build/emu --diff $(REF_SO) -i ./ready-to-run/lab5/kernel.bin $(VOPT) || true

test-lab6: sim
	TEST=sys ./build/emu --no-diff -i ./ready-to-run/lab6/lab6-test.bin $(VOPT) || true

clean:
	rm -rf build

include verilate/Makefile.include
include verilate/Makefile.verilate.mk
include verilate/Makefile.vsim.mk

.PHONY: emu clean sim
