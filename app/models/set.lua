local redis = require("resty.redis-util")
local redis_pool = require("app.config.config").redis_pool

local set_model = {}

function set_model:get_redis_set(params)
    local red = redis:new(redis_pool[params.serverName]);
    red:select(params.dbIndex)
    local count = red:scard(params.key)
    local res, err = red:sscan(params.key, 0 , 'COUNT', count);
    local list = {}
    if not err then
        local s = res[2]
        for i=1, #s do
            local tmp = {
                value = s[i]
            }
            table.insert(list, tmp)
        end
    end
    return list
end

function set_model:update_redis_set(params)
    local data = {
        returncode = "500",
        returnmsg = "request error",
        returnmemo = "RESULT: " .. params.key .. " has failed to update"
    }
    local red = redis:new(redis_pool[params.serverName]);
    red:select(params.dbIndex)

    red:init_pipeline()
    red:srem(params.key, params.field)
    red:sadd(params.key, params.value)
    local results, err = red:commit_pipeline()
    if results then
        data = {
            returncode = "200",
            returnmsg = "request success",
            returnmemo = "RESULT: ".. params.key .. " has been updated successfully",
            data = "attachment",
            operator = "nothing"
        }

    end
    return data
end


function set_model:delete_redis_set(params)
    local data = {
        returncode = "500",
        returnmsg = "request error",
        returnmemo = "RESULT: " .. params.key .. " has failed to update"
    }
    local red = redis:new(redis_pool[params.serverName]);
    red:select(params.dbIndex)

    red:init_pipeline()
    red:srem(params.key, params.field)
    local results, err = red:commit_pipeline()
    if results then
        data = {
            returncode = "200",
            returnmsg = "request success",
            returnmemo = "RESULT: ".. params.key .. " has been deleted successfully",
            data = "attachment",
            operator = "nothing"
        }

    end
    return data
end

return set_model