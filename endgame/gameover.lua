local Gameover = {}
local TT = require "text.text"

local score

function Gameover:init()
    love.window.setTitle("Rest easy. The fight is over")
end

function Gameover.setscore(_score)
    score = _score
end

function Gameover:draw()
    TT.setFont("massive")
    TT.draw("Game Over", 0, 300)
    TT.setFont("big")
    TT.draw("Your score:  "..score, 0, 500)
end

return Gameover