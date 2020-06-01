#
# Makefile for nacs package
#
%: %.cr
	crystal build $(CRYSTAL_OPTIONS)  $<

CRYSTAL_OPTIONS = --release
BIN = mkplummer hackcode1 nacsplot2

.PHONY: all
all: $(BIN)
