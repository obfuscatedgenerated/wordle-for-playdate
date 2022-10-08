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
    correct = assertiveSound("sfx/correct"),
    incorrect = assertiveSound("sfx/incorrect"),
    unorder = assertiveSound("sfx/unorder"),
    win = assertiveSound("sfx/win"),
    fail = assertiveSound("sfx/fail"),
}

return sounds
