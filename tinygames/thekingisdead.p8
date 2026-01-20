pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

scene = 'start'
first_loop = true
map_offset_x = 0
map_offset_y = 14
map_width = 6
map_height = 6
menu_foreground = 8
menu_background = 0
king_procession_start = 128
notifications = {}
death_sprite = 166
death_sprites = {166, 164, 162, 160}
king_names = {
    'john',
    'richard',
    'edward',
    'clover',
    'crimson',
    'henry',
    'louis',
    'charles',
    'ivan',
    'peter',
    'vlad',
    'jonathon',
    'greg',
    'liam',
    'rubin',
    'sam',
    'katharine', -- 17
    'kim',
    'mary',
    'matilda',
    'zenobia'
}

function kings()
    return {
        {
            gender='m',
            type='tyrant',
            sprite={66, 98},
            buffs={
                {stat='strength', val=3},
                {stat='gold', val=-1},
            },
            tiles={
                'army',
                'army',
                'army',
                'wasteland'
            }      
        },
        {
            gender='m',
            type='great',
            sprite={70, 102},
            buffs={
                {stat='strength', val=2},
                {stat='gold', val=2},
            },
            tiles={
                'farm',
                'army',
                'farm',
                'market'
            }
        },
        {
            gender='m',
            type='bountiful',
            sprite={74, 106},
            buffs={
                {stat='food', val=2},
                {stat='gold', val=1},
            },
            tiles={
                'farm',
                'farm',
                'farm',
                'market'
            }
        },
        {
            gender='m',
            type='bad',
            sprite={68, 100},
            buffs={
                {stat='food', val=-2},
                {stat='gold', val=-2},
                {stat='strength', val=-2},
            },
            tiles={
                'wasteland',
                'wasteland',
                'wasteland',
                'wasteland'
            }
        },
        {
            gender='m',
            type='terrible',
            sprite={72, 104},
            buffs={
                {stat='strength', val=2},
                {stat='gold', val=-2},
                {stat='food', val=-2},
            },
            tiles={
                'army',
                'market',
                'wasteland',
                'wasteland'
            }
        },
        {
            gender='m',
            type='miser',
            sprite={64, 96},
            buffs={
                {stat='food', val=-2},
                {stat='gold', val=5},
            },
            tiles={
                'market',
                'market',
                'market',
                'wasteland'
            }
        },
    }
end

