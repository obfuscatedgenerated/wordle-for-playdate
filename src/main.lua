import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx <const> = playdate.graphics

local centerX <const> = 200
local centerY <const> = 120

local alphabet <const> = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

function assertiveSound(path)
    local sfx = playdate.sound.fileplayer.new(path)
    assert(sfx)
    return sfx
end

local sounds = {
    click = assertiveSound("sfx/click"),
}

class("Textbox").extends(gfx.sprite)

function Textbox.new(initText, initCrank, positionX, positionY, sizeX, sizeY)
    return Textbox(initText, initCrank, positionX, positionY, sizeX, sizeY)
end

function Textbox:init(initText, initCrank, positionX, positionY, sizeX, sizeY)
    Textbox.super.init(self)

    self.currentText = initText or ""
    self.crank = initCrank or 0

    self:setSize(sizeX or (centerX * 2), sizeY or (centerY * 2))
    self:moveTo(positionX or centerX, positionY or centerY)

    self:add()
end

function Textbox:draw()
    gfx.pushContext()
    local text = self.currentText
    if text == nil then
        text = ""
    end
    gfx.drawTextAligned(text, self.width / 2, self.height / 2, kTextAlignment.center)
    gfx.popContext()
end

function Textbox:setText(value)
    self.currentText = value
    self:markDirty()
end

function Textbox:getText()
    return self.currentText
end

function Textbox:advanceCharacter(change)
    local old_idx = (math.floor(self.crank) % 26) + 1

    local adjustedChange = change / 10
    self.crank = self.crank + adjustedChange

    local idx = (math.floor(self.crank) % 26) + 1
    self:setText(alphabet:sub(idx, idx))

    if idx ~= old_idx then
        sounds.click:play()
    end
end

local letters_start_x <const> = 100

local letters_size_x <const> = 50
local letters_size_y <const> = 50

local letters = {
    Textbox("A", 0, letters_start_x, centerY, letters_size_x, letters_size_y),
    Textbox("A", 0, letters_start_x + letters_size_x, centerY, letters_size_x, letters_size_y),
    Textbox("A", 0, letters_start_x + 2 * letters_size_x, centerY, letters_size_x, letters_size_y),
    Textbox("A", 0, letters_start_x + 3 * letters_size_x, centerY, letters_size_x, letters_size_y),
    Textbox("A", 0, letters_start_x + 4 * letters_size_x, centerY, letters_size_x, letters_size_y),
}

local current_letter = 1

local handlers = {
    cranked = function(change, accChange)
        letters[current_letter]:advanceCharacter(change)
    end,

    AButtonDown = function()
        current_letter = current_letter + 1 -- TODO: highlight selected letter
        if current_letter > #letters then
            current_letter = 1 -- currently wraps back around TODO: replace with submit logic
        end
    end,

    BButtonDown = function()
        current_letter = current_letter - 1
        if current_letter < 1 then
            current_letter = 1 -- currently prevents further button press TODO: add error sound
        end
    end,
}

function setup()
    playdate.inputHandlers.push(handlers)
end

setup()

function playdate.update()
    gfx.sprite.update()
    playdate.timer.updateTimers()
end
