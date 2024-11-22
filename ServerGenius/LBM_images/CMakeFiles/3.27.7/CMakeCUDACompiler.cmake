set(CMAKE_CUDA_COMPILER "/soft/compilers/cudatoolkit/cuda-12.2.2/bin/nvcc")
set(CMAKE_CUDA_HOST_COMPILER "/opt/cray/pe/craype/2.7.30/bin/CC")
set(CMAKE_CUDA_HOST_LINK_LAUNCHER "/opt/cray/pe/craype/2.7.30/bin/CC")
set(CMAKE_CUDA_COMPILER_ID "NVIDIA")
set(CMAKE_CUDA_COMPILER_VERSION "12.2.140")
set(CMAKE_CUDA_DEVICE_LINKER "/soft/compilers/cudatoolkit/cuda-12.2.2/bin/nvlink")
set(CMAKE_CUDA_FATBINARY "/soft/compilers/cudatoolkit/cuda-12.2.2/bin/fatbinary")
set(CMAKE_CUDA_STANDARD_COMPUTED_DEFAULT "17")
set(CMAKE_CUDA_EXTENSIONS_COMPUTED_DEFAULT "ON")
set(CMAKE_CUDA_COMPILE_FEATURES "cuda_std_03;cuda_std_11;cuda_std_14;cuda_std_17;cuda_std_20")
set(CMAKE_CUDA03_COMPILE_FEATURES "cuda_std_03")
set(CMAKE_CUDA11_COMPILE_FEATURES "cuda_std_11")
set(CMAKE_CUDA14_COMPILE_FEATURES "cuda_std_14")
set(CMAKE_CUDA17_COMPILE_FEATURES "cuda_std_17")
set(CMAKE_CUDA20_COMPILE_FEATURES "cuda_std_20")
set(CMAKE_CUDA23_COMPILE_FEATURES "")

set(CMAKE_CUDA_PLATFORM_ID "Linux")
set(CMAKE_CUDA_SIMULATE_ID "GNU")
set(CMAKE_CUDA_COMPILER_FRONTEND_VARIANT "")
set(CMAKE_CUDA_SIMULATE_VERSION "12.3")



set(CMAKE_CUDA_COMPILER_ENV_VAR "CUDACXX")
set(CMAKE_CUDA_HOST_COMPILER_ENV_VAR "CUDAHOSTCXX")

set(CMAKE_CUDA_COMPILER_LOADED 1)
set(CMAKE_CUDA_COMPILER_ID_RUN 1)
set(CMAKE_CUDA_SOURCE_FILE_EXTENSIONS cu)
set(CMAKE_CUDA_LINKER_PREFERENCE 15)
set(CMAKE_CUDA_LINKER_PREFERENCE_PROPAGATES 1)
set(CMAKE_CUDA_LINKER_DEPFILE_SUPPORTED )

set(CMAKE_CUDA_SIZEOF_DATA_PTR "8")
set(CMAKE_CUDA_COMPILER_ABI "ELF")
set(CMAKE_CUDA_BYTE_ORDER "LITTLE_ENDIAN")
set(CMAKE_CUDA_LIBRARY_ARCHITECTURE "")

if(CMAKE_CUDA_SIZEOF_DATA_PTR)
  set(CMAKE_SIZEOF_VOID_P "${CMAKE_CUDA_SIZEOF_DATA_PTR}")
endif()

if(CMAKE_CUDA_COMPILER_ABI)
  set(CMAKE_INTERNAL_PLATFORM_ABI "${CMAKE_CUDA_COMPILER_ABI}")
endif()

if(CMAKE_CUDA_LIBRARY_ARCHITECTURE)
  set(CMAKE_LIBRARY_ARCHITECTURE "")
endif()

set(CMAKE_CUDA_COMPILER_TOOLKIT_ROOT "/soft/compilers/cudatoolkit/cuda-12.2.2")
set(CMAKE_CUDA_COMPILER_TOOLKIT_LIBRARY_ROOT "/soft/compilers/cudatoolkit/cuda-12.2.2")
set(CMAKE_CUDA_COMPILER_TOOLKIT_VERSION "12.2.140")
set(CMAKE_CUDA_COMPILER_LIBRARY_ROOT "/soft/compilers/cudatoolkit/cuda-12.2.2")

