local utf8 = require "utf8"
local UI2D = {}

local e_mouse_state = { clicked = 1, held = 2, released = 3, idle = 4 }
local e_slider_type = { int = 1, float = 2 }
local modal_window = nil
local active_window = nil
local active_widget = nil
local active_textbox = nil
local dragged_window = nil
local repeating_key = nil
local text_input_character = nil
local begin_idx = nil
local margin = 8
local separator_thickness = 2
local windows = {}
local color_themes = {}
local overriden_colors = {}
local font = { handle = nil, w = nil, h = nil }
local dragged_window_offset = { x = 0, y = 0 }
local mouse = { x = 0, y = 0, state = e_mouse_state.idle, prev_frame = 0, this_frame = 0 }
local texture_flags = { mipmaps = true, usage = { 'sample', 'render', 'transfer' } }
local layout = { x = 0, y = 0, w = 0, h = 0, row_h = 0, total_w = 0, total_h = 0, same_line = false, same_column = false }
local clamp_sampler = lovr.graphics.newSampler( { wrap = 'clamp' } )

color_themes.dark =
{
	text = { 0.8, 0.8, 0.8 },
	window_bg = { 0.26, 0.26, 0.26 },
	window_border = { 0, 0, 0 },
	window_titlebar = { 0.08, 0.08, 0.08 },
	window_titlebar_active = { 0, 0, 0 },
	button_bg = { 0.14, 0.14, 0.14 },
	button_bg_hover = { 0.19, 0.19, 0.19 },
	button_bg_click = { 0.12, 0.12, 0.12 },
	button_border = { 0, 0, 0 },
	check_border = { 0, 0, 0 },
	check_border_hover = { 0.5, 0.5, 0.5 },
	check_mark = { 0.3, 0.3, 1 },
	radio_border = { 0, 0, 0 },
	radio_border_hover = { 0.5, 0.5, 0.5 },
	radio_mark = { 0.3, 0.3, 1 },
	slider_bg = { 0.3, 0.3, 1 },
	slider_bg_hover = { 0.38, 0.38, 1 },
	slider_thumb = { 0.2, 0.2, 1 },
	list_bg = { 0.14, 0.14, 0.14 },
	list_border = { 0, 0, 0 },
	list_selected = { 0.3, 0.3, 1 },
	list_highlight = { 0.3, 0.3, 0.3 },
	textbox_bg = { 0.03, 0.03, 0.03 },
	textbox_bg_hover = { 0.11, 0.11, 0.11 },
	textbox_border = { 0.1, 0.1, 0.1 },
	textbox_border_focused = { 0.58, 0.58, 1 },
	image_button_border_highlight = { 0.5, 0.5, 0.5 },
	tab_bar_bg = { 0.1, 0.1, 0.1 },
	tab_bar_border = { 0, 0, 0 },
	tab_bar_hover = { 0.2, 0.2, 0.2 },
	tab_bar_highlight = { 0.3, 0.3, 1 },
	progress_bar_bg = { 0.2, 0.2, 0.2 },
	progress_bar_fill = { 0.3, 0.3, 1 },
	progress_bar_border = { 0, 0, 0 },
	osk_mode_bg = { 0, 0, 0 },
	osk_highlight = { 1, 1, 1 },
	modal_tint = { 0.3, 0.3, 0.3 },
	separator = { 0, 0, 0 }
}

color_themes.light =
{
	check_border = { 0.000, 0.000, 0.000 },
	check_border_hover = { 0.760, 0.760, 0.760 },
	textbox_bg_hover = { 0.570, 0.570, 0.570 },
	textbox_border = { 0.000, 0.000, 0.000 },
	text = { 0.120, 0.120, 0.120 },
	button_bg_hover = { 0.900, 0.900, 0.900 },
	radio_mark = { 0.172, 0.172, 0.172 },
	slider_bg = { 0.830, 0.830, 0.830 },
	progress_bar_fill = { 0.830, 0.830, 1.000 },
	progress_bar_bg = { 1.000, 1.000, 1.000 },
	tab_bar_highlight = { 0.151, 0.140, 1.000 },
	tab_bar_hover = { 0.802, 0.797, 0.795 },
	tab_bar_border = { 0.000, 0.000, 0.000 },
	tab_bar_bg = { 1.000, 0.994, 0.999 },
	image_button_border_highlight = { 0.500, 0.500, 0.500 },
	textbox_bg = { 0.700, 0.700, 0.700 },
	window_border = { 0.000, 0.000, 0.000 },
	window_bg = { 0.930, 0.930, 0.930 },
	window_titlebar = { 0.8, 0.8, 0.8 },
	window_titlebar_active = { 0.9, 0.9, 0.9 },
	button_bg = { 0.800, 0.800, 0.800 },
	progress_bar_border = { 0.000, 0.000, 0.000 },
	slider_bg_hover = { 0.870, 0.870, 0.870 },
	slider_thumb = { 0.700, 0.700, 0.700 },
	list_bg = { 0.877, 0.883, 0.877 },
	list_border = { 0.000, 0.000, 0.000 },
	list_selected = { 0.686, 0.687, 0.688 },
	list_highlight = { 0.808, 0.810, 0.811 },
	check_mark = { 0.000, 0.000, 0.000 },
	radio_border = { 0.000, 0.000, 0.000 },
	radio_border_hover = { 0.760, 0.760, 0.760 },
	textbox_border_focused = { 0.000, 0.000, 1.000 },
	button_bg_click = { 0.120, 0.120, 0.120 },
	button_border = { 0.000, 0.000, 0.000 },
	osk_mode_bg = { 0.5, 0.5, 0.5 },
	osk_highlight = { 0.1, 0.1, 0.1 },
	modal_tint = { 0.15, 0.15, 0.15 },
	separator = { 0.5, 0.5, 0.5 }
}