tile_types = {
    capital={
        sprite=134,
        action=function(tile)
            food = glyph('food')
            gold = glyph('gold')
            coords = grid_coords(tile.x, tile.y)
            if kingdom.food >= 1 then 
                kingdom.gold -= 1
                kingdom.food -= 1
                args = {gold..'\f8-1\n'..food..'\f8-1',coords.x, coords.y}
                notify(unpack(args))
                add(notifications, args)
            else
                args = {food..'\f5x',coords.x, coords.y}
                notify(unpack(args))
                add(notifications, args)
            end
        end
    },
    farm={
        sprite=130,
        action=function(tile)
            food = glyph('food')
            gold = glyph('gold')
            coords = grid_coords(tile.x, tile.y)
            if kingdom.gold >= 1 then 
                kingdom.gold -= 1
                kingdom.food += 1
                args = {food..'+1\n'..gold..'\f8-1',coords.x, coords.y}
                notify(unpack(args))
                add(notifications, args)
            else
                args = {gold..'\f5x',coords.x, coords.y}
                notify(unpack(args))
                add(notifications, args)
            end
        end
    },
    market={
        sprite=128,
        action=function(tile)
            food = glyph('food')
            gold = glyph('gold')
            coords = grid_coords(tile.x, tile.y)
            if kingdom.food >= 1 then 
                kingdom.gold += 1
                kingdom.food -= 1
                args = {gold..'+1\n'..food..'\f8-1',coords.x, coords.y}
                notify(unpack(args))
                add(notifications, args)
            else
                args = {food..'\f5x',coords.x, coords.y}
                notify(unpack(args))
                add(notifications, args)
            end
        end
    },
    wasteland={
        sprite=136,
        action=function(tile)
            strength = glyph('strength')
            coords = grid_coords(tile.x, tile.y)
            kingdom.strength -= 1
            if kingdom.strength < 0 then
                kingdom.strength = 0
            else
                args = {strength..'\f8-1',coords.x, coords.y}
                notify(unpack(args))
                add(notifications, args)
            end
            if true then
                neigbours = get_neighbours(tile.x, tile.y)
                target = sample(neigbours)
                printh('WHAT IS TARGET')
                printh(target.x)
                if can_place('bandit', target.x, target.y) then
                    tile_i = tile_at(target.x, target.y)
                    if not tile_i then
                        add(kingdom.tiles, {
                            type='bandit',
                            x=target.x,
                            y=target.y
                        })
                    else
                        kingdom.tiles[tile_i] = {
                            type='bandit',
                            x=target.x,
                            y=target.y
                        }
                    end
                    coords = grid_coords(target.x, target.y)
                    spr(  
                        tile_types.bandit.sprite,
                        coords.x,
                        coords.y,
                        2,2
                    )
                end
            end
        end
    },
    army={
        sprite=138,
        action=function(tile)
            gold=glyph('gold')
            food=glyph('food')
            strength=glyph('strength')
            coords = grid_coords(tile.x, tile.y)
            if kingdom.gold < 1 or kingdom.food < 1 then
                args = {food..gold..'\5x',coords.x, coords.y}
                notify(unpack(args))
                add(notifications, args)
                tile.type = 'bandit'
                spr( 
                    140,
                    coords.x,
                    coords.y,
                    2,2 
                )
            else
                kingdom.strength += 1
                kingdom.gold -= 1
                kingdom.food -= 1
               
                args = {strength..'+1\n'..food..'\f8-1\n'..gold..'\f8-1',coords.x, coords.y}
                notify(unpack(args))
                add(notifications, args)
                 for n in all(get_neighbours(tile.x, tile.y)) do
                    tile_i = tile_at(n.x, n.y)
                    if tile_i then
                        if kingdom.tiles[tile_i].type == 'bandit' then
                            deli(kingdom.tiles, tile_i)
                        end
                    end
                end
            end
        end
    },
    bandit={
        sprite=140,
        action=function(tile)
            strength = glyph('strength')
            coords = grid_coords(tile.x, tile.y)
            kingdom.strength -= 1
            if kingdom.strength < 0 then
                kingdom.strength = 0
            else
                args = {strength..'\f8-1',coords.x, coords.y}
                notify(unpack(args))
                add(notifications, args)
            end
            --TODO: destroy random entity
        end
    }
}

king_history = {}

active_king = {}
active_tiles = {}

kingdom = {
    gold=10,
    food=5,
    strength=5,
    tiles={
        {
            type='capital',
            x=3,
            y=3
        }
    }
}
    

king_option_1 = false
king_option_2 = false
selected_king = 0
last_index = 0

selected_tile = { x=3, y=3 }

function rb(b)
    local r = 0
    for i=0,7 do
        r = r * 2 + b % 2
        b = flr(b / 2)
    end
    return r
end

function override_glyph(char, rows)
    code = ord(char)
    local base = 0x5600 + code * 8
    for i = 1, 8 do
        poke(base + (i - 1), rows[i] or 0)
    end
end

function glyph(type) 
    --gold: █
    --food: ▒
    --strength: 🐱
    if type == 'gold' then
        return '\fa\014█\015\fb'
    elseif type == 'food' then
        return '\f8\014▒\015\fb'
    elseif type == 'strength' then
        return '\f9\014🐱\015\fb'
    end
end

