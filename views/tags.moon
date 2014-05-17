import Widget from require "lapis.html"

class Tags extends require "widgets.base"
  content: =>
    h2 @title
    hr!

    @render_errors!

    @render_tags(@tags)

    hr style:"clear:both"


    [[--div class: "pure-g-r", ->
      div class: "pure-u-1-3", ->
        form class:"pure-form", method:'post', ->
          fieldset ->
            input type:'text', name:'name'
          input class:'button pure-button small', type:'submit', value:'Add new tag'
]]
     

          
