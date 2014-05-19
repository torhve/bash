import Widget from require "lapis.html"

class DefaultLayout extends Widget
  content: =>
    html_5 ->
      head ->
        meta charset: "utf-8"
        title @title or 'Bash.no'
        if @description
          meta name: "description", content: @description
        else
          meta name: "description", content: "bash.no quote database"
        meta name:"viewport", content:"width=device-width, initial-scale=1.0, maximum-scale=1"
        meta name:"author", content:"Tor Hveem"
        link rel:"shortcut icon", type:"image/png", href:"/static/favicon.png"
        link rel:"icon", type:"image/png", href:"/static/favicon.png"

        link rel: "stylesheet", href: "//netdna.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css"
        link rel: "stylesheet", href: "/static/pure-min.css"
        link rel: "stylesheet", href: "/static/termcolor.css"
        link rel: "stylesheet", href: "/static/bash.css"
        script type: "text/javascript", src: "/static/react.js"
      body ->
        div class:"header", ->
          span class:'logo', 'bash.no'
          small 'BETA'
        div class:"menu", ->
          div class:"home-menu pure-menu pure-menu-open pure-menu-horizontal", ->
            a class:"pure-menu-heading", href:"/", ->
              text "bash.no"


            ul ->
              li class:"pure-menu-selected", ->
                a href:"/", ->
                  i class:"fa fa-home"
                  text " Home"
              li ->
                a href:"/top", ->
                  i class:"fa fa-star"
                  text " Top"
              li ->
                a href:"/random", ->
                  i class:"fa fa-random"
                  text " Random"
              li ->
                a href:"/tags", ->
                  i class:"fa fa-tags"
                  text " Tags"
              li ->
                a href:"/new", ->
                  i class:"fa fa-plus-square-o"
                  text " Submit"

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

