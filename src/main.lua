import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/animator"

import "global_consts"
import "global_util"

local Textbox = import "textbox"

local word <const> = "CRANK" -- test word
local remaining_guesses = 6

local won = false
local lost = false

local allow_input = true

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
    return Textbox("A", 0, fonts.mvp, letters_start_x + idx * letters_size_x, centerY, letters_size_x, letters_size_y,
        letters_text_scale, letters_force_text_width, letters_force_text_height)
end

local letters = {
    generate_letter_textbox(0),
    generate_letter_textbox(1),
    generate_letter_textbox(2),
    generate_letter_textbox(3),
    generate_letter_textbox(4),
}

local current_letter = 1

function get_input_word()
    local input_word = ""
    for i = 1, #letters do
        input_word = input_word .. letters[i]:getText()
    end
    return input_word
end

function submit()
    allow_input = false

    local guess = get_input_word()
    for i = 1, #letters do
        playdate.timer.performAfterDelay((i - 1) * 250,
            -- simplest way to schedule incrementing delays (like sleeping) without recursion
            function()
                local letter_guess = guess:sub(i, i)
                if letter_guess == word:sub(i, i) then -- letter is correct in correct position
                    sounds.correct:play()
                    letters[i]:fillCorrect()
                elseif (word:find(letter_guess)) then -- letter is correct but in wrong position
                    sounds.unorder:play()
                    letters[i]:fillUnorder()
                else -- letter is incorrect
                    sounds.incorrect:play()
                    letters[i]:fillIncorrect()
                end
            end
        )
    end

    playdate.timer.performAfterDelay(5 * 250,
        function()
            if guess == word then
                won = true
                sounds.win:play()
            end

            if not won then
                remaining_guesses = remaining_guesses - 1

                if remaining_guesses == 0 then
                    lost = true
                    sounds.fail:play()

                    for i = 1, #letters do
                        playdate.timer.performAfterDelay((i - 1) * 100, -- fill out letters with correct word
                            function()
                                letters[i]:fillCorrect()
                                letters[i]:setText(word:sub(i, i))
                            end
                        )
                    end
                else
                    allow_input = true
                end
            end
        end
    )
end

function next_letter()
    if current_letter == #letters then
        submit()
        letters[current_letter]:fillReset()
        current_letter = 1
    else
        letters[current_letter]:fillReset()
        current_letter = current_letter + 1
        letters[current_letter]:fillSelected()
        sounds.next:play()
    end
end

function previous_letter()
    if current_letter == 1 then
        stop_shake()
    else
        letters[current_letter]:fillReset()
        current_letter = current_letter - 1
        letters[current_letter]:fillSelected()
        sounds.back:play()
    end
end

local handlers = {
    cranked = function(change, accChange)
        letters[current_letter]:advanceCharacter(change)
    end,

    AButtonDown = function() if allow_input then next_letter() end end,

    BButtonDown = function() if allow_input then previous_letter() end end,

    upButtonDown = function()
        if allow_input then next_letter()
            letters[current_letter]:advanceCharacter(crank_divisor)
        end
    end,

    downButtonDown = function()
        if allow_input then next_letter()
            letters[current_letter]:advanceCharacter(crank_divisor * -1)
        end
    end,

    rightButtonDown = function() if allow_input then next_letter() end end,

    leftButtonDown = function() if allow_input then previous_letter() end end,
}

function setup()
    playdate.inputHandlers.push(handlers)
    letters[current_letter]:fillSelected()
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
