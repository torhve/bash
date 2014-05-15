db = require "lapis.db"

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

