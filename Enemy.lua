Enemy = class("Enemy", {size = 8, collidable = true, speed = 40, alive = true})

function Enemy:init()
  self.pos = {}
end

function Enemy:draw()
  if self.alive then
    love.graphics.setColor(200, 0, 0, 255)
    love.graphics.circle('fill', self.pos.x, self.pos.y, self.size, 16)
  elseif self.diePS then
    love.graphics.draw(self.diePS, self.pos.x, self.pos.y)
  end
end

--向指定坐标移动
function Enemy:moveTo(x, y, dt)
  local angle = math.angle(self.pos.x, self.pos.y, x, y)
  local dx = self.speed * math.cos(angle) * dt
  local dy = self.speed * math.sin(angle) * dt
  self.pos.x = self.pos.x + dx
  self.pos.y = self.pos.y + dy
end

function Enemy:update(dt)
  if self.alive then
    self:moveTo(self.target.x, self.target.y, dt)
  elseif self.diePS then
    self.diePS:update(dt)
    if self.removeRemainTime <= 0 then
      self.removed = true
    end
    self.removeRemainTime = self.removeRemainTime - dt
  end
end

function Enemy:die()
  if not self.alive then return end
  self.alive = false
  self.collidable = false
  if not self.diePS then
    local image = love.graphics.newImage('circle.png')
    self.diePS = getPS('Blood', image)
    self.removeRemainTime = self.diePS:getEmitterLifetime()+math.max(self.diePS:getParticleLifetime())
  end
end

function Enemy.Generate(posX, posY, size)
  if posX == nil then posX = world.size.width * love.math.random() end
  if posY == nil then posY = world.size.height * love.math.random() end
  if size == nil then size = 20 end
  local enemy = Enemy:new()
  enemy.pos.x = posX
  enemy.pos.y = posY
  enemy.target = player.pos
  world:add(enemy)
end