Enemy = class("Enemy", {size = 8, collidable = true, speed = 36, alive = true, linearDamping = 1, damge = 5})

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
  love.graphics.push()
  if self.alive then
    love.graphics.setColor(200, 0, 0, 255)
    love.graphics.circle('fill', self.pos.x, self.pos.y, self.size, 16)
  elseif self.diePS then
    love.graphics.draw(self.diePS, self.pos.x, self.pos.y)
  end
  love.graphics.pop()
end

--向指定坐标移动
function Enemy:moveTo(pos, dt)
  local angle = math.angle(self.pos.x, self.pos.y, pos.x, pos.y)
  local dx = self.speed * math.cos(angle) * dt
  local dy = self.speed * math.sin(angle) * dt
  self.body:applyLinearImpulse(dx, dy)
end

function Enemy:findPathTo(target)
  self.path = world.map:findPath(self.pos, target)
end

function Enemy:moveOnPath(dt)
  if not self.path then return end
  local target = self.path[1]
  if self.currentTile.x == target.x and self.currentTile.y == target.y then
    table.remove(self.path, 1)
    target = self.path[1]
  end
  if not target then 
    self.path = nil 
    return 
  end
  self:moveTo(world.map:worldCoordinates(target), dt)
end

function Enemy:update(dt)
  self.pos.x = self.body:getX()
  self.pos.y = self.body:getY()
  if self.alive then
    if not self.currentTile then self.currentTile = {} end
    
    -- 如果和目标在同一个tile上，直接向目标移动
    self.currentTile = world.map:tileCoordinates(self.pos)
    local target = {}
    target = world.map:tileCoordinates(self.target.pos)
    if self.currentTile.x == target.x and self.currentTile.y == target.y then
      self:moveTo(self.target.pos, dt)
    else
      if self.target.tileChanged or not self.path then
        startTime = love.timer.getTime()
        self:findPathTo(self.target.pos)
        print(self.id .. ' end: +' .. (love.timer.getTime() - startTime))
      end
      self:moveOnPath(dt)
    end
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

function Enemy:attack(roler)
  roler:hit(self.damge)
end

function Enemy.Generate(posX, posY, size)
  if posX == nil then posX = world.size.width * love.math.random() end
  if posY == nil then posY = world.size.height * love.math.random() end
  if size == nil then size = 20 end
  local pos = {x = posX, y = posY}
  while world.map:isSolid(pos) do
    pos.x = world.size.width * love.math.random()
    pos.y = world.size.height * love.math.random()
  end
  local enemy = Enemy:new(pos.x, pos.y)
  enemy.target = player
  world:add(enemy)
end