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

function lovr.load()
	UI2D.Init( 16 )
end

function lovr.update( dt )
	UI2D.InputInfo()
end

function lovr.keypressed( key, scancode, repeating )
	-- txt = txt .. "0"
	-- UI2D.SetWindowPosition( "third##blah", 100, 150 )
end

function lovr.draw( pass )
	pass:setProjection( 1, mat4():orthographic( pass:getDimensions() ) )
	UI2D.NewFrame( pass )

	UI2D.Begin( "first", 300, 300 )
	if UI2D.Button( "first button" ) then
		print( "from 1st button" )
	end
	if UI2D.ImageButton( icon, 40, 40 ) then
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
	UI2D.Button( "second button" )
	UI2D.End( pass )

	UI2D.Begin( "second", 400, 200 )
	UI2D.ProgressBar( 20 )
	UI2D.Separator()
	UI2D.Button( "first button2" )
	UI2D.Button( "first button2" )
	released, sl1 = UI2D.SliderInt( "a slider", sl1, 0, 100 )
	if released then
		print( released, sl1 )
	end
	UI2D.Button( "second button2" )
	UI2D.End( pass )

	UI2D.Begin( "third", 350, 240 )
	UI2D.Button( "blah1" )
	UI2D.Button( "blah2" )
	UI2D.SameLine()
	released, sl2 = UI2D.SliderInt( "hello", sl2, 0, 100 )
	UI2D.End( pass )

	UI2D.Begin( "fourth", 250, 250 )
	UI2D.Button( txt )
	if UI2D.CheckBox( "Really?", check1 ) then
		check1 = not check1
	end
	if UI2D.CheckBox( "Another check", check2 ) then
		check2 = not check2
	end
	released, sl3 = UI2D.SliderFloat( "hello", sl3, 0, 100, 300 )
	UI2D.End( pass )

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

	pass:setColor( 1, 0, 0 )
	pass:plane( 100, 100, 0, 100, 100 )
	table.insert( ui_passes, pass )
	-- print( #ui_passes )
	return lovr.graphics.submit( ui_passes )
end
