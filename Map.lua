local Grid = require ("jumper.grid") -- The grid class
local Pathfinder = require ("jumper.pathfinder") -- The pathfinder lass

Map = class("Map", {forceDraw = true, solid = true})

function Map:init(file, physics)
  self.tileMap = require(file)
  self.physics = physics
  self.walkableMap = {} -- 二维数组。标记是否可以通过的方块，0表示可以通过，1为不可通过
  self:loadImages(self.tileMap.tilesets)
  self:loadTiles()
  self:buildPathFinder()
  self.findPathUsage = 0
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
    local tileX, tileY = 1, 1
    for _, tileID in ipairs(layer.data) do
      if tileX > self.tileMap.width then
        tileX = tileX - self.tileMap.width
        tileY = tileY + 1
      end
      
      local tile = self.tiles[tileID]
      if tile then
        if not self.walkableMap[tileY] then self.walkableMap[tileY] = {} end
        self.walkableMap[tileY][tileX] = (tile.solid and 1) or 0
        
        local x = (tileX-1)*self.tileMap.tilewidth
        local y = (tileY-1)*self.tileMap.tileheight
        self.spriteBatch:add(tile.quad, x, y)
        
        -- 处理方块的属性
        if tile.solid then
          local body = love.physics.newBody(self.physics, x+self.tileMap.tilewidth/2, y+self.tileMap.tileheight/2)
          local shape = love.physics.newRectangleShape(self.tileMap.tilewidth, self.tileMap.tileheight)
          love.physics.newFixture(body, shape)
        end
      end
     tileX = tileX + 1
    end
  end
end

function Map:buildPathFinder()
  local grid = Grid(self.walkableMap)
  self.pathFinder = Pathfinder(grid, 'ASTAR', 0)
end

-- 将游戏坐标转换为tile坐标
-- @param tilePos 游戏坐标 {x= , y= }
-- @return 地图坐标 {x= , y= }
function Map:tileCoordinates(worldPos)
  return {
    x = math.floor(worldPos.x/self.tileMap.tilewidth)+1, 
    y = math.floor(worldPos.y/self.tileMap.tileheight)+1
  }
end

function Map:isSolid(worldPos)
  local tilePos = self:tileCoordinates(worldPos)
  local walkable = self.walkableMap[tilePos.y][tilePos.x]
  return walkable == 1
end

-- 将地图坐标转换为游戏坐标
-- @param tilePos 地图坐标 {x= , y= }
-- @return 地图坐标 {x= , y= }
function Map:worldCoordinates(tilePos)
  return {
    x = (tilePos.x-0.5)*self.tileMap.tilewidth, 
    y = (tilePos.y-0.5)*self.tileMap.tileheight
  }
end

function Map:improvePath(path)
  if #path < 3 or not path then return path end
  
  local improvedPath = {}
  local direction = nil
  for index = 1, #path - 1 do
    local nextDirection = {}
    nextDirection.x = path[index].x - path[index+1].x
    nextDirection.y = path[index].y - path[index+1].y
    if not direction then
      table.insert(improvedPath, path[index])
    else 
      if direction.x ~= nextDirection.x or direction.y ~= nextDirection.y then
        table.insert(improvedPath, path[index])
      end
    end
    direction = nextDirection
  end
  if not (improvedPath[#improvedPath].x == path[#path].x and improvedPath[#improvedPath].y == path[#path].y) then
    table.insert(improvedPath, path[#path])
  end
  return improvedPath
end

function Map:findPath(from, to)
  local tileFrom = self:tileCoordinates(from)
  local tileTo = self:tileCoordinates(to)
  local time = love.timer.getTime()
	local path = self.pathFinder:getPath(tileFrom.x, tileFrom.y, tileTo.x, tileTo.y, false)
  path = self:improvePath(path)
  local usage = love.timer.getTime()-time
  self.findPathUsage = self.findPathUsage + usage
  return path
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
  if self.findPathUsage > 0 then
    print('usage:' .. self.findPathUsage)
  end
  self.findPathUsage = 0
end