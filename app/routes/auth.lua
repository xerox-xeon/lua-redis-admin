local lor = require("lor.index")
local redis_pool = require("app.config.config").redis_pool
local redis_group = require("app.config.config").redis_group
local manager = require("app.config.config").manager
local loginRouter = lor:Router() -- 生成一个group router对象


loginRouter:get("/login", function(req, res, next)
     res:render("admin/redis/login",{
        res = redis_pool,
        redis_group = redis_group
    })
end)

loginRouter:post("/login", function(req, res, next)
    local username = req.body.Username
    local password = req.body.Password
    ngx.log(ngx.ERR, username)
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