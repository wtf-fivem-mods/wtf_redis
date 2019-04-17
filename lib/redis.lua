Redis = {} -- see setmetatable below

local cbs = { }
local cached = {}

-- local ns = GetCurrentResourceName()
-- local EV = string.format('wtf_redis:ns_%s', ns)
local EV = 'wtf_redis:response'

local function join(...)
    local args = {...}
    local s = args[1]
    for i=2, #args do
        s = s .. args[i]
    end
    return s
end

local function unpackFrom(n, t)
    if #t == 0 then return nil end
    if n == #t then return t[#t] end
    local a = t[n]
    return a, unpackAt(n + 1, t)
end

local mcoro = coroutine.create(function()
        while true do
            local ckey = coroutine.yield()
            if cached[ckey] ~= nil then
                Citizen.CreateThread(function()
                    local args = cached[ckey].args
                    local cmd = args[1]
                    local res, err = Redis[cmd](unpackFrom(2, args))
                    cached[ckey].res = res
                    cached[ckey].err = err
                end)
            end
        end
end)

local _memoize = {}
setmetatable(_memoize, {
    __index = {
        get = function(...)
            local ckey = join('get', ...)
            if cached[ckey] == nil then
                cached[ckey] = {
                    i = 0,
                    res = nil,
                    err = nil,
                    args = {'get', ...}
                }
                local res, err = Redis['get'](...)
                cached[ckey].res = res
                cached[ckey].err = err
            else
                cached[ckey].i = cached[ckey].i + 1
                if cached[ckey].i % 100 == 0 then
                    coroutine.resume(mcoro, ckey)
                end
            end
            return cached[ckey].res, cached[ckey].err
        end,
    },
})

-- send to server
local function redis(cmd, ...)
    local args = {...}
    local id = GetRandomIntInRange(2^32)
    local p = promise.new()
    cbs[id] = function(err, res)
        p:resolve({res, err})
    end
    TriggerServerEvent('wtf_redis:call', EV, id, cmd, args)
    local re = Citizen.Await(p)
    return re[1], re[2]
end

-- response from server
RegisterNetEvent(EV)
AddEventHandler(EV, function(id, err, res)
    if cbs[id] ~= nil then
        cbs[id](err, res)
        cbs[id] = nil
    end
end)

-- metatable to handle Redis.<cmd>
setmetatable(Redis, {
    __index = function(_, cmd)
        return function(...)
            if cmd == 'memoized' then
                return _memoize
            end
            return redis(cmd, ...)
        end
    end,
})