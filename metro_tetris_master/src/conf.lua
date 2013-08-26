function love.conf(config)
	config.title = "Metro Tetris"    
	config.screen.width = 1280;
	config.screen.height = 768;
end

game_config = {
	field_width = 10,
	field_height = 20,
	stone_size = 32,
	speed = 1,
	next_speed = 0.2,
    next_level_score = 1000,
    background_image = "assets/background.png",
	music_volume = 0.5,
	sound_volume = 0.5,
	background_scale_x = 1,
	background_scale_y = 1,
	server = {
		ip =  "78.47.85.70",
		port = 1337
	},
	gamepad = {
		{
			button_rot_left = 5,
			button_rot_right = 6,
			button_start = 10,
			button_back = 9,
			axis_update = 0.1
		},
		{
			button_rot_left = 5,
			button_rot_right = 6,
			button_start = 10,
			button_back = 9,
			axis_update = 0.1
		}
	},
	display = {
		full_screen = false,
		width = 1280,
		height = 768
	}
}
