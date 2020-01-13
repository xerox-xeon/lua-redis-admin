local redis = require("resty.redis-util")
local redis_pool = require("app.config.config").redis_pool

local string_model = {}

function string_model:get_redis_string(params)
    local red = redis:new(redis_pool[params.serverName]);
    red:select(params.dbIndex)
    local ok, err = redis:get(params.key);
    local values = {}
    local tmp = {
         value = ok,
         score = 'null',
         member = 'null',
         field = 'null'
    }
    table.insert(values, tmp)
    return values
end

function string_model:update_redis_string(params)
    local data = {
        returncode = "500",
        returnmsg = "request error",
        returnmemo = "RESULT: " .. params.key .. " has failed to update"
    }
    local red = redis:new(redis_pool[params.serverName]);
    red:select(params.dbIndex)
    local ok, err = redis:set(params.key, params.value);
    if ok then
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


return string_model