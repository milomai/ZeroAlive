Bullet = class("Bullet", {angle = 0, speed = 1000})

function Bullet:init()
  self.location = {}
end

function Bullet:init(posX, posY, mouseX, mouseY, accuracy)
  self.location = {}
  self.location.x = posX
  self.location.y = posY
  self.angle = math.angle(posX, posY, mouseX, mouseY)
  self.angle = self.angle + (love.math.random() - 0.5) * accuracy
  self:deltaValue()
end

function Bullet:draw()
  love.graphics.point(self.location.x, self.location.y)
end

function Bullet:deltaValue()
  self.dx = self.speed * math.cos(self.angle)
  self.dy = self.speed * math.sin(self.angle)
end

function Bullet:updateLocation(dt)
  self.location.x = self.location.x + self.dx * dt
  self.location.y = self.location.y + self.dy * dt
end

function Bullet:update(dt)
  self:updateLocation(dt)
end