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
        lxde gtk2-engines-murrine gosu gnome-themes-standard gtk2-engines-pixbuf gtk2-engines-murrine arc-theme \
        freeglut3 libgtk2.0-dev libwxgtk3.0-gtk3-dev libwx-perl libxmu-dev libgl1-mesa-glx libgl1-mesa-dri  \
        xdg-utils locales locales-all pcmanfm jq curl git \
    && add-apt-repository ppa:mozillateam/ppa \
    && apt update \
    && apt install firefox-esr -y \
    && apt autoclean -y \
    && apt autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Install Prusaslicer
# Many of the commands below were derived and pulled from previous work by dmagyar on GitHub.
# Here's their Dockerfile for reference https://github.com/dmagyar/prusaslicer-vnc-docker/blob/main/Dockerfile.amd64
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
  && groupadd slic3r \
  && useradd -g slic3r --create-home --home-dir /home/slic3r slic3r \
  && mkdir -p /slic3r \
  && mkdir -p /config \
  && mkdir -p /prints/ \
  && chown -R slic3r:slic3r /slic3r/ /home/slic3r/ /prints/ /config/ \
  && locale-gen en_US \
  && mkdir /config/.local \
  && mkdir -p /config/.config/ \
  && ln -s /config/.config/ /home/slic3r/ \
  && mkdir -p /home/slic3r/.config/ \
  # We can now set the Download directory for Firefox and other browsers. 
  # We can also add /prints/ to the file explorer bookmarks for easy access.
  && echo "XDG_DOWNLOAD_DIR=\"/prints/\"" >> /home/slic3r/.config/user-dirs.dirs \
  && echo "file:///prints prints" >> /home/slic3r/.gtk-bookmarks 

# Create the script and make it executable
RUN echo '#!/bin/bash' > /usr/local/bin/prusa-slicer && \
    echo 'sudo -u slic3r /slic3r/slic3r-dist/prusa-slicer --datadir /config/.config/PrusaSlicer/ "$@"' >> /usr/local/bin/prusa-slicer && \
    chmod +x /usr/local/bin/prusa-slicer

# add local files
RUN if [ -f /defaults/menu.xml ]; then rm -rf /defaults/menu.xml; fi
COPY /root /

# ports and volumes
EXPOSE 3000
VOLUME /config
VOLUME /prints
