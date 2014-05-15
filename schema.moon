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
    {"anonid", varchar}
    {"amount", integer}
    {"creator_ip", varchar}
    {"created_at", time}
    {"updated_at", time}

    "PRIMARY KEY (id)"
  }

  create_index "votes", "quote_id"
  create_index "votes", "quote_id", "anonid", unique: true

  -- Tags
  create_table "tags", {
      {"id", serial}
      {"name", varchar}

      "PRIMARY KEY (id)"
  }
  create_index "tags", "name", unique: true

  -- Tag membership
  create_table "tags_page_relation", {
      {"id", serial}
      {"quote_id", foreign_key}
      {"tags_id", foreign_key}

      "PRIMARY KEY (id)"
    }
  create_index "tags_page_relation", "quote_id", "tags_id", unique: true

destroy_schema = ->
    tbls = {
        "quote", "votes", "tags", "tags_page_relation"
    }

    for t in *tbls
        drop_table t



{ :make_schema, :destroy_schema }
