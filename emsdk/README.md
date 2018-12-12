# Emscripten SDK docker image

Published as `rsms/emsdk`

Contains:

- Debian "stretch" (bitnami/minideb:stretch)
- [Emscripten SDK](https://kripken.github.io/emscripten-site/),
  which includes [Clang](https://clang.llvm.org/)
- Python 3.5 (required by emscripten)
- [Nodejs 8.9](https://nodejs.org/) (required by emscripten)
- [Ninja 1.7](https://ninja-build.org/)


Prebuilt Emscripten ports:

- bullet
- cocos2d
- dlmalloc
- emmalloc
- freetype
- gl
- harfbuzz
- libpng
- ogg
- pthreads
- sdl2
- vorbis
- zlib

[See full list of prebuilt libraries](https://github.com/kripken/emscripten/blob/bef3bb0a3f113a57edb3b6afca4c79a345453eff/embuilder.py#L35)


Docker tags:

- `rsms/emsdk:latest` -- most recent Emscripten version
- `rsms/emsdk:<version>` -- specific version of Emscripten, where `<version>`
  is a full version number like `1.38.8` (e.g. rsms/emsdk:1.38.8)


## Usage

There are many ways of making use of this image.

Run the image interactively to enter a bash shell as root:

```
$ docker run --rm -it rsms/emsdk
root@abc123def456:/src#
```

Since `/src` is the default working directory, so you can simply mount
your project directory on `/src` to gain access to your files inside the
image:

```
$ cd example
$ cat hello.c
#include <stdio.h>
int main(int argc, char ** argv) {
  printf("Hello World\n");
}
$ docker run --rm -v "$PWD:/src" rsms/emsdk emcc hello.c -s WASM=1 -o hello.js
$ node hello.js
Hello World
```

This image comes with ninja so that you can build ninja projects in an
effective way:

```
$ cd example
$ docker run --rm -v "$PWD:/src" rsms/emsdk ninja
$ cd build
$ node hello.js
Hello World
```
