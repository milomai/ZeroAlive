require('Weapon')
Player = class("Player", 
  {playerName = "New Player",
   pos = {x = 1000, y = 1000},
   size = 10,
   speed = 80,})

function Player:init()
  self.slash = self.speed/2^0.5
end

function Player:setSpeed(speed)
  self.speed = speed
  self.slash = self.speed/2^0.5
end

function Player:draw()
  love.graphics.setColor(0, 119, 0, 255)
  love.graphics.circle('fill', self.pos.x, self.pos.y, self.size, 16)
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
  
  local dx, dy = 0, 0
  if downKeys == 's'  then dy = self.speed end
  if downKeys == 'w'  then dy = -self.speed end
  if downKeys == 'a'  then dx = -self.speed end
  if downKeys == 'd'  then dx = self.speed end
  if downKeys == 'wa' then dy, dx = -self.slash, -self.slash end
  if downKeys == 'wd' then dy, dx = -self.slash, self.slash end
  if downKeys == 'sa' then dy, dx = self.slash, -self.slash end
  if downKeys == 'sd' then dy, dx = self.slash, self.slash end
  
  self.pos.x = self.pos.x + dx * dt
  self.pos.y = self.pos.y + dy * dt
end

function Player:update(dt)
  if self.weapon then self.weapon:update(dt) end
end
