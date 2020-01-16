local function is_login(req)
    local user
    if req.session then
        user =  req.session.get("user")
        if user and user.username then
            return true, user
        end
    end

    return false, nil
end


local function check_login()
    return function(req, res, next)
        local requestPath = req.path
        local in_white_list = false
        if requestPath == "/auth/login" then
	    	in_white_list = true
	    end
        local islogin, user= is_login(req)
        if in_white_list then
            next()
        else
            if islogin then
                res.locals.login = islogin
                res.locals.username = user and user.username
                next()
            else
                res:redirect("/auth/login")
            end
        end
    end
end

return check_login