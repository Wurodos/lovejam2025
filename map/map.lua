local Map = {}
local Tile = require "map.tile"


local tiles = {}
local available_spots = {}

function Map.init()
    --for _, tile in ipairs(TESTMAP) do
    --    Map.addTile(tile)
    --end
    Map.addTile(Tile("C1RFR", 3, 7))
end

function Map.addTile(tile)
    if tiles[tile.row] == nil then tiles[tile.row] = {} end
    tiles[tile.row][tile.col] = tile

    tile.x = tile.col*Tile.size
    tile.y = tile.row*Tile.size
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

function Map.mousereleased()
    available_spots = {}
end

function Map.getIntersected(tile)
    for i, spot in ipairs(available_spots) do
        if IsInsideRect(tile.x+Tile.size*0.5,tile.y+Tile.size*0.5,spot.x,spot.y,Tile.size,Tile.size) then
            for j = 1, rotations_needed[i], 1 do
                tile:rotate()
            end
            return spot
        end
    end
    return nil
end

function Map.draw()
    for _, tilerow in pairs(tiles) do
        for _, tile in pairs(tilerow) do
            tile:draw()
        end
    end

    love.graphics.setColor(0,0.5,0)
    for _, spot in ipairs(available_spots) do
        love.graphics.rectangle("fill", spot.x, spot.y, Tile.size, Tile.size)
    end
    love.graphics.setColor(1,1,1)
end

return Map