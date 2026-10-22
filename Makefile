# Build the plugin: Hetu source -> bytecode -> .smplug archive.
#
# The compiler is pinned. `hetu_script_dev_tools 0.1.0+2` is the release that
# ships `hetu_script 0.4.2+1` — the exact version Spotube's Hetu VM runs, so
# the bytecode this makes is the bytecode the app can load. A newer
# dev-tools release compiles with hetu_script 0.6.x and emits bytecode the
# app's VM does not accept.
#
# The compiler ships as a Dart snapshot, so it only runs on the Dart version
# it was activated with. `HETU` is overridable for that reason:
#
#   make compile HETU="dart ~/.pub-cache/global_packages/hetu_script_dev_tools/bin/cli_tool.dart-3.10.9.snapshot"
HETU ?= hetu

compile:
	$(HETU) compile src/plugin.ht build/plugin.out

archive: compile
	mkdir -p build/archive; \
	cp plugin.json build/plugin.out build/archive/; \
	python3 tool/pack_smplug.py build/archive; \
	mv build/archive/plugin.smplug build/plugin.smplug

# The archive is only useful if it holds the bytecode: a build that skipped
# the compile step would otherwise pack a manifest on its own and look fine.
check:
	@test -s build/plugin.out || (echo "build/plugin.out is missing" >&2; exit 1)
	@python3 -c "import sys,zipfile; names=zipfile.ZipFile('build/plugin.smplug').namelist(); sys.exit(0 if 'plugin.out' in names else 1)" || \
		(echo "build/plugin.smplug has no plugin.out" >&2; exit 1)
	@echo "build/plugin.smplug holds plugin.json and plugin.out"

# The install URL serves dist/plugin.smplug, so publishing means copying the
# archive there and tagging the version.
publish: archive
	mkdir -p dist; \
	cp build/plugin.smplug dist/plugin.smplug

clean:
	rm -rf build

.PHONY: compile archive check publish clean
