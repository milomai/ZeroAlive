Enemy = class("Enemy", {size = 8, collidable = true, speed = 1200, alive = true, linearDamping = 1})

function Enemy:init(posX, posY)
  self.pos = {}
  self.shape = love.physics.newCircleShape(self.size)
  self.body = love.physics.newBody(world.physics, posX, posY, "dynamic")
  self.body:setLinearDamping(self.linearDamping)
  self.fixture = love.physics.newFixture(self.body, self.shape)
  self.body:setActive(false)
  self.fixture:setUserData(self)
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
  self.body:applyForce(dx, dy)
end

function Enemy:update(dt)
  self.pos.x = self.body:getX()
  self.pos.y = self.body:getY()
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
    local image = love.graphics.newImage('res/img/circle.png')
    self.diePS = getPS('res/particle/Blood', image)
    self.removeRemainTime = self.diePS:getEmitterLifetime()+math.max(self.diePS:getParticleLifetime())
  end
end

function Enemy.Generate(posX, posY, size)
  if posX == nil then posX = world.size.width * love.math.random() end
  if posY == nil then posY = world.size.height * love.math.random() end
  if size == nil then size = 20 end
  local enemy = Enemy:new(posX, posY)
  enemy.target = player.pos
  world:add(enemy)
end