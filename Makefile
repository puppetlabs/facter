cfacter: cfacter.cc cfacterlib.cc cfacterlib.h
	g++ -g -o cfacter cfacter.cc cfacterlib.cc

cfacterlib.o: cfacterlib.cc cfacterlib.h
	g++ -g -fPIC -c -o $@ cfacterlib.cc

cfacterlib.so: cfacterlib.o
	g++ -g -o $@ $^ -fPIC -shared

missing:
	-$(shell facter    | grep "=>" | cut -f1 -d' ' | sort > /tmp/facter.txt)
	-$(shell ./cfacter | grep "=>" | cut -f1 -d' ' | sort > /tmp/cfacter.txt)
	-@$(shell diff /tmp/facter.txt /tmp/cfacter.txt > /tmp/facterdiff.txt | true)
	-@cat /tmp/facterdiff.txt
	-@rm /tmp/facter.txt /tmp/cfacter.txt /tmp/facterdiff.txt
