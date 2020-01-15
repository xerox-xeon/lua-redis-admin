local lor = require("lor.index")
local redis_pool = require("app.config.config").redis_pool
local redis_group = require("app.config.config").redis_group
local manager = require("app.config.config").manager
local loginRouter = lor:Router() -- 生成一个group router对象


loginRouter:get("/login", function(req, res, next)
     res:render("admin/redis/login",{
        res = redis_pool,
        redis_group = redis_group,
        remember = req.cookie.get("remember") or ''
    })
end)

loginRouter:post("/login", function(req, res, next)
    local username = req.body.Username
    local password = req.body.Password
    local remember = req.body.remember

    if remember and username then
        req.cookie.set("remember", username)
    end

    if manager.username == username and manager.password == password then
        req.session.set("user", {
            username = username
        })
        res:redirect('/redis/')
    else
        res:redirect('/auth/login')
    end
end)



loginRouter:get("/logout", function(req, res, next)
    req.session.destroy()
    res:redirect("/auth/login")
end)

return loginRouter