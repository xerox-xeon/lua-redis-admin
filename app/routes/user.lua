local lor = require("lor.index")
local userRouter = lor:Router() -- 生成一个group router对象

-- 按id查找用户
-- e.g. /query/123
userRouter:get("/query/:id", function(req, res, next)
    local query_id = tonumber(req.params.id) -- 从req.params取参数

    if not query_id then
        return res:render("user/info", {
            desc = "Error to find user, path variable `id` should be a number. e.g. /user/query/123"
        })
    end

    -- 渲染页面
    res:render("user/info", {
        id = query_id,
        name = "user" .. query_id,
        desc = "User Information"
    })
end)

-- 删除用户
-- e.g. /delete?id=123
userRouter:delete("/delete", function(req, res, next)
    local id = req.query.id -- 从req.query取参数
    if not id then
        return res:html("<h2 style='color:red'>Error: query param id is required.</h2>")
    end

    -- 返回html
    res:html("<span>succeed to delete user</span><br/>user id is:<b style='color:red'>" .. id .. "</b>")
end)

-- 修改用户
-- e.g. /put/123?name=sumory
userRouter:put("/put/:id", function(req, res, next)
    local id = req.params.id  -- 从req.params取参数
    local name = req.query.name -- 从req.query取参数

    if not id or not name then
        return res:send("error params: id and name are required.")
    end

    -- 返回文本格式的响应结果
    res:send("succeed to modify user[" .. id .. "] with new name:" .. name)
end)

-- 创建用户
userRouter:post("/post", function(req, res, next)
    local content_type = req.headers['Content-Type']

    -- 如果请求类型为form表单或json请求体
    if string.find(content_type, "application/x-www-form-urlencoded",1, true) or
        string.find(content_type, "application/json",1, true) then
        local id = req.body.id -- 从请求体取参数
        local name = req.body.name -- 从请求体取参数

        if not id or not name then
            return res:json({
                success = false,
                msg = "error params: id and name are required."
            })
        end

        res:json({-- 返回json格式的响应体
            success = true,
            data = {
                id = id,
                name = name,
                desc = "succeed to create new user" .. id
            }
        })
    else -- 不支持其他请求体
        res:status(500):send("not supported request Content-Type[" .. content_type .. "]")
    end
end)

return userRouter