local colors = color_themes.dark

local function Clamp( n, n_min, n_max )
	if n < n_min then
		n = n_min
	elseif n > n_max then
		n = n_max
	end

	return n
end

local function GetLineCount( str )
	-- https://stackoverflow.com/questions/24690910/how-to-get-lines-count-in-string/70137660#70137660
	local lines = 1
	for i = 1, #str do
		local c = str:sub( i, i )
		if c == '\n' then lines = lines + 1 end
	end

	return lines
end

local function WindowExists( id )
	for i, v in ipairs( windows ) do
		if v.id == id then
			return true, i
		end
	end
	return false, 0
end

local function PointInRect( px, py, rx, ry, rw, rh )
	if px >= rx and px <= rx + rw and py >= ry and py <= ry + rh then
		return true
	end

	return false
end

local function MapRange( from_min, from_max, to_min, to_max, v )
	return (v - from_min) * (to_max - to_min) / (from_max - from_min) + to_min
end

local function GetLabelPart( name )
	local i = string.find( name, "##" )
	if i then
		return string.sub( name, 1, i - 1 )
	end
	return name
end

local function ResetLayout()
	layout = { x = 0, y = 0, w = 0, h = 0, row_h = 0, total_w = 0, total_h = 0, same_line = false, same_column = false }
end

local function UpdateLayout( bbox )
	-- Update row height
	if layout.same_line then
		if bbox.h > layout.row_h then
			layout.row_h = bbox.h
		end
	elseif layout.same_column then
		if bbox.h + layout.h + margin < layout.row_h then
			layout.row_h = layout.row_h - layout.h - margin
		else
			layout.row_h = bbox.h
		end
	else
		layout.row_h = bbox.h
	end

	-- Calculate current layout w/h
	if bbox.x + bbox.w + margin > layout.total_w then
		layout.total_w = bbox.x + bbox.w + margin
	end

	if bbox.y + layout.row_h + margin > layout.total_h then
		layout.total_h = bbox.y + layout.row_h + margin
	end

	-- Update layout x/y/w/h and same_line
	layout.x = bbox.x
	layout.y = bbox.y
	layout.w = bbox.w
	layout.h = bbox.h
	layout.same_line = false
	layout.same_column = false
end

local function Slider( type, name, v, v_min, v_max, width )
	local text = GetLabelPart( name )
	local cur_window = windows[ begin_idx ]
	local text_w = font.handle:getWidth( text )

	local slider_w = 10 * font.w
	local bbox = {}
	if layout.same_line then
		bbox = { x = layout.x + layout.w + margin, y = layout.y, w = slider_w + margin + text_w, h = (2 * margin) + font.h }
	elseif layout.same_column then
		bbox = { x = layout.x, y = layout.y + layout.h + margin, w = slider_w + margin + text_w, h = (2 * margin) + font.h }
	else
		bbox = { x = margin, y = layout.y + layout.row_h + margin, w = slider_w + margin + text_w, h = (2 * margin) + font.h }
	end

	if width and width > bbox.w then
		bbox.w = width
		slider_w = width - margin - text_w
	end

	UpdateLayout( bbox )

	local col = colors.slider_bg
	local result = false

	if not modal_window or (modal_window and modal_window == cur_window.id) then
		if PointInRect( mouse.x, mouse.y, bbox.x + cur_window.x, bbox.y + cur_window.y, slider_w, bbox.h ) and cur_window == active_window then
			col = colors.slider_bg_hover

			if mouse.state == e_mouse_state.clicked then
				active_widget = cur_window.id .. name
			end
		end
	end

	if mouse.state == e_mouse_state.held and active_widget == cur_window.id .. name and cur_window == active_window then
		v = MapRange( bbox.x + 2, bbox.x + slider_w - 2, v_min, v_max, mouse.x - cur_window.x )
		if type == e_slider_type.float then
			v = Clamp( v, v_min, v_max )
		else
			v = Clamp( math.ceil( v ), v_min, v_max )
			if v == 0 then v = 0 end
		end
	end
	if mouse.state == e_mouse_state.released and active_widget == cur_window.id .. name then
		active_widget = nil
		result = true
	end

	local value_text_w = font.handle:getWidth( v )
	local text_label_rect = { x = bbox.x + slider_w + margin, y = bbox.y, w = text_w, h = bbox.h }
	local text_value_rect = { x = bbox.x, y = bbox.y, w = slider_w, h = bbox.h }
	local slider_rect = { x = bbox.x, y = bbox.y + (bbox.h / 2) - (font.h / 2), w = slider_w, h = font.h }
	local thumb_pos = MapRange( v_min, v_max, bbox.x, bbox.x + slider_w - font.h, v )
	local thumb_rect = { x = thumb_pos, y = bbox.y + (bbox.h / 2) - (font.h / 2), w = font.h, h = font.h }

	local value
	if type == e_slider_type.float then
		num_decimals = num_decimals or 2
		local str_fmt = "%." .. num_decimals .. "f"
		value = string.format( str_fmt, v )
	else
		value = v
	end
	table.insert( windows[ begin_idx ].command_list, { type = "rect_fill", bbox = slider_rect, color = col } )
	table.insert( windows[ begin_idx ].command_list, { type = "rect_fill", bbox = thumb_rect, color = colors.slider_thumb } )
	table.insert( windows[ begin_idx ].command_list, { type = "text", text = text, bbox = text_label_rect, color = colors.text } )
	table.insert( windows[ begin_idx ].command_list, { type = "text", text = value, bbox = text_value_rect, color = colors.text } )
	return result, v
