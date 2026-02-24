

DEV := static/js/main.js
.PHONY: DEV
dev: $(DEV)

PROD := static/js/main.prod.js
.PHONY: PROD
prod: $(PROD)


SRCS = $(wildcard src/*.gren src/Views/*.gren)


static/js/main.js: $(SRCS) | static/js
	gren make --output=$@ Main

static/js/main.prod.js: $(SRCS) | static/js
	gren make --optimize --output=$@ Main

static/js:
	mkdir -p $@

.PHONY: clean
clean:
	rm -f $(DEV) $(PROD)
