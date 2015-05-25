class = require('30log')
require('World')
require('Player')
require('Bullet')
require('Enemy')
local mouse = {x = 0, y = 0}
local edgePoint = {x = 0, y = 0}
function love.load(arg)
  if arg[#arg] == "-debug" then require("mobdebug").start() end
  
  love.graphics.setPointSize(2)
  
  world = World:new(2000, 2000)
  player = Player:new()
  player.weapon = Weapon:new()
  world:add(player)
  world.focus = player.pos
end

local num = 0

function love.update(dt)
  if love.math.random() > 0.97 then
    --[[local x, y = 5+math.fmod(num, 10)*16, 5+math.modf(num/10)*16
    num = num + 1]]--
    Enemy.Generate() 
  end
  world:update(dt)
  
  --[[
  --edgePoint = updateEdgePoint()

  
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
  ]]--
end

function love.draw()
  world:draw()
  love.graphics.print(love.timer.getFPS())
  --love.graphics.print(string.format("%.1f", player.pos.x)..','..string.format("%.1f", player.pos.y))
  --drawAimLine()
  --[[
  for enemy in pairs(enemySet) do
    enemy:draw()
  end
  ]]--
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