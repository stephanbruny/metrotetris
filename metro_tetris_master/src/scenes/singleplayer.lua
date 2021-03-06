require("../field")
require("../stone")

local tween = require("../lib/tween/tween")

SingleplayerScene = {}

local state = 1;

local field_width = 11;
local field_height = 21;
local block_size = 32;
local offsetX, offsetY = 0, 0;
local field = {}
local blink = { alpha = 255 };
local config = {}

local update_interval = 0.5;
local block_timer = 0;

local current_block = {}
local next_block = {}

local scores = {
	40,
	120,
	300,
	1200
}

local player_score = 0;

local block_colors = {
	{r = 255, g = 255, b = 255, a = 200},
	{r = 255, g = 200, b = 0, a = 200},
	{r = 255, g = 0, b = 200, a = 200}
}

local row_color = {
	r = 200, 
	g = 200, 
	b = 200, 
	a = 255,
}

local function start_game()
	state = 2;
	current_block = Stone.new(field);
	next_block = Stone.new(field);
end

local function blink_ready()
	local a = 0;
	
	if (blink.alpha == 255) then a = 0 else a = 255; end
	
	tween.start(1, blink, {alpha = a}, "linear", function() blink_ready() end)
end

function SingleplayerScene.onLoad(conf)
	field = Field.new(field_width, field_height);
	print(Tserial.pack(field));
	offsetX = love.graphics.getWidth() / 2 - (field_width / 2 * block_size) - block_size;
	offsetY = love.graphics.getHeight() / 2 - (field_height / 2 * block_size) - block_size;
	blink_ready();
	config = conf;
end

function SingleplayerScene.onDraw()
	-- Field.draw(field, 32, offsetX, offsetY);
	
	for i = 1, field.width do
	    for j = 1, field.height do 
			love.graphics.setColor(255, 255, 255, 64);
			if (field.data[i * field.height + j] == 0) then 
				love.graphics.rectangle("line", offsetX + i * block_size, offsetY + j *  block_size,  block_size,  block_size )
			end
			
			if (field.data[i * field.height + j] == 1) then 
				love.graphics.setColor(200, 200, 200, 128);
			    love.graphics.rectangle("fill", offsetX + i * block_size, offsetY + j *  block_size,  block_size,  block_size )
			end
			
			if (field.data[i * field.height + j] == -1) then 
				love.graphics.setColor(255, 200, 200, blink.alpha);
			    love.graphics.rectangle("fill", offsetX + i * block_size, offsetY + j *  block_size,  block_size,  block_size )
			end
		end
	end
	
	love.graphics.setColor(0,0,255,200);
	love.graphics.setLine(2, "smooth");
	love.graphics.rectangle("line", offsetX + block_size, offsetY + block_size, field_width * block_size - block_size, field_height * block_size);
	
	if (state == 1) then
		love.graphics.setColor(255, 255, 0, blink.alpha)
		love.graphics.printf("Ready?", love.graphics.getWidth() / 2, love.graphics.getHeight() / 2 - 24, 0, "center", 200)
	end	
	
	if (state >= 2 and state <= 4) then
		if (current_block ~= nil) then
			local offsetBlockX = offsetX + current_block.x * block_size;
			local offsetBlockY = offsetY + current_block.y * block_size;
			
			for x = 1, #current_block.data do
				for y = 1, #current_block.data[x] do
					if (current_block.data[x][y] > 0) then
						love.graphics.setColor(current_block.color.r, current_block.color.g, current_block.color.b, 255);
						love.graphics.rectangle("fill", offsetBlockX + x * block_size, offsetBlockY + y *  block_size,  block_size,  block_size )
					end
					
				end
			end
		end
		love.graphics.setColor(255,255,255,255);
		love.graphics.print("Score: " .. player_score, 5, 5);
	end
end

local function create_next_block()
	current_block = next_block;
	next_block = Stone.new(field);
end

local function make_solid(stone)
	timer = game_config.speed;
	for x = 1, #stone.data do
		for y = 1, #stone.data[x] do
			if (stone.data[x][y] > 0) then
				field.data[ (stone.x + x) * field_height + stone.y + y ] = 1;
			end
		end
	end
end

function SingleplayerScene.onUpdate(dt)
	tween.update(dt);
	if (state == 2) then
		block_timer = block_timer + dt;
		if (block_timer >= update_interval) then
			Stone.update_stone(current_block, function()
				origCol = {}
				for k,v in pairs(current_block.color) do
					origCol[k] = v;
				end 
				state = 3;
				tween.start(0.05, current_block.color, {r = 255, b = 255, g = 255}, "inQuad", function() 
					tween.start(0.05, current_block.color, {r = origCol.r, b = origCol.b, g = origCol.g}, "inQuad", function() 
						-- make solid
						make_solid(current_block)
						local rows = {};
						
						local next_row = Field.check_rows(field);
						local ri = 1;
						while next_row ~= nil
							do 
								rows[ri] = next_row;
								ri = ri + 1; 
								next_row = Field.check_rows(field);
						end
						
						
						if (#rows > 0) then
							
							tween.start(0.5, {r=1}, {r=0}, "linear", function()
								for i = 0, #rows - 1 do
									Field.move_rows_down(field, rows[#rows - i]);
								end
								player_score = player_score + scores[#rows];
							end);
						end
						create_next_block();
						state = 2;
					end);
				end) 
			end);
			block_timer = 0;
		end
	end
end

function SingleplayerScene.onKeypressed(key)
	if (key == " " or key == "return") then
		if (state == 1) then 
			start_game(); 
		end;
	end
	
	if (state == 2) then
		if (current_block ~= nil) then
			if (key == "left") then
				Stone.move_stone(current_block, -1, field);
			end
			
			if (key == "right") then
				Stone.move_stone(current_block, 1, field);
			end
			
			if (key == "up") then
				Stone.rotate_stone(current_block, -1);
			end
			
			if (key == "down") then
				block_timer = update_interval;
			end
		end
	end
end

function SingleplayerScene.onJoystickpressed(joy, key)
	if (key == config.gamepad[1].button_start) then
		if (state == 1) then start_game();end;
	end
end