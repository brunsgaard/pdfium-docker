FROM ubuntu:16.04

RUN apt-get -y update
RUN apt-get install -y build-essential libgtk2.0-dev
RUN apt-get install -y git

WORKDIR /
RUN git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
ENV PATH /depot_tools:"$PATH"

RUN gclient config --unmanaged https://pdfium.googlesource.com/pdfium.git; \
    gclient sync

WORKDIR pdfium
RUN sed -i.bkp '/static_library("pdfium")/a complete_static_lib=true' BUILD.gn
RUN gn gen out/codebuild --args='use_sysroot=false is_clang=false pdf_is_complete_lib=true pdf_is_standalone=true pdf_enable_v8=false pdf_enable_xfa=false pdf_bundle_freetype=true'
RUN ninja -j 4 -C out/codebuild all

WORKDIR /
CMD /bin/bash
