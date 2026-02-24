

DEV := static/js/main.js
.PHONY: DEV
dev: $(DEV)

PROD := static/js/main.prod.js
.PHONY: PROD
prod: $(PROD)


SRCS = $(wildcard src/*.gren src/Views/*.gren)


static/js/main.js: $(SRCS) | static/js
	elm make --output=$@ src/Main.elm

static/js/main.prod.js: $(SRCS) | static/js
	elm make --optimize --output=$@ src/Main.elm

static/js:
	mkdir -p $@

.PHONY: clean
clean:
	rm -f $(DEV) $(PROD)
