local Game = require "game"
local Gamestate = require "lib.gamestate"
local Menu = {}
local TT = require "text.text"

local Tile = require "map.tile"

local rx,ry,rw,rh = 400,640,400,100

local example_tiles = {}

function Menu:init()
    
end

function Menu:update(dt)
    example_tiles = {
        Tile("FC1FF", 3, 1), Tile("FSC1FC1", 3, 2), Tile("FFFC1", 3, 3),

        Tile("RFRF", 1, 4), Tile("C1C1FF", 1, 5), Tile("SC1RRC1", 1, 6),
        Tile("RFRF", 2, 4), Tile("FFFFM", 2, 5), Tile("RFFFM", 2, 6),
        Tile("RRFF", 3, 4), Tile("FRFR", 3, 5), Tile("FRFR", 3, 6), Tile("FRFR", 3, 7),

        Tile("FRRRV", 3, 8), Tile("FRFR", 3, 9), Tile("FFRR", 3, 10), Tile("RC1C1C1", 4, 10)
    }
end

function Menu:draw()

    for _, tile in ipairs(example_tiles) do
        tile:draw()
    end

    love.graphics.setLineWidth(4)
    love.graphics.rectangle("line", rx,ry,rw,rh)
    TT.setFont("massive")
    TT.draw("Play", rx, ry+10, {limit=rw})


    -- castles
    love.graphics.push()
    love.graphics.translate(0, 300)
    TT.setFont("big")
    TT.draw("2", 0, 0, {limit=300})
    TT.draw("2", 100, 0, {limit=300})
    TT.draw("2", 200, 0, {limit=300})
    TT.draw("2", 130, 70, {limit=300})
    TT.draw("2+2+2+2=8", 100, 100, {limit=300})
    TT.draw("Castles are harder to break", 100, 150, {limit=300})
    TT.draw("Shields generate defenders", 100, 240, {limit=300})
    love.graphics.pop()

    -- monastery

    love.graphics.push()
    love.graphics.translate(450, 250)
    TT.draw("1", -100, -60, {limit=300})
    TT.draw("1", -50, -60, {limit=300})
    TT.draw("1", 0, -60, {limit=300})

    TT.draw("1", -100, -10, {limit=300})
    TT.draw("1", -50, -10, {limit=300})
    TT.draw("1", 0, -10, {limit=300})

    TT.draw("1", -100, 30, {limit=300})
    TT.draw("1", -50, 30, {limit=300})
    TT.draw("1", 0, 30, {limit=300})
    TT.draw("1+1+1+1+1+1+1+1+1=9", -40, 150, {limit=300})
    TT.draw("Monasteries restore damaged tiles around them", -40, 250, {limit=300})
    love.graphics.translate(0, 300)


    love.graphics.pop()

    -- roads
    love.graphics.push()
    love.graphics.translate(700, 300)
    TT.draw("1", 0, 0, {limit=300})
    TT.draw("1", 100, 0, {limit=300})
    TT.draw("1", 200, 0, {limit=300})
    TT.draw("1", 220, 100, {limit=300})
    TT.draw("1+1+1+1=4", 100, 200, {limit=300})
    TT.draw("Units move faster on roads", 100, 250, {limit=300})
    love.graphics.translate(0, 300)

    love.graphics.pop()
end

function Menu:mousereleased(x,y,button)
    if button == 1 and IsInsideRect(x,y,rx,ry,rw,rh) then
        Gamestate.switch(Game)
    end
end

return Menu