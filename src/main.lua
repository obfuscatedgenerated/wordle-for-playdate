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

function assertiveFont(path)
    local fnt = gfx.font.new(path)
    assert(fnt)
    return fnt
end

local fonts = {
    mvp = assertiveFont("fnt/mvp"),
}

class("Textbox").extends(gfx.sprite)

function Textbox.new(initText, initCrank, initFont, positionX, positionY, sizeX, sizeY)
    return Textbox(initText, initCrank, initFont, positionX, positionY, sizeX, sizeY)
end

function Textbox:init(initText, initCrank, initFont, positionX, positionY, sizeX, sizeY)
    Textbox.super.init(self)

    self.currentText = initText or ""
    self.crank = initCrank or 0
    self.font = initFont or nil

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

    if self.font then
        gfx.getFont()
        gfx.setFont(self.font)
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

function Textbox:setFont(fnt)
    self.font = fnt
    self:markDirty()
end

function Textbox:getFont()
    return self.font
end

local crank_divisor <const> = 10

function Textbox:advanceCharacter(change)
    local old_idx = (math.floor(self.crank) % 26) + 1

    local adjustedChange = change / crank_divisor
    self.crank = self.crank + adjustedChange

    local idx = (math.floor(self.crank) % 26) + 1
    self:setText(alphabet:sub(idx, idx))

    if idx ~= old_idx then
        sounds.click:play()
    end
end

function Textbox:setFont(font)
    gfx.setFont(font)
end

local letters_start_x <const> = 100

local letters_size_x <const> = 50
local letters_size_y <const> = 50

local letters = {
    Textbox("A", 0, fonts.mvp, letters_start_x, centerY, letters_size_x, letters_size_y),
    Textbox("A", 0, fonts.mvp, letters_start_x + letters_size_x, centerY, letters_size_x, letters_size_y),
    Textbox("A", 0, fonts.mvp, letters_start_x + 2 * letters_size_x, centerY, letters_size_x, letters_size_y),
    Textbox("A", 0, fonts.mvp, letters_start_x + 3 * letters_size_x, centerY, letters_size_x, letters_size_y),
    Textbox("A", 0, fonts.mvp, letters_start_x + 4 * letters_size_x, centerY, letters_size_x, letters_size_y),
}

local current_letter = 1

function next_letter()
    current_letter = current_letter + 1 -- TODO: highlight selected letter
    if current_letter > #letters then
        current_letter = 1 -- currently wraps back around TODO: replace with submit logic
    end
end

function previous_letter()
    current_letter = current_letter - 1
    if current_letter < 1 then
        current_letter = 1 -- currently prevents further button press TODO: add error sound
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
    gfx.sprite.update()
    playdate.timer.updateTimers()
end
