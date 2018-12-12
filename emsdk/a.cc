// this file is built to force emscripten to generate libc and libcxx caches
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <iostream>
#include <memory>
#include <vector>

int main(int argc, char ** argv) {
  std::string s;
  std::cout << s;
  void* x = calloc(1,1);
  const char* y = getenv("X");
  printf("%lu %lx", strlen((const char*)x), (unsigned long)y);
}
