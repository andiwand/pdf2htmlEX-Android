# File include from two places:
# Main CMakeLists.txt
# library builder 3rdparty/CMakeLists.txt

# @TODO: move THIRDPARTY_PREFIX and others to separate file, so Toolchain.cmake could be only for 3rdparty builder
if (ANDROID)
  SET(THIRDPARTY_PREFIX ${CMAKE_CURRENT_LIST_DIR}/built/${CMAKE_BUILD_TYPE}-${ANDROID_ABI})

  SET(THIRDPARTY_PKG_CONFIG_LIBDIR ${THIRDPARTY_PREFIX}/lib/pkgconfig)
  SET(THIRDPARTY_PKG_CONFIG_EXECUTABLE ${THIRDPARTY_PREFIX}/bin/pkg-config)

  SET(PKG_CONFIG_EXECUTABLE ${THIRDPARTY_PKG_CONFIG_EXECUTABLE})
  SET(CMAKE_FIND_ROOT_PATH ${THIRDPARTY_PREFIX} ${CMAKE_FIND_ROOT_PATH})

  # /home/vilius/ndk/19.2.5345600/toolchains/llvm/prebuilt/linux-x86_64
  # @TODO: there should be a var from NDK to get this
  SET(TOOLCHAIN ${ANDROID_NDK}/toolchains/llvm/prebuilt/${ANDROID_NDK_HOST_SYSTEM_NAME})

  # -g -DANDROID -fdata-sections -ffunction-sections -funwind-tables -fstack-protector-strong -no-canonical-prefixes -fno-addrsig -Wa,--noexecstack -Wformat -Werror=format-security 
  SET(CFLAGS ${CMAKE_C_FLAGS})
  # -g -DANDROID -fdata-sections -ffunction-sections -funwind-tables -fstack-protector-strong -no-canonical-prefixes -fno-addrsig -Wa,--noexecstack -Wformat -Werror=format-security -stdlib=libc++ 
  SET(CXXFLAGS ${CMAKE_CXX_FLAGS})
  # -Wl,--exclude-libs,libgcc.a -Wl,--exclude-libs,libatomic.a -static-libstdc++ -Wl,--build-id -Wl,--warn-shared-textrel -Wl,--fatal-warnings -Wl,--no-undefined -Qunused-arguments -Wl,-z,noexecstack -Wl,-z,relro -Wl,-z,now
  SET(LDFLAGS ${ANDROID_LINKER_FLAGS})

  if (CMAKE_BUILD_TYPE STREQUAL Debug)
    # -O0 -fno-limit-debug-info
    LIST(APPEND CFLAGS ${CMAKE_C_FLAGS_DEBUG})
    # string(JOIN "" CFLAGS ${CFLAGS} ${CMAKE_C_FLAGS_DEBUG})
    # -O0 -fno-limit-debug-info 
    # string(JOIN "" CXXFLAGS ${CXXFLAGS} ${CMAKE_CXX_FLAGS_DEBUG})
    LIST(APPEND CXXFLAGS ${CMAKE_CXX_FLAGS_DEBUG})
  elseif(CMAKE_BUILD_TYPE STREQUAL Release)
    # -O2 -DNDEBUG
    # string(JOIN "" CFLAGS ${CFLAGS} ${CMAKE_C_FLAGS_RELEASE})
    LIST(APPEND CFLAGS ${CMAKE_C_FLAGS_RELEASE})
    # -O2 -DNDEBUG 
    # string(JOIN "" CXXFLAGS ${CXXFLAGS} ${CMAKE_CXX_FLAGS_RELEASE})
    LIST(APPEND CXXFLAGS ${CMAKE_CXX_FLAGS_RELEASE})
  elseif(CMAKE_BUILD_TYPE STREQUAL RelWithDebInfo)
    # -O2 -g -DNDEBUG
    # string(JOIN "" CXXFLAGS ${CXXFLAGS} ${CMAKE_CXX_FLAGS_RELWITHDEBINFO})
    LIST(APPEND CXXFLAGS ${CMAKE_CXX_FLAGS_RELWITHDEBINFO})
  elseif(CMAKE_BUILD_TYPE STREQUAL MinSizeRel)
    # -Os -DNDEBUG
    # string(JOIN "" CXXFLAGS ${CXXFLAGS} ${CMAKE_CXX_FLAGS_MINSIZEREL})
    LIST(APPEND CXXFLAGS ${CMAKE_CXX_FLAGS_MINSIZEREL})
  endif()

  LIST(APPEND CFLAGS " -I${THIRDPARTY_PREFIX}/include")
  LIST(APPEND CXXFLAGS " -I${THIRDPARTY_PREFIX}/include")
  LIST(APPEND LDFLAGS " -L${THIRDPARTY_PREFIX}/lib")

  string(JOIN "" CFLAGS ${CFLAGS})
  string(JOIN "" CXXFLAGS ${CXXFLAGS})
  string(JOIN "" LDFLAGS ${LDFLAGS})

  set(TOOLCHAIN_ENV
    TOOLCHAIN=${TOOLCHAIN}
    # /home/vilius/ndk/19.2.5345600/toolchains/llvm/prebuilt/linux-x86_64/bin/x86_64-linux-android-ar
    AR=${ANDROID_AR}
    # /home/vilius/ndk/19.2.5345600/toolchains/llvm/prebuilt/linux-x86_64/bin/x86_64-linux-android-as
    AS=${TOOLCHAIN}/bin/${CMAKE_LIBRARY_ARCHITECTURE}-as

    # /home/vilius/ndk/19.2.5345600/toolchains/llvm/prebuilt/linux-x86_64/bin/x86_64-linux-android28-clang
    CC=${TOOLCHAIN}/bin/${CMAKE_LIBRARY_ARCHITECTURE}${ANDROID_NATIVE_API_LEVEL}-clang
    CFLAGS=${CFLAGS}

    # /home/vilius/ndk/19.2.5345600/toolchains/llvm/prebuilt/linux-x86_64/bin/x86_64-linux-android28-clang++
    CXX=${TOOLCHAIN}/bin/${CMAKE_LIBRARY_ARCHITECTURE}${ANDROID_NATIVE_API_LEVEL}-clang++
    CXXFLAGS=${CXXFLAGS}
    CPPFLAGS=${CXXFLAGS}

    # /home/vilius/ndk/19.2.5345600/toolchains/llvm/prebuilt/linux-x86_64/bin/x86_64-linux-android-ld
    LD=${CMAKE_LINKER}
    LDFLAGS=${LDFLAGS}

    # /home/vilius/ndk/19.2.5345600/toolchains/llvm/prebuilt/linux-x86_64/bin/x86_64-linux-android-nm
    NM=${CMAKE_NM}
    # /home/vilius/ndk/19.2.5345600/toolchains/llvm/prebuilt/linux-x86_64/bin/x86_64-linux-android-objdump
    OBJDUMP=${CMAKE_OBJDUMP}
    # /home/vilius/ndk/19.2.5345600/toolchains/llvm/prebuilt/linux-x86_64/bin/x86_64-linux-android-ranlib
    RANLIB=${ANDROID_RANLIB}
    # /home/vilius/ndk/19.2.5345600/toolchains/llvm/prebuilt/linux-x86_64/bin/x86_64-linux-android-strip
    STRIP=${CMAKE_STRIP}
    # /home/vilius/ndk/19.2.5345600/toolchains/llvm/prebuilt/linux-x86_64/sysroot
    SYSROOT=${CMAKE_SYSROOT}

    PKG_CONFIG=${THIRDPARTY_PKG_CONFIG_EXECUTABLE}
    PKG_CONFIG_LIBDIR=${THIRDPARTY_PKG_CONFIG_LIBDIR}
  )

  SET(MESON_CC ${TOOLCHAIN}/bin/${CMAKE_LIBRARY_ARCHITECTURE}${ANDROID_NATIVE_API_LEVEL}-clang)
  SET(MESON_CPP ${TOOLCHAIN}/bin/${CMAKE_LIBRARY_ARCHITECTURE}${ANDROID_NATIVE_API_LEVEL}-clang++)
  SET(MESON_AR ${ANDROID_AR})
endif(ANDROID)

if (BUILD_SHARED_LIBS)
  configure_file(${CMAKE_CURRENT_LIST_DIR}/pkg-config.in ${THIRDPARTY_PKG_CONFIG_EXECUTABLE} @ONLY)
else (BUILD_SHARED_LIBS)
  configure_file(${CMAKE_CURRENT_LIST_DIR}/pkg-config-static.in ${THIRDPARTY_PKG_CONFIG_EXECUTABLE} @ONLY)
endif (BUILD_SHARED_LIBS)

# Provide a meson cross compile file
SET(MESON_CROSS_COMPILE_FILE ${THIRDPARTY_PREFIX}/meson_cross_file.txt)
configure_file(${CMAKE_CURRENT_LIST_DIR}/meson_cross_file.txt.in ${MESON_CROSS_COMPILE_FILE} @ONLY)