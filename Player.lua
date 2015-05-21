Player = class("Player", 
  {playerName = "New Player",
   location = {x = 100, y = 100},
   speed = 5,})

function Player:draw()
  love.graphics.circle('fill', self.location.x, self.location.y, 10, 32)
end

function Player:update(dt)
  if love.keyboard.isDown('s') then self.location.y = self.location.y + self.speed end
  if love.keyboard.isDown('w') then self.location.y = self.location.y - self.speed end
  if love.keyboard.isDown('a') then self.location.x = self.location.x - self.speed end
  if love.keyboard.isDown('d') then self.location.x = self.location.x + self.speed end
end
