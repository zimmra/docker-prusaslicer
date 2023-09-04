# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-kasmvnc:ubuntujammy

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# app title
ENV TITLE=PrusaSlicer

# Add FreeCAD PPA
RUN apt-get update && \
    apt-get install -y software-properties-common

RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install -y \
    git \
    build-essential \
    autoconf \
    cmake \
    libglu1-mesa-dev \
    libgtk-3-dev \
    libdbus-1-dev \
    ocl-icd-libopencl1 \
    xz-utils && \
  ln -s libOpenCL.so.1 /usr/lib/x86_64-linux-gnu/libOpenCL.so && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*
    
# Clone PrusaSlicer source
RUN git clone https://www.github.com/prusa3d/PrusaSlicer && cd PrusaSlicer && git checkout version_2.6.1-rc2


RUN ls -la

# # Build dependencies
# RUN cd deps && \
#     mkdir build && \
#     cd build && \
#     cmake .. -DDEP_WX_GTK3=ON && \
#     make && \
#     cd ../..

# # Create a build directory and compile PrusaSlicer 
# RUN mkdir build && \
#     cd build && \
#     cmake .. -DSLIC3R_STATIC=1 -DSLIC3R_GTK=3 -DSLIC3R_PCH=OFF -DCMAKE_PREFIX_PATH=$(pwd)/../deps/build/destdir/usr/local && \
#     make -j4

# # Create a symbolic link to invoke FreeCAD with 'freecad'
# RUN ln -s src/prusa-slicer /usr/local/bin/prusa-slicer && \
#     rm -rf \
#       /tmp/* \
#       /var/lib/apt/lists/* \
#       /var/tmp/*

# # add local files
# COPY /root /

# # ports and volumes
# EXPOSE 3000

# VOLUME /config
