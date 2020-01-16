local redis = require("resty.redis-util")
local redis_pool = require("app.config.config").redis_pool

local zset_model = {}

function zset_model:get_redis_zset(params)
    local red = redis:new(redis_pool[params.serverName]);
    red:select(params.dbIndex)
    local res, err = redis:zrange(params.key,0,-1,'WITHSCORES');
    local list = {}
    for i=1,#res,2 do
        local tmp = {
            value = res[i],
            score = res[i+1]
        }
        table.insert(list, tmp)
    end
    return list
end

function zset_model:update_redis_zset(params)
    local data = {
        returncode = "500",
        returnmsg = "request error",
        returnmemo = "RESULT: " .. params.key .. " has failed to update"
    }
    local red = redis:new(redis_pool[params.serverName]);
    red:select(params.dbIndex)


    if params.score_field == '' and params.member_field == '' then
        -- ngx.log(ngx.ERR, params.key .. "-->" .. params.score .. "-->" .. params.member)
        red:init_pipeline()
        red:zadd(params.key, params.score, params.member)
        local results, err = red:commit_pipeline()
        if results then
            data = {
                returncode = "200",
                returnmsg = "request success",
                returnmemo = "RESULT: ".. params.key .. " has been added successfully",
                data = "attachment",
                operator = "nothing"
            }
        end
    else
        red:init_pipeline()
        red:zrem(params.key, params.member_field)
        red:zadd(params.key, params.score, params.member)
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
    end
   return data
end


function zset_model:delete_redis_zset(params)
    local data = {
        returncode = "500",
        returnmsg = "request error",
        returnmemo = "RESULT: " .. params.key .. " has failed to update"
    }
    local red = redis:new(redis_pool[params.serverName]);
    red:select(params.dbIndex)

    red:init_pipeline()
    red:zrem(params.key, params.score, params.member)
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

return zset_model