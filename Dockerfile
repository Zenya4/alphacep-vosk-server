FROM debian:11

ARG KALDI_MKL

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        bzip2 \
        unzip \
        xz-utils \
        g++ \
        make \
        cmake \
        git \
        python3 \
        python3-dev \
        python3-websockets \
        python3-setuptools \
        python3-pip \
        python3-wheel \
        python3-cffi \
        zlib1g-dev \
        automake \
        autoconf \
        libtool \
        pkg-config \
        ca-certificates \
        gfortran \
    && rm -rf /var/lib/apt/lists/*

# Build Kaldi
RUN git clone -b vosk --single-branch https://github.com/Zenya4/alphacep-kaldi /opt/kaldi \
    && cd /opt/kaldi/tools \
    && sed -i 's:status=0:exit 0:g' extras/check_dependencies.sh \
    && sed -i 's:--enable-ngram-fsts:--enable-ngram-fsts --disable-bin:g' Makefile \
    && make -j $(nproc) openfst cub \
    && if [ "x$KALDI_MKL" != "x1" ] ; then \
          extras/install_openblas_clapack.sh; \
       else \
          extras/install_mkl.sh; \
       fi \
    \
    && cd /opt/kaldi/src \
    && if [ "x$KALDI_MKL" != "x1" ] ; then \
          ./configure --mathlib=OPENBLAS_CLAPACK --shared; \
       else \
          ./configure --mathlib=MKL --shared; \
       fi \
    && sed -i 's:-msse -msse2:-msse -msse2:g' kaldi.mk \
    && sed -i 's: -O1 : -O3 :g' kaldi.mk \
    && make -j $(nproc) online2 lm rnnlm

# Build Vosk API with phones support
RUN git clone https://github.com/Zenya4/CommonWealthRobotics-vosk-api /opt/vosk-api \
    && cd /opt/vosk-api/src \
    && KALDI_MKL=$KALDI_MKL KALDI_ROOT=/opt/kaldi make -j $(nproc) \
    && cd /opt/vosk-api/python \
    && python3 ./setup.py install

# Clone Vosk Server
RUN git clone https://github.com/Zenya4/alphacep-vosk-server /opt/vosk-server

# Cleanup
RUN rm -rf /opt/vosk-api/src/*.o \
    && rm -rf /opt/kaldi \
    && rm -rf /root/.cache \
    && rm -rf /var/lib/apt/lists/*
