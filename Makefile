TOOLS_PACKAGE_PATH = Tools
TOOLS_PATH = ${TOOLS_PACKAGE_PATH}/.build/release
SWIFT_FILE_PATHS = Package.swift Tools/Package.swift Sources Plugins Tests Examples

.PHONY: build-tools
build-tools:
	swift build -c release --package-path $(TOOLS_PACKAGE_PATH) --product swift-format

.PHONY: format
format:
	$(TOOLS_PATH)/swift-format format -i -p -r $(SWIFT_FILE_PATHS)

.PHONY: lint
lint:
	$(TOOLS_PATH)/swift-format lint -s -p -r $(SWIFT_FILE_PATHS)
