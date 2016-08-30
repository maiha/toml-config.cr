SHELL = /bin/bash

.PHONY : all test spec

test: spec

spec:
	crystal spec -v
