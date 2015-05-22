Bullet = class("Bullet", {angle = 0, speed = 5,})

function Bullet:init()
  self.location = {}
end

function Bullet:draw()
  love.graphics.point(self.location.x, self.location.y)
end

function Bullet:deltaValue()
  self.dx = self.speed * math.cos(self.angle)
  self.dy = self.speed * math.sin(self.angle)
end

function Bullet:updateLocation()
  self.location.x = self.location.x + self.dx
  self.location.y = self.location.y + self.dy
end

function Bullet:update(dt)
  self:updateLocation()
end