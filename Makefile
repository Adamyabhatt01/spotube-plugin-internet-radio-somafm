# Build the plugin: Hetu source -> bytecode -> .smplug archive.
#
# The compiler is pinned. `hetu_script_dev_tools 0.1.0+2` is the release that
# ships `hetu_script 0.4.2+1` — the exact version Spotube's Hetu VM runs, so
# the bytecode this makes is the bytecode the app can load. A newer
# dev-tools release compiles with hetu_script 0.6.x and emits bytecode the
# app's VM does not accept.

compile:
	hetu compile src/plugin.ht build/plugin.out

archive:
	mkdir -p build/archive; \
	cp plugin.json build/plugin.out build/archive/; \
	cd build/archive; \
	zip -r plugin.zip ./; \
	cd ../..; \
	mv build/archive/plugin.zip build/plugin.smplug

# The install URL serves dist/plugin.smplug, so publishing means copying the
# archive there and tagging the version.
publish: archive
	mkdir -p dist; \
	cp build/plugin.smplug dist/plugin.smplug

clean:
	rm -rf build

.PHONY: compile archive publish clean
