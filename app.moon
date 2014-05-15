http = require "lapis.nginx.http"
db = require "lapis.nginx.postgres"
lapis = require "lapis.init"
csrf = require "lapis.csrf"
html = require "lapis.html"
cjson = require "cjson"

import respond_to, capture_errors, assert_error, yield_error from require "lapis.application"
import validate, assert_valid from require "lapis.validate"
import escape_pattern, trim_filter from require "lapis.util"
import split from require "moonscript.util"
import Quote, Votes from require "models"

debug = (txt) ->
  txt = tostring txt
  ngx.log ngx.ERR, txt

jdebug = (anything) ->
  ngx.say cjson.encode anything

is404 = ->
  render:"error", status:404

class extends lapis.Application
    layout: require "views.layout"

    [index: "/"]: =>
      @title = 'Welcome to bash.no'
      @quoteamount = Quote\count!
      countq = Quote\select "where published = false", fields: "count(*)"
      @moderationamount = countq[1].count
      render: true

    [quote: "/quote/:id"]: =>
      @title = ''
      unless tonumber @params.id
        return is404!
      @quote = Quote\find @params.id
      unless @quote
        return is404!
      render: true

    [top: "/top"]: =>
      @title = 'Top quotes'
      --- FIXME publish order by votes
      @quotes = Quote\select "where published = false"
      render: true

    [new: "/new"]: respond_to {
      before: =>
        @title = "Submit quote"
        @page_description = "Submit new quote"

      GET: =>
        @csrf_token = csrf.generate_token @
        debug @csrf_token
        render: true

      POST: capture_errors =>
        csrf.assert_token @
        assert_valid @params, {
            { 'content', exists: true, min_length: 5, max_length: 2048 }
        }
        {:content} = @params


        ip = ngx.var.remote_addr
        quote = assert_error Quote\create content, ip

        redirect_to: @url_for("quote", id: quote.id)
    }

    "/db/make": =>
      schema = require "schema"
      schema.make_schema!
      json: { status: "ok" }

    "/db/nuke": =>
      schema = require "schema"
      schema.destroy_schema!
      json: { status: "ok" }
