# lor-redis-admin [![Build Status](https://travis-ci.org/lifeblood/lor-redis-admin.svg?branch=master)](https://travis-ci.org/lifeblood/lor-redis-admin)
[![GitHub release](https://img.shields.io/badge/release-download-orange.svg)](https://github.com/lifeblood/lor-redis-admin/releases)
[![License](https://img.shields.io/badge/license-Apache%202-4EB1BA.svg)](https://www.apache.org/licenses/LICENSE-2.0.html)

This is a redis client web tool written based on Openresty lor Lua framework and lua-resty-redis. It's my objective to build the most convenient redis client web tool in the world. In the first place, it will facilitate in editing redis data, such as: add, update, delete, search, cut, copy, paste etc.

![](https://cdn4.iconfinder.com/data/icons/redis-2/467/Redis_Logo-512.png)

## Features

**Multiple Redis version adaptive**

 1. Manage redis server, support server password authentication
 2. Manage redis data
 	* New redis data: string, list, hash, set, sorted set
 	* Delete redis data
 	* Update redis data
 	* Search redis data by key
 	* Support paging query redis data
 	* Support multiple language, now support English

##  Screenshots

![image](http://github.com/lifeblood/lor-redis-admin/app/static/img/Screenshot_1.png)

![image](http://github.com/lifeblood/lor-redis-admin/app/static/img/Screenshot_2.png)

##  Quick Start

`First Step`: edit file:'./app/config/config.lua' :


```
redis_pool= {
                redis1 =  {
                    host = "127.0.0.1",
                    port = 6379,
                    db_index = 0,
                    password = "",
                    timeout = 1000,
                    keepalive = 60000,
                    pool_size = 1000,
                    group = "dev"
                },
                

                redis2 =  {
                        host = "127.0.0.1",
                        port = 6379,
                        db_index = 0,
                        password = "",
                        timeout = 1000,
                        keepalive = 60000,
                        pool_size = 1000,
                        group = "test"
                }

                }



        }
```

`Second Step`: edit file:'./app/config/config.lua' :

```
    -- ####Security Manager
    manager = {
        username = 'admin',
        password = 'admin'
    }
```

`Third Step`: deploy project

docker-compose up -d

`Last Step`: visit redis-admin

open your brower and visit: http://localhost:8848/redis

then, enter username and password what you set in file 'application.properties'


##  Releases Notes

**Please Note: trunk is current development branch.**

* [**Inspired by**](https://github.com/mauersu/redis-admin/) https://github.com/mauersu/redis-admin/

##  FAQ

* [**FAQ**](https://github.com/lifeblood/lor-redis-admin/wiki/FAQ)

![img-source-from-https://github.com/docker/dockercraft](https://github.com/docker/dockercraft/raw/master/docs/img/contribute.png?raw=true)
