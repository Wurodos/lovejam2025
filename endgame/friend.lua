local Map  = require "map.map"
local Tile = require "map.tile"
local Vec2 = require "lib.batteries.vec2"

local enemy_pool = {}

local Friend = Class{
    init = function (self, x, y)
        self.hp = 10
        self.x = x or 0
        self.y = y or 0
        self.origx, self.origy = self.x, self.y
        self.speed = math.random(60,80)
        self.origspeed = self.speed
        self.roadboost = self.speed


        self.alive = true
        self.is_wandering = true
        self.is_fighting = false

        self.point = {x=0,y=0}
        self.target = nil
        self.dir = Vec2(0,0)

        self.clock = 0
        self.tile = nil
    end,
    size = Tile.size*0.3,
    fightdelay = 0.3
}

function Friend:pickpoint()
    self.point.x = self.origx + math.random(-200, 200)
    self.point.y = self.origy + math.random(-200, 200)
    self.dir = Vec2(self.point.x - self.x, self.point.y - self.y)
    self.dir:normalise_inplace()
end

function Friend.setEnemyPool(_enemy_pool)
    enemy_pool = _enemy_pool
end

function Friend:pickmenace()
    if #enemy_pool == 0 then
        return 1e9
    end
    self.target = enemy_pool[1]
    local mindist = math.abs(self.target.x - self.x) + math.abs(self.target.y - self.y)
    for _, enemy in ipairs(enemy_pool) do
        local dist = math.abs(enemy.x - self.x) + math.abs(enemy.y - self.y)
        if dist < mindist then
            self.target = enemy
            mindist = dist
        end
    end
    return mindist
end

function Friend:update(dt)
    self.tile = Map.getTileAt(self.x + Friend.size*0.5, self.y + Friend.size*0.5)
    self.speed = self.origspeed
    if self.tile and not self.tile.destroyed and self.tile.has_road then
        self.speed = self.speed + self.roadboost
    end

    if self.is_wandering then
        self.x = self.x + self.dir.x*self.speed*dt
        self.y = self.y + self.dir.y*self.speed*dt
        if math.abs(self.x - self.point.x) + math.abs(self.y - self.point.y) < 5 then
            self:pickpoint()
        end

        if self:pickmenace() < 500 then
            self.is_wandering = false
        end

    elseif not self.is_fighting then
        if self.target == nil or self.target.alive == false then
            self:pickpoint()
            self.is_wandering = true
            return
        end
        self.dir = Vec2(self.target.x - self.x, self.target.y - self.y)
        self.dir:normalise_inplace()

        self.x = self.x + self.dir.x*self.speed*dt
        self.y = self.y + self.dir.y*self.speed*dt
        if math.abs(self.x - self.target.x) + math.abs(self.y - self.target.y) < 1 then
            self.is_fighting = true
            self.target.is_fighting = true
        end
    else

        -- Fighting
        self.clock = self.clock + dt
        if self.clock >= Friend.fightdelay then
            self.clock = self.clock - Friend.fightdelay
            self.hp = self.hp - 1
            self.target.hp = self.target.hp - 1
            if self.target.hp <= 0 then
                self.target.alive = false
                self.is_fighting = false
                self:pickpoint()
                self.is_wandering = true
            end
            if self.hp <= 0 then
                self.target.is_fighting = false
                self.alive = false
            end
        end
    end
end

function Friend:draw()
    love.graphics.push()
    love.graphics.translate(self.x,self.y)

    love.graphics.setColor(0,0.8,0.3)
    love.graphics.circle("fill", 0,0,Friend.size*0.5)
    love.graphics.setColor(1,1,1)

    love.graphics.pop()
end

return Friend