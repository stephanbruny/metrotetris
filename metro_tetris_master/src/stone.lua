require("stone_data");

Stone = {}

sample_stone = {
	data = {},
	rotation = 0,
	x = 0,
	y = 0
}

function Stone.new()
	next_stone = {};
	next_stone.y = 0;
	next_stone.rot = 1;
	next_stone.x = math.floor(game_config.field_width / 2) - 1;
	next_stone.pattern = STONES[math.random(1, #stones)];
	next_stone.data = next_stone.pattern[1];
	next_stone.color = {
		r = math.random(128,255),
		g = math.random(128,255),
		b = math.random(128,255)	
	}
	return next_stone;
end

function Stone.update_stone(stone)
	for x = 1, #stone.data do
		for y = 1, #stone.data[x] do
			if (stone.data[x][y] > 0) then
				if (stone.y + y >= game_config.field_height) then
					make_solid(stone);
					return false;
				end
				
				if (check_field(stone.x + x, stone.y + y + 1) > 0) then
					if (stone.y + y < 2) then
						game_over();
					end
					make_solid(stone);
					return false;
				end
			end
		end
	end
	stone.y = stone.y + 1;
	return true;
end

-- dir can be -1 or 1
-- 0 left
-- 1 right
function Stone.move_stone(stone, dir, field)
	local canMove = 1;
	
	if (dir == -1 and stone.x == 0) then return; end
	
	for x = 1, #stone.data do
		for y = 1, #stone.data[x] do
			if (stone.data[x][y] > 0) then
				if (dir == 1 and stone.x + x >= game_config.field_width) then return end;
				if (check_field(stone.x + x + dir, stone.y + y) > 0) then
					return;
				end
			end
		end
	end
	
	if (canMove == 1) then
		stone.x = stone.x + dir;
		AudioManager:playSound("move");
	end
end

function Stone.rotate_stone(stone, dir)
	if (nil == stone) then return false; end;
	local old_rot = stone.rot;
	
	if (dir == 1) then
		if (stone.rot < #stone.pattern) then
			stone.rot = stone.rot + dir;
		else
			stone.rot = 1;
		end
	else
		if (stone.rot > 1) then
			stone.rot = stone.rot + dir;
		else
			stone.rot = #stone.pattern;
		end
	end
	
	stone.data = stone.pattern[stone.rot];	
	
	if (nil == stone.data or stone == nil) then return false; end;
	
	-- move stone from borders
	for x = 1, #stone.data do
    if (stone.data[x] == nil) then return false; end
		for y = 1, #stone.data[x] do
			if (stone.x + x > game_config.field_width) then
				stone.x = stone.x - 1;
			end
			
			if (stone.y + y > game_config.field_height) then
				stone.y = stone.y - 1;
			end
			
			if (check_field(stone.x + x, stone.y + y) > 0) then
				stone.data = stone.pattern[old_rot];
				stone.rot = old_rot;
			end
		end
	end
	--AudioManager:playSound("rotate");
	return true;
end
