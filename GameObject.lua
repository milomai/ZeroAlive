GameObject = class("GameObject", 
  {
    size = 10,
    pos = {x = 0, y = 0},
    physic = {},
    debug = false,        --Debug 开关
  })

function GameObject:init(posX, posY)
  self.pos.x = posX or self.pos.x
  self.pos.y = posY or self.pos.y
  self.physic.shape = love.physics.newCircleShape(self.size)
  self.physic.body = love.physics.newBody(world.physics, self.pos.x, self.pos.y, "dynamic")
  self.physic.fixture = love.physics.newFixture(self.physic.body, self.physic.shape)
  self.physic.fixture:setUserData(self)
  if world.debug then 
    self.debug = {}
  end
end

function GameObject:update(dt)
  if self.physic.body then
    self.pos.x = self.physic.body:getX()
    self.pos.y = self.physic.body:getY()
  end
end
  
function GameObject:draw()
  if self.debug then
    self:debugDraw()
  end
end

function GameObject:debugDraw()
end