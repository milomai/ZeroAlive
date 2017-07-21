GameObject = class("GameObject", 
  {
    size = 10,
    pos = {x = 0, y = 0},
    physic = {}
  })

function GameObject:init(posX, posY)
  self.pos.x = posX or self.pos.x
  self.pos.y = posY or self.pos.y
  self.physic.shape = love.physics.newCircleShape(self.size)
  self.physic.body = love.physics.newBody(world.physics, self.pos.x, self.pos.y, "dynamic")
  self.physic.fixture = love.physics.newFixture(self.physic.body, self.physic.shape)
  self.physic.fixture:setUserData(self)
end

function GameObject:update(dt)
  if self.physic.body then
    self.pos.x = self.physic.body:getX()
    self.pos.y = self.physic.body:getY()
  end
end
  
function GameObject:draw()
end