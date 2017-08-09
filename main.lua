Railgun = {
  Const = {
    Category = {
      player  = 2,
      enemy   = 3,
      bullet  = 4,
      wall    = 5,
      effect  = 6,
      grenade = 7,
    },
  },
  Config = {
    debug = false
  }
}

require('ulits')

class = require('30log')
require('GameObject')
require('World')
require('Player')
require('Bullet')
require('Enemy')
require('Map')
require('Grenade')


local mouse = {x = 0, y = 0}
local edgePoint = {x = 0, y = 0}

function love.load(arg)
  if arg[#arg] == "-debug" then 
    require("mobdebug").start() 
    Railgun.Config.debug = true
  end
  love.graphics.setPointSize(2)
  world = World:create()
  world:init({mapPath = 'res/map/stage2'})
  if Railgun.Config.debug then
    world.debug = {}
  end
  
end

local num = 0

function love.update(dt)
  local player = world.player
  if player.alive then
    world:update(dt)
  end
  
  --[[
  --edgePoint = updateEdgePoint()
  ]]--
end

function love.draw()
  love.graphics.push('all')
  world:draw()
  love.graphics.pop()
  
  local player = world.player
  --love.graphics.print(love.timer.getFPS())
  --love.graphics.print(string.format("%.1f", player.pos.x)..','..string.format("%.1f", player.pos.y))
  --drawAimLine()
  if not player.alive then
    love.graphics.push('all')
    love.graphics.setColor(255, 255, 0, 255)
    love.graphics.print('Game Over', love.graphics.getWidth()/2, love.graphics.getHeight()/2, 0, 2, 2, 37, 7)
    love.graphics.pop()
  else 
    if world.pause then
      love.graphics.push('all')
      love.graphics.setColor(255, 255, 255, 255)
      love.graphics.print('Pause', love.graphics.getWidth()/2, love.graphics.getHeight()/2, 0, 2, 2, 37, 7)
      love.graphics.pop()
    else
      local stats = love.graphics.getStats()
      love.graphics.push('all')
      love.graphics.print('HP:'.. player.hp .. '/100' .. ' | AMMO:' .. player.weapon.ammo .. '/' .. player.weapon.maxAmmo .. ' | Enemies:' .. world.enemyCount .. ' | FPS:' .. love.timer.getFPS() .. "\nDrawcalls: "..stats.drawcalls.."\nUsed VRAM: "..string.format("%.2f MB", stats.texturememory / 1024 / 1024), 0, 0)
      love.graphics.pop()
    end
  end
end

function love.keypressed(key, isRepeat)
  if key == 'escape' then
    world.pause = not world.pause
  end
  
  if key == 'g' then
    local x, y = world:mousePos()
    local grenade = Grenade:new(world.physics, world.player.pos.x, world.player.pos.y)
    world:add(grenade)
    grenade:throw(x, y)
  end
end

function love.resize( w, h )
  if world.light then
    world.light:refreshScreenSize()
  end
end

--画瞄准线
local function drawAimLine()
  love.graphics.line(player.pos.x, player.pos.y, edgePoint.x, edgePoint.y)
end