set(CMAKE_CUDA_ARCHITECTURES_ALL "50-real;52-real;53-real;60-real;61-real;62-real;70-real;72-real;75-real;80-real;86-real;87-real;89-real;90")
set(CMAKE_CUDA_ARCHITECTURES_ALL_MAJOR "50-real;60-real;70-real;80-real;90")
set(CMAKE_CUDA_ARCHITECTURES_NATIVE "80-real")

set(CMAKE_CUDA_TOOLKIT_INCLUDE_DIRECTORIES "/soft/compilers/cudatoolkit/cuda-12.2.2/targets/x86_64-linux/include")

set(CMAKE_CUDA_HOST_IMPLICIT_LINK_LIBRARIES "")
set(CMAKE_CUDA_HOST_IMPLICIT_LINK_DIRECTORIES "/soft/compilers/cudatoolkit/cuda-12.2.2/targets/x86_64-linux/lib/stubs;/soft/compilers/cudatoolkit/cuda-12.2.2/targets/x86_64-linux/lib")
set(CMAKE_CUDA_HOST_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES "")

set(CMAKE_CUDA_IMPLICIT_INCLUDE_DIRECTORIES "/opt/cray/pe/mpich/8.1.28/ofi/gnu/12.3/include;/opt/cray/pals/1.3.4/include;/opt/cray/pe/pmi/6.1.13/include;/opt/cray/pe/dsmml/0.2.2/dsmml/include;/soft/spack/base/0.7.1/install/linux-sles15-x86_64/gcc-12.3.0/curl-8.4.0-2ztev25qvydhabvu4nbkrtn4opcvw5nl/include;/soft/spack/base/0.7.1/install/linux-sles15-x86_64/gcc-12.3.0/nghttp2-1.57.0-ciat5hufbwpozo6vmqgxanucn2zwu6z4/include;/usr/include/c++/12;/usr/include/c++/12/x86_64-suse-linux;/usr/include/c++/12/backward;/usr/lib64/gcc/x86_64-suse-linux/12/include;/usr/local/include;/usr/lib64/gcc/x86_64-suse-linux/12/include-fixed;/usr/x86_64-suse-linux/include;/usr/include")
set(CMAKE_CUDA_IMPLICIT_LINK_LIBRARIES "darshan;z;pals;pmi;pmi2;mpi_gnu_123;dsmml;gfortran;quadmath;mvec;m;stdc++;m;gcc_s;gcc;c;gcc_s;gcc")
set(CMAKE_CUDA_IMPLICIT_LINK_DIRECTORIES "/soft/compilers/cudatoolkit/cuda-12.2.2/targets/x86_64-linux/lib/stubs;/soft/compilers/cudatoolkit/cuda-12.2.2/targets/x86_64-linux/lib;/opt/cray/pe/mpich/8.1.28/ofi/gnu/12.3/lib;/opt/cray/pals/1.3.4/lib;/opt/cray/pe/pmi/6.1.13/lib;/opt/cray/pe/dsmml/0.2.2/dsmml/lib;/soft/perftools/darshan/darshan-3.4.4/lib;/usr/lib64/gcc/x86_64-suse-linux/12;/usr/lib64;/lib64;/soft/spack/base/0.7.1/install/linux-sles15-x86_64/gcc-12.3.0/curl-8.4.0-2ztev25qvydhabvu4nbkrtn4opcvw5nl/lib;/soft/spack/base/0.7.1/install/linux-sles15-x86_64/gcc-12.3.0/nghttp2-1.57.0-ciat5hufbwpozo6vmqgxanucn2zwu6z4/lib;/usr/x86_64-suse-linux/lib")
set(CMAKE_CUDA_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES "")

set(CMAKE_CUDA_RUNTIME_LIBRARY_DEFAULT "STATIC")

set(CMAKE_LINKER "/soft/xalt/3.0.2-202408282050/bin/ld")
set(CMAKE_AR "/usr/bin/ar")
set(CMAKE_MT "")
