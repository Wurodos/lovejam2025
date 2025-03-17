local Map = {}
local Tile = require "map.tile"
Map.tilesize = Tile.size

local tiles = {}

local tileset = {}
local available_spots = {}

local canvas = love.graphics.newCanvas(3600, 3600)
local colorData

function Map.init()
    --for _, tile in ipairs(TESTMAP) do
    --    Map.addTile(tile)
    --end
    Map.addTile(Tile("C1RFR", 3, 7))
end

function Map.addTile(tile)
    if tiles[tile.row] == nil then tiles[tile.row] = {} end
    tiles[tile.row][tile.col] = tile
    tileset[#tileset+1] = tile

    tile.x = tile.col*Tile.size
    tile.y = tile.row*Tile.size
    print(tile.row, tile.col)

    love.graphics.setCanvas(canvas)
    love.graphics.clear()
    love.graphics.push()
    love.graphics.translate(canvas:getWidth()*0.5, canvas:getHeight()*0.5)
    for _, tilerow in pairs(tiles) do
        for _, tile in pairs(tilerow) do
            tile:draw()
        end
    end
    love.graphics.pop()
    love.graphics.setCanvas()
    
end

function Map.getShields()
    local shields = {}

    for _, tilerow in pairs(tiles) do
        for _, tile in pairs(tilerow) do
            if tile.shield then shields[#shields+1] = tile end
        end
    end

    print(#shields)
    return shields
end

function Map.getMonasteries()
    local monasteries = {}

    for _, tilerow in pairs(tiles) do
        for _, tile in pairs(tilerow) do
            if tile.monastery then monasteries[#monasteries+1] = tile end
        end
    end

    print(#monasteries)
    return monasteries
end

function Map.getColorData()
    if colorData == nil then
        colorData = canvas:newImageData()
    end
    return colorData
end

function Map.getRandomTile()
    return tileset[math.random(1, #tileset)]
end

function Map.anyTileLeft()
    return #tileset > 0
end

function Map.getTileAt(x, y)
    local col, row = math.floor(x/Tile.size), math.floor(y/Tile.size)
    if tiles[row] == nil then return nil end
    return tiles[row][col]
end


local NEGINF = -1e9
local visited = {}
--recursive
local function findmore(thing, camefrom, row, col)
    if tiles[row] == nil or tiles[row][col] == nil then return NEGINF end
    
    if thing == 'R' then
        local total = 1

        -- for cycles
        if camefrom > 0 and visited[tiles[row][col]] ~= nil then return 0 end
        visited[tiles[row][col]] = true

        if camefrom > 0 and tiles[row][col].village then return total end
        if tiles[row][col].village then total = 0 end
        
        

        if camefrom ~= 3 and tiles[row][col].things[3] == 'R' then
            local sum = findmore('R', 1, row+1, col) 
            if tiles[row][col].village then
                if sum > 0 then
                    total = total + sum + 1 end
            else total = total + sum end
        end
        if camefrom ~= 4 and tiles[row][col].things[4] == 'R' then
            local sum = findmore('R', 2, row, col-1)
            if tiles[row][col].village then
                if sum > 0 then
                    total = total + sum + 1 end
            else total = total + sum end
        end
        if camefrom ~= 1 and tiles[row][col].things[1] == 'R' then
            local sum = findmore('R', 3, row-1, col)
            if tiles[row][col].village then
                if sum > 0 then
                    total = total + sum + 1 end
            else total = total + sum end
        end
        if camefrom ~= 2 and tiles[row][col].things[2] == 'R' then
            local sum = findmore('R', 4, row, col+1) 
            if tiles[row][col].village then
                if sum > 0 then
                    total = total + sum + 1 end
            else total = total + sum end
        end

        return total
    elseif thing == 'C' then
        local total = 2
        local terminated = false

        -- for cycles
        if camefrom > 0 and visited[tiles[row][col]] ~= nil then return 0 end
        visited[tiles[row][col]] = true

        for _, value in ipairs(tiles[row][col].city) do
            if value == 2 then terminated = true break end
        end
        if camefrom > 0 and terminated then return total end
        if terminated then total = 0 end

        if camefrom ~= 3 and tiles[row][col].things[3] == 'C' then
            local sum = findmore('C', 1, row+1, col)
            if terminated then
                if sum > 0 then
                    total = total + sum + 2 end
            else total = total + sum end
        end
        if camefrom ~= 4 and tiles[row][col].things[4] == 'C' then
            local sum = findmore('C', 2, row, col-1)
            if terminated then
                if sum > 0 then
                    total = total + sum + 2 end
            else total = total + sum end
        end
        if camefrom ~= 1 and tiles[row][col].things[1] == 'C' then
            local sum = findmore('C', 3, row-1, col)
            if terminated then
                if sum > 0 then
                    total = total + sum + 2 end
            else total = total + sum end
        end
        if camefrom ~= 2 and tiles[row][col].things[2] == 'C' then
            local sum = findmore('C', 4, row, col+1) 
            if terminated then
                if sum > 0 then
                    total = total + sum + 2 end
            else total = total + sum end
        end

        if tiles[row][col].shield then total = total + 2 end

        return total
    end
end

local function monasterycheck(row, col)
    for i = -1, 1, 1 do
        for j = -1, 1, 1 do
            if tiles[row+i] == nil or tiles[row+i][col+j] == nil then
                return 0
            end
        end
    end
    return 9
end

function Map.score(tile)
    local total = 0
    visited = {}
    visited[tile] = true

    local road = findmore('R', -1, tile.row, tile.col)
    if road > 1 then total = total + road end

    visited = {}
    visited[tile] = true
    
    local castle = findmore('C', -1, tile.row, tile.col)
    if castle > 2 then total = total + castle end


    for i = -1, 1, 1 do
        for j = -1, 1, 1 do
            if tiles[tile.row + i] and tiles[tile.row + i][tile.col + j]
                and tiles[tile.row + i][tile.col + j].monastery then
                total = total + monasterycheck(tile.row+i, tile.col+j)
            end
        end
    end

    return total
end





function Map.pushAvailable(x,y,r,c)
    available_spots[#available_spots+1] = {x=x,y=y,row=r,col=c}
end

local rotations_needed = {}

function Map.makeAvailableFor(newtile)
    available_spots = {}
    rotations_needed = {}

    -- empty neighbors of existing tiles

    for _, tilerow in pairs(tiles) do
        for _, tile in pairs(tilerow) do
            if tiles[tile.row+1] == nil or tiles[tile.row+1][tile.col] == nil then
                Map.pushAvailable(tile.x, tile.y + Tile.size, tile.row+1, tile.col)
            end
            if tiles[tile.row-1] == nil or tiles[tile.row-1][tile.col] == nil then
                Map.pushAvailable(tile.x, tile.y - Tile.size, tile.row-1, tile.col)
            end
            if tiles[tile.row][tile.col+1] == nil then
                Map.pushAvailable(tile.x + Tile.size, tile.y, tile.row, tile.col+1)
            end
            if tiles[tile.row][tile.col-1] == nil then
                Map.pushAvailable(tile.x - Tile.size, tile.y, tile.row, tile.col-1)
            end
        end
    end

    -- filter those

    local rotations = {
        newtile,
        newtile:clone():rotate(),
        newtile:clone():rotate():rotate(),
        newtile:clone():rotate(true),
    }

    -- validation
    -- to be valid
    -- R adjacent to R, C adjacent to C, F adjacent to F
    --
    -- check :
    -- [1] with [3] from top
    -- [2] with [4] from right
    -- [3] with [1] from bottom
    -- [4] with [2] from left

    local filtered = {}

    for _, spot in ipairs(available_spots) do
        local legalanything = false
        for rotid, tile in ipairs(rotations) do
            local legal = true
            if tiles[spot.row+1] and tiles[spot.row+1][spot.col] then
                if tile.things[3] ~= tiles[spot.row+1][spot.col].things[1] then
                    legal = false end end
            if tiles[spot.row-1] and tiles[spot.row-1][spot.col] then
                if tile.things[1] ~= tiles[spot.row-1][spot.col].things[3] then
                    legal = false end end
            if tiles[spot.row] and tiles[spot.row][spot.col+1] then
                if tile.things[2] ~= tiles[spot.row][spot.col+1].things[4] then
                    legal = false end end
            if tiles[spot.row] and tiles[spot.row][spot.col-1] then
                if tile.things[4] ~= tiles[spot.row][spot.col-1].things[2] then
                    legal = false end end
            if legal then
                rotations_needed[#rotations_needed+1] = rotid - 1
                legalanything = true
                break
            end
        end
        if legalanything then filtered[#filtered+1] = spot end
    end

    available_spots = filtered
    
end

function Map.getNeighbors(row, col)
    local adjs = {}
    if tiles[row+1] then adjs[#adjs+1] = tiles[row+1][col] end
    if tiles[row-1] then adjs[#adjs+1] = tiles[row-1][col] end
    adjs[#adjs+1] = tiles[row][col-1]
    adjs[#adjs+1] = tiles[row][col+1]
    return adjs
end

function Map.getNeighborsCircle(row, col)
    local adjs = Map.getNeighbors(row, col)
    if tiles[row+1] then
        adjs[#adjs+1] = tiles[row+1][col+1]
        adjs[#adjs+1] = tiles[row+1][col-1]  
    end
    if tiles[row-1] then
        adjs[#adjs+1] = tiles[row-1][col+1]
        adjs[#adjs+1] = tiles[row-1][col-1]
    end
    return adjs
end

function Map.mousereleased()
    available_spots = {}
end

function Map.getIntersected(tile, camera_x, camera_y)
    for i, spot in ipairs(available_spots) do
        if IsInsideRect(tile.x+Tile.size*0.5-camera_x,tile.y+Tile.size*0.5-camera_y,spot.x,spot.y,Tile.size,Tile.size) then
            for _ = 1, rotations_needed[i], 1 do
                tile:rotate()
            end
            return spot
        end
    end
    return nil
end


local sincelast = 0
local delay = 0.1

function Map.destroytile(tile)
    tile.destroyed = true
    tiles[tile.row][tile.col] = nil
    for i, value in ipairs(tileset) do
        if value.row == tile.row and value.col == tile.col then
            table.remove(tileset, i)
            break
        end
    end
end

function Map.update(dt)
    sincelast = sincelast + dt
    if sincelast < delay then return end
    sincelast = sincelast - delay

    -- sieges
    for _, tile in ipairs(tileset) do
        if not tile.destroyed and #tile.besieging > 0 then
            love.graphics.setCanvas(canvas)
            love.graphics.push()
            love.graphics.translate(canvas:getWidth()*0.5, canvas:getHeight()*0.5)
            love.graphics.setColor(0,0,0)
            for i = 1, #tile.besieging, 1 do
                if tile.besieging[i].alive then
                tile.hp = tile.hp - 1
                love.graphics.circle("fill", math.random(tile.x, tile.x+Tile.size),
                    math.random(tile.y, tile.y+Tile.size),3)
                end
            end

            if tile.hp < 0 then
                Map.destroytile(tile)
                love.graphics.rectangle("fill", tile.x, tile.y, Tile.size, Tile.size)
            end

            love.graphics.setColor(1,1,1)
            love.graphics.pop()
            love.graphics.setCanvas()

            
        end
    end

    -- unsieged monasteries heal

    
end

function Map.unsiege(tile)
    love.graphics.setCanvas(canvas)
    love.graphics.push()
    love.graphics.translate(canvas:getWidth()*0.5, canvas:getHeight()*0.5)
    tile:draw()
    love.graphics.pop()
    love.graphics.setCanvas()
end


function Map.draw()
    love.graphics.draw(canvas, -canvas:getWidth()*0.5, -canvas:getHeight()*0.5)

    love.graphics.setColor(0,0.5,0)
    for _, spot in ipairs(available_spots) do
        love.graphics.rectangle("fill", spot.x, spot.y, Tile.size, Tile.size)
    end
    love.graphics.setColor(1,1,1)
end

return Map