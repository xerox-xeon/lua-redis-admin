return {
    --分页
    pagination = {
        items_per_page = '10'
    },
    -- 静态模板配置，保持默认不修改即可
	view_config = {
		engine = "tmpl",
		ext = "html",
		views = "../app/views"
	},

    redis_group = {
        dev = "开发环境",
        test = "测试环境"
    },


    redis_pool= {
                redis1 =  {
                    host = "172.20.100.25",
                    port = 6379,
                    db_index = 0,
                    password = "456123",
                    timeout = 1000,
                    keepalive = 60000,
                    pool_size = 1000,
                    group = "dev"
                },
                redis2 = {
                    host = "172.20.100.26",
                    port = 6379,
                    db_index = 0,
                    password = "456123",
                    timeout = 1000,
                    keepalive = 60000,
                    pool_size = 1000,
                    group = "dev"
                },

                redis3 =  {
                        host = "172.20.100.25",
                        port = 6379,
                        db_index = 0,
                        password = "456123",
                        timeout = 1000,
                        keepalive = 60000,
                        pool_size = 1000,
                        group = "test"
                },
                redis4 = {
                        host = "172.20.100.26",
                        port = 6379,
                        db_index = 0,
                        password = "456123",
                        timeout = 1000,
                        keepalive = 60000,
                        pool_size = 1000,
                        group = "test"
                }



        }
}