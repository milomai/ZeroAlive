require('Weapon')
Player = class("Player", 
  {playerName = "New Player",
   location = {x = 100, y = 100},
   speed = 3,})

function Player:init()
  self.slash = self.speed/2^0.5
end

function Player:setSpeed(speed)
  self.speed = speed
  self.slash = self.speed/2^0.5
end

function Player:draw()
  love.graphics.circle('fill', self.location.x, self.location.y, 10, 32)
end

function Player:update(dt)
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
  
  self.location.x = self.location.x + dx
  self.location.y = self.location.y + dy
end
