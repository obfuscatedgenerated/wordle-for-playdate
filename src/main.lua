import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx <const> = playdate.graphics

local centerX <const> = 200
local centerY <const> = 120

local alphabet <const> = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

local textbox = gfx.sprite.new()
textbox:setSize(centerX * 2, centerY * 2)
textbox:moveTo(centerX, centerY)
textbox.currentText = "A"
textbox.crank = 0
textbox:add()

function assertiveSound(path)
    local sfx = playdate.sound.fileplayer.new(path)
    assert(sfx)
    return sfx
end


local handlers = {
    cranked = function(change, accChange)
        textbox:advanceCharacter(change)
    end,
}

local sounds = {
    click = assertiveSound("sfx/click"),
}

function textbox:draw()
    gfx.pushContext()
    local text = self.currentText
    if text == nil then
        text = ""
    end
    gfx.drawTextAligned(text, self.width / 2, self.height / 2, kTextAlignment.center)
    gfx.popContext()
end

function textbox:setText(value)
    self.currentText = value
    self:markDirty()
end

function textbox:getText()
    return self.currentText
end

function textbox:advanceCharacter(change)
    local old_idx = (math.floor(self.crank) % 26) + 1

    local adjustedChange = change / 10
    self.crank = self.crank + adjustedChange

    local idx = (math.floor(self.crank) % 26) + 1
    self:setText(alphabet:sub(idx, idx))

    if idx ~= old_idx then
        sounds.click:play()
    end
end

function setup()
    playdate.inputHandlers.push(handlers)
end

setup()

function playdate.update()
    gfx.sprite.update()
    playdate.timer.updateTimers()
end
