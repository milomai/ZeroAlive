require('Weapon')
Player = class("Player", 
  {playerName = "New Player",
   pos = {x = 50, y = 50},
   size = 10,
   speed = 640,
   alive = true,
   collidable = true,
   forceDraw = true,
   linearDamping = 16})

function Player:init()
  self.slash = self.speed/2^0.5
  self.shape = love.physics.newCircleShape(self.size)
  self.body = love.physics.newBody(world.physics, self.pos.x, self.pos.y, "dynamic")
  self.body:setLinearDamping(self.linearDamping)
  self.fixture = love.physics.newFixture(self.body, self.shape)
  self.body:setActive(false)
  self.fixture:setUserData(self)
end

function Player:setSpeed(speed)
  self.speed = speed
  self.slash = self.speed/2^0.5
end

function Player:draw()
  love.graphics.setColor(0, 119, 0, 255)
  love.graphics.circle('fill', self.pos.x, self.pos.y, self.size, 16)
  if self.weapon then
    self.weapon:draw()
  end
end

function Player:handleInput(dt)
  if self.weapon and type(self.weapon.handleInput) == 'function' then
    self.weapon:handleInput()
  end
  
  local downKeys = ''
  if love.keyboard.isDown('s') then downKeys = downKeys..'s' end
  if love.keyboard.isDown('w') then downKeys = downKeys..'w' end
  if love.keyboard.isDown('a') then downKeys = downKeys..'a' end
  if love.keyboard.isDown('d') then downKeys = downKeys..'d' end
  
  --local dx, dy = 0, 0
  if downKeys == 's'  then self.body:applyForce(0, self.speed) end
  if downKeys == 'w'  then self.body:applyForce(0, -self.speed) end
  if downKeys == 'a'  then self.body:applyForce(-self.speed, 0) end
  if downKeys == 'd'  then self.body:applyForce(self.speed, 0) end
  if downKeys == 'wa' then self.body:applyForce(-self.slash, -self.slash) end
  if downKeys == 'wd' then self.body:applyForce(self.slash, -self.slash) end
  if downKeys == 'sa' then self.body:applyForce(-self.slash, self.slash) end
  if downKeys == 'sd' then self.body:applyForce(self.slash, self.slash) end
  
  --self.pos.x = self.pos.x + dx * dt
  --self.pos.y = self.pos.y + dy * dt
end

function Player:update(dt)
  self.pos.x = self.body:getX()
  self.pos.y = self.body:getY()
  if self.weapon then self.weapon:update(dt) end
end

function Player:die()
  self.alive = false
  self.removed = true
  self.collidable = false
end
