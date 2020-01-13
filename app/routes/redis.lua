local lor = require("lor.index")
local redis_pool = require("app.config.config").redis_pool
local redis_group = require("app.config.config").redis_group
local pagination = require("app.config.config").pagination
local http_model = require("app.models.http")
local redis_model = require("app.models.redis")
local redisRouter = lor:Router() -- 生成一个group router对象

redisRouter:get("/test", function(req, res, next)
    res:render("admin/redis/list",{
        res = redis_pool
    })
end)

redisRouter:get("/", function(req, res, next)
    res:render("admin/redis/hello",{
        res = redis_pool,
        redis_group = redis_group
    })
end)

redisRouter:get("/group/:id", function(req, res, next)
    local groupId = req.params.id
    local redis_list = redis_model:get_redis_group(groupId)
    res:render("admin/redis/group",{
        res = redis_pool,
        redis_group = redis_group,
        groupId = groupId,
        redis_list = redis_list
    })
end)

redisRouter:get("/group/:id/:servername/:db", function(req, res, next)
    local groupId = req.params.id
    local servername = req.params.servername
    local db = req.params.db
    local redis_list = redis_model:get_redis_group(groupId)
    local params = http_model:get_http_params(req.params, req.query)
    local redisKeys = redis_model:get_redis_stringList(redis_pool[servername], db, params.queryValue, params.visit_page,  pagination.items_per_page)
    local pagination =http_model:get_pagination(redisKeys.max, pagination.items_per_page, params)

    res:render("admin/redis/list",{
        res = redis_pool,
        redis_group = redis_group,
        serverName = servername,
        serverHost = redis_pool[servername]['host'],
        dbIndex = db,
        groupId = groupId,
        redisKeys = redisKeys.keys,
        params = params,
        pagination = pagination,
        redis_list = redis_list
    })
end)

redisRouter:get("/json", function(req, res, next)
    res:json(redis_pool)
end)

return redisRouter