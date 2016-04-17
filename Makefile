SOURCE = Source
BUILD = build

all: clean example

example:
	haxe examples.hxml

clean:
	rm -rf $(BUILD)
