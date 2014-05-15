import Widget from require "lapis.html"

class DefaultLayout extends Widget
  content: =>
    html_5 ->
      head ->
        meta charset: "utf-8"
        title @title or 'Bash.no'
        if @description
          meta name: "description", content: @description
        meta name:"viewport", content:"width=device-width, initial-scale=1.0, maximum-scale=1"
        meta name:"author", content:"Tor Hveem"
        link rel:"shortcut icon", type:"image/png", href:"/static/favicon.png"
        link rel:"icon", type:"image/png", href:"/static/favicon.png"

        link rel: "stylesheet", href: "/static/site.css"
        script type: "text/javascript", src: "/static/react.min.js"
      body ->
        div class:"header", ->
            text 'bash.no'
        div class:"menu", ->
          div class:"home-menu pure-menu pure-menu-open pure-menu-horizontal", ->
            a class:"pure-menu-heading", href:"/", "bash.no"
            ul ->
              li class:"pure-menu-selected", ->
                a href:"/", "Home"
              li ->
                a href:"/top", "Top"
              li ->
                a href:"/random", "Random"
              li ->
                a href:"/new", "Submit"

        div class: 'content', ->
          @content_for 'inner'

        div class: "footer", ->
          div class: "right", ->
            text "by "
            a href: "http://twitter.com/thveem", "@thveem"
            raw " &middot; "
            a href: "http://github.com/torhve/bash", "Source"

          raw " &middot; "
          a href: '/', "Home"
          raw " &middot; "

        script type: "text/javascript", src: "/static/bash.js"

