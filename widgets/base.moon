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
    small class:'created right', "Submitted #{quote.created_at}"
    div class:"actions", ->
      a class:'pure-button button-small', href:@url_for('quote', id:quote.id), ->
        text "##{quote.id}"
      raw ' '
      a class:'pure-button button-small', href:@url_for('quote', id:quote.id), ->
        span " + "
      raw ' '
      a class:'pure-button button-small', href:@url_for('quote', id:quote.id), ->
        span " - "
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

  render_errors: =>
    if @errors
      div "Errors:"
      ul ->
        for e in *@errors
          li e
