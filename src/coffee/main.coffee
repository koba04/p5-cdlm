jQuery( ($) ->
  "use strict"

  class CDLM
    rankMax: 50

    constructor: (country, rank) ->
      @videoList = []
      @index = rank or @rankMax
      @country = country
      @player = ''
      @init = true

    play: (mode, playIndex) ->
      @index = playIndex if playIndex

      # 動画なかったらさらに次へ
      while not @videoList[@index] or not @videoList[@index].video
        if mode is 'prev'
          # これ以上戻れない
          return if @index >= @rankMax
          ++@index
        else
          # これ以上先はない
          return if @index <= 1
          --@index
      @player.loadVideoById @videoList[@index].video.id if not @init

      currentHtml = """
                    <div class="track">
                    <span class="rank">#{ @videoList[@index].rank }&nbsp</span>
                    <span class="info">#{ @videoList[@index].info.artist.name }&nbsp/&nbsp#{ @videoList[@index].info.name }</span><br />
                    """
      if @videoList[@index].video
        currentHtml += """<span class="video_info">(#{ @videoList[@index].video.title })</span>"""
        $('title').text(@videoList[@index].video.title)
      currentHtml += '</div>'
      $("#current").html(currentHtml)
      if @videoList[@index].rank > 1
        next = @index - 1
        nextSongHtml = ''
        if @videoList[next].video
          nextSongHtml += """
                          <div id="next_img"><img src="#{ @videoList[next].video.thumbnail.sqDefault }" width="120" height="90" /></div>
                          <div class="next_track">
                          <span class="rank">#{ @videoList[next].rank }&nbsp</span>
                          <span class="info">#{ @videoList[next].info.artist.name }&nbsp/&nbsp#{ @videoList[next].info.name }</span><br />
                          <span class="video_info">(#{ @videoList[next].video.title })</span>
                          </div>
                          """
        $("#next_song").html(nextSongHtml)
      else
        $("#next_song").html("")
      @highlight()
      history.replaceState(null, "CDLM " + @country + ":" + @index, "/track/" + @country + "/" + @index)

    next: ->
      return if @index <= 1
      --@index
      @play 'next'

    prev: ->
      return if @index >= @rankMax
      ++@index
      @play 'prev'

    highlight: ->
      $("#list").children().css "color", "black"
      $("#trac_" + @videoList[@index].rank).css "color", "red"

    getList: ->
      $.getJSON("/track/" + @country + ".json", {}, (rs) =>
        html = ""
        isIndexSet = false
        for track in rs.reverse()
          @videoList[track.rank] = track
          html += """
                  <div id="trac_#{ track.rank }" class="track">
                  <span class="rank">#{ track.rank }&nbsp</span>
                  <span class="info">#{ track.info.artist.name }&nbsp;/&nbsp;#{ track.info.name }</span><br />
                  """
          if track.video
            html += """
                    <span class="video_info">(#{ track.video.title })</span>
                    <input type="button" id="button_trac_#{ track.rank }" value="play" class="play_button" />
                    """
            # 最初に再生可能なインデックス
            if not isIndexSet and @index
              @index = track.rank
              isIndexSet = true
          html += '</div>'
        $("#list").html(html)
        @highlight()

        $(".play_button").click( (e) =>
          id = $(e.target).attr('id')
          id = id.replace(/button_trac_/, "")
          @play('next', id)
        )

        # https://developers.google.com/youtube/iframe_api_reference
        tag = document.createElement('script')
        tag.src = "//www.youtube.com/iframe_api"
        firstScriptTag = document.getElementsByTagName('script')[0]
        firstScriptTag.parentNode.insertBefore(tag, firstScriptTag)
        window.onYouTubeIframeAPIReady = =>
          @player = new YT.Player('video',
            height: '425',
            width: '760',
            videoId: @videoList[@index].video.id,
            events:
              'onStateChange': (e) =>
                state = e.data
                @next() if state is YT.PlayerState.ENDED
              'onError': () ->
                @next()
          )
        @play('next')
        @init = false
      )

  cdlm = new CDLM(
    $("meta[name=country]").attr("content"),
    $("meta[name=rank]").attr("content"),
  )
  cdlm.getList()

  # tab
  $("#prev").click ->
    cdlm.prev()
  $("#next").click ->
    cdlm.next()
  $("#show").click ->
    window.show()
  $("#content").tabs()

)
