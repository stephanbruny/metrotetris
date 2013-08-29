Field = {}

function Field.new(width, height)
	-- initialize field with 0
	local data = {}
	for i = 1, width * height do data[i] = 0; end
	
	return {
		width = width,
		height = height,
		data = data
	}
end

function Field.serialize(field)
	result = "";
	for i=1,field.width do
	    for j=1,field.height do
		    result = result .. field.data[i * field.height + j] .. ",";
        end
    end
    return result;
end

function Field.draw(field, stone_size, x, y)
	for i = 1, field.width do
	    for j = 1, field.height do 
			love.graphics.setColor(255, 255, 255, 64);
			if (field.data[i * field.height + j] == 0) then 
				love.graphics.rectangle("line", x + i * stone_size, y + j *  stone_size,  stone_size,  stone_size )
			end
			
			if (field.data[i * field.height + j] == 1) then 
				love.graphics.setColor(200, 200, 200, 128);
			    love.graphics.rectangle("fill", x + i * stone_size, y + j *  stone_size,  stone_size,  stone_size )
			end
		end
	end
end

function Field.get(field, x, y) 
	return field.data[ x * field.height + y ];
end

function Field.set(field, x, y, value) 
	field.data[ x * field.height + y ] = value;
end

function Field.check_row_complete(field, row)
	local complete = true;
	for x = 1, field.width - 1 do
		if (Field.get(field, x, row) <= 0) then
			complete = false;
		end
	end
	return complete;
end

function Field.move_rows_down(field, row)
	for x = 1, field.width - 1 do
		Field.set(field, x, row, Field.get(field, x, row - 1));
	end
	
	if (row > 2) then
		Field.move_rows_down(field, row - 1);
	end
end

function Field.check_rows(field) 
	for y = 1, field.height do
		local complete = true;
		local row = field.height - (y - 1);
		for x = 1, field.width - 1 do
			if (Field.get(field, x, row) <= 0) then
				complete = false;
			end
		end
		
		if (true == complete) then
			-- clear row
			for w = 1, field.width - 1 do
				Field.set(field, w, row, -1);
				
				-- on_row_callback();
				-- todo: place in callback
				--[[score = score + 10 * score_multiplier;
				
				if (score % 1000 == 0) then
					game_config.speed = game_config.speed / 2;
				end
				
				particle_list[w] = {
					x = w * game_config.stone_size - game_config.stone_size/2,
					y = row * game_config.stone_size - game_config.stone_size/3,
					particle = ParticleSystem:create(),
					life = 0.5;
				};--]]
			end
			return row;
		end
		
	end
	return nil;
end