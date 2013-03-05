jQuery( ($) ->
  "use strict"

  videoList = []
  rankMax = 50
  index = rankMax
  country = ''
  player = ''
  init = true

  highlight = ->
    $("#list").children().css "color", "black"
    $("#trac_" + videoList[index].rank).css "color", "red"

  play = (mode, playIndex) ->
    index = playIndex if playIndex

    # 動画なかったらさらに次へ
    while !videoList[index] or !videoList[index].video
      if mode is 'prev'
        # これ以上戻れない
        return if index >= rankMax
        ++index
      else
        # これ以上先はない
        return if index <= 1
        --index
    player.loadVideoById videoList[index].video.id if !init

    currentHtml = '<div class="track">'
    currentHtml += '<span class="rank">' + videoList[index].rank + "&nbsp</span>"
    currentHtml += '<span class="info">' + videoList[index].info.artist.name + " / " + videoList[index].info.name + "</span><br />"
    if videoList[index].video
      currentHtml += '<span class="video_info">(' +  videoList[index].video.title + ")</span>"
      $('title').text(videoList[index].video.title)
    currentHtml += '</div>'
    $("#current").html(currentHtml)
    if videoList[index].rank > 1
      next = index - 1
      nextSongHtml = ''
      if videoList[next].video
        nextSongHtml = '<div id="next_img"><img src="' + videoList[next].video.thumbnail.sqDefault + '" width="120" height="90" /></div>'
      nextSongHtml += '<div class="next_track">'
      nextSongHtml += '<span class="rank">'  + videoList[next].rank + '&nbsp</span>'
      nextSongHtml += '<span class="info">' + videoList[next].info.artist.name + " / " + videoList[next].info.name + "</span><br />"
      if videoList[next].video
        nextSongHtml += '<span class="video_info">(' + videoList[next].video.title + ")</span>"
      nextSongHtml += '</div>'
      $("#next_song").html(nextSongHtml)
    else
      $("#next_song").html("")
    highlight()
    history.replaceState(null, "CDLM " + country + ":" + index, "/track/" + country + "/" + index)

  next = ->
    return if index <= 1
    --index
    play 'next'

  prev = ->
    return if index >= rankMax
    ++index
    play 'prev'

  getList = (loadCountry, initIndex) ->
    country = loadCountry
    index = initIndex if initIndex
    $.getJSON("/track/" + country + ".json", {}, (rs) ->
      html = ""
      isIndexSet = false
      $.each(rs.reverse(), ->
        videoList[this.rank] = this
        html += '<div id="trac_"' + this.rank  + '" class="track">'
        html += '<span class="rank">' + this.rank + "&nbsp</span>"
        html += '<span class="info">' + this.info.artist.name + " / " + this.info.name + "</span><br />"
        if this.video
          html += '<span class="video_info">(' + this.video.title + ")</span>"
          html += '<input type="button" id="button_trac_' + this.rank + '" value="play" class="play_button" />'
          # 最初に再生可能なインデックス
          if !isIndexSet and !initIndex
            index = this.rank
            isIndexSet = true
        html += '</div>'
      )
      $("#list").html(html)
      highlight()

      $(".play_button").click( ->
        id = $(this).attr('id')
        id = id.replace(/button_trac_/, "")
        play('next', id)
      )

      # https://developers.google.com/youtube/iframe_api_reference
      tag = document.createElement('script')
      tag.src = "//www.youtube.com/iframe_api"
      firstScriptTag = document.getElementsByTagName('script')[0]
      firstScriptTag.parentNode.insertBefore(tag, firstScriptTag)
      window.onYouTubeIframeAPIReady = ->
        player = new YT.Player('video',
          height: '425',
          width: '760',
          videoId: videoList[index].video.id,
          events:
            'onStateChange': (e) ->
              state = e.data
              next() if state is YT.PlayerState.ENDED
            'onError': () ->
              next()
        )
      play('next')
      init = false
    )

  $("#prev").click ->
    prev()
  $("#next").click ->
    next()
  $("#show").click ->
    window.show()
  $("#content").tabs()
  getList(
    $("meta[name=country]").attr("content"),
    $("meta[name=rank]").attr("content")
  )
)
