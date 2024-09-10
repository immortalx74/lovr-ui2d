if love then
	function love.conf( t )
		t.window.width = 1300
		t.window.height = 600
		t.window.resizable = true
		t.console = true
		t.modules.joystick = false
	end
else
	function lovr.conf( t )
		t.modules.headset = false
		t.window.resizable = true
		t.window.width = 1300
		t.window.height = 600
	end
end