end

function utf8.sub( s, i, j )
	i = utf8.offset( s, i )
	j = utf8.offset( s, j + 1 ) - 1
	return string.sub( s, i, j )
end

function lovr.textinput( text, code )
	text_input_character = text
	-- print( "here")
end

function lovr.keypressed( key, scancode, repeating )
	if repeating then
		if key == "right" then
			repeating_key = "right"
		elseif key == "left" then
			repeating_key = "left"
		elseif key == "backspace" then
			repeating_key = "backspace"
		end
	end
end

function lovr.keyreleased( key, scancode )
	repeating_key = nil
end

---------------------------------------------------------------
function UI2D.Init( size )
	font.handle = lovr.graphics.newFont( "ui2d/" .. "DejaVuSansMono.ttf", size or 14, 4 )
	font.handle:setPixelDensity( 1.0 )
	font.h = font.handle:getHeight()
	font.w = font.handle:getWidth( "W" )
	lovr.system.setKeyRepeat( true )
end

function UI2D.InputInfo()
	-- Get mouse
	if lovr.system.isMouseDown( 1 ) then
		if mouse.prev_frame == 0 then
			mouse.prev_frame = 1
			mouse.this_frame = 1
			mouse.state = e_mouse_state.clicked
		else
			mouse.prev_frame = 1
			mouse.this_frame = 0
			mouse.state = e_mouse_state.held
		end
	else
		if mouse.prev_frame == 1 then
			mouse.state = e_mouse_state.released
			mouse.prev_frame = 0
		else
			mouse.state = e_mouse_state.idle
		end
	end

	mouse.x, mouse.y = lovr.system.getMousePosition()

	-- Set active window on click
	local hovers_active = false
	local hovers_any = false
	for i, v in ipairs( windows ) do
		if PointInRect( mouse.x, mouse.y, v.x, v.y, v.w, v.h ) then
			if v == active_window then
				hovers_active = true
			end
			hovers_any = true
		end
	end

	if not hovers_active then
		for i, v in ipairs( windows ) do
			if PointInRect( mouse.x, mouse.y, v.x, v.y, v.w, v.h ) and mouse.state == e_mouse_state.clicked then
				active_window = v
			end
		end
	end

	-- Set active to none
	if not hovers_any and mouse.state == e_mouse_state.clicked then
		active_window = nil
	end

	-- Handle window dragging
	if active_window then
		local v = active_window
		if PointInRect( mouse.x, mouse.y, v.x, v.y, v.w, (2 * margin) + font.h ) and mouse.state == e_mouse_state.clicked then
			dragged_window = active_window
			dragged_window_offset.x = mouse.x - active_window.x
			dragged_window_offset.y = mouse.y - active_window.y
		end

		if dragged_window then
			if mouse.state == e_mouse_state.held then
				dragged_window.x = mouse.x - dragged_window_offset.x
				dragged_window.y = mouse.y - dragged_window_offset.y
			end
		end
	end

	if mouse.state == e_mouse_state.released then
		dragged_window = nil
	end
end

function UI2D.Begin( name, x, y, is_modal )
	local exists, idx = WindowExists( name ) -- TODO: Can't currently change window title on runtime

	if not exists then
		local window = {
			id = name,
			title = GetLabelPart( name ),
			x = x,
			y = y,
			w = 0,
			h = 0,
			command_list = {},
			texture = nil,
			texture_w = 0,
			texture_h = 0,
			pass = nil,
			is_hovered = false,
			is_modal = is_modal or false
		}
		table.insert( windows, window )
	end
	layout.y = (2 * margin) + font.h

	if idx == 0 then
		begin_idx = #windows
	else
		begin_idx = idx
	end
end

