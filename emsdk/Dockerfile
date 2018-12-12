FROM bitnami/minideb:stretch

# Note: We could add "openjdk-8-jre-headless" to apt-get install below
# to enable support of closure compiler in Emscripten, though doing so
# drastically increases the image size.

ENV EMSCRIPTEN_VERSION 1.38.20

RUN apt-get -qq update \
  && apt-get install -y -qq --no-install-recommends \
     git curl python3 cmake build-essential ninja-build ca-certificates \
  && ln -s /usr/bin/python3 /usr/bin/python \
  && mkdir ~/emsdk0 \
  && cd ~/emsdk0 \
  && curl -L# 'https://github.com/juj/emsdk/archive/master.tar.gz' | tar xzf - \
  && mv *emsdk* /emsdk \
  && cd /emsdk \
  && rm -rf ~/emsdk0 \
  && ./emsdk update \
  && ./emsdk install latest \
  && ./emsdk activate latest \
  && echo "EMSCRIPTEN_VERSION: $EMSCRIPTEN_VERSION" \
  && /bin/bash emsdk_env.sh >/dev/null

SHELL ["/bin/bash", "-c"]

COPY a.cc /root/a.cc

RUN source /emsdk/emsdk_env.sh >/dev/null \
  && echo "PATH=$PATH" >> /root/env \
  && echo "EMSDK=$EMSDK" >> /root/env \
  && echo "EM_CONFIG=$EM_CONFIG" >> /root/env \
  && echo "EMSCRIPTEN=$EMSCRIPTEN" >> /root/env \
  && echo $EMSCRIPTEN | sed -E 's/.+\/([^\/]+)$/EMSCRIPTEN_VERSION=\1/' >> /root/env \
  && cd /root \
  && EMCC_CORES=8 python3 /emsdk/emscripten/*/embuilder.py build ALL \
  && emcc a.cc -s WASM=1 -o a.js -O0 \
  && rm a.js a.wasm*

# emcc and embuilder.py above causes emscripten to generate and cache
# libc et al, greatly speeding up invocation.
# embuilder.py command from CI config:
# https://github.com/kripken/emscripten/blob/master/.circleci/config.yml

# Cleaning
RUN cd /emsdk \
  && rm -rf \
     emscripten/tag-*/tests \
     emscripten/tag-*/site \
     emscripten/tag-*/docs \
     zips \
  && find . \
     -name "*.o" -or \
     -name "*.a" -or \
     -name "*.tmp" \
     -exec rm {} \; \
  && apt-get -y --purge remove git curl cmake build-essential \
  && apt-get -y autoremove \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

VOLUME /src
WORKDIR /src
