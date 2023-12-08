BUILD_TYPE="Release"
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
  -S${SRC_DIR} \
  -Bbuild \
  -GNinja \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
  -DENABLE_ARCH_FLAGS=OFF \
  -DCMAKE_CXX_COMPILER=${CXX} \
  -DPYMOD_INSTALL_FULLDIR="${SP_DIR#$PREFIX/lib}"


# build and install (testing is done later)
cmake --build build --parallel ${CPU_COUNT} --target install -- -v -d stats
