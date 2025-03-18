local Endgame = {}

local Gamestate = require "lib.gamestate"
local Gameover = require "endgame.gameover"

local Map = require "map.map"
local Enemy = require "endgame.enemy"
local Friend = require "endgame.friend"

local TT = require "text.text"

local camera_x, camera_y = 0, 0

local score = 0
local peacescore = 0

local wave = 1

local friends = {}
local enemies = {}

local shields = {}
local monasteries = {}

local recruitdelay = 20
local sincerecruit = recruitdelay

local offset = 500

local music

function Endgame.init()
    love.window.setTitle("ELEVENTH HOUR HAS COME. SURRENDER NOW")
    music = love.audio.newSource("music/SCP-x3x.mp3", "stream")
    shields = Map.getShields()
    monasteries = Map.getMonasteries()
    Friend.setEnemyPool(enemies)
    peacescore = score
    score = 0
    Endgame.newwave()
end

function Endgame.setscore(_score)
    score = _score
end

function Endgame.newwave()
    local r = math.random(1,4)
    
    for _ = 1, 20*wave, 1 do
        local enemy = Enemy()
        if r == 1 then enemy.x = math.random(0, WINDOW_WIDTH) enemy.y = -offset
        elseif r == 2 then enemy.x = WINDOW_WIDTH + offset enemy.y = math.random(0, WINDOW_HEIGHT)
        elseif r == 3 then enemy.x = math.random(0, WINDOW_WIDTH) enemy.y = WINDOW_HEIGHT + offset
        elseif r == 4 then enemy.x = -offset enemy.y = math.random(0, WINDOW_HEIGHT)
        end
        enemy:makedirection()

        enemies[#enemies+1] =enemy
    end

    -- monasteries heal adjacent tiles
    for _, monas in ipairs(monasteries) do
        if not monas.destroyed then
            for _, tile in ipairs(Map.getNeighborsCircle(monas.row, monas.col)) do
                Map.unsiege(tile)
            end
        end
    end

    score = score + peacescore
    wave = wave + 1
    
end

function Endgame:update(dt)
    --print("fps : "..1/dt)
    if not music:isPlaying( ) then
		love.audio.play( music )
	end

    sincerecruit = sincerecruit + dt
    if sincerecruit > recruitdelay then
        sincerecruit = sincerecruit - recruitdelay
        -- recruit
        for _, shield in ipairs(shields) do
            if not shield.destroyed then
                for _ = 1, 3, 1 do
                    local friend = Friend(shield.x+math.random(0, Map.tilesize),
                        shield.y+math.random(0, Map.tilesize))
                    friend:pickpoint()
                    friends[#friends+1] = friend
                end
            end
        end
        
    end

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

    FilterInplace(friends, function (a) return a.alive end)
    FilterInplace(enemies, function (a) return a.alive end)
    if #enemies == 0 then
        Endgame.newwave()
    end

    for _, friend in ipairs(friends) do
        if friend.alive then
            friend:update(dt)
        end
    end
    for _, enemy in ipairs(enemies) do
        if enemy.alive then
            enemy:update(dt)
        end
    end

    Map.update(dt)
    if not Map.anyTileLeft() then
        Gameover.setscore(score)
        music:stop()
        Gamestate.switch(Gameover)
    end
end

function Endgame:draw()
    love.graphics.push()
    love.graphics.translate(camera_x, camera_y)

    Map.draw()

    for _, friend in ipairs(friends) do
        if friend.alive then
            friend:draw()
        end 
    end
    for _, enemy in ipairs(enemies) do
        if enemy.alive then
            enemy:draw()
        end
    end

    love.graphics.pop()

    TT.setFont("massive")
    TT.draw("Score: "..score, WINDOW_WIDTH * 0.7, 50, {limit = WINDOW_WIDTH*0.3, is_outlined = false})
    love.graphics.setColor(0.8,0,0)
    TT.draw("Wave: "..wave-1, WINDOW_WIDTH * 0.7, 140, {limit = WINDOW_WIDTH*0.3, is_outlined = false})
    love.graphics.setColor(1,1,1)
end

return Endgame