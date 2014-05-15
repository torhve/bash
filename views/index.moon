import Widget from require "lapis.html"

class Index extends require "widgets.base"
  content: =>
    h2 @title
    div class:"pure-g", ->
      div class:"pure-u-1-2", ->
        h3 "Welcome to the bash.no Quote Database"
        p "This web site has user submitted quotes from text communication mediums like IRC or twitter, etc. Currently the database contains a total of ", ->
          strong @quoteamount
          text " quotes. There are "
          strong @moderationamount
          text " quotes waiting to be moderated."
        p "Please submit quotes, and browse and vote to your heart's content. You can also report quotes that you wish to request to be removed."

      div class:"pure-u-1-2", -> 
        h3 "News"
        strong "2014-05-14"
        p "Development starts as a fun little project :-)"


