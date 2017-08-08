Bullet = GameObject:extend("Bullet", {size = 1, linearDamping = 1})

local trackImage = gradient({{255,255,255,255},{255,255,255,0}})

local id = 1

function Bullet:init()
  self.pos = {}
end

function Bullet:init(posX, posY)
  self.super.init(self, posX, posY)
  id = id + 1
  self.id = id
  self.physic.body:setBullet(true)
  self.physic.body:setLinearDamping(self.linearDamping)
  self.physic.fixture:setCategory(RAILGUN_GROUP.bullet)
  self.physic.fixture:setMask(RAILGUN_GROUP.player)
end

function Bullet:deltaValue(speed, angle)
  self.dx = speed * math.cos(angle)
  self.dy = speed * math.sin(angle)
end

function Bullet:debugDraw()
  love.graphics.push('all')
  love.graphics.setPointSize(1)
  love.graphics.setColor(255, 0, 0, 255)
  love.graphics.points(self.pos.x, self.pos.y)
  love.graphics.print(self.id, self.pos.x, self.pos.y)
  love.graphics.pop()
end

function Bullet:draw()
  self.super.draw(self)
  drawInRect(trackImage, self.pos.x, self.pos.y, self.speed/30, 1, math.pi + self.angle)
end

function Bullet:update(dt)
  self.super.update(self, dt)
  local speedX, speedY = self.physic.body:getLinearVelocity()
  self.speed = math.sqrt(speedX * speedX + speedY * speedY)
  if self.speed  == 0 then
    self.removed = true
  end
end

function Bullet:fly(speed, angle)
  self.angle = angle
  self:deltaValue(speed, angle)
  self.physic.body:applyLinearImpulse(self.dx, self.dy)
end