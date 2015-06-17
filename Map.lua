Map = class("Map", {forceDraw = true, solid = true})

local tileMap

function Map:init(file)
  self.tileMap = require(file)
end

function Map:size()
  return self.tileMap.width * self.tileMap.tilewidth, self.tileMap.height * self.tileMap.tileheight
end

function Map:loadTiles()
  for _, layer in ipairs(self.tileMap.layers) do
    for index, tile in ipairs(layer.data) do
      if not (tile == 0) then
        local x = (math.fmod(index, self.tileMap.width)-1)*self.tileMap.tilewidth
        local y = math.modf(index/self.tileMap.width)*self.tileMap.tileheight
        local body = love.physics.newBody(world.physics, x+self.tileMap.tilewidth/2, y+self.tileMap.tileheight/2)
        local shape = love.physics.newRectangleShape(self.tileMap.tilewidth, self.tileMap.tileheight)
        love.physics.newFixture(body, shape)
      end
    end
  end
end

--将游戏坐标转换为tile坐标
local function tileCoordinates(worldX, worldY, layer)
  return math.floor(worldX/self.tileMap.tilewidth), math.floor(worldY/self.tileMap.tileheight)
end

function Map:draw()
  love.graphics.push()
  love.graphics.setColor(0, 255, 255, 255)
  for _, layer in ipairs(self.tileMap.layers) do
    for index, tile in ipairs(layer.data) do
      if not (tile == 0) then
        local x = (math.fmod(index, self.tileMap.width)-1)*self.tileMap.tilewidth
        local y = math.modf(index/self.tileMap.width)*self.tileMap.tileheight
        love.graphics.rectangle('fill', x, y, self.tileMap.tilewidth, self.tileMap.tileheight)
      end
    end
    --[[
    local vision = world:vision()
    local startX, startY, endX, endY
    startX, startY = vision.x, vision.y
    endX, endY = vision.x+vision.width, vision.y+vision.height
    ]]--
  end
  love.graphics.pop()
end

function Map:update(dt)
  
end