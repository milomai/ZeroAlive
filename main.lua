class = require('30log')
require('Player')
local mouse = {x = 0, y = 0}
function love.load(arg)
  player = Player:new()
  if arg[#arg] == "-debug" then require("mobdebug").start() end
end

function love.update(dt)
  player:update(dt)
end

function love.draw()
  player:draw()
  drawAimLine()
end

function drawAimLine()
  love.graphics.line(mouse.x, mouse.y, player.location.x, player.location.y)
end