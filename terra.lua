----------------------------------------------------------
-- Lua A* Pathfinding ~ Terra	v1.0					--
-- Made by grmmhp ~ [Autophoenix]						--
-- please credit me if youre using this in your project --
-- thanks mate :)										--
-- 28/06/16												--
-- #orphanblack #cloneclub								--
----------------------------------------------------------

terra = {}

-- the starting position; the target node position; the walkable tiles
local start  = {y, x}--y = 1, x = 1}
local target = {y, x}--y = 5, x = 10}
local walkable = {}

-- sets list of walkable nodes
function terra.setWalkableNodes(t)
	for n = 1, #t do walkable[n] = t[n] end
end

-- sets the starting node
function terra.setStartingNode(nodeY, nodeX)
	start.y = nodeY
	start.x = nodeX
end

-- sets the target node
function terra.setTargetNode(nodeY, nodeX)
	target.y = nodeY
	target.x = nodeX
end

-- checks if a node is walkable
local function isWalkable(node)
	for n = 1, #walkable do
		if node == walkable[n] then
			return true
		end
	end

	return false
end

-- checks if node is on corner
local function isCorner(map, originY, originX, nodeY, nodeX)
	if originY > 1 and originY < #map and originX > 1 and originX < #map[1] then
		if (not isWalkable(map[originY-1][originX]) and not isWalkable(map[originY][originX+1]) and nodeY == originY-1 and nodeX == originX+1)
		or (not isWalkable(map[originY-1][originX]) and not isWalkable(map[originY][originX-1]) and nodeY == originY-1 and nodeX == originX-1)
		or (not isWalkable(map[originY+1][originX]) and not isWalkable(map[originY][originX-1]) and nodeY == originY+1 and nodeX == originX-1)
		or (not isWalkable(map[originY+1][originX]) and not isWalkable(map[originY][originX+1]) and nodeY == originY+1 and nodeX == originX+1) then
			return true
		end
	end

	return false
end

-- creates new node
local function newNode(y, x, parentY, parentX, g, h)
	local node = {}
	node.y = y
	node.x = x
	node.parentY = parentY
	node.parentX = parentX
	node.g = g
	node.h = h

	return node
end

-- calculates G cost
local function get_gcost(nodeY, nodeX, targetY, targetX)
	if math.abs(nodeX-targetX) + math.abs(nodeY-targetY) == 1 then
		return 10
	else
		return 14
	end
end

-- calculates H cost
local function get_hcost(nodeY, nodeX)
	return (math.abs(nodeX-target.x) + math.abs(nodeY-target.y))*10
end

-- calculates F cost
local function get_fcost(node)
	return node.g + node.h
end

-- the main function
function terra.pathfind(map)
	local path = {}
	local open = {}
	local closed = {}

	local startnode = newNode(start.y, start.x, nil, nil, 0, get_hcost(start.y, start.x))
	table.insert(open, startnode)
  print('A* 1: +' .. (love.timer.getTime() - startTime))
	-- gets the position of a node on the open list based on its position on the map
	local function getNodePos(nodeY, nodeX)
		for n = 1, #open do
			if open[n].y == nodeY and open[n].x == nodeX then
				return n
			end
		end

		return nil
	end
  
  print('A* 2: +' .. (love.timer.getTime() - startTime))
	-- gets the position of the parent node of the given node on the closed list
	local function getParentNode(node)
		for n = 1, #closed do
			if closed[n].y == node.parentY and closed[n].x == node.parentX then
				return n
			end
		end

		return nil
	end

  print('A* 3: +' .. (love.timer.getTime() - startTime))
	-- checks if a node is not on closed list
	local function isOnClosedList(nodeY, nodeX)
		for n = 1, #closed do
			if closed[n].y == nodeY and closed[n].x == nodeX then
				return true
			end
		end

		return false
	end

	-- the program itself
	repeat
		local lowest_fcost_node = 1 -- the position of the node with the lowest f cost

		for n = 2, #open do
			if get_fcost(open[n]) <= get_fcost(open[lowest_fcost_node]) then
				lowest_fcost_node = n
			end
		end

		table.insert(closed, open[lowest_fcost_node])
		table.remove(open, lowest_fcost_node)
		-- the last node added to the closed list (which is the one with the lowest f cost)
		local best = closed[#closed]

		-- checks if the last node added to the closed list is the target node; path was found
		if best.y == target.y and best.x == target.x then
			local currentNode = best

			repeat
				table.insert(path, 1, {y = currentNode.y, x = currentNode.x})
				currentNode = closed[getParentNode(currentNode)]
			until currentNode.y == start.y and currentNode.x == start.x

			break
		end

		-- gets neighbors
		for y = best.y-1, best.y+1 do
			for x = best.x-1, best.x+1 do
				-- checks if the checking node isnt the current node
				if not (y == best.y and x == best.x) then
					-- checks if node is not on closed list
					if not isOnClosedList(y, x) then
						-- checks if node is valid
						if (x > 0 and x <= #map[1]) and (y > 0 and y <= #map) and isWalkable(map[y][x]) and not isCorner(map, best.y, best.x, y, x) then
							-- checks if node is not on open list
							if getNodePos(y, x) == nil then
								-- adds node to the open list
								table.insert(open, newNode(y, x, best.y, best.x, best.g+get_gcost(y, x, best.y, best.x), get_hcost(y, x)))
							-- node is already on open list
							else
								-- checks if the g cost of the node being checked relative to the current node is smaller than its current g cost
								if best.g+get_gcost(best.y, best.x, y, x) < open[getNodePos(y, x)].g then
									open[getNodePos(y, x)].g = best.g+get_gcost(best.y, best.x, y, x)
									open[getNodePos(y, x)].parentY = best.y
									open[getNodePos(y, x)].parentX = best.x
								end
							end
						end
					end
				end
			end
		end
	until #open == 0
  print('A* 4: +' .. (love.timer.getTime() - startTime))
	return path
end
