Weapon = class("Weapon", {rpm = 400, auto = true, accuracy = 4*math.pi/180})

function Weapon:fire()
  if self.isFire then return end
  self.isFire = true
  if self.auto then self.fireTime = love.timer.getTime() end
end

function Weapon:stop()
  self.isFire = false
end

function Weapon:update(dt)
  if self.auto then
    local x, y = love.mouse.getPosition();
    while self.fireTime < love.timer.getTime() and self.isFire do
      local bullet = Bullet:new(player.pos.x, player.pos.y, x, y, self.accuracy)
      bulletSet[#bulletSet+1] = bullet
      fireSinceNow = love.timer.getTime() - self.fireTime
      bullet:updateLocation(fireSinceNow)
      self.fireTime = self.fireTime + 1/(self.rpm/60)
    end
  end
end