import Widget from require "lapis.html"

class New extends require "widgets.base"
  content: =>
    div class: "body", ->
      h2 @title
      @render_errors!

      div class:"pure-g", ->
        div class:"pure-u-1-2", ->
          text "Please use the text format as shown. Ex:"
          pre [[
            <Sui88> 67% of girls are stupid
            <V-girl> i belong with the other 13%
          ]]

          form class:"pure-form pure-form-stacked", method: "POST", action: @url_for("new"), ->
            fieldset ->
              input type: "hidden", name: "csrf_token", value: @csrf_token
              label for: "content_field", "Paste your quote in to the text area below"
              div id:"tacontainer", ->
                textarea name: "content", id: "content_field"
              label for: "tags_field", "Space separted list of tags. Ex. #lua"
              input type: "text", name: "tags", id:"tags_field"
            button type: "submit", class: "pure-button pure-button-primary", 'Submit quote'
        div class:"pure-u-1-2", ->
          p
          pre [[





            ]]

          p "Live preview"
          div id:"preview"
          
      script type:"text/jsx", ->
        raw [[
        ]]
