import Widget from require "lapis.html"
import split from require "moonscript.util"

colorize_nicks = (content) ->
  lines = split(content, '\n')
  out = {}
  for line in *lines
    m, err = ngx.re.match(line, '\\s*<(.*?)>\\s*(.*)\\s*$')
    if m
      nick = m[1]
      text = m[2]
      table.insert out, {:nick,:text}
    else
      table.insert out, {nick:'', text:line}
  return out

class Base extends Widget

  faicon: (name) =>
    raw '<i class="fa fa-'..name..'"></i> '

  term_snippet: (cmd) =>
    pre class: "highlight lang_bash term_snippet", ->
      code ->
        span class: "nv", "$ "
        text cmd

  ncolor: (nick) =>
    color = 0
    for i=1, #nick do 
      color += string.byte(nick\sub(i,i))
    color = color % 256
    return "cef-"..tostring(color)

  render_quote: (quote) =>
    lines = colorize_nicks quote.content
    --- TODO join
    votes = quote\votes! or 0
    small class:'created right', "Submitted #{quote.created_at}"
    div class:"actions", ->
      a class:'pure-button button-small', href:@url_for('quote', id:quote.id), ->
        @faicon "chain"
        text " #{quote.id}"
      raw ' '
      a class:'pure-button button-small', href:@url_for('vote', qid:quote.id, direction:'up'), ->
        @faicon "thumbs-up", ->
        if votes > 0
          text " (#{votes})"
      raw ' '
      a class:'pure-button button-small', href:@url_for('vote', qid:quote.id, direction:'down'), ->
        @faicon "thumbs-down", ->
        if votes < 0
          text " (#{votes})"
      raw ' '
      a class:'pure-button button-small', href:@url_for('vote', qid:quote.id, direction:'nuke'), ->
        @faicon "flag"
    div class:"quote", ->
      element 'table', ->
        for line in *lines
          tr ->
            td class:"prefix", -> 
              text "<"
              span class:@ncolor(line.nick), ->
                text line.nick
              text ">"
            td -> 
              text line.text
    div class:"tags", ->
      --- TODO JOIN
      for tag in *quote\tags!
        span class:'tag', ->
          @faicon "tag"
          text tag.name


  paginate: (paginator) =>
    ul class:'pure-paginator', ->
      li ->
        a class:'pure-button prev', href:'#', ->
          text '1'
        a class:'pure-button active', href:'#', ->
          text '2'
        a class:'pure-button next', href:'#', ->
          text '3'

  render_errors: =>
    if @errors and #@errors
      div "Errors:"
      ul class: 'messages', ->
        for e in *@errors
          li class:'alert', e
  render_messages: =>
    if #@messages and #@messages>0
      h5 "MESSAGES"
      ul class:'messages', ->
        for e in *@messages
          li class:'success', e
