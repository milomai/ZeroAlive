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
  
  --锁定游戏更新时间
  local remains = dt
  local ddt = 1/120
  while remains > 0 do
    if remains < ddt then 
      ddt = remains 
    end
    world:update(ddt)
    remains = remains - ddt
  end
  
  
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

function getPS(name, image)
    local ps_data = require(name)
    local particle_settings = {}
    particle_settings["colors"] = {}
    particle_settings["sizes"] = {}
    for k, v in pairs(ps_data) do
        if k == "colors" then
            local j = 1
            for i = 1, #v , 4 do
                local color = {v[i], v[i+1], v[i+2], v[i+3]}
                particle_settings["colors"][j] = color
                j = j + 1
            end
        elseif k == "sizes" then
            for i = 1, #v do particle_settings["sizes"][i] = v[i] end
        else particle_settings[k] = v end
    end
    local ps = love.graphics.newParticleSystem(image, particle_settings["buffer_size"])
    ps:setAreaSpread(string.lower(particle_settings["area_spread_distribution"]), particle_settings["area_spread_dx"] or 0 , particle_settings["area_spread_dy"] or 0)
    ps:setBufferSize(particle_settings["buffer_size"] or 1)
    local colors = {}
    for i = 1, 8 do 
        if particle_settings["colors"][i][1] ~= 0 or particle_settings["colors"][i][2] ~= 0 or particle_settings["colors"][i][3] ~= 0 or particle_settings["colors"][i][4] ~= 0 then
            table.insert(colors, particle_settings["colors"][i][1] or 0)
            table.insert(colors, particle_settings["colors"][i][2] or 0)
            table.insert(colors, particle_settings["colors"][i][3] or 0)
            table.insert(colors, particle_settings["colors"][i][4] or 0)
        end
    end
    ps:setColors(unpack(colors))
    ps:setColors(unpack(colors))
    ps:setDirection(math.rad(particle_settings["direction"] or 0))
    ps:setEmissionRate(particle_settings["emission_rate"] or 0)
    ps:setEmitterLifetime(particle_settings["emitter_lifetime"] or 0)
    ps:setInsertMode(string.lower(particle_settings["insert_mode"]))
    ps:setLinearAcceleration(particle_settings["linear_acceleration_xmin"] or 0, particle_settings["linear_acceleration_ymin"] or 0, 
                             particle_settings["linear_acceleration_xmax"] or 0, particle_settings["linear_acceleration_ymax"] or 0)
    if particle_settings["offsetx"] ~= 0 or particle_settings["offsety"] ~= 0 then
        ps:setOffset(particle_settings["offsetx"], particle_settings["offsety"])
    end
    ps:setParticleLifetime(particle_settings["plifetime_min"] or 0, particle_settings["plifetime_max"] or 0)
    ps:setRadialAcceleration(particle_settings["radialacc_min"] or 0, particle_settings["radialacc_max"] or 0)
    ps:setRotation(math.rad(particle_settings["rotation_min"] or 0), math.rad(particle_settings["rotation_max"] or 0))
    ps:setSizeVariation(particle_settings["size_variation"] or 0)
    local sizes = {}
    local sizes_i = 1 
    for i = 1, 8 do 
        if particle_settings["sizes"][i] == 0 then
            if i < 8 and particle_settings["sizes"][i+1] == 0 then
                sizes_i = i
                break
            end
        end
    end
    if sizes_i > 1 then
        for i = 1, sizes_i do table.insert(sizes, particle_settings["sizes"][i] or 0) end
        ps:setSizes(unpack(sizes))
    end
    ps:setSpeed(particle_settings["speed_min"] or 0, particle_settings["speed_max"] or 0)
    ps:setSpin(math.rad(particle_settings["spin_min"] or 0), math.rad(particle_settings["spin_max"] or 0))
    ps:setSpinVariation(particle_settings["spin_variation"] or 0)
    ps:setSpread(math.rad(particle_settings["spread"] or 0))
    ps:setTangentialAcceleration(particle_settings["tangential_acceleration_min"] or 0, particle_settings["tangential_acceleration_max"] or 0)
    ps:setRelativeRotation(true)
    return ps
end