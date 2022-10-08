function gfx.drawTextScaled(text, x, y, scale, forceWidth, forceHeight) -- thanks to u/Paul in the Playdate dev forum :)
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
