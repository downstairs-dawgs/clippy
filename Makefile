.PHONY: build run install clean

APP = Clippy.app

build:
	swift build -c release
	mkdir -p $(APP)/Contents/MacOS
	cp .build/release/Clippy $(APP)/Contents/MacOS/
	cp Resources/Info.plist $(APP)/Contents/
	codesign --force --sign - $(APP)

run: build
	open $(APP)

install: build
	cp -r $(APP) /Applications/

clean:
	rm -rf $(APP)
	swift package clean
