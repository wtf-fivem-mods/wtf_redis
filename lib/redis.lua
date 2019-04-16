cbs = { }

Redis = {} -- see setmetatable below

-- local ns = GetCurrentResourceName()
-- local ev = string.format('wtf_redis:ns_%s', ns)
local ev = 'wtf_redis:response'

local function abl(a, ...)
    local n = select('#', ...)
    if n == 0 then return nil end
    if n == 1 then return a end
    return a, abl(...)
end

-- send to server
local function redis(cmd, ...)
    local cb = select(select('#', ...), ...)
    local id = GetRandomIntInRange(2^32)
    cbs[id] = cb
    TriggerServerEvent('wtf_redis:call', ev, id, cmd, abl(...))
end

-- response from server
RegisterNetEvent(ev)
AddEventHandler(ev, function(id, err, res)
    if cbs[id] ~= nil then
        cbs[id](err, res)
        cbs[id] = nil
    end
end)

-- metatable to handle Redis.<cmd>
setmetatable(Redis, {
    __index = function(_, cmd)
        return function(...)
            return redis(cmd, ...)
        end
    end,
})