function UI2D.End( main_pass )
	local cur_window = windows[ begin_idx ]
	cur_window.w = layout.total_w
	cur_window.h = layout.total_h
	assert( cur_window.w > 0, "Begin/End block without widgets!" )

	-- Cache texture
	if cur_window.texture then
		if cur_window.texture_w ~= cur_window.w or cur_window.texture_h ~= cur_window.h then
			cur_window.texture:release()
			cur_window.texture_w = cur_window.w
			cur_window.texture_h = cur_window.h
			cur_window.texture = lovr.graphics.newTexture( cur_window.w, cur_window.h, texture_flags )
			cur_window.pass:setCanvas( cur_window.texture )
		end
	else
		cur_window.texture = lovr.graphics.newTexture( cur_window.w, cur_window.h, texture_flags )
		cur_window.texture_w = cur_window.w
		cur_window.texture_h = cur_window.h
		cur_window.pass = lovr.graphics.newPass( cur_window.texture )
	end

	cur_window.pass:reset()
	cur_window.pass:setFont( font.handle )
	cur_window.pass:setDepthTest( nil )
	cur_window.pass:setProjection( 1, mat4():orthographic( cur_window.pass:getDimensions() ) )
	cur_window.pass:setColor( colors.window_bg )
	cur_window.pass:fill()

	-- Title bar and border
	local title_col = colors.window_titlebar
	if cur_window == active_window then
		title_col = colors.window_titlebar_active
	end
	table.insert( windows[ begin_idx ].command_list,
		{ type = "rect_fill", bbox = { x = 0, y = 0, w = cur_window.w, h = (2 * margin) + font.h }, color = title_col } )

	local txt = cur_window.title
	local title_w = utf8.len( txt ) * font.w
	if title_w > cur_window.w - (2 * margin) then -- Truncate title
		local num_chars = ((cur_window.w - (2 * margin)) / font.w) - 3
		txt = string.sub( txt, 1, num_chars ) .. "..."
		title_w = utf8.len( txt ) * font.w
	end

	table.insert( windows[ begin_idx ].command_list,
		{ type = "text", text = txt, bbox = { x = margin, y = 0, w = title_w, h = (2 * margin) + font.h }, color = colors.text } )

	table.insert( windows[ begin_idx ].command_list,
		{ type = "rect_wire", bbox = { x = 0, y = 0, w = cur_window.w, h = cur_window.h }, color = colors.window_border } )

	-- Do draw commands
	for i, v in ipairs( cur_window.command_list ) do
		if v.type == "rect_fill" then
			if v.is_separator then
				cur_window.pass:setColor( v.color )
				cur_window.pass:plane( v.bbox.x + (cur_window.w / 2), v.bbox.y, 0, cur_window.w - (2 * margin), separator_thickness, 0, 0, 0, 0, "fill" )
			else
				cur_window.pass:setColor( v.color )
				cur_window.pass:plane( v.bbox.x + (v.bbox.w / 2), v.bbox.y + (v.bbox.h / 2), 0, v.bbox.w, v.bbox.h, 0, 0, 0, 0, "fill" )
			end
		elseif v.type == "rect_wire" then
			local m = lovr.math.newMat4( vec3( v.bbox.x + (v.bbox.w / 2), v.bbox.y + (v.bbox.h / 2), 0 ), vec3( v.bbox.w, v.bbox.h, 0 ) )
			cur_window.pass:setColor( v.color )
			cur_window.pass:plane( m, "line" )
		elseif v.type == "circle_wire" then
			local m = lovr.math.newMat4( vec3( v.bbox.x + (v.bbox.w / 2), v.bbox.y + (v.bbox.h / 2), 0 ), vec3( v.bbox.w / 2, v.bbox.h / 2, 0 ) )
			cur_window.pass:setColor( v.color )
			cur_window.pass:circle( m, "line" )
		elseif v.type == "circle_fill" then
			local m = lovr.math.newMat4( vec3( v.bbox.x + (v.bbox.w / 2), v.bbox.y + (v.bbox.h / 2), 0 ), vec3( v.bbox.w / 3, v.bbox.h / 3, 0 ) )
			cur_window.pass:setColor( v.color )
			cur_window.pass:circle( m, "fill" )
		elseif v.type == "text" then
			cur_window.pass:setColor( v.color )
			cur_window.pass:text( v.text, vec3( v.bbox.x + (v.bbox.w / 2), v.bbox.y + (v.bbox.h / 2), 0 ) )
		elseif v.type == "image" then
			-- NOTE Temp fix. Had to do negative vertical scale. Otherwise image gets flipped?
			local m = lovr.math.newMat4( vec3( v.bbox.x + (v.bbox.w / 2), v.bbox.y + (v.bbox.h / 2), 0 ), vec3( v.bbox.w, -v.bbox.h, 0 ) )
			cur_window.pass:setColor( v.color )
			cur_window.pass:setMaterial( v.texture )
			cur_window.pass:setSampler( clamp_sampler )
			cur_window.pass:plane( m, "fill" )
			cur_window.pass:setMaterial()
			cur_window.pass:setColor( 1, 1, 1 )
		end
	end

	main_pass:setColor( 1, 1, 1 )
	main_pass:setMaterial( cur_window.texture )
	local z = 1
	if cur_window == active_window then z = 0 end
	main_pass:plane( cur_window.x + (cur_window.w / 2), cur_window.y + (cur_window.h / 2), z, cur_window.w, -cur_window.h ) --NOTE flip Y fix
	main_pass:setMaterial()

	ResetLayout()
end

