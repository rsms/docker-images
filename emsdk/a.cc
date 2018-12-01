// this file is built to force emscripten to generate libc and libcxx caches
#include <stdio.h>
#include <iostream>

int main(int argc, char ** argv) {
  std::cout << std::endl;
  printf("");
}
