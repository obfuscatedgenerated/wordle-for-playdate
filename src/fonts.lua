function assertiveFont(path)
    local fnt = gfx.font.new(path)
    assert(fnt)
    return fnt
end

local fonts = {
    mvp = assertiveFont("fnt/mvp"),
}

return fonts
