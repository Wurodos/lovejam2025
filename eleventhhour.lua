local Endgame = {}
local Map = require "map.map"

local TT = require "text.text"

local camera_x, camera_y = 0, 0
local score = 0

function Endgame.init()
    love.window.setTitle("ELEVENTH HOUR HAS COME. SURRENDER NOW")
end

function Endgame.setscore(_score)
    score = _score
end

function Endgame:update(dt)
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
end

function Endgame:draw()
    love.graphics.push()
    love.graphics.translate(camera_x, camera_y)
    Map.draw()
    love.graphics.pop()

    TT.setFont("massive")
    TT.draw("Score: "..score, WINDOW_WIDTH * 0.7, 50, {limit = WINDOW_WIDTH*0.3})
end

return Endgame