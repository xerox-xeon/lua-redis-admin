local redis = require("resty.redis-util")
local redis_pool = require("app.config.config").redis_pool

local hash_model = {}


function hash_model:get_redis_hash(params)
    local red = redis:new(redis_pool[params.serverName]);
    red:select(params.dbIndex)
    local count = redis:hlen(params.key)
    local res, err = redis:hscan(params.key, 0 , 'count', count);
    local list = {}
    local s = res[2]
    for i=1, #s, 2 do
        local t = {}
        --for token in string.gmatch("sdssf", "[^,]+") do
	    --    table.insert(t,token)
        --end
        local tmp = {
            field = s[i],
            value = s[i+1]
        }
        table.insert(list, tmp)
    end
    return list
end


function hash_model:update_redis_hash(params)
    local data = {
        returncode = "500",
        returnmsg = "request error",
        returnmemo = "redis string" .. params.key
    }
    local red = redis:new(redis_pool[params.serverName]);
    red:select(params.dbIndex)
    local ok, err = redis:hset(params.key, params.field, params.value);
    if ok then
        data = {
            returncode = "200",
            returnmsg = "request success",
            returnmemo = "SUCCESS:200000:request success",
            data = "attachment",
            operator = "nothing"
        }
    else
        data.returnmemo = err
    end
    return data
end

function hash_model:delete_redis_hash(params)
    local data = {
        returncode = "500",
        returnmsg = "request error",
        returnmemo = "redis string" .. params.key
    }
    local red = redis:new(redis_pool[params.serverName]);
    red:select(params.dbIndex)
    local ok, err = redis:hdel(params.key, params.field);
    if ok then
        data = {
            returncode = "200",
            returnmsg = "request success",
            returnmemo = "SUCCESS:200000:request success",
            data = "attachment",
            operator = "nothing"
        }
    end
    return data
end

return hash_model