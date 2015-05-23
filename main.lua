class = require('30log')
require('Player')
require('Bullet')
local mouse = {x = 0, y = 0}
local edgePoint = {x = 0, y = 0}
bulletSet = {}
function love.load(arg)
  player = Player:new()
  player.weapon = Weapon:new()
  love.graphics.setPointSize(2)
  if arg[#arg] == "-debug" then require("mobdebug").start() end
end

function love.update(dt)
  player:update(dt)
  --edgePoint = updateEdgePoint()
  local removedBullets = {}
  for i,bullet in ipairs(bulletSet) do  
    if bullet.location.x < 0 or
       bullet.location.y < 0 or
       bullet.location.x > love.window.getWidth() or
       bullet.location.y > love.window.getHeight() then
         removedBullets[#removedBullets+1] = i
    end
  end

  for _,v in ipairs(removedBullets) do 
    table.remove(bulletSet, v)
  end
  
  if love.mouse.isDown('l') then
    player.weapon:fire()
    player.weapon:update(dt)
  else
    player.weapon:stop()
  end
  
  for i,bullet in ipairs(bulletSet) do 
    bullet:update(dt)
  end
end

function love.draw()
  love.graphics.print(love.timer.getFPS( ), 0, 0)
  player:draw()
  --drawAimLine()
  for i,bullet in ipairs(bulletSet) do 
    bullet:draw()
  end
end

function updateEdgePoint()
  mouse.x, mouse.y = love.mouse.getPosition()
  local dx = mouse.x - player.location.x
  local dy = mouse.y - player.location.y
  local point = {}
  point.x = player.location.x
  point.y = player.location.y
  if dx == 0 then 
    if dy > 0 then
      point.y = love.window.getHeight()
    else
      point.y = 0
    end
  elseif dy == 0 then
    if dx > 0 then
      point.x = love.window.getWidth()
    else
      point.x = 0
    end
  else
    local k = dy/dx
    if dx > 0 then
      point.x = love.window.getWidth()
    else
      point.x = 0
    end
    point.y = ((point.x - mouse.x) * k) + mouse.y
  end
  return point
end

function drawAimLine()
  love.graphics.line(player.location.x, player.location.y, edgePoint.x, edgePoint.y)
end

-- Returns the angle between two points.
function math.angle(x1,y1, x2,y2) return math.atan2(y2-y1, x2-x1) end