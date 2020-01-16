local lor = require("lor.index")
local redis_pool = require("app.config.config").redis_pool
local redis_group = require("app.config.config").redis_group
local redis_model = require("app.models.redis")
local string_model = require("app.models.string")
local list_model = require("app.models.list")
local set_model = require("app.models.set")
local zset_model = require("app.models.zset")
local hash_model = require("app.models.hash")
local apiRouter = lor:Router() -- 生成一个group router对象

apiRouter:get("/test", function(req, res, next)
    res:render("admin/redis/list",{
        res = redis_pool
    })
end)

apiRouter:get("/", function(req, res, next)
    for i, group in ipairs(redis_pool[1].value) do
        ngx.log(ngx.ERR, group['host'])
        local data = redis_model:get_redis_dbs_json(group)
        res:send(data)
    end


end)


apiRouter:get("/KV", function(req, res, next)
    local params = {
        serverName = req.query.serverName,
        dbIndex = req.query.dbIndex,
        key = req.query.key,
        dataType = req.query.dataType
    }

    local data = redis_model:get_redis_keyValue(params)
    res:json(data)

    --local c_tbl = {
    --    STRING = function() return redis_model:get_redis_string(params) end,
    --    LIST = function() return redis_model:get_redis_string(params) end,
    --    SET = function() return redis_model:get_redis_string(params) end,
    --    ZSET = function() return redis_model:get_redis_string(params) end,
    --    HASH = function() return redis_model:get_redis_string(params) end
    --}
    --
    --local func = c_tbl[string.upper(params.dataType)]
    --if(func) then
    --    local data = func()
    --     res:json(data)
    --else
    --    res:json("The program has been terminated.")
    --end
end)



apiRouter:post("/KV", function(req, res, next)
    local params = {
        serverName = req.body.serverName,
        dbIndex = req.body.dbIndex,
        key = req.body.key,
        dataType = req.body.dataType,
        score_field = req.body.score_field or '',
        score = req.body.score or '',
        field = req.body.field or '',
        member_field = req.body.member_field or '',
        member = req.body.member or '',
        value = req.body.value or ''
    }

    local data = redis_model:post_redis_keyValue(params)
    res:json(data)

end)




apiRouter:post("/delKV", function(req, res, next)
    local params = {
        serverName = req.body.serverName,
        dbIndex = req.body.dbIndex,
        deleteKeys = req.body.deleteKeys
    }
    local data = redis_model:delete_redis_keyValue(params)
    res:json(data)
end)


apiRouter:get("/refresh", function(req, res, next)
    local data = {
        returncode = "200",
        returnmsg = "request success\"",
        returnmemo = "SUCCESS:200000:request success",
        data = "attachment",
        operator = "nothing"
    }
    res:json(data)
end)

apiRouter:get("/serverTree", function(req, res, next)
    local groupId = req.query.groupId -- 从req.query取参数
    local serverName = req.query.serverName
    local data = {}
    --local group_id = tonumber(req.params.id)
    for i, conn_pool in pairs(redis_pool) do
        -- local red = redis:new(conn_pool);
        if conn_pool.group == groupId then
            local dbs = redis_model:get_redis_dbs_json(conn_pool, i, groupId)
            local default = {
            name = conn_pool['host'],
            icon = "/static/img/icons/png/redis.png",
            attach = {
                serverName = i,
                dbIndex = -1,
                seprator = ":",
                groupId = groupId,
                keyPrefixs = {}
            },
            open = i == serverName,
            parent = false,
            children = dbs
            }
            table.insert(data, default)

        end
    end
    -- local red = redis:new(redis_pool);
    res:json(data)
end)

apiRouter:post("/string/updateValue", function(req, res, next)
    local content_type = req.headers['Content-Type']
    local data = {}
    local params = {
        serverName = req.body.serverName,
        dbIndex = req.body.dbIndex,
        key = req.body.key,
        dataType = req.body.dataType,
        value = req.body.value
    }
    data = string_model:update_redis_string(params)
    res:json(data)
end)

apiRouter:post("/list/updateListValue", function(req, res, next)
    local content_type = req.headers['Content-Type']
    local data = {}
    local params = {
        serverName = req.body.serverName,
        dbIndex = req.body.dbIndex,
        key = req.body.key,
        dataType = req.body.dataType,
        field = req.body.field,
        value = req.body.value
    }
    data = list_model:update_redis_list(params)
    res:json(data)
end)

apiRouter:post("/list/delListValue", function(req, res, next)
    local data = {}
    local params = {
        serverName = req.body.serverName,
        dbIndex = req.body.dbIndex,
        key = req.body.key,
        dataType = req.body.dataType,
        field = req.body.field,
        value = req.body.value
    }
    data = list_model:delete_redis_list(params)
    res:json(data)
end)

apiRouter:post("/hash/updateHashField", function(req, res, next)
    local content_type = req.headers['Content-Type']
    local data = {}
    local params = {
        serverName = req.body.serverName,
        dbIndex = req.body.dbIndex,
        key = req.body.key,
        dataType = req.body.dataType,
        field = req.body.field,
        value = req.body.value
    }
    data = hash_model:update_redis_hash(params)
    res:json(data)
end)


apiRouter:post("/hash/delHashField", function(req, res, next)
    local content_type = req.headers['Content-Type']
    local data = {}
    local params = {
        serverName = req.body.serverName,
        dbIndex = req.body.dbIndex,
        key = req.body.key,
        dataType = req.body.dataType,
        field = req.body.field
    }
    data = hash_model:delete_redis_hash(params)
    res:json(data)
end)


apiRouter:post("/set/updateSetValue", function(req, res, next)
    local content_type = req.headers['Content-Type']
    local data = {}
    local params = {
        serverName = req.body.serverName,
        dbIndex = req.body.dbIndex,
        key = req.body.key,
        dataType = req.body.dataType,
        field = req.body.field,
        value = req.body.value
    }
    data = set_model:update_redis_set(params)
    res:json(data)
end)

apiRouter:post("/set/delSetValue", function(req, res, next)
    local content_type = req.headers['Content-Type']
    local data = {}
    local params = {
        serverName = req.body.serverName,
        dbIndex = req.body.dbIndex,
        key = req.body.key,
        dataType = req.body.dataType,
        field = req.body.field,
        value = req.body.value
    }
    data = set_model:delete_redis_set(params)
    res:json(data)
end)

apiRouter:post("/zset/updateZSetValue", function(req, res, next)
    local content_type = req.headers['Content-Type']
    local data = {}
    local params = {
        serverName = req.body.serverName,
        dbIndex = req.body.dbIndex,
        key = req.body.key,
        dataType = req.body.dataType,
        score_field = req.body.score_field,
        member_field = req.body.member_field,
        score = req.body.score,
        member = req.body.member
    }
    data = zset_model:update_redis_zset(params)
    res:json(data)
end)

apiRouter:post("/zset/delZSetValue", function(req, res, next)
    local content_type = req.headers['Content-Type']
    local data = {}
    local params = {
        serverName = req.body.serverName,
        dbIndex = req.body.dbIndex,
        key = req.body.key,
        dataType = req.body.dataType,
        score = req.body.score,
        member = req.body.member
    }
    data = zset_model:delete_redis_zset(params)
    res:json(data)
end)

apiRouter:get("/json", function(req, res, next)
    res:json(redis_pool)
end)

return apiRouter