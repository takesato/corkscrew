#!/bin/sh
rm -f pkg/corkscrew-0.1.0.gem && rake build && gem uninstall corkscrew && rake install:local
