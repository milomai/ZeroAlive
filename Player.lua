require('Gun')
local anim8 = require "anim8.anim8"

Player = GameObject:extend("Player", 
  {playerName = "New Player",
   pos = {x = 50, y = 50},
   size = 10,
   speed = 640,
   alive = true,
   hp = 100,
   forceDraw = true,
   linearDamping = 16,
   debug = false,
   animiatIndex = 1,
   status = "run",})

function Player:init()
  self.super.init(self)
  self.slash = self.speed/2^0.5
  self.physic.body:setLinearDamping(self.linearDamping)
  self.physic.fixture:setCategory(Railgun.Const.Category.player)
  self.image = love.graphics.newImage("res/img/moe_run.png")
  self.frame = {}
  self.frame.stand = {}
  self.frame.stand.image = love.graphics.newImage("res/img/moe_stand.png")
  self.frame.stand.draw = function ()
    love.graphics.draw(self.frame.stand.image, self.pos.x, self.pos.y, 0, self.direction, 1, 8, 8)
  end
  self.frame.run = {}
  self.frame.run.image = love.graphics.newImage("res/img/moe_run.png")
  local g = anim8.newGrid(16, 16, self.frame.run.image:getWidth(), self.frame.run.image:getHeight())
  self.frame.run.quads = g(1,1, 2,1)
  self.frame.run.draw = function ()
    local index = math.fmod(self.animiatIndex, 2) + 1
    love.graphics.draw(self.frame.run.image, self.frame.run.quads[index], self.pos.x, self.pos.y, 0, self.direction, 1, 8, 8)
  end
  
  
  self.timer = love.timer.getTime()
  
  self.tile = {}
  self.light = {
    color = {255, 127, 63},
    range = 300
  }
  
end

function Player:setSpeed(speed)
  self.speed = speed
  self.slash = self.speed/2^0.5
end

function Player:draw()
  self.super.draw(self)
  
  self.frame[self.status].draw()

  if self.weapon then
    self.weapon:draw()
  end
end

function Player:debugDraw()
  self.super.debugDraw(self)
  love.graphics.setColor(100, 100, 255, 255)
  love.graphics.circle('fill', self.pos.x, self.pos.y, self.size)
end

function Player:handleInput(dt)
  if love.mouse.isDown(1) then
    self.weapon:fire()
  else
    self.weapon:stop()
  end
  
  local downKeys = ''
  if love.keyboard.isDown('s') then downKeys = downKeys..'s' end
  if love.keyboard.isDown('w') then downKeys = downKeys..'w' end
  if love.keyboard.isDown('a') then downKeys = downKeys..'a' end
  if love.keyboard.isDown('d') then downKeys = downKeys..'d' end
  
  --local dx, dy = 0, 0
  if downKeys == 's'  then self.physic.body:applyLinearImpulse(0, self.speed*dt) end
  if downKeys == 'w'  then self.physic.body:applyLinearImpulse(0, -self.speed*dt) end
  if downKeys == 'a'  then self.physic.body:applyLinearImpulse(-self.speed*dt, 0) end
  if downKeys == 'd'  then self.physic.body:applyLinearImpulse(self.speed*dt, 0) end
  if downKeys == 'wa' then self.physic.body:applyLinearImpulse(-self.slash*dt, -self.slash*dt) end
  if downKeys == 'wd' then self.physic.body:applyLinearImpulse(self.slash*dt, -self.slash*dt) end
  if downKeys == 'sa' then self.physic.body:applyLinearImpulse(-self.slash*dt, self.slash*dt) end
  if downKeys == 'sd' then self.physic.body:applyLinearImpulse(self.slash*dt, self.slash*dt) end
  
  --self.pos.x = self.pos.x + dx * dt
  --self.pos.y = self.pos.y + dy * dt
end

function Player:update(dt)
  self.super.update(self, dt)
  local currentTile = {}
  currentTile = world.map:tileCoordinates(self.pos)
  if not (currentTile.x == self.tile.x) or not (currentTile.y == self.tile.y) then
    self.tileChanged = true
    self.tile = currentTile
  else
    self.tileChanged = false
  end
  if self.weapon then self.weapon:update(dt) end
  if self.light.object then
    self.light.object.setPosition(self.pos.x, self.pos.y)
  end
  
  local speed, angle, speedX, speedY = getSpeed(self.physic.body)
  
  -- 速度小于 20 在屏幕上就看不出角色在移动了
  if not (speed < 20) then
    self.status = "run"
    
    local diff = math.abs(math.abs(angle) - math.pi/2)
    
    -- 加上一个误差范围，避免异常变换图片的移动方向
    if diff > 0.01 then
      if angle > -math.pi/2 and angle < math.pi/2 then
        self.direction = 1
      else
        self.direction = -1
      end
    end
  else
    self.status = "stand"
  end
  
  local fps = math.modf(speed/25)

  if love.timer.getTime() - self.timer > 1/fps then
    self.timer = love.timer.getTime()
    self.animiatIndex = self.animiatIndex + 1
  end
end

function Player:hit(damge)
  self.hp = self.hp - damge
  if self.hp <= 0 then
    self:die()
  end
end

function Player:die()
  self.alive = false
  self.removed = true
end
