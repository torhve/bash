http = require "lapis.nginx.http"
db = require "lapis.nginx.postgres"
lapis = require "lapis.init"
csrf = require "lapis.csrf"
html = require "lapis.html"
cjson = require "cjson"
config = require("lapis.config").get!

import respond_to, capture_errors, assert_error, yield_error from require "lapis.application"
import validate, assert_valid from require "lapis.validate"
import escape_pattern, trim_filter from require "lapis.util"
import split from require "moonscript.util"
import Quote, Votes, Tags, TagsPageRelation from require "models"
import random from require "math"

debug = (txt) ->
  txt = tostring txt
  ngx.log ngx.ERR, txt

jdebug = (anything) ->
  ngx.say cjson.encode anything

is404 = ->
  render:"error", status:404

class extends lapis.Application
    layout: require "views.layout"

    @before_filter =>
      unless @session.anonid
        -- Generate random anon id
        @session.anonid = ngx.md5 tostring(random(65535))..ngx.var.remote_addr..config.secret
      @anonid = @session.anonid 
      @messages = {}

    [index: "/"]: =>
      @title = 'Welcome to bash.no'
      @quoteamount = Quote\count!
      countq = Quote\select "where published = false", fields: "count(*)"
      @moderationamount = countq[1].count
      render: true

    [quote: "/quote/:id"]: =>
      unless tonumber @params.id
        return is404!
      @quote = Quote\find @params.id
      unless @quote
        return is404!
      @title = @quote\text_version!
      render: true

    [random: "/random"]: =>
      @quotes = Quote\select "where published = false order by random() LIMIT 10"
      render: true

    [top: "/top"]: =>
      @title = 'Top quotes'
      --- FIXME publish order by votes
      @paginator = Quote\paginated [[
        q 
        LEFT JOIN votes 
          ON votes.quote_id = q.id 
        WHERE published = false 
        GROUP BY q.id
        ORDER BY votesum DESC]], per_page:10, fields:"q.*, COALESCE(SUM(amount), 0) AS votesum"
      @pagenum = 1
      if tonumber(@params.page) 
        if tonumber(@params.page) > 1 or tonumber(@params.page) <= @paginator\num_pages!
          @pagenum = tonumber(@params.page)
      render: 'quotes'

    [recent: "/recent"]: =>
      @title = 'Recent quotes'
      --- FIXME publish order by votes
      @paginator = Quote\paginated [[
        q 
        LEFT JOIN votes 
          ON votes.quote_id = q.id 
        WHERE published = false 
        GROUP BY q.id
        ORDER BY created_at DESC, votesum DESC]], per_page:10, fields:"q.*, COALESCE(SUM(amount), 0) AS votesum"
      @pagenum = 1
      if tonumber(@params.page) 
        if tonumber(@params.page) > 1 or tonumber(@params.page) <= @paginator\num_pages!
          @pagenum = tonumber(@params.page)
      render: 'quotes'

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

        tags = split @params.tags, ' '
        for tagname in *tags
          tag = Tags\find name: tagname
          unless tag
            tag = Tags\create tagname
          relation = TagsPageRelation\create quote.id, tag.id

        redirect_to: @url_for("quote", id: quote.id)
    }

    [vote: "/vote/:qid/:direction"]: capture_errors =>
      unless tonumber @params.qid
        return is404!
      @quote = Quote\find @params.qid
      unless @quote
        return is404!
      dir = @params.direction
      amount = 0
      message = ''
      switch dir
        when 'up'
          amount = 1
          message = 'Ok. It has been hyped!'
        when 'down' 
          amount = -1
          message = 'Ok. They shall have to try harder.'
        when 'nuke'
          amount = 0
          message = 'Ok. Admins might react.'
        else
          return is404!
      success, @vote = pcall -> Votes\create @quote.id, amount, @anonid, ngx.var.remote_addr
      unless success
        message = 'You have already inflincted the appropriate amount of power. Sorry.'

      table.insert @messages, message
      render:'quote'

    [tags: "/tags"]: =>
        @title = "All tags"
        @tags = Tags\select "order by name asc"
        render: true

    [tag: "/tag/:name"]: =>
        @tag = ngx.unescape_uri @params.name
        @title = "All quotes with tag"
        @paginator = Quote\paginated [[
          JOIN tags_page_relation as r
              ON (quote.id = r.quote_id)
          JOIN tags as t
              ON (t.id = r.tags_id)
          LEFT JOIN votes 
            ON votes.quote_id = quote.id 
          WHERE 
              published = false
            AND 
              t.name = ?
          GROUP BY quote.id
          ORDER BY votesum DESC]], @tag, per_page:10, fields:"quote.*, COALESCE(SUM(amount), 0) AS votesum"
        @pagenum = 1
        if tonumber(@params.page) 
          if tonumber(@params.page) > 1 or tonumber(@params.page) <= @paginator\num_pages!
            @pagenum = tonumber(@params.page)
        render: true

    [search: "/search"]: =>
        assert_valid @params, {
            { 'q', exists: true, min_length: 1, max_length: 75 }
        }
        {:q} = @params
        @title = 'Search for ' .. q
        @query = q
        pq = q .. ':*'
        --res = db.query "SELECT * FROM wiki_pages WHERE to_tsvector(slug) @@ to_tsquery(?)", q .. ':*'
        --  select distinct on (wiki_page_id) r.* wiki_page_id from revisions r, wiki_pages w where r.wiki_page_id = w.id order by wiki_page_id, r.updated_at desc
        @titlematches = db.select [[* from (select distinct on (r.wiki_page_id) r.*, w.id, w.slug from revisions r, wiki_pages w where r.wiki_page_id = w.id order by r.wiki_page_id, updated_at) as pages 
            WHERE 
                to_tsvector(slug) @@ to_tsquery(?) 
            OR
                to_tsvector(content) @@ to_tsquery(?)]], pq, pq
        if #@titlematches == 1
          redirect_to: @url_for("wikipage", slug:@titlematches[1].slug)
        render: true

    "/api/tags/": =>
      search = ngx.unescape_uri @params.search
      unless search
        return is404!
      -- TODO fast API
      matches = Tags\select 'WHERE name like ? LIMIT 10', "%#{search}%"
      json: [m.name for m in *matches]


    "/db/make": =>
      if @anonid == "e58cab5f47de5c723e9b97417e34091f"
        schema = require "schema"
        schema.make_schema!
        json: { status: "ok" }

    "/db/nuke": =>
      if @anonid == "e58cab5f47de5c723e9b97417e34091f"
        schema = require "schema"
        schema.destroy_schema!
        json: { status: "ok" }
