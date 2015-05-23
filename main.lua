class = require('30log')
require('Player')
require('Bullet')
require('Enemy')
local mouse = {x = 0, y = 0}
local edgePoint = {x = 0, y = 0}
bulletSet = {}
enemySet = {}
function love.load(arg)
  if arg[#arg] == "-debug" then require("mobdebug").start() end
  player = Player:new()
  player.weapon = Weapon:new()
  love.graphics.setPointSize(2)
end

function love.update(dt)
  if love.math.random() > 0.99 then Enemy.Generate() end
  player:update(dt)
  --edgePoint = updateEdgePoint()
  
  --超出屏幕的子弹不需要绘制
  local removedBullets = {}
  for i,bullet in ipairs(bulletSet) do  
    if bullet.pos.x < 0 or
       bullet.pos.y < 0 or
       bullet.pos.x > love.window.getWidth() or
       bullet.pos.y > love.window.getHeight() then
         removedBullets[#removedBullets+1] = i
    end
  end

  for _,v in ipairs(removedBullets) do 
    table.remove(bulletSet, v)
  end
  removedBullets = {}
  
  if love.mouse.isDown('l') then
    player.weapon:fire()
    player.weapon:update(dt)
  else
    player.weapon:stop()
  end
  
  local killedEnemies = {}
  for i,bullet in ipairs(bulletSet) do 
    bullet:update(dt)
    for enemy in pairs(enemySet) do
      local dx = bullet.pos.x - enemy.pos.x
      local dy = bullet.pos.y - enemy.pos.y
      if dx^2 + dy^2 < enemy.size^2 then
        killedEnemies[enemy] = true
        removedBullets[#removedBullets+1] = i
      end
    end
  end
  
  for enemy in pairs(killedEnemies) do
    enemySet[enemy] = nil
  end
  for _,v in ipairs(removedBullets) do 
    table.remove(bulletSet, v)
  end
end

function love.draw()
  love.graphics.print(love.timer.getFPS( ), 0, 0)
  player:draw()
  --drawAimLine()
  for i,bullet in ipairs(bulletSet) do 
    bullet:draw()
  end
  for enemy in pairs(enemySet) do
    enemy:draw()
  end
end

function updateEdgePoint()
  mouse.x, mouse.y = love.mouse.getPosition()
  local dx = mouse.x - player.pos.x
  local dy = mouse.y - player.pos.y
  local point = {}
  point.x = player.pos.x
  point.y = player.pos.y
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

local function checkCircularCollision(ax, ay, bx, by, ar, br)
	local dx = bx - ax
	local dy = by - ay
	return dx^2 + dy^2 < (ar + br)^2
end

local function drawAimLine()
  love.graphics.line(player.pos.x, player.pos.y, edgePoint.x, edgePoint.y)
end

-- Returns the angle between two points.
function math.angle(x1,y1, x2,y2) return math.atan2(y2-y1, x2-x1) end