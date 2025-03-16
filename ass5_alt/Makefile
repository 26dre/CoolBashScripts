GCC_OPTIONS=-Wall -Werror -pthread -arch arm64
DEBUG_FLAGS = -g


default:
	gcc -c work_crew.c $(GCC_OPTIONS)


run: 
	gcc -o test_work_crew.o test_work_crew.c work_crew.c $(GCC_OPTIONS)
	./test_work_crew.o

debug:
	gcc -o test_work_crew_debug.o test_work_crew.c work_crew.c $(GCC_OPTIONS) $(DEBUG_FLAGS)

clean:
	rm -rf *.out *.o *.dSYM	