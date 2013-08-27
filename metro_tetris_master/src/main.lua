require("particles");
require("audio");
require("lib.tserial.tserial")


require("scenes.title")
require("scenes.singleplayer")

require("conf")

particle_list = {}

stone = {
	data = {},
	rotation = 0,
	x = 0,
	y = 0
}

score = 0;

score_multiplier = 1;

active_stone = nil;

timer = 0;

game_state = 8;

game_font = love.graphics.newFont(16);

background = nil;

gameover_anim = 0;
row_cursor = game_config.field_height;

game_music = nil;
game_over_music = nil;

math.randomseed(1234);
next_stone = nil;

socket = require("socket")

connection = nil;

secondPlayer = nil;

multiplayerActive = false;

enemy_field = {};

current_scene = TitleScene;

-- NETWORK STATES
--  0 - NOT CONNECTED
--  1 - CONNECTED TO SERVER
--  2 - CONNECTED TO PLAYER
-- -1 - LET ME ALONE
network_state = 0;

local scenes = {
	TitleScene,
	SingleplayerScene
}

function love.load()
	-- LOAD L�VE2D-related LIBRARIES
	require("lib.loveframes")

	if (love.filesystem.exists( "config.metro" )) then
		local file = love.filesystem.newFile("config.metro")
		file:open("r")
		local data = file:read();
		local_config = Tserial.unpack(data);
		file:close();
		-- add missing configurations
		for k,v in pairs(game_config) do
			if (local_config[k] == nil) then
				local_config[k] = v;
			end
		end
		game_config = local_config;
	end
	
	-- setup game state change callback
	game_config.game_state = 0; -- title screen
	game_config.set_game_state = function(state)
		if (state == game_config.game_state) then return; end -- do nothing if state did not change
		current_scene.onExit();
		current_scene = scenes[state];
		game_config.game_state = state;
		current_scene.onLoad(game_config);
	end

	game_font = love.graphics.newFont("assets/Adore64.ttf", 16);
	love.graphics.setFont(game_font);
    background = love.graphics.newImage(game_config.background_image);

	game_config.background_scale_x = love.graphics.getWidth() / background:getWidth();
	game_config.background_scale_y = love.graphics.getHeight() / background:getHeight()
		
    
    -- todo: put this in some config file
    AudioManager:init(game_config);
    AudioManager:loadSound("pause", "assets/audio/pause.wav");
    AudioManager:loadSound("block", "assets/audio/block.wav");
    AudioManager:loadSound("row", "assets/audio/row.wav");
    AudioManager:loadSound("rotate", "assets/audio/rotate.wav");
    AudioManager:loadSound("lose", "assets/audio/lose.wav");
    AudioManager:loadSound("move", "assets/audio/move.wav");
    AudioManager:loadSound("whoosh", "assets/audio/whoosh.wav");
    AudioManager:loadSound("zack", "assets/audio/zack.wav");
    AudioManager:loadSound("again", "assets/audio/again.wav");
	AudioManager:loadSound("down", "assets/audio/down.wav");
	   
	--game_music = love.audio.newSource("assets/audio/tetris-b-classic.mp3");
    --game_music:setVolume(game_config.music_volume);
	--game_music:setLooping(true);
	--love.audio.play(game_music)
	
	--game_over_music = love.audio.newSource("assets/audio/tetris-score.mp3");
	--game_over_music:setVolume(game_config.music_volume);
	--game_over_music:setLooping(true);
	
	connection = initNetwork(game_config.server.ip, game_config.server.port, 0.2);
	
	love.graphics.setMode(game_config.display.width, game_config.display.height)
	
	if (game_config.display.full_screen == true) then
		love.graphics.toggleFullscreen();
	end
	
    current_scene.onLoad(game_config);
    
end

function game_over()
	game_state = 0;
	gameover_anim = 0;
	row_cursor = game_config.field_height;
	AudioManager:playSound("lose");
	--love.audio.stop(game_music)
	--love.audio.play(game_over_music);
