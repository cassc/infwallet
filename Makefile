.PHONY:clean build dev icon install
deps:
	flutter pub get
clean:
	flutter clean
build: clean
	flutter build apk --target-platform android-arm64 --target-platform android-arm
dev:
	flutter run
icon:
	flutter pub get
	flutter pub run flutter_launcher_icons:main -f pubspec.yaml
install: build
	adb install -r build/app/outputs/apk/release/app-*
