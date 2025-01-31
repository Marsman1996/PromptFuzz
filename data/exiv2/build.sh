#!/bin/bash

source ../common.sh

PROJECT_NAME=exiv2
STALIB_NAME=libexiv2.a
DYNLIB_NAME=libexiv2.so
DIR=$(pwd)
set -Eeo pipefail
set -x

function download() {
    apt-get update &&
        # apt-get -y upgrade &&
        apt-get -y install libinih-dev libfmt-dev

    cd $SRC
    cp -r /prompt_fuzz/data/exiv2/exiv2 ./
    # git clone https://github.com/miniupnp/ngiflib.git
    # cd ngiflib
    # git checkout db19270de491210b18f14a7b9a1f637743f523ed
    # cp tiff.dict ${PROJECT_NAME}/tiff.dict

}

function build_lib() {
    LIB_STORE_DIR=$WORK/lib
    rm -rf $LIB_STORE_DIR
    
    rm -rf $WORK/build
    mkdir -p $WORK/build
    cd $WORK/build

    # build dynamic
    cmake $SRC/exiv2 -DCMAKE_INSTALL_PREFIX=$WORK -DBUILD_SHARED_LIBS=ON -DEXIV2_ENABLE_BROTLI=OFF
    make -j4 && make install
    # build static
    rm -rf ./*
    cmake $SRC/exiv2 -DCMAKE_INSTALL_PREFIX=$WORK -DBUILD_SHARED_LIBS=OFF -DEXIV2_ENABLE_BROTLI=OFF
    make -j4 && make install
}

function build_oss_fuzz() {
    echo "No OSS Fuzz Driver here"
    $CXX $CXXFLAGS -I$WORK/include \
        $SRC/exiv2/fuzz/fuzz-read-print-write.cpp -o $OUT/fuzz-read-print-write \
        $LIB_FUZZING_ENGINE $WORK/lib/libexiv2.a -lfmt -lexpat -lz -lINIReader
    # if [ "$ARCHITECTURE" = "i386" ]; then
    #     $CXX $CXXFLAGS -std=c++11 -I$WORK/include \
    #         $SRC/libtiff/contrib/oss-fuzz/tiff_read_rgba_fuzzer.cc -o $OUT/tiff_read_rgba_fuzzer \
    #         $LIB_FUZZING_ENGINE $WORK/lib/libtiffxx.a $WORK/lib/libtiff.a -lz
    # else
    #     $CXX $CXXFLAGS -std=c++11 -I$WORK/include \
    #         $SRC/libtiff/contrib/oss-fuzz/tiff_read_rgba_fuzzer.cc -o $OUT/tiff_read_rgba_fuzzer \
    #         $LIB_FUZZING_ENGINE $WORK/lib/libtiffxx.a $WORK/lib/libtiff.a -lz -llzma #-Wl,-Bstatic -llzma -Wl,-Bdynamic
    # fi
}

function copy_include() {
    mkdir -p ${LIB_BUILD}/include
    cp $WORK/include/exiv2/* ${LIB_BUILD}/include/
}

function build_corpus() {
    pwd
    # cd $SRC
    # wget https://lcamtuf.coredump.cx/afl/demo/afl_testcases.tgz
    # mkdir afl_testcases
    # (cd afl_testcases; tar xf "$SRC/afl_testcases.tgz")
    # mkdir tif
    # find afl_testcases -type f -name '*.tif' -exec mv -n {} tif/ \;
    # mv tif ${LIB_BUILD}/corpus
}

function build_dict() {
    pwd
    # cp $SRC/$PROJECT_NAME/tiff.dict $LIB_BUILD/fuzzer.dict
}

build_all
# rm $WORK/lib/libtiffxx.so