FROM bitnami/minideb:stretch

# Note: We could add "openjdk-8-jre-headless" to apt-get install below
# to enable support of closure compiler in Emscripten, though doing so
# drastically increases the image size.

ENV EMSCRIPTEN_VERSION 1.38.11

RUN apt-get -qq update \
  && apt-get install -y -qq --no-install-recommends \
     git curl python cmake build-essential ninja-build ca-certificates \
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
  && emcc a.cc -s WASM=1 -o a.js \
  && rm a.*

# the emcc line above causes emscripten to generate and cache things like
# internal configuration and libc, greatly speeding up subsequent invocations.

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
