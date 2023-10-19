UI2D = require "ui2d/ui2d"

lovr.graphics.setBackgroundColor( 0.2, 0.2, 0.7 )
local win1_pos_x = 300
local win1_pos_y = 300
local sl1 = 20
local sl2 = 10
local sl3 = 10.3
local txt = "sample text"
local icon = lovr.graphics.newTexture( "ui2d/lovrlogo.png" )
local tab_bar_idx = 1
local check1 = true
local check2 = false
local rb_idx = 1
local progress = { value = 0, adder = 0 }
local txt1 = "Αυτό είναι utf8 κείμενο"
local txt2 = "Another textbox"
local amplitude = 50
local frequency = 0.1

function lovr.load()
	UI2D.Init()
end

function lovr.update( dt )
	UI2D.InputInfo()

	progress.adder = progress.adder + (10 * dt)
	if progress.adder > 100 then progress.adder = 0 end
	progress.value = math.floor( progress.adder )
end

function lovr.draw( pass )
	pass:setProjection( 1, mat4():orthographic( pass:getDimensions() ) )
	-- pass:setColor( 1, 0, 0 )
	-- pass:plane( 100, 100, 0, 100, 100 )
	UI2D.NewFrame( pass )

	UI2D.Begin( "first", 300, 300 )
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
	UI2D.End( pass )

	UI2D.Begin( "second", 400, 200 )
	UI2D.Label( "We're doing progress...", true )
	UI2D.ProgressBar( progress.value )
	UI2D.Separator()
	if UI2D.Button( "Font size +" ) then
		UI2D.SetFontSize( UI2D.GetFontSize() + 1 )
	end
	if UI2D.Button( "Font size -" ) then
		UI2D.SetFontSize( UI2D.GetFontSize() - 1 )
	end
	released, sl1 = UI2D.SliderInt( "a slider", sl1, 0, 100 )
	if released then
		print( released, sl1 )
	end
	UI2D.Button( "second button2" )
	UI2D.End( pass )

	UI2D.Begin( "third", 350, 240 )
	UI2D.Button( "blah1" )
	UI2D.OverrideColor( "button_bg", { 0.8, 0, 0.8 } )
	UI2D.Button( "colored button" )
	UI2D.ResetColor( "button_bg" )
	UI2D.Button( "blah3" )
	UI2D.SameLine()
	released, sl2 = UI2D.SliderInt( "hello", sl2, 0, 100 )
	UI2D.End( pass )

	UI2D.OverrideColor( "window_bg", { 0.1, 0.2, 0.6 } )
	UI2D.Begin( "Colored window", 250, 250 )
	UI2D.Button( txt )
	UI2D.SameLine()
	txt1 = UI2D.TextBox( "textbox1", 11, txt1 )
	txt2 = UI2D.TextBox( "textbox2", 20, txt2 )
	if UI2D.CheckBox( "Really?", check1 ) then
		check1 = not check1
	end
	if UI2D.CheckBox( "Another check", check2 ) then
		check2 = not check2
	end

	released, sl3 = UI2D.SliderFloat( "hello", sl3, 0, 100, 300 )
	UI2D.End( pass )
	UI2D.ResetColor( "window_bg" )

	UI2D.Begin( "TabBar window", 350, 100 )
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

	local ui_passes = UI2D.RenderFrame( pass )
	table.insert( ui_passes, pass )
	return lovr.graphics.submit( ui_passes )
end
