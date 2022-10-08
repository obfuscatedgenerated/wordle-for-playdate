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

return Textbox