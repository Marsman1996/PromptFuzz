#!/bin/bash

source ../common.sh

PROJECT_NAME=ngiflib
STALIB_NAME=libngiflib.a
DYNLIB_NAME=libngiflib.so
DIR=$(pwd)
set -Eeo pipefail
set -x

function download() {
    apt-get update &&
        # apt-get -y upgrade &&
        apt-get -y install libsdl1.2-dev

    cp -r ./ngiflib $SRC/
    cd $SRC
    cp -r /prompt_fuzz/data/ngiflib/ngiflib ./
    # git clone https://github.com/miniupnp/ngiflib.git
    # cd ngiflib
    # git checkout db19270de491210b18f14a7b9a1f637743f523ed
    # cp tiff.dict ${PROJECT_NAME}/tiff.dict

}

function build_lib() {
    INSTALL_DIR=$WORK

    cd $SRC/${PROJECT_NAME}
    LIB_STORE_DIR=$WORK/lib
    rm -rf $LIB_STORE_DIR

    sed -i 's/^LDFLAGS=\$(shell pkg-config sdl --libs-only-L)$/LDFLAGS+=\$(shell pkg-config sdl --libs-only-L)/' Makefile
    
    # ./autogen.sh
    # ./configure --prefix=$WORK --enable-shared=yes --enable-static=yes 

    make clean
    make
    ar cru libngiflib.a ngiflib.o ngiflibSDL.o
    clang -shared -o libngiflib.so ngiflib.o ngiflibSDL.o
    mkdir -p $WORK/bin $WORK/lib $WORK/include
    cp gif2tga SDLaffgif $WORK/bin
    cp *.h $WORK/include
    cp libngiflib.a $WORK/lib
    cp libngiflib.so $WORK/lib
}

function build_oss_fuzz() {
    echo "No OSS Fuzz Driver here"
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
    cp $WORK/include/ngiflib.h ${LIB_BUILD}/include/
    cp $WORK/include/ngiflibSDL.h ${LIB_BUILD}/include/
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