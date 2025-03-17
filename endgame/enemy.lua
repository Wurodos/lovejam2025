local Map = require "map.map"
local Tile = require "map.tile"
local Vec2 = require "lib.batteries.vec2"

local Enemy = Class{
    init = function (self, x, y)
        self.hp = 3
        self.x = x or 0
        self.y = y or 0
        self.origx, self.origy = self.x, self.y
        self.speed = math.random(40,60)
        self.alive = true
        self.is_moving = true
        self.is_fighting = false
        self.point = {x=0,y=0}
        self.dir = Vec2(0,0)

        self.tile = nil
    end,
    size = Tile.size*0.3
}

function Enemy:makedirection()
    local newx, newy = math.random(), math.random()
    if self.x > WINDOW_WIDTH * 0.5 then newx = newx * -1 end
    if self.y > WINDOW_HEIGHT * 0.5 then newy = newy * -1 end
    local target = Map.getRandomTile()
    if target == nil then return end
    self.dir = Vec2(target.x-self.x, target.y-self.y)
    self.dir:normalize_inplace()
end

function Enemy:update(dt)

    if self.is_fighting then
        return
    end

    if self.is_moving then
        self.x = self.x + self.dir.x*self.speed*dt
        self.y = self.y + self.dir.y*self.speed*dt
        if self.x < -500 or self.x > WINDOW_WIDTH + 500 or self.y < -500 or self.x > WINDOW_HEIGHT + 500 then
            self.alive = false
        end
    end

    -- if over a tile with castle,stop and start destroying it
    if self.is_moving then
        self.tile = Map.getTileAt(self.x, self.y) or Map.getTileAt(self.x+Enemy.size, self.y+Enemy.size)
        if self.tile ~= nil then
            self.is_moving = false
            self.tile.besieging[#self.tile.besieging+1] = self
        end
    else
        if self.tile.destroyed then
            self:makedirection()
            self.is_moving = true
        end
    end

end

function Enemy:draw()
    love.graphics.push()
    love.graphics.translate(self.x,self.y)

    love.graphics.setColor(1,0,0)
    love.graphics.polygon("fill", Enemy.size*0.5, 0, 0, Enemy.size, Enemy.size, Enemy.size)
    love.graphics.setColor(1,1,1)

    love.graphics.pop()
end

return Enemy