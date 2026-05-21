# SDS

SDS stands for "super duper standard library replacement". Yes, silly name.

This is not a replacement of C++ standard library.

But it does provide some classes that will feel familiar in functionality and interface.

It consists of:

 - fstream: near drop-in replacement of std::ifstream / ofstream
 - fstreamApk: for reading files from Android's APK, while being able to fallback to reading and writing normal files if requested
 - fstreamNsud: for reading/writing on iOS using NSUserDefaults storage as backend. Be aware of  NSUserDefaults storage capacity limitations though.
 - sds_algorithm: various useful functions

One can use typedefs or macros to switch between platforms eg.

```cpp
#ifdef __ANDROID__
	typedef fstreamApk DefaultFStream;
#elif defined( TARGET_OS_IPHONE ) && TARGET_OS_IPHONE
	typedef fstreamNsud DefaultFStream;
#else
	typedef fstream DefaultFStream;
#endif
```

# Why this exists?

It started as a couple of files that solved a few simple and common problems and grew up and started being used on multiple internal projects.

Eventually bugs started getting fixed so we had to centralize the repo.

And then we started using this functionality on external projects, which is why we're open sourcing it.

# How to integrate

## Raw integration

There are no fancy build settings.

Simply add `include` folder to your include directories and add all *.cpp and *.mm (iOS) files under the `src` folder.

You're done.

## CMake

We have a CMakeLists.txt script as an example.

Simply do:

`add_subdirectory( sds )`

and then:

`target_link_libraries( my_project sds_library )`

# License

Written by Matías N. Goldberg
Copyright (C) 2018-present Art of the State LLC

Under MIT License, see [LICENSE](LICENSE.md) for details