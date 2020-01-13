local redis = require("resty.redis-util")
local redis_pool = require("app.config.config").redis_pool

local list_model = {}

function list_model:get_redis_list(params)
    local red = redis:new(redis_pool[params.serverName]);
    red:select(params.dbIndex)
    local count = red:llen(params.key)
    local res, err = red:lrange(params.key, 0 , count);
    local list = {}
    local s = res
    for i=1, #s do
        local t = {}
        --for token in string.gmatch("sdssf", "[^,]+") do
	    --    table.insert(t,token)
        --end
        local tmp = {
            field = "" .. i .. "",
            value = s[i]
        }
        table.insert(list, tmp)
    end
    return list
end


function list_model:update_redis_list(params)
    local data = {
        returncode = "500",
        returnmsg = "request error",
        returnmemo = "RESULT: " .. params.key .. " has failed to update"
    }
    local red = redis:new(redis_pool[params.serverName]);
    red:select(params.dbIndex)
    local ok, err  = ''
    if params.field == '' then
        ok, err = red:lpush(params.key, params.value);
    else
        ok, err = red:lset(params.key, tonumber(params.field) - 1, params.value);
    end
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

function list_model:delete_redis_list(params)
    local data = {
        returncode = "500",
        returnmsg = "request error",
        returnmemo = "RESULT: " .. params.key .. " has failed to delete"
    }
    local red = redis:new(redis_pool[params.serverName]);
    red:select(params.dbIndex)
    local delete_name = '---VALUE_REMOVED_BY_REDIS_ADMIN---'
    red:init_pipeline()
    red:lset(params.key, params.field - 1, delete_name);
    red:lrem(params.key, params.field - 1, delete_name);
    local results, err = red:commit_pipeline()
    if results then
        data = {
            returncode = "200",
            returnmsg = "request success",
            returnmemo = "RESULT: ".. params.key .. " has been deleted successfully",
            data = "attachment",
            operator = "nothing"
        }
    else
        data.returnmemo = err
    end
    return data
end

return list_model