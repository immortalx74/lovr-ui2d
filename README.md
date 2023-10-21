# lovr-ui2d

### An immediate mode GUI library for [LÖVR](https://lovr.org/)
This is the sister project of [lovr-ui](https://github.com/immortalx74/lovr-ui) (a VR GUI library).
It borrows concepts from the outstanding [Dear ImGui](https://github.com/ocornut/imgui) library and is inspired by [microui](https://github.com/rxi/microui), trying to be simple and minimal.

https://github.com/immortalx74/lovr-ui2d/assets/29693328/3b1e15cc-948f-401f-a236-ee63c44e07ea

**How to use:**
 - Put the ui2d folder inside your project and require it: `UI2D = require "ui2d..ui2d"`
 - Initialize the library by calling `UI2D.Init()` on `lovr.load()`
 - Call `UI.InputInfo()` on `lovr.update()`
 - Everything inside `UI2D.NewFrame()`/`UI2D.RenderFrame()` is your GUI
 - `UI2D.RenderFrame()` returns a table of passes. Insert the main pass from `lovr.draw()` in that table and submit to LOVR.

**Widgets:**

 - Button
 - ImageButton
 - TextBox
 - ListBox
 - SliderInt
 - SliderFloat
 - Label
 - CheckBox
 - RadioButton
 - TabBar
 - Dummy
 - ProgressBar
 - CustomWidget
 - Modal window
 - Separator

**API:(WIP)**