function UI2D.SetWindowPosition( id, x, y )
	local exists, idx = WindowExists( id )
	if exists then
		windows[ idx ].x = x
		windows[ idx ].y = y
		return true
	end

	return false
end

function UI2D.SetColorTheme( theme, copy_from )
	if type( theme ) == "string" then
		colors = color_themes[ theme ]
	elseif type( theme ) == "table" then
		copy_from = copy_from or "dark"
		for i, v in pairs( color_themes[ copy_from ] ) do
			if theme[ i ] == nil then
				theme[ i ] = v
			end
		end
		colors = theme
	end
end

function UI2D.GetColorTheme()
	for i, v in pairs( color_themes ) do
		if v == colors then
			return i
		end
	end
end

function UI2D.OverrideColor( col_name, color )
	if not overriden_colors[ col_name ] then
		local old_color = colors[ col_name ]
		overriden_colors[ col_name ] = old_color
		colors[ col_name ] = color
	end
end

function UI2D.ResetColor( col_name )
	if overriden_colors[ col_name ] then
		colors[ col_name ] = overriden_colors[ col_name ]
		overriden_colors[ col_name ] = nil
	end
end

function UI2D.SameLine()
	layout.same_line = true
end

function UI2D.SameColumn()
	layout.same_column = true
end

function UI2D.Button( name, width, height )
	local text = GetLabelPart( name )
	local cur_window = windows[ begin_idx ]
	local text_w = utf8.len( name ) * font.w
	local num_lines = GetLineCount( name )

	local bbox = {}
	if layout.same_line then
		bbox = { x = layout.x + layout.w + margin, y = layout.y, w = (2 * margin) + text_w, h = (2 * margin) + (num_lines * font.h) }
	elseif layout.same_column then
		bbox = { x = layout.x, y = layout.y + layout.h + margin, w = (2 * margin) + text_w, h = (2 * margin) + (num_lines * font.h) }
	else
		bbox = { x = margin, y = layout.y + layout.row_h + margin, w = (2 * margin) + text_w, h = (2 * margin) + (num_lines * font.h) }
	end

	if width and type( width ) == "number" and width > bbox.w then
		bbox.w = width
	end
	if height and type( height ) == "number" and height > bbox.h then
		bbox.h = height
	end

	UpdateLayout( bbox )

	local result = false
	local col = colors.button_bg

	if not modal_window or (modal_window and modal_window == cur_window.id) then
		if PointInRect( mouse.x, mouse.y, bbox.x + cur_window.x, bbox.y + cur_window.y, bbox.w, bbox.h ) and cur_window == active_window then
			col = colors.button_bg_hover
			if mouse.state == e_mouse_state.clicked then
				result = true
			end
			if mouse.state == e_mouse_state.held then
				col = colors.button_bg_click
			end
		end
	end

	table.insert( windows[ begin_idx ].command_list, { type = "rect_fill", bbox = bbox, color = col } )
	table.insert( windows[ begin_idx ].command_list, { type = "rect_wire", bbox = bbox, color = colors.button_border } )
	table.insert( windows[ begin_idx ].command_list, { type = "text", text = text, bbox = bbox, color = colors.text } )

	return result
end

function UI2D.SliderInt( name, v, v_min, v_max, width )
	return Slider( e_slider_type.int, name, v, v_min, v_max, width )
end

function UI2D.SliderFloat( name, v, v_min, v_max, width, num_decimals )
	return Slider( e_slider_type.float, name, v, v_min, v_max, width, num_decimals )
end

function UI2D.ProgressBar( progress, width )
	if width and width >= (2 * margin) + (4 * font.w) then
		width = width
	else
		width = 300
	end

	local bbox = {}
	if layout.same_line then
		bbox = { x = layout.x + layout.w + margin, y = layout.y, w = width, h = (2 * margin) + font.h }
	elseif layout.same_column then
		bbox = { x = layout.x, y = layout.y + layout.h, w = width, h = (2 * margin) + font.h }
	else
		bbox = { x = margin, y = layout.y + layout.row_h + margin, w = width, h = (2 * margin) + font.h }
	end

	UpdateLayout( bbox )

	progress = Clamp( progress, 0, 100 )
	local fill_w = math.floor( (width * progress) / 100 )
	local str = progress .. "%"

	table.insert( windows[ begin_idx ].command_list,
		{ type = "rect_fill", bbox = { x = bbox.x, y = bbox.y, w = fill_w, h = bbox.h }, color = colors.progress_bar_fill } )
	table.insert( windows[ begin_idx ].command_list,
		{ type = "rect_fill", bbox = { x = bbox.x + fill_w, y = bbox.y, w = bbox.w - fill_w, h = bbox.h }, color = colors.progress_bar_bg } )
	table.insert( windows[ begin_idx ].command_list, { type = "rect_wire", bbox = bbox, color = colors.progress_bar_border } )
	table.insert( windows[ begin_idx ].command_list, { type = "text", text = str, bbox = bbox, color = colors.text } )
end

function UI2D.Separator()
	local bbox = {}
	if layout.same_line or layout.same_column then
		return
	else
		bbox = { x = 0, y = layout.y + layout.row_h + margin, w = 0, h = 0 }
	end

	UpdateLayout( bbox )

	table.insert( windows[ begin_idx ].command_list, { is_separator = true, type = "rect_fill", bbox = bbox, color = colors.separator } )
