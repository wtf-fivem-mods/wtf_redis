cbs = { }

Redis = {} -- see setmetatable below

-- local ns = GetCurrentResourceName()
-- local ev = string.format('wtf_redis:ns_%s', ns)
local ev = 'wtf_redis:response'

-- send to server
local function redis(cmd, ...)
    local args = {...}
    local id = GetRandomIntInRange(2^32)
    if type(args[#args]) == 'function' then
        cbs[id] = args[#args]
        args[#args] = nil
    end
    TriggerServerEvent('wtf_redis:call', ev, id, cmd, args)
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