box2DDebugDraw = require('debugWorldDraw')
World = class("World")

--local frameIndex = 0

local function instanceOfClass(aClass, object1, object2)
  if class.isInstance(object1, aClass) then
    return object1
  end
  if class.isInstance(object2, aClass) then
    return object2
  end
end

local function beginContact(a, b, coll)
  local bullet, player, enemy
  bullet = instanceOfClass(Bullet, a:getUserData(), b:getUserData())
  player = instanceOfClass(Player, a:getUserData(), b:getUserData())
  enemy = instanceOfClass(Enemy, a:getUserData(), b:getUserData())
  if bullet and not player then bullet.removed = true end
  
  if bullet and enemy and enemy.alive then
    bullet.removed = true
    enemy:die()
  end
  
  if enemy and player and enemy.alive and player.alive then
    player:die()
  end
end

local _objects = {}
function World:init(width, height)
  self.size = {}
  self.size.width = width
  self.size.height = height
  self.focus = {x = self.size.width/2, y = self.size.height/2}
  love.physics.setMeter(32)
  self.physics = love.physics.newWorld(0, 0, true)
  self.physics:setCallbacks(beginContact)
end

function World:add(object)
  if object.body then
    object.body:setActive(true)
  end
  _objects[#_objects+1] = object
end

function World:vision()
  local rect = {}
  rect.x, rect.y = self:worldCoordinates(0, 0)
  rect.width, rect.height = love.window.getWidth(), love.window.getHeight()
  return rect
end

local function removeUnusedObjects()
  local indexes = {}
  for i, object in ipairs(_objects) do
    if object.removed == true then 
      indexes[#indexes+1] = i 
      --print('['..frameIndex..']('..i..')'..object.name..':'..object.pos.x..','..object.pos.y)
    end
  end
  for i = #indexes, 1, -1 do
    local object = table.remove(_objects, indexes[i])
    if object.body then object.body:destroy() end
    --[[
    if object == nil then
      print('['..frameIndex..']'..'out of range')
    end
    ]]--
  end
end

function World:removeOutOfRangeObjects()
  for i,object in ipairs(_objects) do  
    if not object.solid then
      if object.pos.x < 0 or
         object.pos.y < 0 or
         object.pos.x > self.size.width or
         object.pos.y > self.size.height then
            if object == player then 
              player:die()
            else
              object.removed = true
            end
      end
    end
  end
end

function World:checkCircularCollision(ax, ay, bx, by, ar, br)
  if ar == nil then ar = 0 end
  if br == nil then br = 0 end
	local dx = bx - ax
	local dy = by - ay
	return dx^2 + dy^2 < (ar + br)^2
end

function World:CheckRectCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

function World:checkRectPointCollision(rectX, rectY, rectWidth, rectHeight, pointX, pointY)
  return self:CheckRectCollision(rectX, rectY, rectWidth, rectHeight, pointX, pointY, 0, 0)
end

function World:checkCircleRectCollision(circleX, circleY, circleRadius, rectX, rectY, rectWidth, rectHeight)
  if not circleRadius then circleRadius = 0 end
  
  local result = self:checkRectPointCollision(rectX-circleRadius, rectY-circleRadius, rectWidth+circleRadius*2, rectHeight+circleRadius*2, circleX, circleY)
  return result

--[[  
  --左上
  if self:checkRectPointCollision(rectX-circleRadius, rectY-circleRadius, circleRadius, circleRadius, circleX, circleY) then
    return World:checkCircularCollision(circleX, circleY, rectX, rectY, circleRadius)
  end
  
  --右上
  if self:checkRectPointCollision(rectX+rectWidth, rectY-circleRadius, circleRadius, circleRadius, circleX, circleY) then
    return World:checkCircularCollision(circleX, circleY, rectX+rectWidth, rectY, circleRadius)
  end
  
  --左下
  if self:checkRectPointCollision(rectX-circleRadius, rectY, circleRadius, circleRadius, circleX, circleY) then
    return World:checkCircularCollision(circleX, circleY, rectX, rectY+rectHeight, circleRadius)
  end
  
  --右下
  if self:checkRectPointCollision(rectX+rectWidth, rectY+rectHeight, circleRadius, circleRadius, circleX, circleY) then
    return World:checkCircularCollision(circleX, circleY, rectX+rectWidth, rectY+rectHeight, circleRadius)
  end
  
  return false
  --]]
end

function World:collide(object1, object2)
  local bullet, enemy, player
  bullet = instanceOfClass(Bullet, object1, object2)
  enemy = instanceOfClass(Enemy, object1, object2)
  player = instanceOfClass(Player, object1, object2)
  
  
end

local EnemyGenerateRate = 1
local remainTime = 0

function World:update(dt)
  if self.pause then
    return
  end
  
  remainTime = remainTime - dt
    if remainTime <= 0 then
      Enemy.Generate()
      remainTime = remainTime + EnemyGenerateRate
    end
  
  self.physics:update(dt)
  --frameIndex = frameIndex + 1
  for i, object in ipairs(_objects) do
    if type(object.handleInput) == 'function' then
      object:handleInput(dt)
    end
  end
  
  for i, object in ipairs(_objects) do
    if type(object.update) == 'function' then
      object:update(dt)
    end
  end
  
  for i = 1, #_objects do
    local object1 = _objects[i]
    if not object1.removed and object1.collidable then
      for j = i+1, #_objects do
        local object2 = _objects[j]
        if not object2.removed and object2.collidable then
          if self:checkCircularCollision(object1.pos.x, object1.pos.y, object2.pos.x, object2.pos.y, object1.size, object2.size) then
            self:collide(object1, object2)
          end
        end
      end
    end
  end
  
  self:removeOutOfRangeObjects()
  removeUnusedObjects()
end

function World:draw()
  love.graphics.push()
  love.graphics.translate(-self.focus.x+love.window.getWidth()/2, -self.focus.y+love.window.getHeight()/2)
  love.graphics.rectangle('line', 0, 0, self.size.width, self.size.height)
  
  local window = self:vision()
  --love.graphics.line(0, window.y+window.height, self.size.width, window.y+window.height)
  box2DDebugDraw(self.physics, window.x, window.y, window.width, window.height)
  
  for i, object in ipairs(_objects) do
    if object.forceDraw or self:checkCircleRectCollision(object.pos.x, object.pos.y, object.size, window.x, window.y, window.width, window.height) then
      object:draw()
    end
  end
  love.graphics.pop()
end

--将屏幕坐标转换为游戏坐标
function World:worldCoordinates(screenX, screenY)
  if screenX == nil or screenY == nil then return end
  return self.focus.x-love.window.getWidth()/2+screenX, self.focus.y-love.window.getHeight()/2+screenY
end

function World:mousePos()
  return self:worldCoordinates(love.mouse.getPosition())
end

function World:remove(target)
  local index = -1
  for i, object in ipairs(_objects) do
    if target == object then index = i; break end
  end
  table.remove(_objects, index)
end