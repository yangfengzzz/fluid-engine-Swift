This project is inspired by [fluid-engine-dev](https://github.com/doyubkim/fluid-engine-dev) which can support bunch of numerical methods like Flip and SPH. This project transfer all C++ code from [fluid-engine-dev](https://github.com/doyubkim/fluid-engine-dev) by using Swift, which is a very elegent language. Swift is a young language which have less third-party code and I found nothing about numerical simulation at all. luckily Swift 5 is ABI stable and Grand Center Dispatch is functioning well which can replace TBB very well. 

GPGPU is the other reason to do this transferment. By using Swift,  this project can use Metal API by not writing the Objective-C bridge (which is the common way for graphics engines to use GPU in Apple ecosystem.) you can simplely change Renderer like:

```Swift
Renderer.arch = .GPU
```

GPU method will launch kernel to replace Grand Center Dispatch to accelerate the simualtion.

This project is still on the development which will add more render features like rayMarching and rasterization. My willingness is to use Metal to replace all Python visuallization code in [fluid-engine-dev](https://github.com/doyubkim/fluid-engine-dev) and display the simulation results on the screens simultaneously.

At last by not least, this project use the drawble object MTKView with SwiftUI. so It is easy to add button and text in GUI which can control the settings of the simualtion.