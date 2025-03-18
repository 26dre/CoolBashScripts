GCC_OPTIONS=-Wall -Werror -pthread
DEBUG_FLAGS = -g


default:
	gcc -c work_crew_2.c $(GCC_OPTIONS)

run: 
	gcc -o test_work_crew_2.o test_work_crew_2.c work_crew_2.c $(GCC_OPTIONS)
	./test_work_crew_2.o

debug:
	gcc -o test_work_crew_debug_2.o test_work_crew_2.c work_crew_2.c $(GCC_OPTIONS) $(DEBUG_FLAGS)

clean:
	rm -rf *.out *.o *.dSYM	

# test_finiteness: run
# 	@echo "Running test 100 times..."
# 	@for i in {1..100}; do \
# 		echo "Test run $$i"; \
# 		./test_work_crew_2.o; \
# 	done