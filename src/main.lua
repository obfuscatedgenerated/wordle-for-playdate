import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/animator"

import "global_consts"
import "global_util"

local Textbox = import "textbox"

local animators = {}

function stop_shake()
    sounds.stop:play()
    animators.shake = playdate.graphics.animator.new(50, 0, 10)
    animators.shake.repeatCount = 2
    animators.shake.reverses = true
end

local letters_start_x <const> = 100

local letters_size_x <const> = 50
local letters_size_y <const> = 50

local letters_text_scale <const> = 4
local letters_force_text_width <const> = nil
local letters_force_text_height <const> = 8

function generate_letter_textbox(idx)
    return Textbox("A", 0, fonts.mvp, letters_start_x + idx * letters_size_x, centerY, letters_size_x, letters_size_y, letters_text_scale, letters_force_text_width, letters_force_text_height)
end

local letters = {
    generate_letter_textbox(0),
    generate_letter_textbox(1),
    generate_letter_textbox(2),
    generate_letter_textbox(3),
    generate_letter_textbox(4),
}

local current_letter = 1

function next_letter()
    if current_letter == #letters then
        --current_letter = #letters -- currently prevents further button press TODO: replace with submit logic
        stop_shake()
    else
        current_letter = current_letter + 1 -- TODO: highlight selected letter
        sounds.next:play()
    end
end

function previous_letter()
    if current_letter == 1 then
        --current_letter = #letters
        stop_shake()
    else
        current_letter = current_letter - 1 -- TODO: highlight selected letter
        sounds.back:play()
    end
end

local handlers = {
    cranked = function(change, accChange)
        letters[current_letter]:advanceCharacter(change)
    end,

    AButtonDown = next_letter,

    BButtonDown = previous_letter,

    upButtonDown = function()
        letters[current_letter]:advanceCharacter(crank_divisor)
    end,

    downButtonDown = function()
        letters[current_letter]:advanceCharacter(crank_divisor * -1)
    end,

    rightButtonDown = next_letter,

    leftButtonDown = previous_letter,
}

function setup()
    playdate.inputHandlers.push(handlers)
end

setup()

function playdate.update()
    if animators.shake then
        if animators.shake:ended() then
            animators.shake = nil
        else
            playdate.display.setOffset(animators.shake:currentValue(), 0)
        end
    end

    gfx.sprite.update()
    playdate.timer.updateTimers()
end
