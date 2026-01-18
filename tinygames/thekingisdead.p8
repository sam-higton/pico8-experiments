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
    'kim',
    'jonathon',
    'greg',
    'liam',
    'rubin',
    'sam',
    'kat'
}
kings = {
    {
        type='tyrant',
        sprite=64,
        buffs={
            {stat='strength', val=2},
            {stat='gold', val=-1},
        },
        tiles={
            'farm',
            'market',
            'farm',
            'market'
        }      
    },
    {
        type='great',
        sprite=66,
        buffs={
            {stat='strength', val=2},
            {stat='gold', val=-1},
        },
        tiles={
            'farm',
            'market',
            'farm',
            'market'
        }
    },
    {
        type='bountiful',
        sprite=68,
        buffs={
            {stat='strength', val=2},
            {stat='gold', val=-1},
        },
        tiles={
            'farm',
            'market',
            'farm',
            'market'
        }
    },
    {
        type='bad',
        sprite=70,
        buffs={
            {stat='strength', val=2},
            {stat='gold', val=-1},
        },
        tiles={
            'farm',
            'market',
            'farm',
            'market'
        }
    },
    {
        type='terrible',
        sprite=72,
        buffs={
            {stat='strength', val=2},
            {stat='gold', val=-1},
        },
        tiles={
            'farm',
            'market',
            'farm',
            'market'
        }
    },
    {
        type='miser',
        sprite=74,
        buffs={
            {stat='strength', val=2},
            {stat='gold', val=-1},
        },
        tiles={
            'farm',
            'market',
            'farm',
            'market'
        }
    },
}
tile_types = {
    capital={
        sprite=134,
        action=function(tile)
            food = glyph('food')
            gold = glyph('gold')
            coords = grid_coords(tile.x, tile.y)
            if kingdom.food >= 1 then 
                kingdom.gold += 1
                kingdom.food -= 1
                notify(gold..'+1\n'..food..'\f8-1',coords.x, coords.y)
            else
                notify(food..'\f5x',coords.x, coords.y)
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
                notify(food..'+1\n'..gold..'\f8-1',coords.x, coords.y)
            else
                notify(gold..'\5x',coords.x, coords.y)
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
                notify(gold..'+1\n'..food..'\f8-1',coords.x, coords.y)
            else
                notify(food..'\5x',coords.x, coords.y)
            end
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
  return t[flr(rnd(#t)) + 1]
end

function notify(message, x, y,color,duration)
    duration = duration or 4
    color = color or 11
    print('\#0'..message..'\^'..duration, x,y,color)

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

function spr2x(n, x, y)
  local sx = (n % 16) * 8
  local sy = flr(n / 16) * 8
  sspr(sx, sy, 16, 16, x, y, 32, 32)
end

function draw_start()
    cls()

    print('he king is dead', 30, 50, 8)
    print("press ❎ to start", 28, 100, 8)
end

function update_start()
    if btnp(❎) then
        start_game()
    end 
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

    set_scene('apply_buffs')
end

function update_apply_buffs() 
    if first_loop then 
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
end

function update_calculate_tiles()
    for tile in all(kingdom.tiles) do
        tile_type = tile_types[tile.type]
        tile_type.action(tile)
        draw_top_menu()
    end
    -- todo: calculate game over
    print('\^6')
    set_scene('start')
end

function place_tile()
    add(kingdom.tiles, {
        type=active_tiles[1],
        x=selected_tile.x,
        y=selected_tile.y
    })
    deli(active_tiles, 1)
end

function draw_place_tiles()
    draw_main()
    coords = grid_coords(
        selected_tile.x,
        selected_tile.y
    )
    rect(
        coords.x,
        coords.y,
        coords.x + 16,
        coords.y + 16,
        9
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
    king_option_1 = sample(kings)
    king_option_1.name = sample(king_names)
    repeat
        king_option_2 = sample(kings)
        king_option_2.name = sample(king_names)
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
    end
    first_loop = false
end 

__gfx__
00000000cccccccccccccccccccccccccccccccc3333333333333333cccccccccccccccc33333333333333330000000000000000000000000000000000000000
00000000cccccccccccccccccccccccccccccccc3333333333333333cccccccccccccccc33333333333333330000000000000000000000000000000000000000
00700700cccccccc33333cccccc33333cccccccc333333333333333333ccccccc333333333333333333333330000000000000000000000000000000000000000
00077000ccccc3333333333333333333333ccccc3333333333333333333333333333333333333333333333330000000000000000000000000000000000000000
00077000cccc333333333333333333333333cccc3333333333333333333333333333333333333333333333330000000000000000000000000000000000000000
00700700ccc33333333333333333333333333ccc3333333333333333333333333333333333333333333333330000000000000000000000000000000000000000
00000000ccc33333333333333333333333333ccc3333333333333333333333333333333333333333333333330000000000000000000000000000000000000000
00000000ccc33333333333333333333333333ccc3333333333333333333333333333333333333333333333330000000000000000000000000000000000000000
00000000ccc33333333333333333333333333ccc3333333333333333333333333333333333333333333333330000000000000000000000000000000000000000
00000000cc3333333333333333333333333333cc3333333333333333333333333333333333333333333333330000000000000000000000000000000000000000
00000000cc3333333333333333333333333333cc3333333333333333333333333333333333333333333333330000000000000000000000000000000000000000
00000000cc3333333333333333333333333333cc3333333333333333333333333333333333333333333333330000000000000000000000000000000000000000
00000000cc3333333333333333333333333333cc3333333333333333333333333333333333333333333333330000000000000000000000000000000000000000
00000000cc3333333333333333333333333333cc333333333333333333333333333333333333333ccccccc330000000000000000000000000000000000000000
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
00000000000000000000011111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000009a9a9a900000000001111100000000000000a00000000000000900000000000000090000000000000000000000000000000000000000
00000444400000000001111111100000000019a9a9a000000000000aea00000000000098900000000000909b9090000000000000000000000000000000000000
000094494490000000011777777000000000a1111110000000000ada8ada00000000094949000000000099999990000000000000000000000000000000000000
000499999990000000017117117000000001144444400000000099a999a9000000009b989b9000000005ddfffdf0000000000000000000000000000000000000
00094fffff4000000001778778700000000117147140000000008dd666dd000000004f6fff600000000dfffffff0000000000000000000000000000000000000
0004f44f44f00000000067777760000000001444244000000000d644444d00000000f644f4400000000df71f71ff000000000000000000000000000000000000
0004f75f75f0000000007777777000000000444884400000000064dd4dd4000000045673f7300000000dfffefff0000000000000000000000000000000000000
0000ffff6ff00000000006766700000000011444442000000000647147140000000546fffef000000005dfffff50000000000000000000000000000000000000
00000ffeeff0000000000777770000000001104442000000000006ddd4d00000000454ff88f000000005dfeeffd0000000000000000000000000000000000000
00009fffff90000000001977791100000011100240000000000006d6886000000004445fff000000000d5dfffdd0000000000000000000000000000000000000
000ee96669222000001112a7a881110000111002400000000000a266dd6a00000000544ff3300000000ddd6f5d50000000000000000000000000000000000000
00ee8896988822000112229a8888811000111099b900000000cc1a26dd61cc00000b454ff3bb0000000d5d6fad5d000000000000000000000000000000000000
0e88829298882220112888898888881100011144444440000ccc11a266a1ccc000bbb4499b3bb0000005d5aaadd4400000000000000000000000000000000000
ee88829292888222128888898888888100241114447744001111122a2a2111110333345b9b33330000445d9aa9d4990000000000000000000000000000000000
8ee8822922888828288888898888888802444717277744402211222a2a2222123333544bbb333330044ad59a9944499000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333332334334334334332333333333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000
33cecececececec34334444444444444333b33333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000
33cecececececec34332332332332334b33b3b333333333360660600006066060000000000000000000000000000000000000000000000000000000000000000
33181818181818132333333333333332333333333333333366666600006666660000000000000000000000000000000000000000000000000000000000000000
33453333333335434337763333b3333433333333333b333306556000000655600000000000000000000000000000000000000000000000000000000000000000
3345333333333543437777dd33b3b334333333333333333b06556000000655600000000000000000000000000000000000000000000000000000000000000000
33453333333335432367777333333332333333333333333b06666000000666600000000000000000000000000000000000000000000000000000000000000000
33453333333335434336773333333334333333333333333366666666666666660000000000000000000000000000000000000000000000000000000000000000
3345555555555543433d3d3333333b343b333b333333333365555555555555560000000000000000000000000000000000000000000000000000000000000000
33444444444444432333333333b33b32333333333333333365555555555555560000000000000000000000000000000000000000000000000000000000000000
334949494f4f4f4343b3333b3bb33334333333333333333365555555555555560000000000000000000000000000000000000000000000000000000000000000
334949494f4f4f4343b3b33333333334333333333333333365555555555555560000000000000000000000000000000000000000000000000000000000000000
334949494f4f4f43233333333333333233333b3333b3333365555555555555560000000000000000000000000000000000000000000000000000000000000000
33333333333333334334334334334334333b3b333333b33365555555555555560000000000000000000000000000000000000000000000000000000000000000
33333333333333334444444444444444333333333333333365555555555555560000000000000000000000000000000000000000000000000000000000000000
33333333333333332332332332332332333333333333333366666666666666660000000000000000000000000000000000000000000000000000000000000000
