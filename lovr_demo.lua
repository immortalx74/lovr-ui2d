UI2D = require "ui2d..ui2d"

lovr.graphics.setBackgroundColor( 0.2, 0.2, 0.7 )
local sl1 = 20
local sl2 = 10
local sl3 = 10.3
local icon = lovr.graphics.newTexture( "lovrlogo.png" )
local tab_bar_idx = 1
local check1 = true
local check2 = false
local toggle1 = false
local toggle2 = true
local rb_idx = 1
local progress = { value = 0, adder = 0 }
local txt1 = "482.32"
local txt2 = "a bigger textbox"
local amplitude = 50
local frequency = 0.1
local modal_window_open = false
local some_list = { "fade", "wrong", "milky", "zinc", "doubt", "proud", "well-to-do",
	"carry", "knife", "ordinary", "yielding", "yawn", "salt", "examine", "historical",
	"group", "certain", "disgusting", "hum", "left", "camera", "grey", "memorize",
	"squalid", "second-hand", "domineering", "puzzled", "cloudy", "arrogant", "flat",
	"activity", "obedient", "poke", "power", "brave", "ruthless", "knowing", "shut",
	"crook", "base", "pleasure", "cycle", "kettle", "regular", "substantial", "flowery",
	"industrious", "credit", "rice", "harm", "nifty", "boiling", "get", "volleyball",
	"jobless", "honey", "piquant", "desire", "glossy", "spark", "hulking", "leg", "hurry" }

-- Helper function to draw a CustomWidget
local function DrawMyCustomWidget( ps, held, hovered, mx, my )
	if held then
		amplitude = (75 * my) / 150
		frequency = (0.2 * mx) / 250
	end

	local col = { 0, 0, 0 }
	if hovered then
		col = { 0.1, 0, 0.2 }
	end

	ps:setClear( col )
	ps:setColor( 1, 1, 1 )

	local xx = 0
	local yy = 0
	local y = 75

	for i = 1, 250 do
		yy = y + (amplitude * math.sin( frequency * xx ))
		ps:points( xx, yy, 0 )
		xx = xx + 1
	end
end

function lovr.load()
	-- Initialize the library. You can optionally pass a font size. Default is 14.
	UI2D.Init( "lovr" )
end

function lovr.keypressed( key, scancode, repeating )
	UI2D.KeyPressed( key, repeating )
end

function lovr.textinput( text, code )
	UI2D.TextInput( text )
end

function lovr.keyreleased( key, scancode )
	UI2D.KeyReleased()
end

function lovr.wheelmoved( deltaX, deltaY )
	UI2D.WheelMoved( deltaX, deltaY )
end

function lovr.update( dt )
	-- This gets input information for the library.
	UI2D.InputInfo()
end

function lovr.update( dt )
	-- This gets input information for the library.
	UI2D.InputInfo()
end

