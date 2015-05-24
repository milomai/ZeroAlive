Bullet = class("Bullet", {angle = 0, speed = 600, collidable = true})

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
end

function Bullet:draw()
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.point(self.pos.x, self.pos.y)
end

function Bullet:deltaValue()
  self.dx = self.speed * math.cos(self.angle)
  self.dy = self.speed * math.sin(self.angle)
end

function Bullet:updateLocation(dt)
  self.pos.x = self.pos.x + self.dx * dt
  self.pos.y = self.pos.y + self.dy * dt
end

function Bullet:update(dt)
  self:updateLocation(dt)
end