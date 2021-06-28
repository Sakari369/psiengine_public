PSITriangle 3D Engine
=====================

My custom built 3D engine. Supports macOS 10.13+.

Features:

- C++14 & Lua -scripting.
- Simple OpenGL 3.3+ renderer.
- Application logic can be written with C++ or Lua. Scripting with Lua preferred.
- Focus on simplicity and ease of use.
- Fast startup time & idea iteration.
- Geometry shader based line rendering for closed polygon shapes. This engine was originally designed to be used with very specifical recursive geometric shapes, which required fast line rendering methods.

Wrote this engine originally for the Geometrify VR project (https://geometrify.net) and to understand how 3D engines work. In it's current state this is a toy engine, but with the Lua scriptability you can already do some pretty advanced stuff with fast iteration times and ease of development.

NOTE: That said, I have not included the Geometry shader based line rendering code in this public release, as we are developing IP around this idea and have put a lot of work into iterating this implementation. For this public release, all other code is available though.

This is more of a toy engine, as I have no interest in trying to optimize the performance to match those of commercial or other game engines. Focus is on trying out 3D -ideas in as simple as possible way. I have an undestanding on how to make the engine perform better, but making this happen would mean having to implement a lot of state tracking optimizations, which are are a pain in the ass and not fun to implement :) For any serious use case, I would prefer to use Godot these days.

Motivation behind writing a 3D engine
=====================================

Wrote this engine to understand how 3D and 3D engines work and to target specifically rendering this kind of recursive geometry in an efficient way (click on image to open video): 

[![Geometry shader circle polylines](http://img.youtube.com/vi/SDGj6vSqS5Y/0.jpg)](http://www.youtube.com/watch?v=SDGj6vSqS5Y" "Geometry shader circle polylines")

Currently I use this engine to toy around, as the Lua scripting environment that I've setup for this project is very nice and performant to use, and it's nice to be more close to the metal when doing for example demo-coding or creating some cool effects.

The engine is pretty simple. Supports basic textured phong shaded models, mouse and keyboard input support, OpenGL 3.3+, shader loading, glTF -model loading and generating geometry meshes procedurally. Text rendering using Freetype-gl, video support through GLFW, optional audio playback with fmodx, custom logging framework and HSV color manipulation.

Based on a simple object based system, where application logic runs from Lua scripts. All rendered objects are placed inside a scene, and the scene is rendered. 

Main unique feature of this engine are the Poly classes which can render complex, recursive, closed polygonal formations in a fast way. Utilizes geometry shader support in OpenGL 3.3.

This engine was mostly written during 2014 - 2016, with some updates being worked afterwards. I've tried to update the code to match my current style preference with C++, but it is still a pretty naive implementation. My C++ skills have evolved a lot since building this, so this does not represent my current knowledge on this subject :) 

Releases using PSIEngine
========================

The only publicly released project made with this engine is an demoscene demo made for the Skrolli Party 2017.
Our demo placed first place in the compo, which I am happy about :) This demo showcases our fast procedural closed polygonal fractal rendering support.

![Skrollightenment screenshot](https://content.pouet.net/files/screenshots/00069/00069986.png)

You can download the demo for macOS here: http://www.pouet.net/prod.php?which=69986

We also had a Geometrify demo with Oculus Rift DK2 support pretty far, but ultimately we could not create this application without tooling back in 2015. You can see a video of how far we got with the DK2 demo here (click on image to open video):

[![Geometrify DK2 demo](http://img.youtube.com/vi/k7-zH0YaEBs/0.jpg)](http://www.youtube.com/watch?v=k7-zH0YaEBs "Geometrify DK2 demo")

Now we have OmniGeometry for creating the scenes (http://www.omnigeometry.com) and I have been since implementing the same idea utilizing Godot -game engine and now latest one with Unity, but still this vision has not been finished. Work continues :)


Directory Structure
===================

The project is structured into the following directories:

 - engine :: Main source code
	- core :: Main source for the core engine parts. Compiles as separate library.
	- src :: Application source code. Utilizes the PSICore library and defines the Lua -scripting interface.
 	- assets :: Assets like application scripts, music, scenes and graphics.
	- assets/scripts :: Lua -scripts for main program logic.
 	- assets/shaders :: OpenGL GLSL shaders.

 - testing : Test projects in mainly C++.

Software needed for building.
================================

PSIEngine uses the following open source libraries and software:

Needed to compile:

 - https://cmake.org/ :: CMake for building.
 - https://conan.io/ :: C++ package manager. Needed to build and install library dependencies.

Library dependencies installed via Conan:

 - https://glm.g-truc.net/0.9.9/index.html :: GLSL semantic compatible math lib. Vectors and matrixes etc
 - http://www.glfw.org/ :: Creating windows, handling input & other window events.
 - http://glew.sourceforge.net/ :: OpenGL Extension Wrapper. Makes it easy to use available OpenGL extensions.
 - https://www.freetype.org/ :: Freetype for text rendering support.

Provided prebuilt library for macOS x64:

 - https://github.com/rougier/freetype-gl :: Simple OpenGL implementation for Freetype.

You need to also have Lua installed and compiled with a C++ compiler:

 - https://www.lua.org/ :: Lua -programming language, for scripting application logic support.

Compiling & Running
===================

Clone the repository, run:

`git submodule update --init --recursive`

To pull in the psiengine core and required submodules.

Change to directory 'engine', and run:

```bash
mkdir build && cd build
conan install ../
cmake -G Ninja ../
ninja
```

(You can also use 'cmake -g "Unix Makefiles"' and make, if you dont have Ninja installed.)

Now you should have the engine binary under 'build/bin/psiengine'.
You can now run this from the build directory (script assets are loaded relative to the binary path currently):

```
bin/psiengine hypercube
```

This will start the engine and load the application logic from the provided 'engine/assets/scripts/hypercube.lua' script.

Screenshots
====================

![Hypercube screenshot](screenshots/hypercube.png?raw=true "PSIEngine :: hypercube")
![Polyzoomer screenshot](screenshots/polyzoomer.png?raw=true "PSIEngine :: polyzoomer")
![DNA Snake screenshot](screenshots/dna_snake.png?raw=true "PSIEngine :: dna_snake")
![Icosahedron ball](screenshots/icosahedron_ball.png?raw=true "PSIEngine :: icosahedron_ball")
![Pong game screenshot](screenshots/pong_game.png?raw=true "PSIEngine :: pong_game")

