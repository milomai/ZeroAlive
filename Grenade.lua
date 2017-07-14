Grenade = class("Grenade", {
    range = 100,
    explosiveDelay = 3,
    size = 3,
    linearDamping = 5,
    })

function Grenade:init(physics, posX, posY)
  self.pos = {x = posX, y = posY}
  self.physics = physics
  self.shape = love.physics.newCircleShape(self.size)
  self.body = love.physics.newBody(physics, posX, posY, "dynamic")
  self.body:setLinearDamping(self.linearDamping)
  self.fixture = love.physics.newFixture(self.body, self.shape)
  self.fixture:setGroupIndex(RAILGUN_GROUP.player)
  self.body:setActive(false)
  self.fixture:setUserData(self)
  --self.debug = {}
end

function Grenade:update(dt)
  self.pos.x = self.body:getX()
  self.pos.y = self.body:getY()
  
  self.explosiveDelay  = self.explosiveDelay - dt
  if self.explosiveDelay <= 0 then
    self:explosive()
  end
  
  if self.ps then
    self.ps:update(dt)
    if self.removeRemainTime <= 0 then
      self.removed = true
    end
    self.removeRemainTime = self.removeRemainTime - dt
  end
end

function Grenade:draw()
  if self.removed then return end
  
  love.graphics.push("all")
  if self.ps then
    love.graphics.draw(self.ps, self.pos.x, self.pos.y)
  else
    love.graphics.setColor(0, 0, 255, 255)
    love.graphics.circle('fill', self.pos.x, self.pos.y, self.size, 6)
  end
  love.graphics.pop()
  
  if self.debug then
    love.graphics.push("all")
    --[[
    for j, hit in ipairs(hits) do
      for i, pos in ipairs(hit) do
        love.graphics.print(pos.index, pos.x, pos.y)
        love.graphics.setLineWidth(1)
        love.graphics.line(hit.pos.x, hit.pos.y, pos.x, pos.y)
      end
    end]]
    
    love.graphics.circle("line",self.pos.x, self.pos.y, self.range)
    love.graphics.pop()
  end
end

local hit --用来记录一条射线碰到的最近的物体

local function rayCastCallback(fixture, posX, posY, xn, yn, fraction)
  if fixture:getGroupIndex() == RAILGUN_GROUP.enemy then
    local enemy = fixture:getUserData()
    hit = enemy
  else 
    hit = nil --如果最近的物体不是敌人，就置空
  end
  return fraction --返回当前碰到的物体的系数，以保证接下来碰撞到的物体一定是比现在的离爆炸点更近
end

function Grenade:explosive()
  self.disable = true
  local startPos = self.pos
  local rayCount = 128
  local deltaAngle = math.pi*2/rayCount
  local angle = 0
  local range = self.range
  if self.debug then
    self.debug.rays = {}
  end
  for num = 1, rayCount do
    local endPos = {}
    endPos.y = startPos.y + math.sin(deltaAngle*num)*range
    endPos.x = startPos.x + math.cos(deltaAngle*num)*range
    hit = nil
    self.physics:rayCast(startPos.x, startPos.y, endPos.x, endPos.y, rayCastCallback)
    if hit then
      hit:die()
    end
  end
  
  if not self.ps then
    local image = love.graphics.newImage('res/img/plus.png')
    self.ps = getPS('res/particle/Explosive', image)
    self.removeRemainTime = self.ps:getEmitterLifetime()+math.max(self.ps:getParticleLifetime())
  end
end

function Grenade:throw(targetX, targetY)
  local force = 30
  local angle = math.angle(self.pos.x, self.pos.y, targetX, targetY)
  local dx = force * math.cos(angle)
  local dy = force * math.sin(angle)
  self.body:applyLinearImpulse(dx, dy)
end