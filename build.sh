#!/bin/bash
# (c) 2015, 2016, Leo Xu <otakunekop@banana-pi.org.cn>
# Build script for BPI-M2U-BSP 2016.09.10

TARGET_PRODUCT="bpi-w2"
ALL_SOC="bpi-w2"
BOARD=BPI-W2-720P
board="bpi-w2"
kernel="4.9.119-BPI-W2-Kernel"
headers="linux-headers-4.9.119-BPI-W2-Kernel"
MODE=$1
BPILINUX=linux-rtk
BPISOC=rtk
RET=0

cp_download_files()
{
T="$TOPDIR"
SD="$T/SD/$board"
U="${SD}/100MB"
B="${SD}/BPI-BOOT"
R="${SD}/BPI-ROOT"
	#
	## clean SD dir.
	#
	rm -rf $SD
	#
	## create SD dirs (100MB, BPI-BOOT, BPI-ROOT) 
	#
	mkdir -p $SD
	mkdir -p $U
	mkdir -p $B
	mkdir -p $R
	#
	## copy files to 100MB
	#
	cp -a /tmp/${board}/*.img.gz $U
	#
	## copy files to BPI-BOOT
	#
	mkdir -p $B/bananapi/${board}
	cp -a $T/${BPILINUX}/arch/arm64/boot/Image $B/bananapi/${board}/linux/uImage
	cp -a $T/${BPILINUX}/arch/arm64/boot/dts/realtek/rtd129x/rtd-1296-bananapi-w2-2GB.dtb $B/bananapi/${board}/linux/

	#
	## modules
	rm -rf $R/lib/modules
	mkdir -p $R/lib/modules
	cp -a $T/${BPILINUX}/output/lib/modules/${kernel} $R/lib/modules
	#
	## headers
	rm -rf $R/usr/src
	mkdir -p $R/usr/src
	cp -a $T/${BPILINUX}/output/usr/src/${headers} $R/usr/src/
	#
	## create files for bpi-tools & bpi-migrate
	#
	(cd $B ; tar czvf $SD/BPI-BOOT-${board}.tgz .)
	#(cd $R ; tar czvf $SD/${kernel}-net.tgz lib/modules/${kernel}/kernel/net)
	#(cd $R ; mv lib/modules/${kernel}/kernel/net $R/net)
	(cd $R ; tar czvf $SD/${kernel}.tgz lib/modules)
	#(cd $R ; mv $R/net lib/modules/${kernel}/kernel/net)
	(cd $R ; tar czvf $SD/${headers}.tgz usr/src/${headers})

	return #SKIP
}

./configure $BOARD

if [ -f env.sh ] ; then
	. env.sh
fi

echo "This tool support following building mode(s):"
echo "--------------------------------------------------------------------------------"
echo "	1. Build all, kernel and pack to download images."
echo "	2. Build kernel only."
echo "	3. kernel configure."
echo "	4. Create bsp update packages for BPI SD Images"
echo "	5. Update local build to SD with BPI Image flashed"
echo "	6. Clean all build."
echo "--------------------------------------------------------------------------------"

if [ -z "$MODE" ]; then
	read -p "Please choose a mode(1-6): " mode
	echo
else
	mode=$MODE
fi

if [ -z "$mode" ]; then
        echo -e "\033[31m No build mode choose, using Build all default   \033[0m"
        mode=1
fi

echo -e "\033[31m Now building...\033[0m"
echo
case $mode in
	1) RET=1;make && 
	   cp_download_files &&
	   RET=0
	   ;;
	2) make kernel;;
	3) make kernel-config;;
	4) cp_download_files;;
	5) make install;;
	6) make clean;;
esac
echo

if [ "$RET" -eq "0" ];
then
  echo -e "\033[32m Build success!\033[0m"
else
  echo -e "\033[31m Build failed!\033[0m"
fi
echo
