ParticleSystem = {}

function ParticleSystem:create()
	print("Create Particle System")
	  id = love.image.newImageData(32, 32)
	  --1b. fill that blank image data
	  for x = 0, 8 do
	    for y = 0, 8 do
	      local gradient = 1 - ((x-15)^2+(y-15)^2)/40
	      id:setPixel(x, y, 255, 255, 255, 255)
	    end
	  end
	  
	  --2. create an image from that image data
	  i = love.graphics.newImage(id)
	  
	  --3a. create a new particle system which uses that image, set the maximum amount of particles (images) that could exist at the same time to 256
	  p = love.graphics.newParticleSystem(i, 256)
	  --3b. set various elements of that particle system, please refer the wiki for complete listing
	  p:setEmissionRate          (5)
	  p:setLifetime              (3)
	  p:setParticleLife          (1)
	  p:setPosition              (50, 50)
	  p:setDirection             (-1.57)
	  p:setSpread                (2)
	  p:setSpeed                 (20, 100)
	  p:setGravity               (0)
	  p:setRadialAcceleration    (0)
	  p:setTangentialAcceleration(0)
	  p:setSizes                  (1,2,3)
	  p:setSizeVariation         (0.5)
	  p:setRotation              (0)
	  p:setSpin                  (1)
	  p:setSpinVariation         (0)
	  p:setColors                 (255, 255, 255, 250, 255, 255, 255, 10)
	  p:stop();--this stop is to prevent any glitch that could happen after the particle system is created
	
	return p;
end

function ParticleSystem:update(particles, delta)
	particles:start();
	particles:update(delta);
end

function ParticleSystem:draw(particles, x, y) 
	love.graphics.draw(particles, x, y);
end