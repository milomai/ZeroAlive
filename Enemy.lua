Enemy = class("Enemy", {size = 8})

function Enemy:init()
  self.pos = {}
end

function Enemy:draw()
  love.graphics.setColor(255, 0, 0, 255)
  love.graphics.circle('fill', self.pos.x, self.pos.y, self.size, 16)
end

function Enemy.Generate(posX, posY, size)
  if posX == nil then posX = love.window.getWidth() * love.math.random() end
  if posY == nil then posY = love.window.getHeight() * love.math.random() end
  if size == nil then size = 20 end
  local enemy = Enemy:new()
  enemy.pos.x = posX
  enemy.pos.y = posY
  enemySet[enemy] = true
end