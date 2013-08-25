require("../audio")

TitleScene = {}

local tween = require("../lib/tween/tween")

local background = nil
local background_scale_x = 1
local background_scale_y = 1
local running = true
local state = 0
local config = nil;

local options = {};

local options_cursor = 1;

local config_value = nil;

local function error_frame(text)
	state = -1; -- error state
	local frame = loveframes.Create("frame")
	frame:SetModal(true);
	frame:SetSize(500, 300)
	frame:SetName("Error")
	frame:Center()
	frame.OnClose = function()
		state = 2;
	end
	local text = loveframes.Create("text", frame)
	text:SetMaxWidth(400)
	text:SetText(text); -- + "\nPress Escape to exit")
	text:SetParent(frame);
	text:SetPos(5, 30)
	local button = loveframes.Create("button", frame)
	button:SetWidth(100);
	button:SetText("OK")
	button:Center();
	button.OnClick = function()
		frame:Remove();
		state = 2;
	end
end

local singleplayer_options = {};
local hotseat_options = {};
local multiplayer_options = {};
local audio_options = {};
local config_options = {};
local gamepad_options = {};
local credits_options = {};
local exit_options = {};
local base_options = {};

function load_menu()
	 singleplayer_options = {
		{name = "Survival", value = 0, onSelect = function() end},
		{name = "Mode A", value = 0, onSelect = function() error_frame("Not implemented.") end},
		{name = "Mode B", value = 0, onSelect = function() error_frame("Not implemented.") end},
		{name = "Back", valie = 0, onSelect = function() options = base_options; options_cursor = 1; end}
	}
	
	hotseat_options = {
		{name = "Classic", value = 0, onSelect = function() end},
		{name = "Time Attack", value = 0, onSelect = function() end},
		{name = "Survival", value = 0, onSelect = function() end},
		{name = "Back", valie = 0, onSelect = function() options = base_options; options_cursor = 1; end}
	}
	
	multiplayer_options = {
		{name = "Hot Seat", value = 0, onSelect = function() 
			if (love.joystick.getNumJoysticks() < 2) then
				error_frame("Hot Seat Mode need 2 gamepads connected.")
			else 
				options = hotseat_options;
			end
		end},
		{name = "Online", value = 0, onSelect = function() end},
		{name = "Back", value = 0, onSelect = function() options = base_options; options_cursor = 1; end},	
	}
	
	audio_options = {
		{name = "Music Volume = " .. config.music_volume, value = 0, onSelect = function() end, onFocus = function() config_value = config.music_volume; end,
		 onValueUp = function() if (config.music_volume <= 0.9) then config.music_volume = config.music_volume + 0.1; AudioManager:setMusicVolume(config.music_volume); audio_options[1].name = "Music Volume = " .. config.music_volume; end; end,
		 onValueDown = function() if (config.music_volume >= 0.1) then config.music_volume = config.music_volume - 0.1; AudioManager:setMusicVolume(config.music_volume); audio_options[1].name = "Music Volume = " .. config.music_volume; end; end
		 },
		{name = "Master Volume = " .. config.sound_volume, value = 0, onSelect = function() end, onFocus = function() config_value = config.sound_volume; end,
		 onValueUp = function() if (config.sound_volume <= 0.9) then config.sound_volume = config.sound_volume + 0.1; AudioManager:setSoundVolume(config.sound_volume); audio_options[2].name = "Master Volume = " .. config.sound_volume; end; end,
		 onValueDown = function() if (config.sound_volume >= 0.1) then config.sound_volume = config.sound_volume - 0.1; AudioManager:setSoundVolume(config.sound_volume); audio_options[2].name = "Master Volume = " .. config.sound_volume; end; end},
		{name = "Back", value = 0, onSelect = function() options = config_options; options_cursor = 1; config_value = nil; end},	
	}
	
	gamepad_options = {
		{name = "Gamepad 1", value = 0, onSelect = function() end},
		
		{name = "Rotate Left = " .. config.gamepad[1].button_rot_left, value = 0, onSelect = function(key) config.gamepad[1].button_rot_left = key; gamepad_options[2].name = "Rotate Left = " .. key; end},
		{name = "Rotate Right = " .. config.gamepad[1].button_rot_right, value = 0, onSelect = function(key) config.gamepad[1].button_rot_right = key; gamepad_options[3].name = "Rotate Right = " .. key; end},
		{name = "Start/Pause = " .. config.gamepad[1].button_start, value = 0, onSelect = function(key) config.gamepad[1].button_start = key; gamepad_options[4].name = "Start/Pause = " .. key; end},
		
		{name = "Gamepad 2", value = 0, onSelect = function() end},
		
		{name = "Rotate Left = " .. config.gamepad[2].button_rot_left, value = 0, onSelect = function(key) config.gamepad[2].button_rot_left = key; gamepad_options[6].name = "Rotate Left = " .. key; end},
		{name = "Rotate Right = " .. config.gamepad[2].button_rot_right, value = 0, onSelect = function(key) config.gamepad[2].button_rot_right = key; gamepad_options[7].name = "Rotate Right = " .. key; end},
		{name = "Start/Pause = " .. config.gamepad[2].button_start, value = 0, onSelect = function(key) config.gamepad[2].button_start = key; gamepad_options[8].name = "Start/Pause = " .. key; end},
		
		{name = "Back", value = 0, onSelect = function() options = config_options; options_cursor = 1; end},	
	}
	
	config_options = {
		{name = "Audio", value = 0, onSelect = function() options = audio_options end},
		{name = "Configure Gamepads", value = 0, onSelect = function() options = gamepad_options; options_cursor = 1; end},
		{name = "Save Configuration", value = 0, onSelect = function() 
			local file = love.filesystem.newFile("config.metro")
			file:open("w")
			local data = Tserial.pack(config);
			file:write(data, #data);
			file:close()
		end},
		{name = "Back", value = 0, onSelect = function() options = base_options; options_cursor = 1; end},	
	}
	
	credits_options = {
		{name = "Programming: Stephan Bruny", value = 0, onSelect = function() end},
		{name = "Loveframes: Kenny Shields", value = 0, onSelect = function() end},
		{name = "tween.lua: Enrique Garcia Cota", value = 0, onSelect = function() end},
		{name = "Adore64 Font: ck! [Freeky Fonts]", value = 0, onSelect = function() end},
		{name = "Graphics and Music: Stephan Bruny", value = 0, onSelect = function() end},
		{name = "Made with LOVE2D", value = 0, onSelect = function() end},
		{name = "Back", value = 0, onSelect = function() options = base_options; options_cursor = 1; end},		
	}
	
	
	exit_options = {
		{name = "Quit Application", value = 0, onSelect = function() love.event.quit(); end},
		{name = "Credits", value = 0, onSelect = function() options = credits_options; options_cursor = 1; end},
		{name = "Back", value = 0, onSelect = function() options = base_options; options_cursor = 1; end},		
	}
	
	base_options = {
		{name = "Single Player", value = 0, onSelect = function() options = singleplayer_options;options_cursor = 1; end},
		{name = "Multiplayer", value = 0, onSelect = function() options = multiplayer_options; options_cursor = 1;end},
		{name = "Options", value = 0, onSelect = function() options = config_options; options_cursor = 1;end},
		{name = "Exit", value = 0, onSelect = function() options = exit_options; options_cursor = 1; end}
	}
	
	options = base_options;
end



options = base_options;

local background_color = {
	r = 255,
	g = 255,
	b = 255,
	a = 255
}

local wallpaper_color = {
	r = 255,
	g = 255,
	b = 255,
	a = 255
}


local block_joy = {x = 0, y = 0}

local function create_fancy_tween()
	tween.start(5, wallpaper_color, {r = math.random(128, 256)}, "linear");
	tween.start(5, wallpaper_color, {g = math.random(128, 256)}, "linear");
	tween.start(5, wallpaper_color, {b = math.random(128, 256)}, "linear", function() create_fancy_tween() end);
end

function TitleScene.onLoad(game_config)
    config = game_config;
	background = love.graphics.newImage("assets/title.png");
	background_scale_x = love.graphics.getWidth() / background:getWidth();
	background_scale_y = love.graphics.getHeight() / background:getHeight();
	
	background2 = love.graphics.newImage("assets/wallpaper.png");
	
	logo = love.graphics.newImage("assets/metro_tetris.png");
	
	
	AudioManager:playMusic("assets/audio/Title2.mp3", true);
    
	AudioManager:loadSound("blip", "assets/audio/blip.wav");
	AudioManager:loadSound("ok", "assets/audio/ok.wav");
	
	load_menu();
	
	create_fancy_tween();
	
end

function TitleScene.onUpdate(dt)
	if (dt > 0) then tween.update(dt); end -- prevents crash from tween when dt < 0
	TitleScene.joystick();
end

local function draw_options(x, y) 
	for i=1, #options do
		if (i == options_cursor) then
			love.graphics.setColor(255, 200, 0, 255);
		else
			love.graphics.setColor(255, 255, 255, 200);
		end
		love.graphics.printf(options[i].name, x - 300, y + ((i-1)*30), 600, "center")
	end
end

local function option_down()
	AudioManager:playSound("blip")
	if (options_cursor < #options) then
		options_cursor = options_cursor + 1;
	else 
		options_cursor = 1;
	end
	if (options[options_cursor].onFocus ~= nil) then options[options_cursor].onFocus(); end
end

local function option_up()
	AudioManager:playSound("blip")
	if (options_cursor > 1) then
		options_cursor = options_cursor - 1;
	else 
		options_cursor = #options;
	end
end

local function option_value_up()
	
	if (options[options_cursor].onValueUp ~= nil) then
		AudioManager:playSound("blip")
		options[options_cursor].onValueUp();
	end
end

local function option_value_down()
	
	if (options[options_cursor].onValueDown~= nil) then
		AudioManager:playSound("blip")
		options[options_cursor].onValueDown();
	end
end


local function option_select(key)
	AudioManager:playSound("ok")
	options[options_cursor].onSelect(key);
end

function TitleScene.onDraw()

	if (state < 2) then
		love.graphics.setColor(background_color.r, background_color.g, background_color.b, background_color.a)
		love.graphics.draw(background, 0, 0, 0, background_scale_x, background_scale_y);
		if (state == 0) then 
			love.graphics.setColor(255, 255, 255, 255);
			love.graphics.printf("Press any key", love.graphics.getWidth() / 2 - 150, love.graphics.getHeight() / 2, 300, "center")
		end
	end
	
	if (state == 2) then
		love.graphics.setColor(wallpaper_color.r, wallpaper_color.g, wallpaper_color.b, wallpaper_color.a)
		love.graphics.draw(background2, 0, 0, 0, background_scale_x, background_scale_y);
		love.graphics.setColor(255, 255, 255, 255);
		love.graphics.draw(logo, love.graphics.getWidth() / 2 - logo:getWidth()/2, 200);
		draw_options(love.graphics.getWidth() / 2, love.graphics.getHeight()/2)
	end
end

function TitleScene.onKeypressed(key)
	if (state == 0) then
		state = 1;
		AudioManager:playSound("ok");
		tween(3, background_color, {a = 0}, "outQuad", function() state = 2; end)
	end
	
	if (state == 2) then
		if (key == "up") then option_up(); end
		if (key == "down") then option_down(); end
		if (key == "return" or key == " ") then option_select(); end
		if (key == "left") then option_value_down(); end
		if (key == "right") then option_value_up(); end
		
	end
	
	if (state == -1 and (key == "escape") or (key == "return")) then
		loveframes.util.RemoveAll()
		state = 2;
	end
end

function TitleScene.onJoystickpressed(joy, key)
	if (state == 0) then
		state = 1;
		AudioManager:playSound("ok");
		tween(3, background_color, {a = 0}, "outQuad", function() state = 2; end)
	end
	
	if (state == 2) then
		option_select(key);
	end
	
	if (state == -1) then
		loveframes.util.RemoveAll()
		state = 2;
	end
end

function TitleScene.joystick()
    local x = love.joystick.getAxis(1,1);
	local y = love.joystick.getAxis(1,2);
	
	if (x == 0) then
		block_joy.x = 0;
	end
	
	if (y == 0) then
		block_joy.y = 0;
	end
	
				
	if (block_joy.x == 0 and x~= 0) then
		block_joy.x = 1;
		tween.start(config.gamepad[1].axis_update, block_joy, {x = 0})
		
		if (state == 2) then
			if (x < 0) then
				option_value_down();
			else
				option_value_up();
			end
		end
	end
	
	if (block_joy.y == 0 and y ~= 0) then
		block_joy.y = 1;
		tween.start(config.gamepad[1].axis_update, block_joy, {y = 0})
		
		if (state == 2) then
			if (y < 0) then option_up(); end
			if (y > 0) then option_down(); end
		end
	end
end