function lovr.draw( pass )
	pass:setProjection( 1, mat4():orthographic( pass:getDimensions() ) )

	-- Every window should be contained in a Begin/End block. This is the start of the first window.
	UI2D.Begin( "First Window", 50, 200 )
	if UI2D.Button( "first button" ) then
		print( "from 1st button" )
	end
	if UI2D.ImageButton( icon, 32, 32, "img button" ) then
		print( "img" )
	end
	if UI2D.RadioButton( "Radio1", rb_idx == 1 ) then
		rb_idx = 1
	end
	if UI2D.RadioButton( "Radio2", rb_idx == 2 ) then
		rb_idx = 2
	end
	if UI2D.RadioButton( "Radio3", rb_idx == 3 ) then
		rb_idx = 3
	end
	if UI2D.Button( "Change theme" ) then
		if UI2D.GetColorTheme() == "light" then
			UI2D.SetColorTheme( "dark" )
		else
			UI2D.SetColorTheme( "light" )
		end
	end
	UI2D.End( pass ) -- And this is the end of the first window.

	-- More windows...
	UI2D.Begin( "Second Window", 250, 50 )
	UI2D.Label( "We're doing progress...", true )
	progress.adder = progress.adder + (10 * lovr.timer.getDelta())
	if progress.adder > 100 then progress.adder = 0 end
	progress.value = math.floor( progress.adder )
	UI2D.ProgressBar( progress.value )
	UI2D.Separator()
	if UI2D.Button( "Font size +" ) then
		UI2D.SetFontSize( UI2D.GetFontSize() + 1 )
	end
	UI2D.SameLine()
	if UI2D.Button( "Font size -" ) then
		UI2D.SetFontSize( UI2D.GetFontSize() - 1 )
	end
	sl1, released = UI2D.SliderInt( "another slider", sl1, 0, 100, 296 )
	if released then
		print( released, sl1 )
	end
	if UI2D.ToggleButton( "Toggle1", toggle1 ) then
		toggle1 = not toggle1
	end
	if UI2D.ToggleButton( "Toggle2", toggle2 ) then
		toggle2 = not toggle2
	end
	UI2D.Label( "Widgets on same line", true )
	UI2D.Button( "Hello", 80, nil, "This is a Tooltip" )
	UI2D.SameLine()
	UI2D.Button( "World!", 80, nil, "And this is\na multi-line\nTooltip" )
	UI2D.End( pass )

	UI2D.Begin( "utf8 text support: ΞΔΠΘ", 950, 50 )
	if UI2D.Button( "Open modal window" ) then
		modal_window_open = true
	end
	UI2D.OverrideColor( "button_bg", { 0.8, 0, 0.8 } )
	UI2D.Button( "colored button" )

	local clicked, idx = UI2D.ListBox( "list1", 15, 28, some_list )
	if clicked then
		print( "selected item: " .. idx .. " - " .. some_list[ idx ] )
	end
	UI2D.ResetColor( "button_bg" )
	UI2D.Button( "Click me" )
	UI2D.SameLine()
	sl2 = UI2D.SliderInt( "int slider", sl2, 0, 100 )
	UI2D.End( pass )

	UI2D.OverrideColor( "window_bg", { 0.1, 0.2, 0.6 } )
	UI2D.Begin( "Colored window", 600, 300 )
	UI2D.Button( "sample text" )
	UI2D.SameLine()
	txt1, finished_editing = UI2D.TextBox( "textbox1", 11, txt1 )
	if finished_editing then
		if type( tonumber( txt1 ) ) ~= "number" then
			txt1 = "0"
		end
	end
	txt2 = UI2D.TextBox( "textbox2", 25, txt2 )
	if UI2D.CheckBox( "Really?", check1 ) then
		check1 = not check1
	end
	if UI2D.CheckBox( "Check me too", check2 ) then
		check2 = not check2
	end

	sl3 = UI2D.SliderFloat( "float slider", sl3, 0, 100, 300 )
	UI2D.End( pass )
	UI2D.ResetColor( "window_bg" )

	UI2D.Begin( "TabBar window", 300, 390 )
	local was_clicked, idx = UI2D.TabBar( "my tab bar", { "first", "second", "third" }, tab_bar_idx )
	if was_clicked then
		tab_bar_idx = idx
	end
	if tab_bar_idx == 1 then
		UI2D.Button( "Button on 1st tab" )
		UI2D.Label( "Label on 1st tab" )
		UI2D.Label( "LÖVR..." )
	elseif tab_bar_idx == 2 then
		UI2D.Button( "Button on 2nd tab" )
		UI2D.Label( "Label on 2nd tab" )
		UI2D.Label( "is..." )
	elseif tab_bar_idx == 3 then
		UI2D.Button( "Button on 3rd tab" )
		UI2D.Label( "Label on 3rd tab" )
		UI2D.Label( "awesome!" )
	end
	UI2D.End( pass )

	UI2D.Begin( "Another window", 600, 50 )
	UI2D.Label( "This is a custom widget" )
	local ps, clicked, held, released, hovered, mx, my, wheelx, wheely = UI2D.CustomWidget( "widget1", 250, 150 )
	DrawMyCustomWidget( ps, held, hovered, mx, my )
	UI2D.End( pass )

	-- A modal window is like all other windows, except there can only be one open at a time.
	-- This is set by passing 'true' as the last parameter of Begin().
	-- When it's time to close a modal window ALWAYS call EndModalWindow()
	if modal_window_open then
		UI2D.Begin( "Modal window", 400, 200, true )
		UI2D.Label( "Close this window\nto interact with other windows" )
		if UI2D.Button( "Close" ) then
			modal_window_open = false
			UI2D.EndModalWindow()
		end
		UI2D.End( pass )
	end

	-- This marks the end of the GUI.
	-- RenderFrame returns a table of passes generated by UI2D.
	-- Insert the main pass into that table and call lovr.graphics.submit.
	local ui_passes = UI2D.RenderFrame( pass )
	table.insert( ui_passes, pass )
	return lovr.graphics.submit( ui_passes )
end
