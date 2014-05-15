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

class Votes extends Model
  @timestamp: true

  @create: (qid, amount, ip) =>
    Model.create @, {
      qoute_id: qid
      amount: amount
      creator_ip: ip
    }

{
  :Quote, :Votes
}

