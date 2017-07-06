require('Weapon')
Player = class("Player", 
  {playerName = "New Player",
   pos = {x = 50, y = 50},
   size = 10,
   speed = 640,
   alive = true,
   hp = 100,
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
  self.image = love.graphics.newImage("res/img/player.png")
  self.tile = {}
  self.light = {
    color = {255, 127, 63},
    range = 300
    }
end

function Player:setSpeed(speed)
  self.speed = speed
  self.slash = self.speed/2^0.5
end

function Player:draw()
  if self.image then
    love.graphics.draw(self.image, self.pos.x - (self.image:getWidth()/2), self.pos.y - (self.image:getHeight()/2))
  end
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
  if downKeys == 's'  then self.body:applyLinearImpulse(0, self.speed*dt) end
  if downKeys == 'w'  then self.body:applyLinearImpulse(0, -self.speed*dt) end
  if downKeys == 'a'  then self.body:applyLinearImpulse(-self.speed*dt, 0) end
  if downKeys == 'd'  then self.body:applyLinearImpulse(self.speed*dt, 0) end
  if downKeys == 'wa' then self.body:applyLinearImpulse(-self.slash*dt, -self.slash*dt) end
  if downKeys == 'wd' then self.body:applyLinearImpulse(self.slash*dt, -self.slash*dt) end
  if downKeys == 'sa' then self.body:applyLinearImpulse(-self.slash*dt, self.slash*dt) end
  if downKeys == 'sd' then self.body:applyLinearImpulse(self.slash*dt, self.slash*dt) end
  
  --self.pos.x = self.pos.x + dx * dt
  --self.pos.y = self.pos.y + dy * dt
end

function Player:update(dt)
  self.pos.x = self.body:getX()
  self.pos.y = self.body:getY()
  local currentTile = {}
  currentTile = world.map:tileCoordinates(self.pos)
  if not (currentTile.x == self.tile.x) or not (currentTile.y == self.tile.y) then
    self.tileChanged = true
    self.tile = currentTile
  else
    self.tileChanged = false
  end
  if self.weapon then self.weapon:update(dt) end
  if self.light.object then
    self.light.object.setPosition(world:screenCoordinates(self.pos.x, self.pos.y))
  end
end

function Player:hit(damge)
  self.hp = self.hp - damge
  if self.hp <= 0 then
    self:die()
  end
end

function Player:die()
  self.alive = false
  self.removed = true
  self.collidable = false
end
