.PHONY:clean build dev icon install
deps:
	flutter pub get
clean: 
	flutter clean
build: clean
	flutter build apk
dev:
	flutter run
icon: 
	flutter pub pub run flutter_launcher_icons:main
install: build
	flutter install
