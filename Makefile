cfacter: cfacter.cc cfacterlib.cc cfacterlib.h
	g++ -std=c++0x -g -o cfacter cfacter.cc cfacterlib.cc -I rapidjson

cfacterlib.o: cfacterlib.cc cfacterlib.h
	g++ -std=c++0x -g -fPIC -c -o $@ cfacterlib.cc -I rapidjson

cfacterlib.so: cfacterlib.o
	g++ -std=c++0x -g -o $@ $^ -fPIC -shared

missing:
	-$(shell facter    | grep "=>" | cut -f1 -d' ' | sort > /tmp/facter.txt)
	-$(shell ./cfacter | grep "=>" | cut -f1 -d' ' | sort > /tmp/cfacter.txt)
	-@$(shell diff /tmp/facter.txt /tmp/cfacter.txt > /tmp/facterdiff.txt | true)
	-@cat /tmp/facterdiff.txt
	-@rm /tmp/facter.txt /tmp/cfacter.txt /tmp/facterdiff.txt
