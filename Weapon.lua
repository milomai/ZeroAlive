Weapon = class("Weapon", {
    rpm = 600, 
    auto = true, 
    accuracy = 4*math.pi/180,
    ammo = 5})

function Weapon:init()
  local image = love.graphics.newImage('res/img/circle.png')
  self.ps = getPS('res/particle/Fire', image)
end

function Weapon:fire()
  if self.isFire then return end
  self.isFire = true
  if self.auto then self.fireTime = love.timer.getTime() end
end

function Weapon:stop()
  self.isFire = false
end

function Weapon:handleInput()
  if love.mouse.isDown('l') then
    player.weapon:fire()
  else
    player.weapon:stop()
  end
end

function Weapon:update(dt)
  if self.isFire and self.auto then
    if self.ps then 
      self.ps:update(dt) 
    end
    local x, y = world:mousePos()
    while self.fireTime < love.timer.getTime() and self.ammo > 0 do
      local bullet = Bullet:new(player.pos.x, player.pos.y, x, y, self.accuracy)
      world:add(bullet)
      self.ammo = self.ammo - 1
      fireSinceNow = love.timer.getTime() - self.fireTime
      self.fireTime = self.fireTime + 1/(self.rpm/60)
    end
    if self.ammo <= 0 then
      self:stop()
    end
  end
end

function Weapon:draw()
  if self.isFire and self.ps and self.auto then
    love.graphics.draw(self.ps, player.pos.x, player.pos.y)
  end
end