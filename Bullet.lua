Bullet = GameObject:extend("Bullet", {angle = 0, speed = 800, size = 1})

local trackImage = gradient({{255,255,255,255},{255,255,255,0}})

function Bullet:init()
  self.pos = {}
end

function Bullet:init(posX, posY, mouseX, mouseY, accuracy)
  self.super.init(self, posX, posY)
  self.angle = math.angle(posX, posY, mouseX, mouseY)
  self.angle = self.angle + (love.math.random() - 0.5) * accuracy
  self:deltaValue()
  self.physic.body:setBullet(true)
  self.physic.body:applyLinearImpulse(self.dx, self.dy)
  self.physic.fixture:setCategory(RAILGUN_GROUP.bullet)
  self.physic.fixture:setMask(RAILGUN_GROUP.player)
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
  drawInRect(trackImage, self.pos.x, self.pos.y, 20, 1, math.pi + self.angle)
end

function Bullet:update(dt)
  self.super.update(self, dt)
end