import Redis from 'ioredis'

var redis = new Redis() // todo: add convar support for custom server params

global.onNet('wtf_redis:call', (ev, id, cmd, ...args) => {
    let source = global.source // provided by FiveM to scope response to appropriate client
    redis[cmd](...args, (err, res) =>
        setTimeout(() => global.emitNet(ev, source, id, err || false, res), 0)
    )
})