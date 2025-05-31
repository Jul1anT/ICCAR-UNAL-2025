fig.pdf: script.gp data.txt
	gnuplot script.gp

sumupdown.x : sumupdown.cpp
	g++ sumupdown.cpp -o sumupdown.x

data.txt : sumupdown.x
	./sumupdown.x > data.txt

clean:
	rm -f *.x a.out * .txt
