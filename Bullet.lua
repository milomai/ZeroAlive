Bullet = class("Bullet", {angle = 0, speed = 800})

trackImage = gradient({{255,255,255,255},{255,255,255,0}})

function Bullet:init()
  self.pos = {}
end

function Bullet:init(posX, posY, mouseX, mouseY, accuracy)
  self.pos = {}
  self.pos.x = posX
  self.pos.y = posY
  self.angle = math.angle(posX, posY, mouseX, mouseY)
  self.angle = self.angle + (love.math.random() - 0.5) * accuracy
  self:deltaValue()
  self.shape = love.physics.newCircleShape(1)
  self.body = love.physics.newBody(world.physics, self.pos.x, self.pos.y, "dynamic")
  self.body:setBullet(true)
  self.body:applyLinearImpulse(self.dx, self.dy)
  self.body:setActive(false)
  self.fixture = love.physics.newFixture(self.body, self.shape)
  self.fixture:setUserData(self)
  self.fixture:setCategory(RAILGUN_GROUP.bullet)
end

function Bullet:deltaValue()
  self.dx = self.speed * math.cos(self.angle)
  self.dy = self.speed * math.sin(self.angle)
  self.pos.x = self.pos.x + (player.size+1) * math.cos(self.angle)
  self.pos.y = self.pos.y + (player.size+1) * math.sin(self.angle)
end

function Bullet:debugDraw()
  love.graphics.push('all')
  love.graphics.setPointSize(1)
  love.graphics.setColor(255, 0, 0, 255)
  love.graphics.point(self.pos.x, self.pos.y)
  love.graphics.pop()
end

function Bullet:draw()
  drawInRect(trackImage, self.pos.x, self.pos.y, self.speed/40, 1, math.pi + self.angle)
end

function Bullet:update(dt)
  self.pos.x = self.body:getX()
  self.pos.y = self.body:getY()
end