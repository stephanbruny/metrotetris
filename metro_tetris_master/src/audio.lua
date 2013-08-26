-- Audio manager

AudioManager = {}

local Sounds = {};
local Music = {};

local config = {}

function AudioManager:init(game_config)
	config = game_config;
	love.audio.setVolume(config.sound_volume)
end

function AudioManager:loadSound(name, source)
	Sounds[name] = love.sound.newSoundData(source);
		
end

function AudioManager:playSound(name) 
	if (nil ~= Sounds[name]) then
		love.audio.setVolume(config.sound_volume)
		love.audio.newSource(Sounds[name], "static"):play();
	end
end

function AudioManager:playMusic(source, loop)
	local new_music = love.audio.newSource(source);
    new_music:setVolume(config.music_volume);
	new_music:setLooping(loop);
	love.audio.play(new_music)
	Music = new_music;
end

function AudioManager:stopMusic(source, loop)
	if (Music ~= nil) then
		love.audio.stop(Music);
	end
end

function AudioManager:setSoundVolume(vol)
	
end

function AudioManager:setMusicVolume(vol)
	if (Music ~= nil) then
		Music:setVolume(vol)
	end
end
