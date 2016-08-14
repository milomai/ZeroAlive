Map = class("Map", {forceDraw = true, solid = true})

function Map:init(file, physics)
  self.tileMap = require(file)
  self.physics = physics
  self:loadImages(self.tileMap.tilesets)
  self:loadTiles()
end

function Map:loadImages(tilesets)
  local set = tilesets[1]
  local image = love.graphics.newImage(set.image)
  self.spriteBatch = love.graphics.newSpriteBatch(image, self.tileMap.width*self.tileMap.height)
  self.tiles = {}
  for i = 1, set.tilecount do
    local tile = {};
    tile.quad = love.graphics.newQuad((i-1)*set.tilewidth, 0, set.tilewidth, set.tileheight, image:getDimensions())
    self.tiles[set.firstgid + (i-1)] = tile
  end
  
  for _, tile in ipairs(set.tiles) do
    for k, v in pairs(tile.properties) do 
      self.tiles[tile.id+1][k] = v 
    end
  end
end

function Map:size()
  return self.tileMap.width * self.tileMap.tilewidth, self.tileMap.height * self.tileMap.tileheight
end

function Map:loadTiles()
  for _, layer in ipairs(self.tileMap.layers) do
    for index, tileID in ipairs(layer.data) do
      if not (tileID == 0) then
        local tile = self.tiles[tileID]
        local x = (math.fmod(index-1, self.tileMap.width))*self.tileMap.tilewidth
        local y = math.modf((index-1)/self.tileMap.height)*self.tileMap.tileheight
        self.spriteBatch:add(tile.quad, x, y)
        
        -- 处理方块的属性
        if tile.solid then
          local body = love.physics.newBody(self.physics, x+self.tileMap.tilewidth/2, y+self.tileMap.tileheight/2)
          local shape = love.physics.newRectangleShape(self.tileMap.tilewidth, self.tileMap.tileheight)
          love.physics.newFixture(body, shape)
        end
      end
    end
  end
end

--将游戏坐标转换为tile坐标
local function tileCoordinates(worldX, worldY, layer)
  return math.floor(worldX/self.tileMap.tilewidth), math.floor(worldY/self.tileMap.tileheight)
end

function Map:isSolid(worldPos)
  local x, y = self:tileCoordinates(worldPos)
  local tileID = self.data[y][x]
  return self.tiles[tileID].solid
end

function Map:draw()
  love.graphics.push()
  if self.spriteBatch then
    love.graphics.draw(self.spriteBatch)
  end
  --[[
  love.graphics.setColor(0, 255, 255, 255)
  for _, layer in ipairs(self.tileMap.layers) do
    for index, tile in ipairs(layer.data) do
      if not (tile == 0) then
        local x = (math.fmod(index, self.tileMap.width)-1)*self.tileMap.tilewidth
        local y = math.modf(index/self.tileMap.width)*self.tileMap.tileheight
        love.graphics.rectangle('fill', x, y, self.tileMap.tilewidth, self.tileMap.tileheight)
      end
    end
    
    local vision = world:vision()
    local startX, startY, endX, endY
    startX, startY = vision.x, vision.y
    endX, endY = vision.x+vision.width, vision.y+vision.height
    
  end
  ]]--
  love.graphics.pop()
end

function Map:update(dt)
  
end