Class = require "lib.class"
local Tile = require "map.tile"

local TT = require "text.text"
local Menu = require "menu"
local Game = require "game"
local Gamestate = require "lib.gamestate"

TESTMAP = {}
WINDOW_WIDTH = 1200
WINDOW_HEIGHT = 800

function IsInsideRect(p_x,p_y,r_x,r_y,r_w,r_h)
    return p_x >= r_x and p_x <= r_x + r_w
    and p_y >= r_y and p_y <= r_y + r_h
end

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    print(x1,y1,x2,y2)
    return x1 < x2+w2 and
           x2 < x1+w1 and
           y1 < y2+h2 and
           y2 < y1+h1
end

local test_tile

function love.load()
    TT.init()
    math.randomseed(os.time())
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)
    love.window.setTitle("NULLIFIED JUSTIFICATION")

    TESTMAP = {
       Tile("FFC1F", 1,1),
       Tile("RRFF", 1,2),
       Tile("FRRRV", 1,3),
       Tile("C1C1RR", 2,0),
       Tile("C1RRC1", 2,1),
       Tile("FFRR", 2,2),
       Tile("RFRF", 2,3),
       Tile("C1C1FF", 2,4),
       Tile("RRRC1V", 2,5),
       Tile("RRC1F", 3,1),
       Tile("RFC1R", 3,2),
       Tile("RFRF", 3,3),
       Tile("FFFFM", 3,4),
       Tile("RC1RF", 3,5),
       Tile("C1FSC1C1", 4,1),
       Tile("C1C1FF", 4,2),
       Tile("RRC1C1", 4,3),
       Tile("FRFR", 4,4),
       Tile("FSC1C1F", 5,2),
       Tile("C1C1FC1", 5,3),
    }

    --test_tile = Tile("C1C1SC1R", 5, 5)

    Gamestate.registerEvents()
    Gamestate.switch(Game)
end

function love.update(dt)
end

function love.draw()
    --test_tile:draw()
    --for _, tile in ipairs(TESTMAP) do
    --    tile:draw()
    --end
end