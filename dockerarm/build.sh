#!/bin/bash

TAG=latest
if [ ! -z "$1" ];then
	TAG=$1
fi

TMPDIR=openwrt_rootfs
OUTDIR=/root/dockerarm/
IMG_NAME=rainxi/openwrt-arm64

[ -d "$TMPDIR" ] && rm -rf "$TMPDIR"
sudo apt-get install pigz
mkdir -p "$TMPDIR"  && \
gzip -dc openwrt-armvirt-64-default-rootfs.tar.gz | ( cd "$TMPDIR" && tar xf - ) && \
cp -f patches/rc.local "$TMPDIR/etc/" && \
rm -f "$TMPDIR/etc/bench.log" && \
sss=$(date +%s) && \
ddd=$((sss/86400)) && \
sed -e "s/:0:0:99999:7:::/:${ddd}:0:99999:7:::/" -i "${TMPDIR}/etc/shadow" && \
rm -rf "$TMPDIR/lib/firmware/*" "$TMPDIR/lib/modules/*" && \
(cd "$TMPDIR" && tar cf ../openwrt-armvirt-64-default-rootfs-patched.tar .) && \
docker build -t ${IMG_NAME}:${TAG} . && \
rm -rf "$TMPDIR" && \
docker save ${IMG_NAME}:${TAG} | pigz -9 > docker-img-openwrt-armvirt-${TAG}.gz
