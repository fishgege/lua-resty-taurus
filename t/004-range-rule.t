
use Test::Nginx::Socket::Lua;
use Cwd qw(cwd);

repeat_each(2);

plan tests => repeat_each() * (3 * blocks());

$ENV{TEST_NGINX_CWD} = cwd();

no_long_string();

our $HttpConfig = <<'_EOC_';
    lua_need_request_body on;
    lua_load_resty_core off;
    lua_package_path "$TEST_NGINX_CWD/lib/?.lua;$TEST_NGINX_CWD/t/lualib/?.lua;";

    init_by_lua_block {
        local yaml = require "resty.yaml"
        local taurus = require "resty.taurus"
        local text = io.open("$TEST_NGINX_CWD/t/rule/004-range-rule.yaml"):read("*a")
        local r = yaml.parse(text) or {}
        _G.rule_engine = taurus.compile(r)
    }
_EOC_

run_tests();

__DATA__

=== TEST 1: range rule match 150
--- http_config eval: $::HttpConfig
--- config
    location = /t {
        content_by_lua_block {
            local fact = require "resty.taurus.context.fact"
            local decision = require "resty.taurus.context.decision"
            local decide = decision.new()
            _G.rule_engine:match(fact.new(
                ngx.req.get_headers(),
                ngx.req.get_uri_args(),
                ngx.req.get_post_args(),
                {}
            ), decide)
            ngx.say(decide.rulename or "")
            ngx.say(decide.upstream or "")
        }
    }
--- request
GET /t?param=150
--- response_body
rulename
proxy
--- error_code: 200
--- no_error_log
[warn]



=== TEST 2: range rule match 200
--- http_config eval: $::HttpConfig
--- config
    location = /t {
        content_by_lua_block {
            local fact = require "resty.taurus.context.fact"
            local decision = require "resty.taurus.context.decision"
            local decide = decision.new()
            _G.rule_engine:match(fact.new(
                ngx.req.get_headers(),
                ngx.req.get_uri_args(),
                ngx.req.get_post_args(),
                {}
            ), decide)
            ngx.say(decide.rulename or "")
            ngx.say(decide.upstream or "")
        }
    }
--- request
GET /t?param=200
--- response_body
rulename
proxy
--- error_code: 200
--- no_error_log
[warn]



=== TEST 3: range rule not match 100
--- http_config eval: $::HttpConfig
--- config
    location = /t {
        content_by_lua_block {
            local fact = require "resty.taurus.context.fact"
            local decision = require "resty.taurus.context.decision"
            local decide = decision.new()
            _G.rule_engine:match(fact.new(
                ngx.req.get_headers(),
                ngx.req.get_uri_args(),
                ngx.req.get_post_args(),
                {}
            ), decide)
            ngx.say(decide.rulename or "")
            ngx.say(decide.upstream or "")
        }
    }
--- request
GET /t?param=100
--- response_body
rulename2
proxy2
--- error_code: 200
--- no_error_log
[warn]



=== TEST 4: range rule not match, no parameter
--- http_config eval: $::HttpConfig
--- config
    location = /t {
        content_by_lua_block {
            local fact = require "resty.taurus.context.fact"
            local decision = require "resty.taurus.context.decision"
            local decide = decision.new()
            _G.rule_engine:match(fact.new(
                ngx.req.get_headers(),
                ngx.req.get_uri_args(),
                ngx.req.get_post_args(),
                {}
            ), decide)
            ngx.say(decide.rulename or "")
            ngx.say(decide.upstream or "")
        }
    }
--- request
GET /t
--- response_body
rulename2
proxy2
--- error_code: 200
--- no_error_log
[warn]