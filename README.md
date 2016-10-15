# NanoGUI Test

Shader source:
http://glslsandbox.com/e#35192.0

Includes CMake build, but before you can do that you will need
to download the dependencies using git submodule...

    git submodule update --init --recursive

Simple example looks like this:
http://glslsandbox.com/e#35192.0

![Screenshot](https://raw.githubusercontent.com/wtfbbqhax/shadertoy/master/screenshot.png "Screenshot")

Uses [NanoGUI](https://github.com/wjakob/nanogui), [GLFW](http://www.glfw.org/),
[Eigen](http://eigen.tuxfamily.org/), [Embed Resource](https://github.com/cyrilcode/embed-resource),
and raymarching template from [Raymarching.com](http://raymarching.com/).

Thanks to darenmothersele for his nanogui-test repo which is what I started with.
