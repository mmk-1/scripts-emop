.PHONY: all seperate_results combine_results

all:
	./run_emop.sh

seperate_results:
	./collect_results.sh

combine_results:
	./combine.sh
