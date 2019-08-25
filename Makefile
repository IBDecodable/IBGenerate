PREFIX?=/usr/local

build:
		swift build --disable-sandbox -c release --static-swift-stdlib

clean_build:
		rm -rf .build
		make build

portable_zip: build
		rm -rf portable_ibgenerate
		mkdir portable_ibgenerate
		mkdir portable_ibgenerate/bin
		cp -f .build/release/ibgenerate portable_ibgenerate/bin/ibgenerate
		cp -f LICENSE portable_ibgenerate
		cd portable_ibgenerate
		(cd portable_ibgenerate; zip -yr - "bin" "LICENSE") > "./portable_ibgenerate.zip"
		rm -rf portable_ibgenerate

install: build
		mkdir -p "$(PREFIX)/bin"
		cp -f ".build/release/ibgenerate" "$(PREFIX)/bin/ibgenerate"

current_version:
		@cat .version

bump_version:
		$(eval NEW_VERSION := $(filter-out $@,$(MAKECMDGOALS)))
		@echo $(NEW_VERSION) > .version
		@sed 's/__VERSION__/$(NEW_VERSION)/g' script/Version.swift.template > Sources/IBGenerateFrontend/Version.swift
		git commit -am"Bump version to $(NEW_VERSION)"

publish:
		brew update && brew bump-formula-pr --tag=$(shell git describe --tags) --revision=$(shell git rev-parse HEAD) ibgenerate
		COCOAPODS_VALIDATOR_SKIP_XCODEBUILD=1 pod trunk push IBGenerate.podspec

%:
	@:
