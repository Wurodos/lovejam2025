local size = 100
local q_size = size/4

--  1  
--4   2
--  3

local cardinal = {
    {x = size*0.5, y=0},
    {x = size, y=size*0.5},
    {x = size*0.5,y= size},
    {x = 0, y=size*0.50}
}

local off_cardinal = {
    {x = cardinal[1].x, y = cardinal[1].y + q_size},
    {x = cardinal[2].x - q_size, y = cardinal[2].y},
    {x = cardinal[3].x, y = cardinal[3].y - q_size},
    {x = cardinal[4].x + q_size, y = cardinal[4].y}
}

-- 1  2
-- 
-- 4  3

local corner = {
    {x=0,y=0},
    {x=size,y=0},
    {x=size,y=size},
    {x=0,y=size},
    {x=0,y=0},
}

local center = {x=size*0.5, y=size*0.5}




local Tile = Class{
    init = function (self, encoding, row, col)
        self.encoding = encoding
        self.destroyed = false
        self.lightopacity = 0

        self.besieging = {}
        self.hp = 250

        self.shield = false
        self.village = false
        self.monastery = false
        self.has_road = false

        self.row = row
        self.col = col

        -- absolute positions
        self.x = (self.col or 0)*size
        self.y = (self.row or 0)*size
        self.isdragged = false

        self:decode()
    end,
    basehp = 250,
    size = size,
    monastery_img = love.graphics.newImage("map/monastery.png"),
    shield_img = love.graphics.newImage("map/shield.png"),
    village_img = love.graphics.newImage("map/village.png")
}



