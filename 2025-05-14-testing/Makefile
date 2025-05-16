all: main_factorial.x

%.x: %.o factorial.o
	g++ $^ -o $@

%.o: %.cpp
	g++ -c $<

test_factorial.x: test_factorial.o factorial.o
	g++ $^ -o $@ -l Catch2Main -l Catch2

test: test_factorial.x
	./test_factorial.x

clean:
	rm -f *.o *.x