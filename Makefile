.PHONY: all sim report demo clean
all: sim report
sim:
	vsim -do sim/run.do > out/logs/rtl.log 2>&1 || (echo "Simulation failed; see out/logs/rtl.log"; exit 1)
	@echo "Simulation complete. Log at out/logs/rtl.log"
report:
	perl scripts/parse_logs.pl
demo:
	perl scripts/demo_generate_mock_log.pl
	perl scripts/parse_logs.pl
clean:
	rm -rf out/logs/* out/csv/* out/reports/*
