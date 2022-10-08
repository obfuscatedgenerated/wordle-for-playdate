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

return sounds