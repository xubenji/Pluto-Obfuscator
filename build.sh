mkdir -p build
cd build

cmake -G "Ninja" -DLLVM_ENABLE_PROJECTS="clang" \
    -DCMAKE_BUILD_TYPE=Release -DLLVM_TARGETS_TO_BUILD="X86" \
    -DBUILD_SHARED_LIBS=On -DCMAKE_INSTALL_PREFIX="../install" ../llvm

ninja -j$(nproc)
ninja install
