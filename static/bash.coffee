{createClass, renderComponent, DOM} = React
{div, textarea, table, tr, td, span} = DOM


ncolor = (nick) ->
    unless nick
        return ''
    color = 0
    for char in nick
      color += String.charCodeAt(char)
    color = color % 256
    return "cef-"+color

parse_lines = (content) ->
  lines = content.split('\n')
  out = [] 
  for line in lines
    m = line.match /\s*<[&@+% ]?(.*?)>\s*(.*)\s*$/
    if m
        nick = m[1]
        text = m[2]
        out.push {nick:nick,text:text}
    else
        out.push {nick:'',text:line}
  return out

quoteTextArea = createClass
    getInitialState: ->
        value: ''
    render: -> 
        (textarea { ref: 'textarea', onKeyUp: @handleKeyUp, name: 'content', id: 'content_field' }, @state.value)
    handleKeyUp: ->
        value = @refs.textarea.getDOMNode().value
        @setState value: value
        console.log(value)
        lines = {lines: parse_lines value}
        console.log lines
        renderComponent quote(lines), document.getElementById 'preview'

quote = createClass
    render: ->
        (table {}, [@props.lines.map quoteLine])

coloredNick = createClass
    render: -> (div {}, [
        (span {}, '<'),
        (span {className:ncolor(@props.nick)}, @props.nick),
        (span {}, '>')
    ])

quoteLine = createClass
    render: ->
        (tr {}, [
         (td {className:'prefix'}, coloredNick({nick:@props.nick})),
         (td {}, @props.text)
         ])


QuoteApp = createClass


renderComponent quoteTextArea(), document.getElementById 'tacontainer'



