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
  self.nextChangeTime = 1
  self.effectObjects = {}
  --self.debug = {}
end

local hit --用来记录一条射线碰到的最近的物体

local function rayCastCallback(fixture, posX, posY, xn, yn, fraction)
  hit = fixture:getUserData()
  return fraction
end

function Grenade:update(dt)
  self.pos.x = self.body:getX()
  self.pos.y = self.body:getY()
  
  self.explosiveDelay  = self.explosiveDelay - dt
  if self.explosiveDelay <= self.nextChangeTime then
    self.nextChangeTime = self.nextChangeTime - 0.1
    self.flash = not self.flash
  end
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
  
  --不清楚什么时候会为空，但是遇到过pos为空闪退的情况
  if not self.pos then 
    print("error!!!")
    return 
  end
  
  --向传感器碰到的物体发出射线
  for _, object in ipairs(self.effectObjects) do
    if class.isInstance(object, Enemy) then
      if not object.pos then
        print("error!!")
      else 
        self.physics:rayCast(self.pos.x, self.pos.y, object.pos.x, object.pos.y, rayCastCallback)
        if hit == object then
          hit:die()
          hit = nil
        end
      end
    end
  end
end

function Grenade:draw()
  if self.removed then return end
  
  love.graphics.push("all")
  if self.ps then
    love.graphics.draw(self.ps, self.pos.x, self.pos.y)
  else
    if self.flash then
      love.graphics.setColor(200, 200, 255, 255)
    else
      love.graphics.setColor(0, 0, 255, 255)
    end
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
    end--]]
    
    love.graphics.circle("line",self.pos.x, self.pos.y, self.range)
    love.graphics.pop()
  end
end

--[[
爆炸效果实现原理：
1、在爆炸位置生成一个圆形传感器
2、检测传感器碰到的物体
3、向检测到的物体发出一条射线
4、通过射线检查爆炸位置和物体间是否有障碍物
5、没有障碍物就把目标炸掉
]]
function Grenade:explosive()
  if self.disable then return end
  self.disable = true
  local startPos = self.pos
  local rayCount = 256
  local deltaAngle = math.pi*2/rayCount
  local angle = 0
  local range = self.range
  
  --生成传感器（碰撞检测回调在 World.lua 中）
  self.explosiveShape = love.physics.newCircleShape(self.range)
  self.explosiveBody = love.physics.newBody(self.physics, self.pos.x, self.pos.y, "dynamic")
  self.explosiveFixture = love.physics.newFixture(self.explosiveBody, self.explosiveShape)
  self.explosiveFixture:setUserData(self)
  self.explosiveFixture:setSensor(true)
  self.explosiveFixture:setMask(RAILGUN_GROUP.wall, RAILGUN_GROUP.bullet, RAILGUN_GROUP.effect, RAILGUN_GROUP.grenade)
  self.explosiveFixture:setCategory(RAILGUN_GROUP.effect)
  
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