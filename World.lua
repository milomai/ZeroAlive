World = class("World")

--local frameIndex = 0

local _objects = {}
function World:init(width, height)
  self.size = {}
  self.size.width = width
  self.size.height = height
  self.focus = {x = self.size.width/2, y = self.size.height/2}
end

function World:add(object)
  _objects[#_objects+1] = object
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
    --[[
    if object == nil then
      print('['..frameIndex..']'..'out of range')
    end
    ]]--
  end
end

function World:removeOutOfRangeObjects()
  for i,object in ipairs(_objects) do  
    if object.pos.x < 0 or
       object.pos.y < 0 or
       object.pos.x > self.size.width or
       object.pos.y > self.size.height then
        object.removed = true
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

function World:collide(object1, object2)
  if (class.isInstance(object1, Bullet) and class.isInstance(object2, Enemy)) or
  (class.isInstance(object1, Enemy) and class.isInstance(object2, Bullet)) then
    object1.removed = true
    object2.removed = true
  end
end

function World:update(dt)
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
    if object1.collidable then
      for j = i+1, #_objects do
        local object2 = _objects[j]
        if object2.collidable then
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
  --love.graphics.line(self.size.width/2, 0, self.size.width/2, self.size.height)
  for i, object in ipairs(_objects) do
    object:draw()
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