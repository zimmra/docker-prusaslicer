# Work-In-Progress
## Use at Your Own Risk

Can be found at https://hub.docker.com/r/pzubuntu593/docker-freecad

Based off LSIO's implementation of KasmVNC w/ Blender

Large image, because currently the image has FreeCAD pre-installed via compiling from source.

The apt versions (default repo & PPA) were having issues for me, and they seem to no longer be maintained.

.AppImage and Flatpak versions did not like running in docker

## Docker Compose Example
```yaml
---
version: "2.1"
services:
  freecad:
    image: pzubuntu593/docker-freecad:latest
    container_name: FreeCAD
    privileged: true
    security_opt:
      - seccomp:unconfined #optional
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/New_York
      - TITLE=FreeCAD
    volumes:
      - /dockercfg/freecad:/config
    devices:
      - /dev/dri:/dev/dri 
    ports:
      - 3011:3000
    restart: unless-stopped
```

### To-Do
- Cleanup vestigial Blender stuff that has carried over (e.g. right clicking still brings up the option to launch Blender, even the the menu xml has been updated)
- Further test persistence - appears addons and settings survive container destruction/recreation but haven't done extensive testing
- See if Full-Screen can be set by default upon launch
