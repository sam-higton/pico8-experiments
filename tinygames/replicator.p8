pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
local scene = "main"
local player

function grid_coords(x, y)
    return {
        x=(x*8),
        y=(y*8)
    }
end

--gremlin class
local gremlin = {}
gremlin.__index = gremlin


function gremlin.new(x, y)
    new_gremlin = {
        x = x,
        y = y,
        direction= 'up'
    }
    setmetatable(new_gremlin, gremlin)
    return new_gremlin
end

function gremlin:draw()
    coords = grid_coords(self.x, self.y)
    if self.direction == 'up' or self.direction == 'down' then
        sprite = 2
        flip_x = false
        flip_y = self.direction == 'down'
    else 
        sprite = 1
        flip_y = false
        flip_x = self.direction == 'right'
    end
    spr(
        sprite,
        coords.x,
        coords.y,
        1,1,
        flip_x, flip_y
    )
end

function gremlin:update()
    if btnp(⬆️) then 
        self.y -= 1
        self.direction = 'up'
    end

    if btnp(⬇️) then 
        self.y += 1
        self.direction = 'down'
    end

    if btnp(⬅️) then 
        self.x -= 1
        self.direction = 'left'
    end
    
    if btnp(➡️) then 
        self.x += 1
        self.direction = 'right'
    end
end

--end gremlin class



function draw_grid()
    rect(0,0,127,127,5)
    for y = 1, 16 do
        for x = 1, 16 do
            line((x*8)-1,(y*8), (x*8)+1, (y*8), 5)
            line((x*8), (y*8)-1, (x*8), (y*8)+1)
        end
    end
end

function _init()
    player = gremlin.new(10,10)
end

function _update()
    player:update()
end

function _draw()
    cls()
    draw_grid()
    player:draw()
end
__gfx__
00000000600666666660066606666660066666600666666006666660000000000000000000000000000000000000000000000000000000000000000000000000
000000006666663606000060699999966cccccc6688888866bbbbbb6000000000000000000000000000000000000000000000000000000000000000000000000
007007006006366306000060699999966cccccc6688888866bbbbbb6000000000000000000000000000000000000000000000000000000000000000000000000
000770000006666366666666699999966cccccc6688888866bbbbbb6000000000000000000000000000000000000000000000000000000000000000000000000
000770000006666366366366699999966cccccc6688888866bbbbbb6000000000000000000000000000000000000000000000000000000000000000000000000
007007006006366366666666699999966cccccc6688888866bbbbbb6000000000000000000000000000000000000000000000000000000000000000000000000
000000006666663663666636699999966cccccc6688888866bbbbbb6000000000000000000000000000000000000000000000000000000000000000000000000
00000000600666666633336606666660066666600666666006666660000000000000000000000000000000000000000000000000000000000000000000000000