end

function UI2D.ImageButton( texture, width, height, text )
	local cur_window = windows[ begin_idx ]
	local width = width or texture:getWidth()
	local height = height or texture:getHeight()

	local bbox = {}
	if layout.same_line then
		bbox = { x = layout.x + layout.w + margin, y = layout.y, w = width, h = height }
	elseif layout.same_column then
		bbox = { x = layout.x, y = layout.y + layout.h + margin, w = width, height = height }
	else
		bbox = { x = margin, y = layout.y + layout.row_h + margin, w = width, h = height }
	end

	local text_w

	if text then
		text_w = font.handle:getWidth( text )
		font.h = font.handle:getHeight()

		if font.h > bbox.h then
			bbox.h = font.h
		end
		bbox.w = bbox.w + (2 * margin) + text_w
	end

	UpdateLayout( bbox )

	local result = false
	local col = 1

	if not modal_window or (modal_window and modal_window == cur_window.id) then
		if PointInRect( mouse.x, mouse.y, bbox.x + cur_window.x, bbox.y + cur_window.y, bbox.w, bbox.h ) and cur_window == active_window then
			table.insert( windows[ begin_idx ].command_list, { type = "rect_wire", bbox = bbox, color = colors.image_button_border_highlight } )

			if mouse.state == e_mouse_state.clicked then
				result = true
			end
			if mouse.state == e_mouse_state.held then
				col = 0.7
			end
		end
	end

	if text then
		table.insert( windows[ begin_idx ].command_list,
			{ type = "image", bbox = { x = bbox.x, y = bbox.y + ((bbox.h - height) / 2), w = width, h = height }, texture = texture, color = { col, col, col } } )
		table.insert( windows[ begin_idx ].command_list,
			{ type = "text", text = text, bbox = { x = bbox.x + width, y = bbox.y, w = text_w + (2 * margin), h = bbox.h }, color = colors.text } )
	else
		table.insert( windows[ begin_idx ].command_list, { type = "image", bbox = bbox, texture = texture, color = { col, col, col } } )
	end

	return result
end

function UI2D.Dummy( width, height )
	local bbox = {}
	if layout.same_line then
		bbox = { x = layout.x + layout.w + margin, y = layout.y, w = width, h = height }
	else
		bbox = { x = margin, y = layout.y + layout.row_h + margin, w = width, h = height }
	end

	UpdateLayout( bbox )
end

function UI2D.TabBar( name, tabs, idx )
	local cur_window = windows[ begin_idx ]

	local bbox = {}

	if layout.same_line then
		bbox = { x = layout.x + layout.w + margin, y = layout.y, w = 0, h = (2 * margin) + font.h }
	else
		bbox = { x = margin, y = layout.y + layout.row_h + margin, w = 0, h = (2 * margin) + font.h }
	end

	local result = false, idx
	local total_w = 0
	local col = colors.tab_bar_bg
	local x_off = bbox.x

	for i, v in ipairs( tabs ) do
		local text_w = font.handle:getWidth( v )
		local tab_w = text_w + (2 * margin)
		bbox.w = bbox.w + tab_w

		if not modal_window or (modal_window and modal_window == cur_window.id) then
			if PointInRect( mouse.x, mouse.y, x_off + cur_window.x, bbox.y + cur_window.y, tab_w, bbox.h ) and cur_window == active_window then
				col = colors.tab_bar_hover
				if mouse.state == e_mouse_state.clicked then
					idx = i
					result = true
				end
			else
				col = colors.tab_bar_bg
			end
		end

		local tab_rect = { x = x_off, y = bbox.y, w = tab_w, h = bbox.h }
		table.insert( windows[ begin_idx ].command_list, { type = "rect_fill", bbox = tab_rect, color = col } )
		table.insert( windows[ begin_idx ].command_list, { type = "rect_wire", bbox = tab_rect, color = colors.tab_bar_border } )
		table.insert( windows[ begin_idx ].command_list, { type = "text", text = v, bbox = tab_rect, color = colors.text } )

		if idx == i then
			-- table.insert( windows[ begin_idx ].command_list,
			-- 	{ type = "rect_fill", bbox = { x = tab_rect.x + 2, y = tab_rect.y + tab_rect.h - 6, w = tab_rect.w - 4, h = 5 }, color = colors.tab_bar_highlight } )
			local highlight_thickness = math.floor( font.h / 4 )
			table.insert( windows[ begin_idx ].command_list,
				{
					type = "rect_fill",
					bbox = { x = tab_rect.x + 2, y = tab_rect.y + tab_rect.h - (highlight_thickness), w = tab_rect.w - 4, h = highlight_thickness },
					color = colors.tab_bar_highlight
				} )
		end
		x_off = x_off + tab_w
	end

	table.insert( windows[ begin_idx ].command_list, { type = "rect_wire", bbox = bbox, color = colors.tab_bar_border } )
	UpdateLayout( bbox )

	return result, idx
end

