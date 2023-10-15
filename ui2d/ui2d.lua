local UI2D = {}

local e_mouse_state = { clicked = 1, held = 2, released = 3, idle = 4 }
local modal_window = nil
local active_window = nil
local active_widget = nil
local dragged_window = nil
local dragged_window_offset = { x = 0, y = 0 }
local begin_idx = nil
local margin = 8

local separator_thickness = 4
local font = { handle = nil, w = nil, h = nil }
local windows = {}
local color_themes = {}
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

---------------------------------------------------------------
function UI2D.Init( size )
	font.handle = lovr.graphics.newFont( "ui2d/" .. "DejaVuSansMono.ttf", size or 14, 4 )
	font.handle:setPixelDensity( 1.0 )
	font.h = font.handle:getHeight()
	font.w = font.handle:getWidth( "W" )
end

function UI2D.InputInfo()
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

	local hovers_active = false
	for i, v in ipairs( windows ) do
		if PointInRect( mouse.x, mouse.y, v.x, v.y, v.w, v.h ) then
			if v == active_window then
				hovers_active = true
				break
			end
		end
	end

	if not hovers_active then
		for i, v in ipairs( windows ) do
			if PointInRect( mouse.x, mouse.y, v.x, v.y, v.w, v.h ) and mouse.state == e_mouse_state.clicked then
				active_window = v
			end
		end
	end

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
	local exists, idx = WindowExists( name )

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

	if not cur_window.texture then
		cur_window.texture = lovr.graphics.newTexture( cur_window.w, cur_window.h, texture_flags )
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

	table.insert( windows[ begin_idx ].command_list,
		{ type = "text", text = cur_window.title, bbox = { x = 0, y = 0, w = cur_window.w, h = (2 * margin) + font.h }, color = colors.text } )

	table.insert( windows[ begin_idx ].command_list,
		{ type = "rect_wire", bbox = { x = 0, y = 0, w = cur_window.w, h = cur_window.h }, color = colors.window_border } )

	for i, v in ipairs( cur_window.command_list ) do
		if v.type == "rect_fill" then
			if v.is_separator then
				cur_window.pass:setColor( v.color )
				local m = lovr.math.newMat4( vec3( v.bbox.x + (cur_window.w / 2), v.bbox.y, 0 ), vec3( cur_window.w - (2 * margin), separator_thickness, 0 ) )
				cur_window.pass:plane( m, "fill" )
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

function UI2D.SameLine()
	layout.same_line = true
end

function UI2D.Button( name, width, height )
	local text = GetLabelPart( name )
	local cur_window = windows[ begin_idx ]
	local text_w = font.handle:getWidth( text )
	local num_lines = GetLineCount( text )

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
				active_widget = cur_window.id .. name
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
	local text = GetLabelPart( name )
	local cur_window = windows[ begin_idx ]
	local text_w = font.handle:getWidth( text )

	local slider_w = 10 * font.w
	local bbox = {}
	if layout.same_line then
		bbox = { x = layout.x + layout.w + margin, y = layout.y, w = slider_w + margin + text_w, h = (2 * margin) + font.h }
	else
		bbox = { x = margin, y = layout.y + layout.row_h + margin, w = slider_w + margin + text_w, h = (2 * margin) + font.h }
	end

	if width and type( width ) == "number" and width > bbox.w then
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
		v = Clamp( math.ceil( v ), v_min, v_max )
		if v == 0 then v = 0 end
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

	table.insert( windows[ begin_idx ].command_list, { type = "rect_fill", bbox = slider_rect, color = col } )
	table.insert( windows[ begin_idx ].command_list, { type = "rect_fill", bbox = thumb_rect, color = colors.slider_thumb } )
	table.insert( windows[ begin_idx ].command_list, { type = "text", text = text, bbox = text_label_rect, color = colors.text } )
	table.insert( windows[ begin_idx ].command_list, { type = "text", text = v, bbox = text_value_rect, color = colors.text } )
	return result, v
end

function UI2D.NewFrame( main_pass )
	font.handle:setPixelDensity( 1.0 )
end

function UI2D.RenderFrame( main_pass )
	local passes = {}

	for i, v in ipairs( windows ) do
		v.command_list = nil
		v.command_list = {}
		table.insert( passes, v.pass )
	end
	return passes
end

return UI2D
