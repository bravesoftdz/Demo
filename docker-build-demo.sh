#!/bin/bash
set -x

# INCLUDES=-Fi/root/ultibo/core/fpc/source/packages/fv/src

function build {
    echo ......................... building $1
    rm -f *.bin *.elf *.img *.o *.ppu
    set -x
    docker run --rm -v $(pwd):/workdir markfirmware/ufpc \
     -B \
     -Tultibo \
     -O2 \
     -Parm \
     $2 \
     $INCLUDES \
     @/root/ultibo/core/fpc/bin/$3 \
     $1
    EXIT_STATUS=$?
    set +x
    if [ "$EXIT_STATUS" != 0 ]
    then
        exit 1
    fi
}

function build-QEMU {
    build $1 "-CpARMV7A -WpQEMUVPB" qemuvpb.cfg
}

function build-RPi {
    build $1 "-CpARMV6 -WpRPIB" rpi.cfg
}

function build-RPi2 {
    build $1 "-CpARMV7A -WpRPI2B" rpi2.cfg
}

function build-RPi3 {
    build $1 "-CpARMV7A -WpRPI3B" rpi3.cfg
}

function demo {
    TARGET=$2
    build-$TARGET "$1.lpr"
    mkdir -p $CIRCLE_ARTIFACTS/Demo/$TARGET
    cp -a kernel* $CIRCLE_ARTIFACTS/Demo/$TARGET
}

demo UltiboDemoRPi RPi
demo UltiboDemoRPi2 RPi2
demo UltiboDemoRPi3 RPi3