function UI2D.Label( text, compact )
	local text_w = font.handle:getWidth( text )
	local num_lines = GetLineCount( text )

	local mrg = (2 * margin)
	if compact then
		mrg = 0
	end

	local bbox = {}
	if layout.same_line then
		bbox = { x = layout.x + layout.w + margin, y = layout.y, w = text_w, h = mrg + (num_lines * font.h) }
	elseif layout.same_column then
		bbox = { x = layout.x, y = layout.y + layout.h + margin, w = text_w, h = mrg + (num_lines * font.h) }
	else
		bbox = { x = margin, y = layout.y + layout.row_h + margin, w = text_w, h = mrg + (num_lines * font.h) }
	end

	UpdateLayout( bbox )

	table.insert( windows[ begin_idx ].command_list, { type = "text", text = text, bbox = bbox, color = colors.text } )
end

function UI2D.CheckBox( text, checked )
	local cur_window = windows[ begin_idx ]
	local text_w = font.handle:getWidth( text )

	local bbox = {}
	if layout.same_line then
		bbox = { x = layout.x + layout.w + margin, y = layout.y, w = font.h + margin + text_w, h = (2 * margin) + font.h }
	else
		bbox = { x = margin, y = layout.y + layout.row_h + margin, w = font.h + margin + text_w, h = (2 * margin) + font.h }
	end

	UpdateLayout( bbox )

	local result = false
	local col = colors.check_border

	if not modal_window or (modal_window and modal_window == cur_window.id) then
		if PointInRect( mouse.x, mouse.y, bbox.x + cur_window.x, bbox.y + cur_window.y, bbox.w, bbox.h ) and cur_window == active_window then
			col = colors.check_border_hover
			if mouse.state == e_mouse_state.clicked then
				result = true
			end
		end
	end

	local check_rect = { x = bbox.x, y = bbox.y + margin, w = font.h, h = font.h }
	local text_rect = { x = bbox.x + font.h + margin, y = bbox.y, w = text_w + margin, h = bbox.h }
	table.insert( windows[ begin_idx ].command_list, { type = "rect_wire", bbox = check_rect, color = col } )
	table.insert( windows[ begin_idx ].command_list, { type = "text", text = text, bbox = text_rect, color = colors.text } )

	if checked and type( checked ) == "boolean" then
		table.insert( windows[ begin_idx ].command_list, { type = "text", text = "✔", bbox = check_rect, color = colors.check_mark } )
	end

	return result
end

function UI2D.RadioButton( text, checked )
	local cur_window = windows[ begin_idx ]
	local text_w = font.handle:getWidth( text )

	local bbox = {}
	if layout.same_line then
		bbox = { x = layout.x + layout.w + margin, y = layout.y, w = font.h + margin + text_w, h = (2 * margin) + font.h }
	else
		bbox = { x = margin, y = layout.y + layout.row_h + margin, w = font.h + margin + text_w, h = (2 * margin) + font.h }
	end

	UpdateLayout( bbox )

	local result = false
	local col = colors.radio_border

	if not modal_window or (modal_window and modal_window == cur_window.id) then
		if PointInRect( mouse.x, mouse.y, bbox.x + cur_window.x, bbox.y + cur_window.y, bbox.w, bbox.h ) and cur_window == active_window then
			col = colors.radio_border_hover

			if mouse.state == e_mouse_state.clicked then
				result = true
			end
		end
	end

	local check_rect = { x = bbox.x, y = bbox.y + margin, w = font.h, h = font.h }
	local text_rect = { x = bbox.x + font.h + margin, y = bbox.y, w = text_w + margin, h = bbox.h }
	table.insert( windows[ begin_idx ].command_list, { type = "circle_wire", bbox = check_rect, color = col } )
	table.insert( windows[ begin_idx ].command_list, { type = "text", text = text, bbox = text_rect, color = colors.text } )

	if checked and type( checked ) == "boolean" then
		table.insert( windows[ begin_idx ].command_list, { type = "circle_fill", bbox = check_rect, color = colors.radio_mark } )
	end

	return result
end

