# -*- MakeFile -*-

run: build prebuild
	./controllers/run.exe
build: prebuild
	./controllers/build.exe
prebuild:
	./controllers/prebuild.exe