local Game = {}
local Gamestate = require "lib.gamestate"

local Endgame = require "eleventhhour"

local Map = require "map.map"

local TT = require "text.text"

local Tile = require "map.tile"
local tiledeck = {}

local camera_x, camera_y = 0, 0


local score = 0

local function shuffleInPlace(t)
    for i = #t, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
end

local hand = {}

function Game:init()
    for line in io.lines("map/tiledata.txt") do
        local dupes = tonumber(line:sub(1,1))
        for _ = 1, dupes, 1 do
            tiledeck[#tiledeck+1] = Tile(line:sub(2))
        end
    end
    shuffleInPlace(tiledeck)
    --tiledeck = {tiledeck[1], tiledeck[2], tiledeck[3], tiledeck[4], tiledeck[5], tiledeck[6]}
    Map.init()
    Game.newhand()
end

function Game.newhand()
    hand[1] = Game.drawtile()
    if hand[1] == nil then
        Endgame.setscore(score)
        Gamestate.switch(Endgame)
        return
    end
    hand[1].draggable = true
    hand[1].x, hand[1].y = WINDOW_WIDTH * 0.3 + Tile.size, WINDOW_HEIGHT - 150
    hand[1].snapx, hand[1].snapy = hand[1].x, hand[1].y
    hand[2] = Game.drawtile()
    hand[2].draggable = true
    hand[2].x, hand[2].y = WINDOW_WIDTH * 0.3 + 3*Tile.size, WINDOW_HEIGHT - 150
    hand[2].snapx, hand[2].snapy = hand[2].x, hand[2].y
end

function Game.drawtile()
    local tile = table.remove(tiledeck, 1)
    return tile
end

function Game:keypressed(key)
    
end

local are_dragging_tile = false

function Game:mousereleased()
    local picked_spot
    for i, tile in ipairs(hand) do
        if tile.isdragged then
            picked_spot = Map.getIntersected(tile, camera_x, camera_y)
            are_dragging_tile = false

            if picked_spot ~= nil then
                tile.row = picked_spot.row
                tile.col = picked_spot.col
                Map.addTile(tile)
                score = score + Map.score(tile)
                table.remove(hand, i)
                Game.newhand()
            else
                tile.x, tile.y = tile.snapx, tile.snapy
                tile:rotate(true)
            end

            tile.isdragged = false
        end
    end
    
    Map.mousereleased()
end

function Game:update(dt)
    --print("fps : "..1/dt)

    if love.keyboard.isDown("s") then
        camera_y = camera_y - 10
    elseif love.keyboard.isDown("w") then
        camera_y = camera_y + 10
    end

    if love.keyboard.isDown("d") then
        camera_x = camera_x - 10
    elseif love.keyboard.isDown("a") then
        camera_x = camera_x + 10
    end


    for _, tile in ipairs(hand) do
        if tile:update(dt) then
            if not are_dragging_tile then
                are_dragging_tile = true
                Map.makeAvailableFor(tile)
            end
            break
        end
    end
end



function Game:draw()
    love.graphics.push()
    love.graphics.translate(camera_x, camera_y)
    Map.draw()
    love.graphics.pop()


    love.graphics.setColor(0.5,0.5,0.5, 0.7)
    love.graphics.rectangle("fill", WINDOW_WIDTH * 0.3, WINDOW_HEIGHT - 200, Tile.size*5, 200)
    love.graphics.setColor(1,1,1)

    for i, tile in ipairs(hand) do
        tile:draw()
    end
   

    

    TT.setFont("big")
    TT.draw("Drag one!", 0, WINDOW_HEIGHT - 200)
    TT.setFont("massive")
    TT.draw("Score: "..score, WINDOW_WIDTH * 0.7, 50, {limit = WINDOW_WIDTH*0.3})
end



return Game