function UI2D.TextBox( name, num_visible_chars, text )
	local cur_window = windows[ begin_idx ]
	local label_w = font.handle:getWidth( name )

	local bbox = {}
	if layout.same_line then
		bbox = { x = layout.x + layout.w + margin, y = layout.y, w = (4 * margin) + (num_visible_chars * font.w) + label_w, h = (2 * margin) + font.h }
	else
		bbox = { x = margin, y = layout.y + layout.row_h + margin, w = (4 * margin) + (num_visible_chars * font.w) + label_w, h = (2 * margin) + font.h }
	end

	UpdateLayout( bbox )

	local scroll = 0
	if active_textbox then
		scroll = active_textbox.scroll
	end

	local text_rect = { x = bbox.x, y = bbox.y, w = (2 * margin) + (num_visible_chars * font.w), h = bbox.h }
	local visible_text = nil
	if utf8.len( text ) > num_visible_chars then
		visible_text = utf8.sub( text, scroll + 1, scroll + num_visible_chars )
	else
		visible_text = text
	end
	local label_rect = { x = text_rect.x + text_rect.w + margin, y = bbox.y, w = label_w, h = bbox.h }
	local char_rect = { x = text_rect.x + margin, y = text_rect.y, w = (utf8.len( visible_text ) * font.w), h = text_rect.h }

	-- Caret
	local caret_rect = nil
	if active_widget == cur_window.id .. name then
		if text_input_character then
			local p = active_textbox.caret + active_textbox.scroll
			local part1 = utf8.sub( text, 1, p )
			local part2 = utf8.sub( text, p + 1, utf8.len( text ) )
			text = part1 .. text_input_character .. part2
			active_textbox.caret = active_textbox.caret + 1
			if active_textbox.caret > num_visible_chars then
				active_textbox.scroll = active_textbox.scroll + 1
			end
		end

		if lovr.system.wasKeyPressed( "backspace" ) or repeating_key == "backspace" then
			if active_textbox.caret > 0 then
				local p = active_textbox.caret + active_textbox.scroll
				local part1 = utf8.sub( text, 1, p - 1 )
				local part2 = utf8.sub( text, p + 1, utf8.len( text ) )
				text = part1 .. part2

				local max_scroll = utf8.len( text ) - num_visible_chars
				-- if active_textbox.scroll < max_scroll or utf8.len( text ) <= num_visible_chars then
				if active_textbox.scroll < max_scroll or utf8.len( text ) < num_visible_chars then
					active_textbox.caret = active_textbox.caret - 1
				end
				-- if active_textbox.scroll <= 0 then
				-- 	active_textbox.caret = active_textbox.caret - 1
				-- end
				-- if active_textbox.scroll > max_scroll then
				-- 	active_textbox.scroll = active_textbox.scroll - 1
				-- end
			end
		end

		if lovr.system.wasKeyPressed( "left" ) or repeating_key == "left" then
			if active_textbox.caret == 0 then
				if active_textbox.scroll > 0 then
					active_textbox.scroll = active_textbox.scroll - 1
				end
			end
			active_textbox.caret = active_textbox.caret - 1
		end

		if lovr.system.wasKeyPressed( "right" ) or repeating_key == "right" then
			local full_length = utf8.len( text )
			local visible_length = utf8.len( visible_text )
			if active_textbox.caret == num_visible_chars and full_length > num_visible_chars and active_textbox.scroll < (full_length - visible_length) then
				active_textbox.scroll = active_textbox.scroll + 1
			end
			if active_textbox.caret < full_length then
				active_textbox.caret = active_textbox.caret + 1
			end
		end

		local max_scroll = utf8.len( text ) - num_visible_chars
		if max_scroll < 0 then max_scroll = 0 end
		active_textbox.scroll = Clamp( active_textbox.scroll, 0, max_scroll )
		scroll = active_textbox.scroll
		active_textbox.caret = Clamp( active_textbox.caret, 0, num_visible_chars )
		caret_rect = { x = char_rect.x + (active_textbox.caret * font.w), y = char_rect.y + margin, w = 2, h = font.h }
	end

	local col1 = colors.textbox_bg
	local col2 = colors.textbox_border

	if not modal_window or (modal_window and modal_window == cur_window.id) then
		if PointInRect( mouse.x, mouse.y, text_rect.x + cur_window.x, text_rect.y + cur_window.y, text_rect.w, text_rect.h ) and cur_window == active_window then
			col1 = colors.textbox_bg_hover

			if mouse.state == e_mouse_state.clicked then
				local pos = math.floor( (mouse.x - cur_window.x - text_rect.x) / font.w )
				if pos > utf8.len( text ) then
					pos = utf8.len( text )
				end

				if active_widget ~= cur_window.id .. name then
					active_textbox = { id = cur_window.id .. name, caret = pos }
					active_textbox.scroll = 0
					active_widget = cur_window.id .. name
				else
					active_textbox.caret = pos
				end
			end
		else
			if mouse.state == e_mouse_state.clicked then
				if active_widget == cur_window.id .. name then -- Deactivate self
					active_textbox = nil
					active_widget = nil
					return text
				end
			end
		end

		if active_widget == cur_window.id .. name then
			if lovr.system.wasKeyPressed( "tab" ) or lovr.system.wasKeyPressed( "return" ) then -- Deactivate self
				active_textbox = nil
				active_widget = nil
				return text
			end
		end
	end


	table.insert( windows[ begin_idx ].command_list, { type = "rect_fill", bbox = text_rect, color = col1 } )
	table.insert( windows[ begin_idx ].command_list, { type = "rect_wire", bbox = text_rect, color = col2 } )
	table.insert( windows[ begin_idx ].command_list, { type = "text", text = visible_text, bbox = char_rect, color = colors.text } )
	table.insert( windows[ begin_idx ].command_list, { type = "text", text = name, bbox = label_rect, color = colors.text } )

	if caret_rect then
		table.insert( windows[ begin_idx ].command_list, { type = "rect_fill", bbox = caret_rect, color = colors.text } )
	end

	return text
end

function UI2D.ListBox( name )
end

function UI2D.NewFrame( main_pass )
	font.handle:setPixelDensity( 1.0 )
end

function UI2D.RenderFrame( main_pass )
	text_input_character = nil
	local passes = {}

	for i, v in ipairs( windows ) do
		v.command_list = nil
		v.command_list = {}
		table.insert( passes, v.pass )
	end
	return passes
end

return UI2D
