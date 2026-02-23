

DEV := static/js/main.js
.PHONY: DEV
dev: $(DEV)


SRCS = $(wildcard src/*.gren src/Views/*.gren)


static/js/main.js: $(SRCS) gren.json | static/js
	gren make --output=$@ Main

static/js:
	mkdir -p $@

.PHONY: clean
clean:
	rm -f $(DEV)