end

function createField(width, height)
	field = {};
	for i=1,game_config.field_width do
	    for j=1,game_config.field_height do
		    field[i*game_config.field_height + j] = 0;
        end
    end
	return field;
end

tetris_field = createField(game_config.field_width, game_config.field_height);
enemy_field = createField(game_config.field_width, game_config.field_height);

function draw_enemy_field()
	offsetX = love.graphics.getWidth() - game_config.stone_size * (game_config.field_width + 2);

	for i = 1, game_config.field_width do
	    for j = 1, game_config.field_height do 
			love.graphics.setColor(255, 255, 255, 64);
			
			currentStone = enemy_field[i * game_config.field_height + j];
			
			if (currentStone == 0) then 
				love.graphics.rectangle("line", offsetX + i * game_config.stone_size, j *  game_config.stone_size,  game_config.stone_size,  game_config.stone_size )
			end
			
			if (currentStone == 1) then 
				love.graphics.setColor(200, 200, 200, 128);
			    love.graphics.rectangle("fill", offsetX + i * game_config.stone_size, j *  game_config.stone_size,  game_config.stone_size,  game_config.stone_size )
			end
			
			if (currentStone == 16) then 
				love.graphics.setColor(255, 32, 64, 128);
			    love.graphics.rectangle("fill", offsetX + i * game_config.stone_size, j *  game_config.stone_size,  game_config.stone_size,  game_config.stone_size )
			end
		end
	end
	
	if (network_state ~= 2) then
		love.graphics.setColor(255,255,255,255);
		text = "Waiting";
		if (network_state == 0) then text = "Not connected" end 
		
		love.graphics.print(text, offsetX + game_config.field_width / 2 * game_config.stone_size, 300)
	end
	
end

function love.draw()

	if (game_state == 8) then
		current_scene.onDraw()
	else
	  -- Draw Background
	  love.graphics.setColor(255,255,255,255);
	  love.graphics.draw(background, 0, 0, 0, game_config.background_scale_x, game_config.background_scale_y);
	  
		-- DRAW GAME OVER SCREEN
		if (game_state == 0) then
--			draw_field();
			love.graphics.setColor(0,0,0,200);
	    	love.graphics.printf("GAME OVER\nPress 'r' for new game", love.graphics.getWidth() / 2 - 75 + 2, 300 + 2, 150, "center");
	    	love.graphics.setColor(255,255,255,255);
	    
	    	love.graphics.printf("GAME OVER\nPress 'r' for new game", love.graphics.getWidth() / 2 - 75, 300, 150, "center");
		end
	
		-- DRAW GAME or PAUSE	
		if (game_state == 1 or game_state == 2) then
			
			love.graphics.setColor(255, 255, 255, 255);
			
			love.graphics.print("SCORE " .. score, 5, 5);
			
			draw_field();
			draw_enemy_field();
			
			for i = 1, #particle_list do
				ParticleSystem:draw(particle_list[i].particle, particle_list[i].x, particle_list[i].y)
			end
				
			
			if (active_stone ~= nil) then
				offsetX = active_stone.x * game_config.stone_size;
				offsetY = active_stone.y * game_config.stone_size;
				
				for x = 1, #active_stone.data do
					for y = 1, #active_stone.data[x] do
						if (active_stone.data[x][y] > 0) then
							love.graphics.setColor(active_stone.color.r, active_stone.color.g, active_stone.color.b, 255);
							love.graphics.rectangle("fill", offsetX + x * game_config.stone_size, offsetY + y *  game_config.stone_size,  game_config.stone_size,  game_config.stone_size )
						end
					end
				end
			end
			
			if (next_stone ~= nil) then
				offsetX = game_config.stone_size * game_config.field_width + game_config.stone_size
				offsetY = game_config.stone_size 
				love.graphics.setColor(255,255,255,255);
				love.graphics.print("NEXT", offsetX, 5);
				
				for x = 1, #next_stone.data do
					for y = 1, #next_stone.data[x] do
						if (next_stone.data[x][y] > 0) then
							love.graphics.setColor(next_stone.color.r, next_stone.color.g, next_stone.color.b, 255);
							love.graphics.rectangle("fill", offsetX + x * game_config.stone_size, offsetY + y *  game_config.stone_size,  game_config.stone_size,  game_config.stone_size )
						end
					end
				end
			end
		end
		
		if (game_state == 2) then 
			love.graphics.setColor(0,0,0,128);
			love.graphics.rectangle("fill", 0,0,love.graphics.getWidth(), love.graphics.getHeight())
		end
	end
	
	loveframes.draw();
	
