db = require "lapis.db"
import split from require "moonscript.util"
import Model from require "lapis.db.model"

local *

class Quote extends Model
  @timestamp: true

  @create: (content, ip) =>

    Model.create @, {
      content: content
      creator_ip: ip
    }

  votes: =>
    res = Votes\select "where quote_id = ?", @id, fields: "SUM(amount)"
    return res[1].sum or 0

  tags: =>
    Tags\select [[
      INNER JOIN tags_page_relation r
        ON (tags.id = r.tags_id)
        WHERE quote_id = ?
      ]], @id

  lines: =>
    lines = split(@content, '\n')
    out = {}
    for line in *lines
      m, err = ngx.re.match(line, '\\s*<[@&%+ ]?(.*?)>\\s*(.*)\\s*$')
      if m
        nick = m[1]
        text = m[2]
        table.insert out, {:nick,:text}
      else
        table.insert out, {nick:'', text:line}
    return out

  text_version: =>
    out = {}
    for line in *@lines!
      nick = ''
      unless line.nick == ''
        nick = "<#{line.nick}> "
      table.insert out, "#{nick}#{line.text}"
    table.concat out, ' '


class Votes extends Model
  @timestamp: true

  @create: (qid, amount, anonid, ip) =>
    Model.create @, {
      quote_id: qid
      amount: amount
      creator_ip: ip
      anonid: anonid
    }

class Tags extends Model
  @create: (name) =>

    Model.create @, {
      name: name\lower!
    }

class TagsPageRelation extends Model
  @create: (quote_id, tags_id) =>

    Model.create @, {
        quote_id: quote_id
        tags_id: tags_id
    }

{
  :Quote, :Votes, :Tags, :TagsPageRelation
}

