# hhvm-build

_A shell script used to build the images at [HTL/hhvm](https://hub.docker.com/r/hersheltheodorelayton/hhvm-full)_


```SH
# How I built hhvm 26.2.0
./build.sh hhvm-2026-2 26 2 0 2>&1 | tee build_log.txt
docker image tag hhvm-2026-2-full:latest hersheltheodorelayton/hhvm-full:beta
docker image tag hhvm-2026-2-basic:latest hersheltheodorelayton/hhvm-basic:beta
docker push hersheltheodorelayton/hhvm-full:beta
docker push hersheltheodorelayton/hhvm-basic:beta
```