function sample(t)
    last_index = flr(rnd(#t)) + 1
    return t[last_index]
end

function notify(message, x, y,color,duration)
    duration = duration or 4
    color = color or 11
    message = '\#0'..message
    if duration != 0 then
        message = message .. '\^'..duration
    end
    print(message, x,y,color)

end

function set_scene(new_scene)
    printh("SETTING SCENE: "..new_scene)
    scene = new_scene
    first_loop = true
end

function grid_coords(x, y)
    return {
        x=map_offset_x + (x*16),
        y=map_offset_y + (y*16)
    }
end

function get_neighbours(x, y) 
    local result = {}
    for dy = -1, 1 do
        for dx = -1, 1 do
            local nx, ny = x + dx, y + dy
            if not (dx == 0 and dy == 0) and
               nx >= 0 and nx <= 6 and
               ny >= 0 and ny <= 6 then
                add(result, {x=nx, y=ny})
            end
        end
    end
    return result
end

function tile_at(x,y) 
    for k, tile in pairs(kingdom.tiles) do
        if tile.x == x and tile.y == y then
            return k
        end
    end
    return false
end

function can_place(type, x, y) 
    tile_i = tile_at(x, y)
    if not tile_i then
        return true
    end
    tile = kingdom.tiles[tile_i]

    if tile.type == 'bandit' and type == 'army' then
        return true
    end

    if #kingdom.tiles < 49 then
        return false
    elseif tile.type == 'capital' then
        return false
    end
    
    return true
end

function spr2x(n, x, y)
  local sx = (n % 16) * 8
  local sy = flr(n / 16) * 8
  sspr(sx, sy, 16, 16, x, y, 32, 32)
end

function draw_start()
    cls()

    print('the king is dead', 30, 30, 8)
    spr2x(death_sprite,50, 50)
    if #king_history == 0 then
        print("press ❎ to start", 28, 100, 8)
    else
        print("press ❎ to continue", 20, 100, 8)
    end
end

function draw_game_over()
    cls()

    for i, king in pairs(king_history) do
        -- rect(2, king_procession_start + (37 * i-1), 35, king_procession_start +  (35 * i-1) + 35)
        offset = (70 * i-1)
        spr2x(king.sprite, 5, king_procession_start + offset)
        print(
            king.name.. "\n the \n".. king.type,
            7, king_procession_start + offset + 35, 8
        )
    end 

    print('the kingdom has fallen', 40, 30, 8)
    spr2x(168, 65, 58)
    print("press ❎ to try again", 43, 100, 8)
end

function update_start()
    if btnp(❎) then
        start_game()
    end 
end

function update_game_over()
    if btnp(❎) then
        setup_new_kingdom()
        start_game()
    end 
    king_procession_start -= 0.6
end

function update_king_picker()

    if btnp(⬅️) then
        selected_king = 1
    end 
    
    if btnp(➡️) then
        selected_king = 2
    end 

    if btnp(❎) then
        if selected_king == 1 then
            king = king_option_1
        else
            king = king_option_2
        end
        pick_king(king)
    end 
end

function pick_king(king)
    active_king = king
    active_tiles = king.tiles

    add(king_history,king) 
    death_sprite = sample(death_sprites)
    set_scene('apply_buffs')
end

function update_apply_buffs() 
    if first_loop then 
        first_loop = false
        return
    end

    for buff in all(active_king.buffs) do
        kingdom[buff.stat] += buff.val
    end
    set_scene('place_tiles')
end

function draw_apply_buffs() 
    draw_main()
    print("\#0gold: +1  str: -1\^6", 8, 15, 11)
    first_loop = false
end

function update_place_tiles() 
     if btnp(⬅️) and selected_tile.x > 0 then
        selected_tile.x -= 1
    end 
    
    if btnp(➡️) and selected_tile.x < 6 then
        selected_tile.x += 1
    end 
    
    if btnp(⬆️) and selected_tile.y > 0 then
        selected_tile.y -= 1
    end 
    
    if btnp(⬇️) and selected_tile.y < 6 then
        selected_tile.y += 1
    end 

    if btnp(❎) then
        place_tile()
    end

    if #active_tiles < 1 then
        set_scene('calculate_tiles')
    end
    
end

function draw_calculate_tiles()
    draw_main()
    if not first_loop then
        if not btn(🅾️) then
            for n in all(notifications) do
                notify(n[1], n[2], n[3],  11, 0)
            end
        end
        print('\#0press ❎ to continue',20,120,11)
    end
end

function update_calculate_tiles()
    if first_loop then
        notifications = {}
        for y=0, map_height do
            for x=0, map_width do
                tile_i = tile_at(x, y)
                if tile_i then
                    tile = kingdom.tiles[tile_i]
                    tile_type = tile_types[tile.type]
                    tile_type.action(tile)
                    draw_top_menu()
                else
                    -- do nothing
                end
            end
        end
        first_loop = false
    end
    
    if btnp(❎) then
        if kingdom.food < 1 or kingdom.gold < 1 or kingdom.strength < 1 then
            set_scene('game_over')
            return
        end
        
        
        set_scene('start')
    end
    
end

function place_tile()
    if not can_place(placing, selected_tile.x, selected_tile.y) then
        return
    end

    tile_i = tile_at(selected_tile.x, selected_tile.y)
    if not tile_i then
        add(kingdom.tiles, {
            type=active_tiles[1],
            x=selected_tile.x,
            y=selected_tile.y
        })
    else
        kingdom.tiles[tile_i] = {
            type=active_tiles[1],
            x=selected_tile.x,
            y=selected_tile.y
        }
    end
    
    deli(active_tiles, 1)
end

function draw_place_tiles()
    draw_main()
    coords = grid_coords(
        selected_tile.x,
        selected_tile.y
    )

    placing = active_tiles[1]
    if can_place(placing, selected_tile.x, selected_tile.y) then
        color = 11
    else
        color = 8
    end

    rect(
        coords.x,
        coords.y,
        coords.x + 16,
        coords.y + 16,
        color
    )
end

function draw_main()
    cls(12)
	draw_map()
    draw_top_menu()
    draw_side_menu()
end

function start_game()
    setup_king_picker()
end

function setup_king_picker()
    king_option_1 = sample(kings())
    king_option_1.name = sample(king_names)
    if last_index >= 17 then
        king_option_1.gender = 'f'
        king_option_1.sprite = king_option_1.sprite[2]
    else
        king_option_1.sprite = king_option_1.sprite[1]
    end
    repeat
        king_option_2 = sample(kings())
        king_option_2.name = sample(king_names)
        if last_index >= 17 then
            king_option_2.gender = 'f'
            king_option_2.sprite = king_option_2.sprite[2]
        else
            king_option_2.sprite = king_option_2.sprite[1]
        end
    until king_option_1.name != king_option_2.name 
        and king_option_1.type != king_option_2.type
    
    selected_king = 0
    set_scene('king_picker')
end

function draw_king_picker()
    cls()
    print("long live the king",30,4,8)
    draw_king_option(king_option_1, 1)
    draw_king_option(king_option_2, 2)
end

function draw_king_option(king, option)
    width = 51
    height = 105
    positions = {
        {x=10, y=14},
        {x=70, y=14},
    }
    x = positions[option].x
    y = positions[option].y
    
    if selected_king == option then
        x += 2
        y -=2
        border_color = 9
    else
        border_color = 8
    end

    rect(
        x,
        y,
        x + width,
        y + height,
        border_color
    )

    -- sprite goes here
    -- double it's size using sspr
    sprite_offset = 9
    spr2x(
        king.sprite,
        x+sprite_offset,
        y+6
    )

    print(
        king.name.. "\n the \n".. king.type,
        x+10, y+43, 8
    )

    buff_string = ""
    for buff in all(king.buffs) do
        buff_val = tostr(buff.val)
        if buff.val > 0 then
            buff_val = "+"..buff_val
        end
        buff_string = buff_string..buff.stat..":"..buff_val.."\n"
    end
    print(
        buff_string,
        x+5, y+65, 8
    )
    for i,tile in pairs(king.tiles) do
        tile_type = tile_types[tile]
        spr(
            tile_type.sprite,
            x+6+((i-1)*10),105,
            1,1
        )
    end
end

function draw_map()
    for y=0,map_height do
        for x=0,map_width do
            if x == 0 and y == 0 then
                sprite = 1
            elseif x == map_width and y == 0 then
                sprite = 3
            elseif x == map_width and y == map_height then
                sprite = 35
            elseif x == 0 and y == map_height then
                sprite = 33
            elseif x == 0 then 
                sprite = 37
            elseif x == map_width then
                sprite = 39
            elseif y == 0 then
                sprite = 7
            elseif y == map_height then
                sprite = 9
            else 
                sprite = 5
            end
            spr(
                sprite,
                (x*16) + map_offset_x,
                (y*16) + map_offset_y,
                2,2
            )
        end
    end

    for tile in all(kingdom.tiles) do
        tile_type = tile_types[tile.type]
        coords = grid_coords(tile.x, tile.y)
        spr(
            tile_type.sprite,
            coords.x,
            coords.y,
            2,2
        )
    end
end

function draw_top_menu() 
    rectfill(0,0,127,12, menu_background)
    rect(0,0,127,12, menu_foreground)
    print("gold: "..kingdom.gold.." food: "..kingdom.food.." strength: "..kingdom.strength,
    3,4,menu_foreground)
end

function draw_side_menu()
    rectfill(112,12, 127, 127, menu_background)
    rect(112,12, 127, 127, menu_foreground)
    print("gen\n "..#king_history, 114, 15, menu_foreground)
    spr(active_king.sprite, 113, 30, 2, 2)

    for i, tile in pairs(active_tiles) do
        tile_type = tile_types[tile]
        spr(
            tile_type.sprite,
            116, 60 + ((i-1)*12),
            1,1
        )
        if i==1 then
            rect(
                115, 60 + ((i-1)*12) - 1,
                124, 60 + ((i-1)*12) + 8,
                9
            )
        end
    end
end

function _init()
    --█▒🐱
    
 -- Set up custom font header: 8x8 glyphs, no offsets
    poke(0x5600, 8)  -- char width (0-255 px)
    poke(0x5601, 8)  -- wide char width (128+)
    poke(0x5602, 7)  -- char height
    poke(0x5603, 0)  -- draw x offset
    poke(0x5604, 0)  -- draw y offset
    poke(0x5605, 0)  -- unused (vertical offset?)
    poke(0x5606, 0)  -- unused
    poke(0x5607, 0)  -- unused

    override_glyph('█',{
        rb(0b01111000),
        rb(0b11001100),
        rb(0b10110100),
        rb(0b10110100),
        rb(0b11001100),
        rb(0b01111000),
        rb(0b00000000),
        rb(0b00000000)
    })

    override_glyph('▒',{
        rb(0b00000000),
        rb(0b00001000),
        rb(0b00110000),
        rb(0b01111000),
        rb(0b01111000),
        rb(0b00110000),
        rb(0b00000000),
        rb(0b00000000)
    })

    override_glyph('🐱',{
        rb(0b11111100),
        rb(0b11111100),
        rb(0b11111100),
        rb(0b11111100),
        rb(0b01111000),
        rb(0b00110000),
        rb(0b00000000),
        rb(0b00000000)
    })

    setup_new_kingdom()
end

function setup_new_kingdom()
    kingdom = {
        gold=10,
        food=10,
        strength=10,
        tiles={
            {
                type='capital',
                x=3,
                y=3
            }
        }
    }
    king_history = {}
    king_procession_start = 128
end

function _update()
	if scene == 'start' then
        update_start()
    elseif scene == 'king_picker' then
        update_king_picker()
    elseif scene == 'apply_buffs' then
        update_apply_buffs()
    elseif scene == 'place_tiles' then
        update_place_tiles()
    elseif scene == 'calculate_tiles' then
        update_calculate_tiles()
    elseif scene == 'game_over' then
        update_game_over()
    end
end

function _draw()
	if scene == 'start' then
        draw_start()
    elseif scene == 'king_picker' then
        draw_king_picker()
    elseif scene == 'apply_buffs' then
        draw_apply_buffs()
    elseif scene == 'place_tiles' then
        draw_place_tiles()
    elseif scene == 'calculate_tiles' then
        draw_calculate_tiles()
    elseif scene == 'game_over' then 
        draw_game_over()
    end
    
end 

__gfx__
00000000cccccccccccccccccccccccccccccccc3333333333333333cccccccccccccccc33333333333333330000000000000000000000000000000000000000
00000000cccccccccccccccccccccccccccccccc333b333333333333cccccccccccccccc33333333333333330000000000000000000000000000000000000000
00700700cccccccc33333cccccc33333ccccccccb33b3b333333333333ccccccc333333333333333333333330000000000000000000000000000000000000000
00077000ccccc3333333333333333333333ccccc3333333333333333333333333333333333333333333333330000000000000000000000000000000000000000
00077000cccc333333333333333333333333cccc33333333333b3333333333333333333333333333333333330000000000000000000000000000000000000000
00700700ccc33333333333333333333333333ccc333333333333333b333333333333333333333333333333330000000000000000000000000000000000000000
00000000ccc33333333333333333333333333ccc333333333333333b333333333333333333333333333333330000000000000000000000000000000000000000
00000000ccc33333333333333333333333333ccc3333333333333333333333333333333333333333333333330000000000000000000000000000000000000000
00000000ccc33333333333333333333333333ccc3b333b3333333333333333333333333333333333333333330000000000000000000000000000000000000000
00000000cc3333333333333333333333333333cc3333333333333333333333333333333333333333333333330000000000000000000000000000000000000000
00000000cc3333333333333333333333333333cc3333333333333333333333333333333333333333333333330000000000000000000000000000000000000000
00000000cc3333333333333333333333333333cc3333333333333333333333333333333333333333333333330000000000000000000000000000000000000000
00000000cc3333333333333333333333333333cc33333b3333b33333333333333333333333333333333333330000000000000000000000000000000000000000
00000000cc3333333333333333333333333333cc333b3b333333b33333333333333333333333333ccccccc330000000000000000000000000000000000000000
00000000cc3333333333333333333333333333cc33333333333333333333333333333333cccccccccccccccc0000000000000000000000000000000000000000
00000000cc3333333333333333333333333333cc33333333333333333333333333333333cccccccccccccccc0000000000000000000000000000000000000000
00000000cc3333333333333333333333333333cccc3333333333333333333333333333cc00000000000000000000000000000000000000000000000000000000
00000000cc3333333333333333333333333333cccc3333333333333333333333333333cc00000000000000000000000000000000000000000000000000000000
00000000cc3333333333333333333333333333ccccc33333333333333333333333333ccc00000000000000000000000000000000000000000000000000000000
00000000cc3333333333333333333333333333ccccc33333333333333333333333333ccc00000000000000000000000000000000000000000000000000000000
00000000cc3333333333333333333333333333ccccc33333333333333333333333333ccc00000000000000000000000000000000000000000000000000000000
00000000cc3333333333333333333333333333ccccc33333333333333333333333333ccc00000000000000000000000000000000000000000000000000000000
00000000cc3333333333333333333333333333ccccc33333333333333333333333333ccc00000000000000000000000000000000000000000000000000000000
00000000ccc33333333333333333333333333cccccc33333333333333333333333333ccc00000000000000000000000000000000000000000000000000000000
00000000ccc33333333333333333333333333cccccc33333333333333333333333333ccc00000000000000000000000000000000000000000000000000000000
00000000ccc33333333333333333333333333ccccc3333333333333333333333333333cc00000000000000000000000000000000000000000000000000000000
00000000ccc33333333333333333333333333ccccc3333333333333333333333333333cc00000000000000000000000000000000000000000000000000000000
00000000cccc333333333333333333333333cccccc3333333333333333333333333333cc00000000000000000000000000000000000000000000000000000000
00000000ccccc3333333333333333333333ccccccc3333333333333333333333333333cc00000000000000000000000000000000000000000000000000000000
00000000cccccccc33333cccccc33333cccccccccc3333333333333333333333333333cc00000000000000000000000000000000000000000000000000000000
00000000cccccccccccccccccccccccccccccccccc3333333333333333333333333333cc00000000000000000000000000000000000000000000000000000000
00000000cccccccccccccccccccccccccccccccccc3333333333333333333333333333cc00000000000000000000000000000000000000000000000000000000
00000000000000000000011111000000000000000000000000000000000000000000000900000000000000000000000000000000000000000000000000000000
000000000000000000009a9a9a900000000001111100000000000000a00000000000009890000000000000d9d000000000000000000000000000000000000000
000004444000000000011111111000000000a9a9a9a000000000000aea000000000004494400000000009d9b9d90000000000000000000000000000000000000
00009449449000000001177777700000000011111110000000000ada8ada000000009b989b900000000099999990000000000000000000000000000000000000
000499999990000000017117117000000001144444400000000099a999a9000000004444444000000005ddfffdf0000000000000000000000000000000000000
00094fffff4000000001778778700000000117147140000000008dd666dd000000044fffff400000000dff6ffff0000000000000000000000000000000000000
0004f44f44f00000000067777760000000001442444000000000d644444d00000004f44f44f00000000d671f71ff000000000000000000000000000000000000
0004f75f75f0000000007777777000000000444444400000000064dd4dd400000004f75f75f00000000d6ffefff0000000000000000000000000000000000000
0000ffff6ff0000000000676670000000000024ee440000000006471471400000000f44464f000000005fffffff0000000000000000000000000000000000000
00000ffeeff0000000000777770000000000024444000000000006ddd4d000000000042ee20000000000ffeeef00000000000000000000000000000000000000
00009fffff90000000001977791100000000000240000000000006d688600000000002244200000000000fffff00000000000000000000000000000000000000
000ee96669222000001112a7a881110000000002400000000000a166dd6a000000009324423000000000006ff000000000000000000000000000000000000000
00ee8896988822000112229a88888110000002774770000000111a16dd611100003bb932239b30000004446ff940000000000000000000000000000000000000
0e8882929888222011288889888888110002477777774000011111a166a1111003bbbb93393bb300004449aaaa94400000000000000000000000000000000000
ee888292928882221288888988888881002247777777440011111cca1acc1111333bbb399b33333004449a9a99a4990000000000000000000000000000000000
8ee8822922888828288888898888888802447777777724401111ccca1acccc113333bbb33b3333304449a9999944499000000000000000000000000000000000
00000000000000000000011111000000000000000000000000000000a00000000000000900000000000000000000000000000000000000000000000000000000
000000000000000000009a9a9a90000000000111110000000000000aea0000000000009890000000000000d9d000000000000000000000000000000000000000
00000444400000000001111111100000000019a9a9a0000000000ada8ada0000000009494900000000009d9b9d90000000000000000000000000000000000000
000094494490000000011777771000000000a11111100000000099a999a9000000009b989b900000000099999990000000000000000000000000000000000000
00049999999000000001711711700000000114444440000000008dd666dd000000004444444000000005ddfffdf0000000000000000000000000000000000000
00094fffff400000000177877870000000011714714000000000d644444d000000044f6fff600000000dff6ffff0000000000000000000000000000000000000
0004f44f44f0000000016777776000000000144424400000000d64dd4dd6d0000004f644f4400000000d671f71ff000000000000000000000000000000000000
0004f75f75f000000001776777700000000044488440000000d664714716660000045673f7300000000d6ffefff0000000000000000000000000000000000000
0004ffff6ff0000000011776671000000001144444200000006d644442466d00000546fffef000000005dfffff50000000000000000000000000000000000000
00444ff88ff40000000111777710000000011044420000000006d4448846d000000454ff88f000000005dfeeffd0000000000000000000000000000000000000
00044fffff4400000001111771100000001110024000000000000044444000000004445fff000000000d5dfffdd0000000000000000000000000000000000000
000446ffff4420000001111771100000001110024000000000000004440000000000544ff3300000000ddd6f5d50000000000000000000000000000000000000
00e4496ff8844200000111177798000000111099b90000000000000244000000000b454ff3bb0000000d5d6fad5d000000000000000000000000000000000000
0e84429f9888442000281117998880000001114444444000000011a222a1000000bbb4499b3bb0000005d5aaadd4400000000000000000000000000000000000
ee88429f928844220288811988888800002411144477440000011cca1acc11000333345b9b33330000445d9aa9d4990000000000000000000000000000000000
8ee8422922888428028888198888880002444717277744400011ccca1acccc103333544bbb333330044ad59a9944499000000000000000000000000000000000
eceece3333888333233433433433433233333333333333333433cc3333333333fffff6fff666556f000cc0600000006000000000000000000000000000000000
eceece3332888e334334444444444444333b33333333333334ccc1cc3d3d3d336fffffffffffffff00c66060000cc06002880d0000000d000000000000000000
4188143322888ee34332332332332334b33b3b3333333333341c111c3ddddd336ff6f6ffffffffff0006f06000c6606000ff0d0002880d000000000000000000
4333343222888eee233333333333333233333333333333333411331133dfd3336ff464ffffffffff0cc11c600006f06001120d0000ff0d000000000000000000
433bb43222888eee4337763333b3333433333333333b33333433333333ddd3336fff4fffff6f6ff506666df00cc11cf011121fd001120fd00000000000000000
4355b43222888eee437777dd33b3b334333333333333333b6463633333d6d6366fffffffff464ff60fddd04006666d40f55a0d0011121d000000000000000000
4344443222888eee2367777333333332333333333333333b6666633333d66666ffffffff6ff4fff60cd1d0000fd1d0000d0d0000f55a00000000000000000000
3333333222888eee433677333333333433333333333333333d66333333dd6663ff6f6ffffffffff6c1616000c161600005050000050500000000000000000000
7a77a73222888eee433d3d3333333b343b333b333333333336f6d363d36d6f63fffffffffffffff500000060000cc06000000000000000000000000000000000
7a77a73222888eee2333333333b33b3233333333333333333666dddddddd6663f6f6ff6f6ffffff6000cc06000c6606000000d0002880d000000000000000000
6966943222888eee43b3333b3bb3333433333333333333333d666dddd6dd6d63ffffff464ffffff500c660600006f06002880d0000ff0d000000000000000000
4333343222555eee43b3b333333333343333333333333333366ddddddddd66d3fffffff4ff6f6ff60006f0600cc11c6000ff0d0001120d000000000000000000
433bb43225dd65ee233333333333333233333b3333b333333666ddd11dd666636fff6ffffffffff50cc11cf006666df001120fd011121fd00000000000000000
4355b4325666665e4334334334334334333b3b333333b33336d6d6d11ddd66635ffffffffff6f6f506666d400fddd04011121d00f55a0d000000000000000000
434444336616d663444444444444444433333333333333333666ddd11dddd663666ffffffffffff60fd1d0000cd1d000f55a00000d0d00000000000000000000
333333336d1666d323323323323323323333333333333333366d3333333366d36566655666ffff56c1616000c161600005050000050500000000000000000000
00222222222220000000004450000000000000000000000000444444000000000000010011000000000000000000000000000000000000000000000000000000
00044444444400000000011111000000000000000000000004422222400000000000015d1d6100000000000000dd000000000000000000000000000000000000
000400060004000000001c445c10000000000000000dd8004424444424000000000016551d6610000000000000ff000000dd0000000000000000000000000000
000444444424000000000111110000000000000000d78800424447b442400000000166661d6761000000000005dd044000ff0440000000000000000000000000
00046dddddd200000000017cc1000000000000000d76880042447a7b442400000001777111d7710000000000555d5f0005dd0f00000000000000000000000000
000406ddddd400000000017cc100000000000000d766d8004244473b34424000000111111111110000000000f4440400555d5400000000000000000000000000
00040088ddd200000000017cc10000000000000d7668080044224444b3442400001ddd66666661000000000004040400f4040400000000000000000000000000
0004000086d400000000173333100000000000d76680000055442244444442400166ddd66dd55510000000000202040002020400000000000000000000000000
0002000000620000000173333331000000002d766d000800545544224444424001611d1d1d1d1510000000000000000000000000000000000000000000000000
0004000000040000001733111333100000029266d00000005295554422442420016d1d1d212d1510000000000000000000000000000000000000000000000000
000200000004000000173131313310000000292d00000800552a95554422422001611d1d12d11510000000000000000000000000000000000000000000000000
000400000004000000133113113310000002429200000000005422955544222001622d2d2dd22510000000000000000000000000000000000000000000000000
0002000000040000001333111333100000242020000000000000422a9552220001dddddddd5ddd10000000000000000000000000000000000000000000000000
00124200022410000013331313331000002200000000000000000044445220000111111111dddd10000000000000000000000000000000000000000000000000
0142448084244100001133333331100000000000000000000000000004420000166666666dddddd1000000000000000000000000000000000000000000000000
1402222848420410000111111111000000000000000000000000000000000000165555555555dd51000000000000000000000000000000000000000000000000
