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
    ocl-icd-libopencl1 \
    xz-utils && \
  ln -s libOpenCL.so.1 /usr/lib/x86_64-linux-gnu/libOpenCL.so && \
  # Get all of the remaining dependencies for the OS, VNC, and Prusaslicer.
  apt-get update -y && \
  apt-get install -y --no-install-recommends lxterminal nano wget openssh-client rsync ca-certificates xdg-utils htop tar xzip gzip bzip2 zip unzip && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

RUN apt update && apt install -y --no-install-recommends --allow-unauthenticated \
        fonts-noto-core fonts-noto-hinted fonts-noto-ui-core libblosc1 \
        libboost-chrono1.74.0 libboost-filesystem1.74.0 libboost-iostreams1.74.0 \
        libboost-locale1.74.0 libboost-log1.74.0 libboost-regex1.74.0 \
        libboost-thread1.74.0 libglew2.2 libilmbase25 liblog4cplus-2.0.5 libnlopt0 *gtk3-0v5\
        libnotify4 libopenvdb8.1 libtbb2 libtbbmalloc2 libwxbase3.0-0v5 nautilus jq curl git \
    && add-apt-repository ppa:mozillateam/ppa \
    && apt update \
    && apt install firefox-esr -y \
    && apt autoclean -y \
    && apt autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Install Prusaslicer
# Many of the commands below were derived and pulled from previous work by dmagyar helfrichmichael on GitHub.
# Here's their Dockerfiles for reference https://github.com/dmagyar/prusaslicer-vnc-docker/blob/main/Dockerfile.amd64 & https://github.com/helfrichmichael/prusaslicer-novnc/blob/main/Dockerfile
WORKDIR /slic3r
ADD get_latest_prusaslicer_release.sh /slic3r

RUN chmod +x /slic3r/get_latest_prusaslicer_release.sh \
  && latestSlic3r=$(/slic3r/get_latest_prusaslicer_release.sh url) \
  && slic3rReleaseName=$(/slic3r/get_latest_prusaslicer_release.sh name) \
  && curl -sSL ${latestSlic3r} > ${slic3rReleaseName} \
  && rm -f /slic3r/releaseInfo.json \
  && mkdir -p /slic3r/slic3r-dist \
  && tar -xjf ${slic3rReleaseName} -C /slic3r/slic3r-dist --strip-components 1 \
  && rm -f /slic3r/${slic3rReleaseName} \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get autoclean \
  && mkdir -p /slic3r \
  && mkdir -p /home/kasm-user/.config/PrusaSlicer \
  && mkdir -p /prints \
  && ln -s /home/.config/PrusaSlicer /config/PrusaSlicer \
  && chown -R kasm-user:kasm-user /slic3r /prints /config /home/kasm-user/.config/PrusaSlicer
 

# Create the script and make it executable
RUN echo '#!/bin/bash' > /usr/local/bin/prusa-slicer && \
    echo '/slic3r/slic3r-dist/prusa-slicer --datadir /home/kasm-user/.config/PrusaSlicer/ "$@"' >> /usr/local/bin/prusa-slicer && \
    chmod +x /usr/local/bin/prusa-slicer

# add local files
RUN if [ -f /defaults/menu.xml ]; then rm -rf /defaults/menu.xml; fi
COPY /root /

# ports and volumes
EXPOSE 3000
VOLUME /config
VOLUME /prints
