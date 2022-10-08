class("Textbox").extends(gfx.sprite)

function Textbox.new(initText, initCrank, initFont, positionX, positionY, sizeX, sizeY, textScale, forceTextWidth,
                     forceTextHeight)
    return Textbox(initText, initCrank, initFont, positionX, positionY, sizeX, sizeY, textScale, forceTextWidth,
        forceTextHeight)
end

function Textbox:init(initText, initCrank, initFont, positionX, positionY, sizeX, sizeY, textScale, forceTextWidth,
                      forceTextHeight)
    Textbox.super.init(self)

    self.currentText = initText or ""
    self.crank = initCrank or 0
    self.font = initFont or nil
    self.textScale = textScale or 1
    self.forceTextWidth = forceTextWidth or nil
    self.forceTextHeight = forceTextHeight or nil

    self.rectFilled = false
    self.rectDarkGrey = false
    self.rectLightGrey = false

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

    if self.rectFilled then
        local old_color = gfx.getColor()

        if self.rectDarkGrey then -- TODO: simplify this. maybe use a single bitfield then selectively apply funcs?
            gfx.setPattern({ 0x1, 0x2, 0x4, 0x8, 0x10, 0x20, 0x40, 0x80 })
            gfx.fillRoundRect(0, 0, self.width, self.height, 10)
            gfx.setColor(old_color)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        elseif self.rectLightGrey then
            gfx.setPattern({ 0xFE, 0xFD, 0xFB, 0xF7, 0xEF, 0xDF, 0xBF, 0x7F })
            gfx.fillRoundRect(0, 0, self.width, self.height, 10)
            gfx.setColor(old_color)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
            gfx.drawRoundRect(0, 0, self.width, self.height, 10)
            gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
        else
            gfx.fillRoundRect(0, 0, self.width, self.height, 10)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        end
    else
        gfx.drawRoundRect(0, 0, self.width, self.height, 10)
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

function Textbox:fillReset()
    self.rectFilled = false
    self.rectDarkGrey = false
    self.rectLightGrey = false
    self:markDirty()
end

function Textbox:fillSelected()
    self.rectFilled = true
    self.rectDarkGrey = false
    self.rectLightGrey = true
    self:markDirty()
end

function Textbox:fillCorrect()
    self.rectFilled = true
    self.rectDarkGrey = false
    self.rectLightGrey = false
    self:markDirty()
end

function Textbox:fillIncorrect()
    self:fillReset()
end

function Textbox:fillUnorder()
    self.rectFilled = true
    self.rectDarkGrey = true
    self.rectLightGrey = false
    self:markDirty()
end

return Textbox
