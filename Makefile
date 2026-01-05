.PHONY: build build-lua-types build-lua-defaults build-json-schema clean

# Build all generated files
build:
	@$(MAKE) build-lua-types
	@$(MAKE) build-lua-defaults
	@$(MAKE) build-json-schema

# Generate the Lua type definition file (lua/hare-conf/types.lua)
build-lua-types:
	node js/generate-lua-types.js > lua/hare-conf/types.lua
	echo '' >> lua/hare-conf/types.lua
	node js/generate-lua-types.js --input >> lua/hare-conf/types.lua

# Generate the Lua defaults file (lua/hare-conf/defaults.lua)
build-lua-defaults:
	node js/generate-lua-defaults.js > lua/hare-conf/defaults.lua

# Generate the JSON schema file (schemas/hare-conf.schema.json)
build-json-schema:
	mkdir -p schemas
	node js/generate-json-schema.js > schemas/hare-conf.schema.json

# Clean generated files
clean:
	rm -f lua/hare-conf/types.lua
	rm -f lua/hare-conf/defaults.lua
	rm -f schemas/hare-conf.schema.json
