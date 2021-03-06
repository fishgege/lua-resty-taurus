Name
=============

lua-resty-taurus - A Simple RuleEngine for OpenResty/LuaJIT which named Taurus

Status
======

This library is considered production ready.

Build status: [![Travis](https://travis-ci.org/toruneko/lua-resty-taurus.svg?branch=master)](https://travis-ci.org/toruneko/lua-resty-taurus)

Description
===========

This library requires an nginx build with [ngx_lua module](https://github.com/openresty/lua-nginx-module), and [LuaJIT 2.0](http://luajit.org/luajit.html).

Synopsis
========

```lua
    # nginx.conf:

    lua_package_path "/path/to/lua-resty-taurus/lib/?.lua;;";

    server {
        location = /t {
            content_by_lua_block {
                local r = {
                    rules = {
                        {
                            name = "rulename",
                            when = {
                                equals = {
                                    ["request.query.param"] = "demo"
                                }
                            },
                            ["do"] = {
                                proxy = "proxy"
                            }
                        }
                    }
                }
                local taurus = require "resty.taurus"
                local rule_engine = taurus.compile(r)

                local fact = require "resty.taurus.context.fact"
                local decision = require "resty.taurus.context.decision"
                local decide = decision.new()
                local matched = rule_engine:match(fact.new(
                    ngx.req.get_headers(),
                    ngx.req.get_uri_args(),
                    ngx.req.get_post_args(),
                    {}
                ), decide)
                ngx.say(decide.rulename)
                ngx.say(decide.upstream)
            }
        }
    }
    
```

Learning more about rule definition: [defining-processors](https://www.elastic.co/guide/en/beats/filebeat/current/defining-processors.html)

Methods
=======

To load this library,

1. you need to specify this library's path in ngx_lua's [lua_package_path](https://github.com/openresty/lua-nginx-module#lua_package_path) directive. For example, `lua_package_path "/path/to/lua-resty-taurus/lib/?.lua;;";`.
2. you use `require` to load the library into a local Lua variable:

```lua
    local taurus = require "resty.taurus"
```

compile
---
`syntax: rule_engine = taurus.compile(r)`

Creates a new rule engine object instance


```lua
-- creates a rule engine object
local taurus = require "resty.taurus"
local rule_engine = taurus.compile(r)
```

match
----
`syntax: matched = rule_engine:match(fact, decide)`

```lua
local fact = require "resty.taurus.context.fact"
local decision = require "resty.taurus.context.decision"
local decide = decision.new()
local matched = rule_engine:match(fact.new(
    ngx.req.get_headers(),
    ngx.req.get_uri_args(),
    ngx.req.get_post_args(),
    {}
), decide)
ngx.say(decide.rulename)
ngx.say(decide.upstream)
```

Expression Definition
======

And
----
```yaml
rules:
  - name: [rulename]
    when:
      and: 
        - [conditions]
        - [conditions]
    do:
      [action]
```

Or
----
```yaml
rules:
  - name: [rulename]
    when:
      or: 
        - [conditions]
        - [conditions]
    do:
      [action]
```

Not
----
```yaml
rules:
  - name: [rulename]
    when:
      not:
        [conditions]
    do:
      [action]
```

Rule Definition
======

```yaml
rules:
  - name: [rulename]
    when:
      [conditions]
    do:
      [action]
```

Contains
----
contains rule defines that the fact value contains a expected value.
```yaml
contains:
  request.query.param: demo
```

Equals
----
equals rule defines that the fact value equals to a expected value.
```yaml
equals:
  request.query.param: demo
```

HasFields
----
has fields rule defines that the fact includes expected fields.
```yaml
has_fields: 
  - request.query.param
```

InArray
----
in array rule defines that the fact value includes some expected values.
```yaml
in_array:
  request.query.param: 
    - demo1
    - demo2
```

StartWith
----
start with rule defines that the fact value begins with a expected prefix.
```yaml
startwith:
  request.query.param: demo
```

EndWith
----
end with rule defines that the fact value ends with a expected suffix.
```yaml
endwith:
  request.query.param: demo
```

Range
----
range rule defines that the fact value larger than or less than a expected number.
```yaml
range:
  request.query.param:
    gt: 100
    lte: 200
```

Count
----
count rule defines that the fact value counters. In expected window second(s), fact counts over than expected total number, this rule will be matched.
```yaml
count:
  request.query.param: 
    dict_name: count
    total: 1
    window: 1
```

Author
======

Jianhao Dai (toruneko) <toruneko@outlook.com>


Copyright and License
=====================

This module is licensed under the MIT license.

Copyright (C) 2018, by Jianhao Dai (toruneko) <toruneko@outlook.com>

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


See Also
========
* the ngx_lua module: https://github.com/openresty/lua-nginx-module