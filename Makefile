.PHONY: build build-lua-types build-lua-defaults build-json-schema clean

build:
	@$(MAKE) build-lua-types
	@$(MAKE) build-lua-defaults
	@$(MAKE) build-json-schema

build-lua-types:
	node js/generate-lua-types.js > lua/hare-conf/types.lua
	node js/generate-lua-types.js --input >> lua/hare-conf/types.lua

build-lua-defaults:
	node js/generate-lua-defaults.js > lua/hare-conf/defaults.lua

build-json-schema:
	mkdir -p schemas
	node js/generate-json-schema.js > schemas/hare-conf.schema.json

clean:
	rm -f lua/hare-conf/types.lua
	rm -f lua/hare-conf/defaults.lua
	rm -f schemas/hare-conf.schema.json
