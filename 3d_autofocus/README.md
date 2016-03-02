# 3D Autofocus

## Build

```shell
mex GCC="/usr/sup/gcc-4.7.4/bin/gcc" CXXFLAGS="-std=c++11 -O2 -fPIC" grad_h_mex.cpp grad_h.cpp
```

NOTE: Remove `GCC` if compiling on OS X.

To build the driver program, simple run `make`.