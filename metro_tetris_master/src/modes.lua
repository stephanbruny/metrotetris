GameMode = {}

game_modes = {
	{
		name = "Mode A",
		onUpdateStone = function(field, stone)
		
		end
	},
	{
		name = "Mode B"
	},
	{
		name = "Mode C"
	}	
}

function GameMode:GetAllModes()
	return game_modes;
end;

