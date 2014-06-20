# Simple JSON stuffs
getJSON = (options, callback) ->
    xhttp = new XMLHttpRequest()
    options.url = options.url || location.href
    options.data = options.data || null
    callback = callback || ->
    options.type = options.type || 'json'
    url = options.url

    if options.type is 'jsonp'
        window.jsonCallback = callback
        $url = url.replace('callback=?', 'callback=jsonCallback')
        script = document.createElement('script')
        script.src = $url
        document.body.appendChild(script)

    xhttp.open('GET', options.url, true)
    xhttp.send(options.data)
    xhttp.onreadystatechange = ->
        if (xhttp.status == 200 && xhttp.readyState == 4)
            try
                text = JSON.parse xhttp.responseText
            callback text


# List of "safe" colors
colors =  [ 22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201 ]

ncolor = (nick) ->
    return '' unless nick?
    color = 0
    for char in nick
      color += char.charCodeAt(0)
    color = color % colors.length
    return "cef-"+colors[color]

parse_lines = (content) ->
  lines = content.trim().split('\n')
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

# React shortcuts
{createClass, renderComponent} = React

build_tag = (tag) ->
  (options...) ->
    unless typeof(options[0]) is 'object'
        options.unshift {} 
    React.DOM[tag].apply @, options

DOM = (->
  object = {}
  for element in Object.keys(React.DOM)
    object[element] = build_tag element
  object
)()

{h1, div, textarea, table, tr, td, span, input, ul, li, a} = DOM

quoteTextArea = createClass
    getInitialState: ->
        value: ''

    render: -> 
        textarea { ref: 'textarea', onKeyUp: @handleKeyUp, name: 'content', id: 'content_field' }, @state.value

    handleKeyUp: ->
        value = @refs.textarea.getDOMNode().value
        @setState value: value
        lines = {lines: parse_lines value}
        renderComponent quote(lines), document.getElementById 'preview'

quote = createClass
    render: ->
        table {}, [quoteLine line for line in @props.lines]

coloredNick = createClass
    render: ->
        unless @props.nick is ''
            div {},
                span '<',
                span {className:ncolor(@props.nick)}, @props.nick,
                span '>'
        else
            (div {})


quoteLine = createClass
    render: ->
        tr {},
         td {className:'prefix'}, coloredNick {nick:@props.nick}
         td @props.text

renderComponent quoteTextArea(), document.getElementById 'tacontainer'


Tag = createClass
    render: ->
        a {className:'tag', href:'#'}, @props.name

TagList = createClass
    render: ->
        ul {className:'tags'}, [Tag {name:n} for n in @props.autocomplete]


TagBox = createClass
    getInitialState: ->
      {autocomplete: [], call: {latest:0, term:''}}

    makeCall: (term, current) ->
        apiurl = "/api/tags/?search=#{encodeURIComponent(term)}"
        getJSON {url:apiurl}, ((data) ->
            if (current is @state.call.latest) 
                newPriority = @state.call.latest - 1
                if data is {} then data = []
                @setState({autocomplete: data, call: {latest: newPriority, term:''} })
        ).bind(@)

    handleKeyUp: (e) ->
        # TODO: split term into multiple space separated terms
        k = @refs.tagbox.getDOMNode().value
        if k.length > 0
            priority = @state.call.latest+1
            @setState {call: {latest: priority, term: k}, term:k}
        if k.length is 0 and @state.autocomplete.length > 0
            @setState {autocomplete: [], call: {latest:0, term:''}}
        return false

    handleKeyPress: (e) ->
        # Tab or enter
        if e.keyCode is 9 or e.keyCode is 13
            @refs.tagbox.getDOMNode().value = @refs.tagbox.getDOMNode().value.replace(@state.term, @state.autocomplete[0])
            return false
        return true

    render: ->
        if @state.call.latest > 0 and @state.call.term != ''
            @makeCall @state.call.term, @state.call.latest
        div {},
            TagList autocomplete:@state.autocomplete
            input ref: 'tagbox', type:'text', id: 'tags_field', name:'tags', onKeyUp:@handleKeyUp, onKeyPress:@handleKeyPress


renderComponent TagBox(), document.getElementById 'tagbox'









