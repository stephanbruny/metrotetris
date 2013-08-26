require("../field")
require("../stone")

SingleplayerScene = {}

local state = 1;

local field_width = 10;
local field_height = 20;
local block_size = 32;
local offsetX, offsetY = 0, 0;
local field = {}

function SingleplayerScene.onLoad()
	field = Field.new(field_width, field_height);
	offsetX = love.graphics.getWidth() / 2 - (field_width / 2 * block_size) ;
	offsetY = love.graphics.getHeight() / 2 - (field_height / 2 * block_size);
end

function SingleplayerScene.onDraw()
	Field.draw(field, 32, offsetX, offsetY);
end

function SingleplayerScene.onUpdate(dt)

end

function SingleplayerScene.onKeypressed(key)

end

function SingleplayerScene.onJoystickpressed(joy, key)

end