function Tile:decode()
    self.road = {0,0,0,0}
    self.city = {0,0,0,0}
    self.castle = false
    self.things = {'F','F','F','F'}
    self.hp = Tile.basehp

    -- array of arrays of vertices
    self.city_vertices = {{},{}}

    
    local id = 1
    for i = 1, #self.encoding do
        local c = self.encoding:sub(i,i)
        if c == 'M' then
            self.monastery = true
        elseif c == 'R' then
            self.has_road = true
            self.things[id] = 'R'
            self.road[id] = 1
            id = id + 1
        

        elseif c == 'C' then
            self.hp = self.hp + 100
            self.castle = true
            local city_id = tonumber(self.encoding:sub(i+1,i+1))
            self.things[id] = 'C'
            self.city[id] = city_id

            self.city_vertices[city_id][#self.city_vertices[city_id]+1] = corner[id].x
            self.city_vertices[city_id][#self.city_vertices[city_id]+1] = corner[id].y

            if id < 4 then
            self.city_vertices[city_id][#self.city_vertices[city_id]+1] = corner[id+1].x
            self.city_vertices[city_id][#self.city_vertices[city_id]+1] = corner[id+1].y
            else self.city_vertices[city_id][#self.city_vertices[city_id]+1] = corner[1].x
                self.city_vertices[city_id][#self.city_vertices[city_id]+1] = corner[1].y
            end

            self.city_vertices[city_id][#self.city_vertices[city_id]+1] = center.x
            self.city_vertices[city_id][#self.city_vertices[city_id]+1] = center.y

            id = id + 1
        
        elseif c == 'F' then
            id = id + 1
        elseif c == 'S' then
            self.shield = id
        elseif c == 'V' then
            self.village = true
        end
    end


    -- city vertices
    -- basically there's 5 types:
    -- singular = needs code below
    -- triangle = fucking bugged too HOWWWW
    -- pipe = needs code below
    -- pacman = there's a bug when rotating, so not covered
    -- full = covered
    for i, city in ipairs(self.city_vertices) do
        local city_size, side, empty_side = 0, 0, 0
        local is_pipe = false

        for j, city_id in ipairs(self.city) do
            
            if city_id == i then
                city_size = city_size + 1
                if side > 0 and j - side == 2 then
                    is_pipe = true
                end
                side = j
            else empty_side = j end
        end
        if city_size == 1 then
            city[5] = off_cardinal[side].x
            city[6] = off_cardinal[side].y
        elseif city_size == 2 and is_pipe then
            city.is_pipe = side
        elseif city_size == 3 then
            print(self.encoding)
            print(empty_side)
            city.is_pacman = empty_side
        end
    end
    

    -- log
    --for _, city in ipairs(self.city_vertices) do
    --    if #city > 2 then
    --        for _, value in ipairs(city) do
    --            print(value)
    --        end
    --    end
    --end

end

function Tile:rotate(isClockwise)
    print("Before rotation: "..self.encoding)

    if isClockwise then
        local id
        for i = #self.encoding, 1, -1 do
            local c = self.encoding:sub(i,i)
            if c == 'R' or c == 'C' or c == 'F' then
                id = i
                break
            end
        end
        self.encoding = self.encoding:sub(id)..self.encoding:sub(1,id-1)
    else
        local id = -1
        for i = 1, #self.encoding do
            local c = self.encoding:sub(i,i)
            if c == 'R' or c == 'C' or c == 'F' then
                if id == -1 then id = 0 
                else
                    id = i
                    break
                end
            end
        end
        self.encoding = self.encoding:sub(id)..self.encoding:sub(1,id-1)
    end

    if self.encoding:sub(#self.encoding, #self.encoding) == 'S' then
        self.encoding = 'S'..self.encoding:sub(1,#self.encoding-1)
    end

    print("After rotation: "..self.encoding)

    self:decode()
    return self
end


function Tile:draw()
    love.graphics.push()
    if self.col then
        love.graphics.translate(self.col*size,self.row*size)
    else 
        love.graphics.translate(self.x, self.y)
    end

    love.graphics.setColor(0,0.0,0.0)
    love.graphics.rectangle("line", 0, 0, size, size);
    love.graphics.setColor(0,0.4,0.6)
    love.graphics.rectangle("fill", 0, 0, size, size);
    love.graphics.setColor(1,1,1)

    love.graphics.setLineWidth(4)
    for i, hasRoad in ipairs(self.road) do
        if hasRoad > 0 then
            love.graphics.line(cardinal[i].x,cardinal[i].y,center.x,center.y)
        end
    end
    love.graphics.setLineWidth(1)

    if self.monastery then
        love.graphics.draw(Tile.monastery_img, q_size, q_size, 0, size/2/512)
    end

    love.graphics.setColor(0.7,0.5,0.3)
    for _, city in ipairs(self.city_vertices) do
        if #city > 2 then
            if not city.is_pipe and not city.is_pacman then
                love.graphics.polygon("fill", city)
            elseif city.is_pacman == nil then
                if city.is_pipe == 3 then
                    love.graphics.polygon("fill", corner[1].x, corner[1].y, corner[2].x, corner[2].y,
                        off_cardinal[2].x, off_cardinal[2].y, off_cardinal[4].x, off_cardinal[4].y)
                    love.graphics.polygon("fill", corner[3].x, corner[3].y, corner[4].x, corner[4].y,
                        off_cardinal[4].x, off_cardinal[4].y, off_cardinal[2].x, off_cardinal[2].y)
                else
                    love.graphics.polygon("fill", corner[1].x, corner[1].y, corner[4].x, corner[4].y,
                        off_cardinal[3].x, off_cardinal[3].y, off_cardinal[1].x, off_cardinal[1].y)
                    love.graphics.polygon("fill", corner[3].x, corner[3].y, corner[2].x, corner[2].y,
                        off_cardinal[1].x, off_cardinal[1].y, off_cardinal[3].x, off_cardinal[3].y)
                end
            else
                for i = 1, 4, 1 do
                    if i ~= city.is_pacman then  
                    love.graphics.polygon("fill", corner[i].x, corner[i].y, corner[i+1].x, corner[i+1].y,
                        center.x, center.y)
                    end
                end
            end
        end
    end
    love.graphics.setColor(1,1,1)
    
    if self.shield then
        love.graphics.draw(Tile.shield_img, off_cardinal[self.shield].x, off_cardinal[self.shield].y,0, size/4/512)
    end

    if self.village then
        love.graphics.draw(Tile.village_img, q_size, q_size, 0, size/2/512)
    end
    --love.graphics.polygon("fill", 0,0,200,0,200,200,150,100,100,50)
    love.graphics.pop()
    
end

function Tile:update(dt)
    local x,y = love.mouse.getPosition()
    if love.mouse.isDown(1) and (IsInsideRect(x, y, self.x, self.y, Tile.size, Tile.size) or self.isdragged) then
        self.x, self.y = x - Tile.size*0.5, y - Tile.size * 0.5
        self.isdragged = true
        return true
    end
    return false
end

return Tile