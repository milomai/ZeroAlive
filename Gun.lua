require("Bullet")

Gun = class("Gun", {
    rpm = 600,                --每分钟射速
    auto = true, 
    accuracy = 4*math.pi/180,
    maxAmmo = 30,
    reloadTime = 3,})

function Gun:init()
  --开火效果
  local image = love.graphics.newImage('res/img/circle.png')
  self.ps = getPS('res/particle/Fire', image)
  
  self.ammo = self.maxAmmo
  self.remainReloadTime = 0
end

function Gun:fire()
  if self.ammo <= 0 then return end --弹药不足不能开火
  if self.isFire then return end
  self.isFire = true
  if self.auto then self.fireTime = love.timer.getTime() end
end

function Gun:shot(dt)
  local x, y = world:mousePos()
  while self.fireTime < love.timer.getTime() and self.ammo > 0 do
    local bullet = Bullet:new(player.pos.x, player.pos.y, x, y, self.accuracy)
    world:add(bullet)
    self.ammo = self.ammo - 1
    self.fireTime = self.fireTime + 1/(self.rpm/60)
  end
end

function Gun:stop()
  self.isFire = false
end

function Gun:handleInput()
  if love.mouse.isDown(1) then
    player.weapon:fire()
  else
    player.weapon:stop()
  end
end

function Gun:reload()
  self.remainReloadTime = self.reloadTime
end

function Gun:update(dt)
  if self.remainReloadTime > 0 then
    self.remainReloadTime = self.remainReloadTime - dt
    if self.remainReloadTime <= 0 then
      self.ammo = self.maxAmmo
    end
  end
  if self.isFire and self.auto then
    if self.ps then 
      self.ps:update(dt) 
    end
    self:shot()
    if self.ammo <= 0 and self.remainReloadTime <= 0 then
      self:stop()
      self:reload()
    end
  end
end

function Gun:draw()
  if self.isFire and self.ps and self.auto then
    love.graphics.draw(self.ps, player.pos.x, player.pos.y)
  end
end