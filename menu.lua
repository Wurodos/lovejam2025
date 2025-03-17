local Game = require "game"
local Gamestate = require "lib.gamestate"
local Menu = {}
local TT = require "text.text"

local Tile = require "map.tile"

local rx,ry,rw,rh = 400,540,400,100

local example_tiles = {}

function Menu:init()
    
end

function Menu:update(dt)
    example_tiles = {
        Tile("FC1FF", 2, 3), Tile("FSC1FC1", 2, 4), Tile("FFFC1", 2, 5)
    }
end

function Menu:draw()

    for _, tile in ipairs(example_tiles) do
        tile:draw()
    end

    love.graphics.setLineWidth(4)
    love.graphics.rectangle("line", rx,ry,rw,rh)
    TT.setFont("massive")
    TT.draw("Play", 400, 550, {limit=400})

    TT.setFont("big")
    TT.draw("2", 200, 200, {limit=300})
    TT.draw("2", 300, 200, {limit=300})
    TT.draw("2", 400, 200, {limit=300})
    TT.draw("2", 330, 270, {limit=300})
    TT.draw("2+2+2+2=8", 300, 300, {limit=300})
end

function Menu:mousereleased(x,y,button)
    if button == 1 and IsInsideRect(x,y,rx,ry,rw,rh) then
        Gamestate.switch(Game)
    end
end

return Menu