local redis = require("resty.redis-util")
local http_model = require("app.models.http")
local redis_pool = require("app.config.config").redis_pool
local string_model = require("app.models.string")
local list_model = require("app.models.list")
local set_model = require("app.models.set")
local zset_model = require("app.models.zset")
local hash_model = require("app.models.hash")
local redis_model = {}

function redis_model:get_redis_dbs(redis_pool)
    local red = redis:new(redis_pool);
    --local ok,err = red:eval("return redis.call('config', 'get', 'databases')","0")
    local db,err = red:config("get","databases")
    if err then return err end
    return db[2]
end

function redis_model:get_redis_dbsize(redis_pool, db)
    local red = redis:new(redis_pool);
    local ok,err = red:select(db)
    local db,err = red:dbsize()
    if err then return err end
    return db
end

function redis_model:get_redis_dbs_json(redis_pool, serverName, groupId)
    local children = {}
    --local db_num = tonumber(redis_model:get_redis_dbs(redis_pool))
    local red = redis:new(redis_pool)
     -- ngx.log(ngx.ERR, red)
    local db,err = red:config("get","databases")
    if err then
        local tmp = {
            name = "连接失败" .. err
        }
        table.insert(children, tmp)
        return children
    end
    for i=1, tonumber(db[2]) do
        local dbsize = redis_model:get_redis_dbsize(redis_pool,i-1)
        local tmp = {
            name = "db" .. i - 1 .. " (" .. dbsize .. ")",
            parent = false,
            children = {},
            checked = true,
            attach = {
                serverName = serverName,
                dbIndex = i - 1,
                seprator = ":",
                groupId = groupId,
                keyPrefixs = {}
            }
        }
        table.insert(children, tmp)
    end
    return children

end

function redis_model:get_redis_stringList_bak(redis_pool, db, params)
    if http_model:is_empty(params) then
        params = '*'
    end
    local data ={}
    local red = redis:new(redis_pool);
    red:select(db)
    local ok,err = red:keys(params)
    if err then return err end
    if type(ok)  == "table" then
        for i, key in ipairs(ok) do
            local tmp = {
                id = i,
                name = key,
                type = string.upper(red:type(key))
            }
            table.insert(data,tmp)
        end
    else
        data = {}
    end
    return data
end


-- Get per page list

function redis_model:get_per_pageList(ans, visit_page, items_per_page)
    local data = {}
    if http_model:is_empty(visit_page) then
        visit_page = 0
    end
    visit_page = visit_page + 1

    for i = 1, items_per_page do
        local page_cursor = visit_page * items_per_page
        local s = ans[page_cursor + i]
        local tmp = {
                id = page_cursor + i,
                name = s,
                type = string.upper(red:type(s))
        }
        table.insert(data,tmp)
    end
    return data
end

-- Get string list via scan command

function redis_model:get_redis_stringList(redis_pool, db, params, visit_page, items_per_page)
    ngx.log(ngx.ERR, visit_page)
    if http_model:is_empty(params) then
        params = '*'
    end
    if http_model:is_empty(visit_page) then
        visit_page = 0
    end
    -- visit_page = visit_page + 1
    local red = redis:new(redis_pool);
    red:select(db)
    local db,err = red:dbsize()
    local data, ans, has, cursor = {}, {}, {}, "0";
    repeat
        local t = red:scan(cursor, "MATCH", params, "COUNT", 1000);
        local list = t[2];
        for i = 1, #list do
            local s = list[i];
            --local tmp = {
            --    id = #ans + 1,
            --    name = s,
            --    type = red:type(s)
            --}
            --table.insert(ans,tmp)


            if has[s] == nil then
                has[s] = 1;
                ans[#ans + 1] = s;
            end;
        end;
        cursor = t[1];
    until cursor == "0";

    for i = 1, items_per_page do
        local page_cursor = visit_page * items_per_page
        local s = ans[page_cursor + i]
        if s then
            local tmp = {
                id = page_cursor + i,
                name = s,
                type = string.upper(red:type(s))
            }
            table.insert(data,tmp)
        end

    end

    local result = {
        max = #ans,
        keys = data
    }
    return result;
end

function redis_model:get_redis_keyValue(params)
    local key_data_struct = {
        STRING = function() return string_model:get_redis_string(params) end,
        LIST = function() return list_model:get_redis_list(params) end,
        SET = function() return set_model:get_redis_set(params) end,
        ZSET = function() return zset_model:get_redis_zset(params) end,
        HASH = function() return hash_model:get_redis_hash(params) end
    }

    local func = key_data_struct[string.upper(params.dataType)]
    local values = func()

    local data = {
            returncode = '200',
            returnmsg = "request success",
            returnmemo = "SUCCESS:20010001:update success",
            data = {
                dataType = params.dataType,
                values = values
            },
            operator = "GETKV"
        }
        return data
end

function redis_model:post_redis_keyValue(params)
    local key_data_struct = {
        STRING = function() return string_model:update_redis_string(params) end,
        LIST = function() return list_model:update_redis_list(params) end,
        SET = function() return set_model:update_redis_set(params) end,
        ZSET = function() return zset_model:update_redis_zset(params) end,
        HASH = function() return hash_model:update_redis_hash(params) end
    }

    local func = key_data_struct[string.upper(params.dataType)]
    local values = func()

    local data = values
    return data
end

function redis_model:delete_redis_keyValue(params)
    local data = {
        returncode = "500",
        returnmsg = "request error",
        returnmemo = "RESULT: " .. params.deleteKeys .. " has failed to delete"
    }
    local red = redis:new(redis_pool[params.serverName]);
    red:select(params.dbIndex)
    red:init_pipeline()
    for key in string.gmatch(params.deleteKeys, "[^,]+") do
        red:del(key)
    end
    local results, err = red:commit_pipeline()
    if results then
        data = {
            returncode = "200",
            returnmsg = "request success",
            returnmemo = "RESULT: ".. params.deleteKeys .. " has been deleted successfully",
            data = "attachment",
            operator = "nothing"
        }
    end
    return data

end




function redis_model:get_redis_group(groupId)
    local data = {}
    for i, conn_pool in pairs(redis_pool) do
        if conn_pool.group == groupId then
            local tmp = {
                name = i,
                host = conn_pool.host
            }
            table.insert(data, tmp)
        end
    end
    return data
end

return redis_model