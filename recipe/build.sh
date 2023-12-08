#!/usr/bin/env bash

set -ex

export CXX=$(basename ${CXX})

CXXFLAGS="${CXXFLAGS//-march=nocona}"
CXXFLAGS="${CXXFLAGS//-mtune=haswell}"
# needed for macOS see here: https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

ARCH_ARGS=""
IS_PYPY=$(${PYTHON} -c "import platform; print(int(platform.python_implementation() == 'PyPy'))")

if [[ $IS_PYPY == 1 ]]; then
    ARCH_ARGS="-DPython_INCLUDE_DIR=${PREFIX}/include/pypy${PY_VER} ${ARCH_ARGS}"
fi

# configure
cmake ${CMAKE_ARGS} ${ARCH_ARGS} \
  -S"${SRC_DIR}" \
  -Bbuild \
  -GNinja \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
  -DCMAKE_CXX_COMPILER:STRING="${CXX}" \
  -DCMAKE_FIND_FRAMEWORK:STRING=NEVER \
  -DCMAKE_FIND_APPBUNDLE:STRING=NEVER \
  -DPython_EXECUTABLE:STRING="${PYTHON}" \
  -DENABLE_ARCH_FLAGS:BOOL=OFF \

# build and install (testing is done later)
cmake --build build --parallel ${CPU_COUNT} --target install -- -v -d stats
