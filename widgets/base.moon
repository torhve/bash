import Widget from require "lapis.html"
import split from require "moonscript.util"
-- List of "safe" colors
colors =  {
  22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201
}
colorize_nicks = (content) ->
  lines = split(content, '\n')
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

class Base extends Widget

  render_tags: (tags) =>
    ul class: "tags", ->
      for tag in *tags
        name = ngx.escape_uri tag.name
        li ->
          a class:"tag", href:@url_for('tag', name: name), ->
            -- @faicon "tag"
            text tag.name


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
    color = color % #colors
    return "cef-"..tostring(colors[color])

  render_quote: (quote) =>
    lines = colorize_nicks quote.content
    --- TODO join
    votes = quote.votesum or quote\votes! or 0
    div class: "quote", ->
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
      element 'table', ->
        for line in *lines
          tr ->
            td class:"prefix", -> 
              unless line.nick == ''
                text "<"
                span class:@ncolor(line.nick), ->
                  text line.nick
                text ">"
            td -> 
              text line.text
      --- TODO JOIN
      @render_tags quote\tags!


  paginate: (paginator) =>
    pages = @paginator\num_pages!
    link = (n) ->
      if n < 1 then n = 1
      if n > pages then n = pages
      '?page='..n
    ul class:'pure-paginator', ->
      li ->
        a class:'pure-button prev', href:link(@pagenum-1), ->
          raw "&#171;"
      for i=1, pages
        if @pagenum == i
          a class:'pure-button active', href:link(i), ->
            text i
        else
          a class:'pure-button', href:link(i), ->
            text i
      li ->
        a class:'pure-button next', href:link(@pagenum+1), ->
          raw "&#187;"

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