end

function make_solid(stone)
	timer = game_config.speed;
	for x = 1, #stone.data do
		for y = 1, #stone.data[x] do
			if (stone.data[x][y] > 0) then
				tetris_field[ (stone.x + x) * game_config.field_height + stone.y + y ] = 1;
			end
		end
	end
end

function mark_enemy_field(stone, field)
	newField = {};
	for k, v in pairs(field) do
		newField[k] = v;
	end

	for x = 1, #stone.data do
		for y = 1, #stone.data[x] do
			if (stone.data[x][y] > 0) then
				newField[ (stone.x + x) * game_config.field_height + stone.y + y ] = 16;
			end
		end
	end
	
	return newField;
end

function splitstr(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
	 table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

function handleNetwork(connection, dt)
	updateNetwork(connection, dt, function(message)
		-- Sending according to state
		if (network_state == 0) then
			connection.udp:send("CONNECT");			
		elseif (network_state == 1) then
			connection.udp:send("RETRY")
		elseif (network_state == 2) then
		    newmessage = "WORLD ";
		    if (nil == active_stone) then 
		    	newmessage = newmessage .. Tserial.pack(tetris_field)
		    else 
		    	newmessage = newmessage .. Tserial.pack(mark_enemy_field(active_stone,tetris_field));
		    end
		    
			connection.udp:send(newmessage);
		end
		
		if (message) then
			if (message == "WAIT") then
				
				-- if (network_state == 2) then print ("Got disconnected from multiplayer"); end
				network_state = 1;
			elseif (message == "UNKNOWN") then
				network_state = 0;
			elseif (string.find(message, "CONNECT_TO") ~= nil) then
				print ("Finally Connected: " .. message);
				network_state = 2;
				-- set game state
			elseif (string.find(message, "WORLD") ~= nil) then
				network_state = 2;
				-- parse field
				fieldData = string.sub(message, 6);
				enemy_field = Tserial.unpack(fieldData);
			end

		end
	end);
end

function love.update(delta_time)
	loveframes.update(delta_time);
	current_scene.onUpdate(delta_time)
	--[[if (game_state == 8) then
		current_scene.onUpdate(delta_time)
	else
		handle_joystick();
		
		handleNetwork(connection, delta_time);
				
		if (game_state == 0) then
	    	gameover_anim = gameover_anim  + delta_time;
	    	if (row_cursor > 0 and gameover_anim > 0.1) then
	    		for i = 1, game_config.field_width do
	    			set_field(i, row_cursor, 1);
	    		end
	    		AudioManager:playSound("zack");
	    		row_cursor = row_cursor - 1;
	    		gameover_anim = 0;
	    	end
		end
	
		if (game_state == 1) then
			timer = timer + delta_time;
			if (timer >= game_config.speed) then 
				if (next_stone == nil) then
					next_stone = {};
					next_stone.y = 0;
					next_stone.rot = 1;
					next_stone.x = math.floor(game_config.field_width / 2) - 1;
					next_stone.pattern = stones[math.random(1, #stones)];
					next_stone.data = next_stone.pattern[1];
					next_stone.color = {
						r = math.random(128,255),
						g = math.random(128,255),
						b = math.random(128,255)	
					}
				end
				
				if (active_stone == nil) then
					active_stone = {};
					for k,v in pairs(next_stone) do
					    active_stone[k] = v
					  end
					create_next_stone()
				else 
					if (false == update_stone(active_stone)) then
						active_stone = nil;
						score_multiplier = 1;
						AudioManager:playSound("block");
						while check_rows(tetris_field) do score_multiplier = score_multiplier +1; end
						if (score_multiplier > 1) then
							if (score_multiplier < 4) then
								AudioManager:playSound("row");
							else
								AudioManager:playSound("whoosh");
							end
						end
					end
					
				end
				
				timer = 0;
			end
			
			for i = 1, #particle_list do
				ParticleSystem:update(particle_list[i].particle, delta_time)
				particle_list[i].life = particle_list[i].life - delta_time;
				if (particle_list[i].life <= 0) then
					particle_list[i].particle:stop();
				end
			end
			
		end
	end--]]
end

function love.keypressed(key)
	loveframes.keypressed(key);
	current_scene.onKeypressed(key)
	
	--[[if (game_state == 1) then
		if (active_stone ~= nil) then
			if (key == "left" or key == "a") then
				move_stone(active_stone, -1)
			end
		
			if (key == "right" or key == "d") then
				move_stone(active_stone, 1)
			end
			
			if (key == "down" or key == "s") then
				update_stone(active_stone);
			end
			
			if (key == "up" or key == "w") then
				rotate_stone(active_stone);
			end
			
			if (key == "p") then
				game_state = 2;
				AudioManager:playSound("pause");
				love.audio.pause(game_music)
				return;
			end
		end
	end
	
	if (game_state == 0) then
		if (key == "escape") then
			tetris_field = createField(game_config.field_width, game_config.field_height);
			active_stone = nil;
			game_state = 1;
			game_config.speed = 1;
			score = 0;
			AudioManager:playSound("again");
			love.audio.play(game_music)
			love.audio.stop(game_over_music);
		end
	end
	
	if (game_state == 2) then
		if (key == "p" or key == "escape") then
			AudioManager:playSound("pause");
		    love.audio.play(game_music)
			game_state = 1;
		end
	end
	
	if (game_state == 8) then
		if (key == "escape") then game_state = 1; end
	end--]]
end

function love.keyreleased(key) 
	loveframes.keyreleased(key);
end

function love.mousepressed(x, y, button)
    loveframes.mousepressed(x, y, button)
end
 
function love.mousereleased(x, y, button)
    loveframes.mousereleased(x, y, button)
end

block_joy_x = false;
block_joy_y = false;

function love.joystickpressed(joy, button)
	current_scene.onJoystickpressed(joy, button);
	--[[print(button)
	if (button == 1) then
		rotate_stone(active_stone, 1)
	end
	
	if (button == 2) then
		rotate_stone(active_stone, -1)
	end
	
	if (button == 10) then
		if (game_state == 0) then
			tetris_field = createField(game_config.field_width, game_config.field_height);
			love.audio.stop(game_over_music)
			active_stone = nil;
			game_state = 1;
			game_config.speed = 1;
			score = 0;
			AudioManager:playSound("again");
			love.audio.play(game_music)
		elseif (game_state == 2) then
			AudioManager:playSound("pause");
			love.audio.play(game_music)
			game_state = 1;
		elseif (game_state == 1) then
			game_state = 2;
			AudioManager:playSound("pause");
			love.audio.pause(game_music)
		end
	end--]]
	
	
		
end

function handle_joystick()

    local x = love.joystick.getAxis(1,1);
	local y = love.joystick.getAxis(1,2);
	
	if (x == 0) then
		block_joy_x = false;
	end
	
	if (y == 0) then
		block_joy_y = false;
	end
	
	if (game_state == 1) then
			if (active_stone ~= nil) then
				
				if (block_joy_x == false) then
					if (x < 0) then
						love.keypressed("left")
						block_joy_x = true;
					end
				
					if (x > 0) then
						move_stone(active_stone, 1)
						block_joy_x = true;
					end
				end
				
				if (y > 0) then
					update_stone(active_stone);
				end
				
				if (y < 0 and block_joy_y == false) then
					rotate_stone(active_stone, -1);
					block_joy_y = true;
				end

			end
		end
		
		if (game_state == 0) then
			if (love.joystick.isDown(1, 1)) then
				tetris_field = createField(game_config.field_width, game_config.field_height);
				active_stone = nil;
				game_state = 1;
				game_config.speed = 1;
				score = 0;
				AudioManager:playSound("again");
				love.audio.play(game_music)
			end
		end
		
		if (game_state == 2) then
			if (key == "p" or key == "escape") then
				AudioManager:playSound("pause");
			    love.audio.play(game_music)
				game_state = 1;
			end
		end
		
end

--- initializes network
-- sets up socket library via UDP
-- @param address address to connect to
-- @param port    port to connect to
-- @param update  time in seconds before requesting update
-- @return returns udp connection
function initNetwork(address, port, update)
	connection = {};
	connection.udp = socket.udp()
	connection.udp:settimeout(0);
	connection.udp:setpeername(address, port)   
	connection.updateInterval = update; 
	connection.updateTime = 0;
	print ("Listen to " .. address .. ":" .. port .. " every " .. update .. " seconds.");
	network_state = 0;
	return connection;
end

--- updates connection
-- waits for data when update interval is reached
-- data is send to a callback function
-- @param connection connection table
-- @param dt times since last frame
-- @param callback function to call on updateinterval receiving udp data
function updateNetwork(connection, dt, callback)
	connection.updateTime = connection.updateTime + dt;
	if (connection.updateTime >= connection.updateInterval) then
		connection.updateTime = 0;
		callback(connection.udp:receive())		
	end
end

function love.quit()
	connection.udp:send("QUIT");
end

local function error_printer(msg, layer)
    print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end

function love.errhand(message)
	local quit = false;
	
	local frame = loveframes.Create("frame")
	frame:SetSize(500, 300)
	frame:Center()
	frame:SetName("An error occured")
	frame:SetModal(true);
	
	local text = loveframes.Create("text", frame)
	text:SetMaxWidth(400)
	text:SetText(message); -- + "\nPress Escape to exit")
	text:SetParent(frame);
	text:SetPos(5, 30)

	msg = tostring(message)

    error_printer(msg, 2)

    if not love.graphics or not love.event or not love.graphics.isCreated() then
        return
    end

    -- Load.
    --if love.audio then love.audio.stop() end
    --[[love.graphics.reset()
    local font = love.graphics.newFont(14)
    love.graphics.setFont(font)

    love.graphics.setColor(255, 255, 255, 255)


    love.graphics.clear()
    --]]
    local trace = debug.traceback()

    local err = {}

    table.insert(err, "Error\n")
    table.insert(err, msg.."\n\n")

    for l in string.gmatch(trace, "(.-)\n") do
        if not string.match(l, "boot.lua") then
            l = string.gsub(l, "stack traceback:", "Traceback\n")
            table.insert(err, l)
        end
    end

    local p = table.concat(err, "\n")

    p = string.gsub(p, "\t", "")
    p = string.gsub(p, "%[string \"(.-)\"%]", "%1")

    local function draw()
        love.graphics.clear()
        loveframes.draw()
        love.graphics.present()
    end

    draw()

    local e, a, b, c
    while true do
    	loveframes.update()
        e, a, b, c = love.event.wait()
		if e == "joystickpressed" then 
			return 
		end
        if e == "quit" then
            return
        end
        if e == "keypressed" and a == "escape" then
            return
        end
        
        if (quit == true) then return; end

        draw()

    end
end
