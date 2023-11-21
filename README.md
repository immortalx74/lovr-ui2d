# lovr-ui2d

### An immediate mode GUI library for the [LÖVR](https://lovr.org/) and [LÖVE](https://love2d.org/) frameworks.
This is the sister project of [lovr-ui](https://github.com/immortalx74/lovr-ui) (a VR GUI library for lovr).
Both projects borrow concepts from the outstanding [Dear ImGui](https://github.com/ocornut/imgui) library and are inspired by [microui](https://github.com/rxi/microui), trying to be simple and minimal.


This was formerly 2 different branches, one for each framework. It's now a unified codebase since lovr and love have a very similar API. It has zero depedencies and it is pure Lua, meaning this is not bindings to a "foreign" library (which usually require a specific version of said library to work).

https://github.com/immortalx74/lovr-ui2d/assets/29693328/3b1e15cc-948f-401f-a236-ee63c44e07ea

**How to use:**

See `main.lua` for minimal and demo implementations. Below is the complete API documentation but some things will make more sense by examining the examples.

**Widgets:**

 - Button
 - ImageButton
 - TextBox
 - ListBox
 - SliderInt
 - SliderFloat
 - Label
 - CheckBox
 - ToggleButton
 - RadioButton
 - TabBar
 - Dummy
 - ProgressBar
 - CustomWidget
 - Modal window
 - Separator

**API:**

---
`UI2D.Button(name, width, height)`
|Argument|Type|Description
|:---|:---|:---|
|`name`|string|button's text
|`width` _[opt]_|number|button width in pixels
|`height` _[opt]_|number|button height in pixels
 
<span style="color:DeepSkyBlue">Returns:</span> `boolean`, true when clicked.  
NOTE:  if no `width` and/or `height` are provided, the button size will be auto-calculated based on text. Otherwise, it will be set to `width` X `height` (with the text centered) or ignored if that size doesn't fit the text. 

---
`UI2D.ImageButton(texture, width, height, text)`
|Argument|Type|Description
|:---|:---|:---|
|`texture`|texture/image|texture(lovr) or image(love)
|`width`|number|image width in pixels
|`height`|number|image height in pixels
|`text` _[opt]_|string|optional text

<span style="color:DeepSkyBlue">Returns:</span> `boolean` , true when clicked.  

---
`UI2D.CustomWidget(name, width, height)`
|Argument|Type|Description
|:---|:---|:---|
|`name`|string|custom widget name
|`width`|number|width in pixels
|`height`|number|height in pixels

<span style="color:DeepSkyBlue">Returns:</span> `Pass(lovr) or Canvas(love)`, `boolean`, `boolean`, `boolean`, `boolean`, `number`, `number`, `number`, `number` [1] Pass object(lovr) or Canvas(love), [2] clicked, [3] down, [4] released, [5] hovered, [6] mouse X, [7] mouse Y, [8] wheel X, [9] wheel Y  
NOTE: General purpose widget for custom drawing/interaction. The returned Pass(lovr) or Canvas(love) can be used to do regular draw-commands. X and Y are the local 2D coordinates of the pointer (0,0 is top,left)

---
`UI2D.TextBox(name, num_visible_chars, text)`
|Argument|Type|Description
|:---|:---|:---|
|`name`|string|textbox name
|`num_visible_chars`|number|number of visible characters
|`text`|string|text

<span style="color:DeepSkyBlue">Returns:</span> `string`, `boolean` [1] text, [2] finished editing.  
NOTE: Always assign back to your string variable e.g. `mytext = UI2D.TextBox("My textbox, 10, mytext)`. To do validation on the edited text, check the finished editing return value.

---
`UI2D.ListBox(name, num_visible_rows, num_visible_chars, collection, selected, multi_select)`
|Argument|Type|Description
|:---|:---|:---|
|`name`|string|listbox name
|`num_visible_rows`|number|number of visible rows
|`num_visible_chars`|number|number of visible characters on each row
|`collection`|table|table of strings
|`selected` _[opt]_|number or string|selected item index (in case it's a string, selects the 1st occurence of the item that matches the string)
|`multi_select` _[opt]_|boolean|whether multi-select should be enabled

<span style="color:DeepSkyBlue">Returns:</span> `boolean`, `number`, `table`, [1] true when clicked, [2] selected item index, [3] table of selected item indices (if multi_select is true)  
NOTE: The `UI2D.ListBoxSetSelected` helper can be used to select item(s) programmatically.

---
`UI2D.SliderInt(name, v, v_min, v_max, width)`
|Argument|Type|Description
|:---|:---|:---|
|`name`|string|slider text
|`v`|number|initial value
|`v_min`|number|minimum value
|`v_max`|number|maximum value
|`width` _[opt]_|number|total width in pixels of the slider, including it's text

<span style="color:DeepSkyBlue">Returns:</span> `number`, `boolean`, [1] current value, [2] true when released  
NOTE: Always assign back to your slider-value, e.g. `myval = UI2D.SliderInt("my slider", myval, 0, 100)`
If width is provided, it will be taken into account only if it exceeds the width of text, otherwise it will be ignored. 

---
`UI2D.SliderFloat(name, v, v_min, v_max, width, num_decimals)`
|Argument|Type|Description
|:---|:---|:---|
|`name`|string|slider text
|`v`|number|initial value
|`v_min`|number|minimum value
|`v_max`|number|maximum value
|`width` _[opt]_|number|total width in pixels of the slider, including it's text
|`num_decimals` _[opt]_|number|number of decimals to display

<span style="color:DeepSkyBlue">Returns:</span> `number`, `boolean`, [1] current value, [2] true when released   
NOTE: Always assign back to your slider-value, e.g. `myval = UI2D.SliderFloat("my slider", myval, 0, 100)`
If `width` is provided, it will be taken into account only if it exceeds the width of text, otherwise it will be ignored. If no `num_decimals` is provided, it defaults to 2.

---
`UI2D.Label(text)`
|Argument|Type|Description
|:---|:---|:---|
|`text`|string|label text
|`compact` _[opt]_|boolean|ignore vertical margin

<span style="color:DeepSkyBlue">Returns:</span> `nothing`  

---
`UI2D.ProgressBar(progress, width)`
|Argument|Type|Description
|:---|:---|:---|
|`progress`|number|progress percentage
|`width` _[opt]_|number|width in pixels

<span style="color:DeepSkyBlue">Returns:</span> `nothing`  
NOTE: Default width is 300 pixels

---
`UI2D.Separator()`
|Argument|Type|Description
|:---|:---|:---|
|`none`||

<span style="color:DeepSkyBlue">Returns:</span> `nothing`  
NOTE: Horizontal Separator

---
`UI2D.CheckBox(text, checked)`
|Argument|Type|Description
|:---|:---|:---|
|`text`|string|checkbox text
|`checked`|boolean|state

<span style="color:DeepSkyBlue">Returns:</span> `boolean`, true when clicked  
NOTE: To set the state use this idiom: `if UI2D.CheckBox("My checkbox", my_state) then my_state = not my_state end`

---
`UI2D.ToggleButton(text, checked)`
|Argument|Type|Description
|:---|:---|:---|
|`text`|string|toggle button text
|`checked`|boolean|state

<span style="color:DeepSkyBlue">Returns:</span> `boolean`, true when clicked  
NOTE: To set the state use this idiom: `if UI2D.ToggleButton("My toggle button", my_state) then my_state = not my_state end`

---
`UI2D.RadioButton(text, checked)`
|Argument|Type|Description
|:---|:---|:---|
|`text`|string|radiobutton text
|`checked`|boolean|state

<span style="color:DeepSkyBlue">Returns:</span> `boolean`, true when clicked  
NOTE: To set the state on a group of RadioButtons use this idiom: 
`if UI2D.RadioButton("Radio1", rb_group_idx == 1) then rb_group_idx = 1 end`
`if UI2D.RadioButton("Radio2", rb_group_idx == 2) then rb_group_idx = 2 end`
`-- etc...`

---
`UI2D.TabBar(name, tabs, idx)`
|Argument|Type|Description
|:---|:---|:---|
|`name`|string|TabBar name
|`tabs`|table|a table of strings
|`idx`|number|initial active tab index

<span style="color:DeepSkyBlue">Returns:</span> `boolean`, `number`, [1] true when clicked, [2] the selected tab index  

---
`UI2D.Dummy(width, height)`
|Argument|Type|Description
|:---|:---|:---|
|`width`|number|width
|`height`|number|height

<span style="color:DeepSkyBlue">Returns:</span> `nothing`  
NOTE: This is an invisible widget useful only to "push" other widgets' positions or to leave a desired gap.

---
`UI2D.Begin(name, x, y, is_modal)`
|Argument|Type|Description
|:---|:---|:---|
|`name`|string|window title
|`x`|number|window X position
|`y`|number|window Y position
|`is_modal` _[opt]_|boolean|is this a modal window

<span style="color:DeepSkyBlue">Returns:</span> `nothing`  
NOTE: Starts a new window. Every widget call after this function will belong to this window, until `UI2D.End()` is called. If this is set as a modal window (by passing true to the last argument) you should always call `UI2D.EndModalWindow` before closing it physically. 

---
`UI2D.End(main_pass(lovr) or nothing(love))`
|Argument|Type|Description
|:---|:---|:---|
|`main_pass`|Pass|the main Pass object(only for lovr)

<span style="color:DeepSkyBlue">Returns:</span> `nothing`  
NOTE: Ends the current window. 

---
`UI2D.SameLine()`
|Argument|Type|Description
|:---|:---|:---|
|`none`||

<span style="color:DeepSkyBlue">Returns:</span> `nothing`  
NOTE: Places the next widget side-to-side with the last one, instead of bellow

---
`UI2D.GetWindowSize(name)`
|Argument|Type|Description
|:---|:---|:---|
|`name`|number|window name

<span style="color:DeepSkyBlue">Returns:</span> `number`, `number`, [1] window width, [2] window height  
NOTE: If no window with this name was found, return type is `nil`

---
`UI2D.Init(type, size)`
|Argument|Type|Description
|:---|:---|:---|
|`type`|string|which framework to use (valid values: "lovr", "love")
|`size` _[opt]_|number|font size

<span style="color:DeepSkyBlue">Returns:</span> `nothing`  
NOTE: Initializes the library and should be called on `lovr/love.load()`. Font size dictates the general size of the UI. Default is 14

---
`UI2D.InputInfo()`
|Argument|Type|Description
|:---|:---|:---|
|`none`||

<span style="color:DeepSkyBlue">Returns:</span> `nothing`  
NOTE: Should be called on `lovr/love.update()`

---
`UI2D.RenderFrame(main_pass(only for lovr))`
|Argument|Type|Description
|:---|:---|:---|
|`main_pass`|Pass|the main Pass object(lovr).

<span style="color:DeepSkyBlue">Returns:</span> `table` of ui passes(lovr) or nothing(love)  
NOTE: Renders the UI. Should be called in `lovr/love.draw()`. (If you're using lovr see the examples on how to handle the passes returned from this call.)

---
`UI2D.OverrideColor(col_name, color)`
|Argument|Type|Description
|:---|:---|:---|
|`col_name`|string|color name
|`color`|table|color value in table form (r, g, b, a)

<span style="color:DeepSkyBlue">Returns:</span> `nothing`  
NOTE: Helper to override a color value.

---
`UI2D.SetColorTheme(theme, copy_from)`
|Argument|Type|Description
|:---|:---|:---|
|`theme`|string or table|color name or table with names of colors
|`copy_from` _[opt]_|string|color-theme to copy values from

<span style="color:DeepSkyBlue">Returns:</span> `nothing`  
NOTE: Sets the color-theme to one of the built-in ones ("dark", "light") if the passed argument is a string. Also accepts a table of colors. If the passed table doesn't contain all of the keys, the rest of them will be copied from the built-in theme of the `copy_from` argument.

---
`UI2D.CloseModalWindow()`
|Argument|Type|Description
|:---|:---|:---|
|`none`||

<span style="color:DeepSkyBlue">Returns:</span> `nothing`  
NOTE: Closes a modal window

---
`UI2D.KeyPressed(key, repeating)`
|Argument|Type|Description
|:---|:---|:---|
|`key`|string|key name
|`repeating`|boolean|if the key is repeating instead of an instant press.

<span style="color:DeepSkyBlue">Returns:</span> `nothing`  
NOTE: Should be called on `lovr/love.keypressed()` callback.

---
`UI2D.TextInput(text)`
|Argument|Type|Description
|:---|:---|:---|
|`text`|string|character from a textinput event.

<span style="color:DeepSkyBlue">Returns:</span> `nothing`  
NOTE: Should be called on `lovr/love.textinput()` callback.

---
`UI2D.KeyReleased()`
|Argument|Type|Description
|:---|:---|:---|
|`none`||

<span style="color:DeepSkyBlue">Returns:</span> `nothing`  
NOTE: Should be called on `lovr/love.keyreleased()` callback.

---
`UI2D.WheelMoved(x, y)`
|Argument|Type|Description
|:---|:---|:---|
|`x`|number|wheel X.
|`y`|number|wheel Y.

<span style="color:DeepSkyBlue">Returns:</span> `nothing`  
NOTE: Should be called on `lovr/love.wheelmoved()` callback.

---
`UI2D.HasMouse()`
|Argument|Type|Description
|:---|:---|:---|
|`none`||

<span style="color:DeepSkyBlue">Returns:</span> `nothing`  
NOTE: Whether the mouse-pointer hovers a UI2D window.

---
`UI2D.SetWindowPosition(name, x, y)`
|Argument|Type|Description
|:---|:---|:---|
|`name`|string|name of the window
|`x`|number|X position
|`y`|number|Y position

<span style="color:DeepSkyBlue">Returns:</span> `boolean`, true if the window was found  
NOTE: Sets a window's position programmatically.

---
`UI2D.GetColorTheme()`
|Argument|Type|Description
|:---|:---|:---|
|`none`||

<span style="color:DeepSkyBlue">Returns:</span> `string`, theme name  
NOTE: Gets the current color-theme

---
`UI2D.ResetColor(col_name)`
|Argument|Type|Description
|:---|:---|:---|
|`col_name`|string|color name

<span style="color:DeepSkyBlue">Returns:</span> `nothing`  
NOTE: Resets a color to its default value

---
`UI2D.SetFontSize(size)`
|Argument|Type|Description
|:---|:---|:---|
|`size`|number|font size

<span style="color:DeepSkyBlue">Returns:</span> `nothing`  
NOTE: Sets the font size

---
`UI2D.GetFontSize()`
|Argument|Type|Description
|:---|:---|:---|
|`none`||

<span style="color:DeepSkyBlue">Returns:</span> `number`, font size  
NOTE: Gets the current font size

---
`UI2D.HasTextInput()`
|Argument|Type|Description
|:---|:---|:---|
|`none`||

<span style="color:DeepSkyBlue">Returns:</span> `boolean`, true if a textbox has focus  
NOTE: Gets whether the text of a textbox is currently being edited

---
`UI2D.IsModalOpen()`
|Argument|Type|Description
|:---|:---|:---|
|`none`||

<span style="color:DeepSkyBlue">Returns:</span> `boolean`, true if a modal window is currently open  
NOTE: Gets whether a modal window is currently open

---
`UI2D.EndModalWindow()`
|Argument|Type|Description
|:---|:---|:---|
|`none`||

<span style="color:DeepSkyBlue">Returns:</span> `nothing`  
NOTE: Informs UI2D that a previously open modal-window was closed. You should always call this when closing a modal-window (usually performed from a button inside that window) so that UI2D can restore interaction with the other windows. 

---
`UI2D.SameColumn()`
|Argument|Type|Description
|:---|:---|:---|
|`none`||

<span style="color:DeepSkyBlue">Returns:</span> `nothing`  
NOTE: If the last widget used the `UI2D.SameLine()` call, it effectively started a new "column". This function can be called such as the next widget will be placed on that column, under the last widget.

---
`UI2D.ListBoxSetSelected(name, idx)`
|Argument|Type|Description
|:---|:---|:---|
|`name`|string|listbox name
|`idx`|number or table|Index of item to be selected, or table of indices (in case this listbox' multi_select property is set to true)

<span style="color:DeepSkyBlue">Returns:</span> `nothing`  
NOTE: Sets the selected item(s) of a ListBox programmatically
