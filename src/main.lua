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
    next = assertiveSound("sfx/next"),
    back = assertiveSound("sfx/back"),
    stop = assertiveSound("sfx/stop"),
}

function assertiveFont(path)
    local fnt = gfx.font.new(path)
    assert(fnt)
    return fnt
end

local fonts = {
    mvp = assertiveFont("fnt/mvp"),
}

function playdate.graphics.drawTextScaled(text, x, y, scale, forceWidth, forceHeight) -- thanks to u/Paul in the Playdate dev forum :)
    local padding = string.upper(text) == text and 6 or 0 -- Weird padding hack?
    local font = gfx.getFont()
    local w <const> = forceWidth or font:getTextWidth(text)
    local h <const> = forceHeight or font:getHeight() - padding
    local img <const> = gfx.image.new(w, h, gfx.kColorClear)
    gfx.lockFocus(img)
    gfx.drawTextAligned(text, w / 2, 0, kTextAlignment.center)
    gfx.unlockFocus()
    img:drawScaled(x - (scale * w) / 2, y - (scale * h) / 2, scale)
end

class("Textbox").extends(gfx.sprite)

function Textbox.new(initText, initCrank, initFont, positionX, positionY, sizeX, sizeY, textScale, forceTextWidth, forceTextHeight)
    return Textbox(initText, initCrank, initFont, positionX, positionY, sizeX, sizeY, textScale, forceTextWidth, forceTextHeight)
end

function Textbox:init(initText, initCrank, initFont, positionX, positionY, sizeX, sizeY, textScale, forceTextWidth, forceTextHeight)
    Textbox.super.init(self)

    self.currentText = initText or ""
    self.crank = initCrank or 0
    self.font = initFont or nil
    self.textScale = textScale or 1
    self.forceTextWidth = forceTextWidth or nil
    self.forceTextHeight = forceTextHeight or nil

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

    gfx.drawTextScaled(text, self.width / 2, self.height / 2, self.textScale, self.forceTextWidth, self.forceTextHeight)
    
    gfx.popContext()
end

function Textbox:setText(value, scale)
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
        sounds.stop:play()
    else
        current_letter = current_letter + 1 -- TODO: highlight selected letter
        sounds.next:play()
    end
end

function previous_letter()
    if current_letter == 1 then
        --current_letter = #letters
        sounds.stop:play()
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
    gfx.sprite.update()
    playdate.timer.updateTimers()
end
