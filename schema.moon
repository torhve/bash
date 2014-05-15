db = require "lapis.nginx.postgres"
schema = require "lapis.db.schema"

import types, create_table, create_index, drop_table from schema

make_schema = ->
  {
    :serial
    :varchar
    :text
    :time
    :integer
    :foreign_key
    :boolean
  } = schema.types

  -- Quote
  create_table "quote", {
    {"id", serial}
    {"content", text}
    {"creator_ip", varchar}
    {"flagged", boolean}
    {"published", boolean}
    {"created_at", time}
    {"updated_at", time}

    "PRIMARY KEY (id)"
  }


  -- Votes
  create_table "votes", {
    {"id", serial}
    {"quote_id", foreign_key}
    {"amount", integer}
    {"creator_ip", varchar}
    {"created_at", time}
    {"updated_at", time}

    "PRIMARY KEY (id)"
  }

  create_index "votes", "quote_id"

destroy_schema = ->
    tbls = {
        "quote", "votes"
    }

    for t in *tbls
        drop_table t



{ :make_schema, :destroy_schema }
