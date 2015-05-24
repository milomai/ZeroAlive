Enemy = class("Enemy", {size = 8, collidable = true, speed = 40})

function Enemy:init()
  self.pos = {}
end

function Enemy:draw()
  love.graphics.setColor(255, 0, 0, 255)
  love.graphics.circle('fill', self.pos.x, self.pos.y, self.size, 16)
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
  self:moveTo(self.target.x, self.target.y, dt)
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