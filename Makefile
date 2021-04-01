filename = top
filename_tb = top_tb

ICELINK_DIR=$(shell df | grep iCELink | awk '{print $$6}')

build:
	yosys -g -l $(filename).log -p "synth_ice40 -json $(filename).json" $(filename).v
	nextpnr-ice40 \
		--up5k \
		--package sg48 \
		--json $(filename).json \
		--pcf io.pcf \
		--asc $(filename).asc
	icepack $(filename).asc $(filename).bin

flash: build
	@if [ -d '$(ICELINK_DIR)' ]; \
        then \
            cp $(filename).bin $(ICELINK_DIR); \
        else \
            echo "Device not found"; \
            exit 1; \
    fi

debug:
	iverilog -g2005 -o $(filename_tb).out $(filename_tb).v /usr/local/share/yosys/ice40/cells_sim.v
	vvp $(filename_tb).out -fst
	gtkwave $(filename_tb).vcd

clean:
	rm -rf $(filename).json $(filename).asc $(filename).bin $(filename).log $(filename_tb).out $(filename_tb).vcd