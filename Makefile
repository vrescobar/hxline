SOURCE = Source
BUILD = build

all: clean example

example:
	haxe build.hxml

clean:
	rm -rf $(BUILD)
