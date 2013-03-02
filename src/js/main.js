(function () {
  "use strict";
  var videoList = [];
  var rankMax = 50;
  var index = rankMax;
  var country;
  var player;
  var init = true;

  var highlight = function () {
    $("#list").children().css("color", "black");
    $("#trac_" + videoList[index].rank).css("color", "red");
  };

  var play = function (mode, playIndex) {
    if (playIndex) {
      index = playIndex;
    }

    // 動画なかったらさらに次へ
    while (!videoList[index] || !videoList[index].video) {
      if (mode === 'prev') {
        // これ以上戻れない
        if (index >= rankMax) {
          return;
        }
        ++index;
      } else {
        // これ以上先はない
        if (index <= 1) {
          return;
        }
        --index;
      }
    }

    if (!init) {
      player.loadVideoById(videoList[index].video.id);
    }

    var currentHtml = '<div class="track">';
    currentHtml += '<span class="rank">' + videoList[index].rank + "&nbsp;</span>";
    currentHtml += '<span class="info">' + videoList[index].info.artist.name + " / " + videoList[index].info.name + "</span><br />";
    if (videoList[index].video) {
      currentHtml += '<span class="video_info">(' +  videoList[index].video.title + ")</span>";
      $('title').text(videoList[index].video.title);
    }
    currentHtml += '</div>';
    $("#current").html(currentHtml);
    if (videoList[index].rank > 1) {
      var next = index - 1;
      var nextSongHtml = '';
      if (videoList[next].video) {
        nextSongHtml = '<div id="next_img"><img src="' + videoList[next].video.thumbnail.sqDefault + '" width="120" height="90" /></div>';
      }
      nextSongHtml += '<div class="next_track">';
      nextSongHtml += '<span class="rank">'  + videoList[next].rank + '&nbsp;</span>';
      nextSongHtml += '<span class="info">' + videoList[next].info.artist.name + " / " + videoList[next].info.name + "</span><br />";
      if (videoList[next].video) {
        nextSongHtml += '<span class="video_info">(' + videoList[next].video.title + ")</span>";
      }
      nextSongHtml += '</div>';
      $("#next_song").html(nextSongHtml);
    } else {
      $("#next_song").html("");
    }
    highlight();
    history.replaceState(null, "CDLM " + country + ":" + index, "/track/" + country + "/" + index);
  };

  var next = function () {
    if (index <= 1) {
      return;
    }
    --index;
    play('next');
  };

  var prev = function () {
    if (index >= rankMax) {
      return;
    }
    ++index;
    play('prev');
  };

  var getList = function (loadCountry, initIndex) {
    country = loadCountry;
    if (initIndex) {
      index = initIndex;
    }
    $.getJSON("/track/" + country + ".json", {}, function (rs) {
      var html = "";
      var isIndexSet = false;
      $.each(rs.reverse(), function () {
        videoList[this.rank] = this;
        html += '<div id="trac_"' + this.rank  + '" class="track">';
        html += '<span class="rank">' + this.rank + "&nbsp;</span>";
        html += '<span class="info">' + this.info.artist.name + " / " + this.info.name + "</span><br />";
        if (this.video) {
          html += '<span class="video_info">(' + this.video.title + ")</span>";
          html += '<input type="button" id="button_trac_' + this.rank + '" value="play" class="play_button" />';
          // 最初に再生可能なインデックス
          if (!isIndexSet && !initIndex) {
            index = this.rank;
            isIndexSet = true;
          }
        }
        html += '</div>';
      });
      $("#list").html(html);
      highlight();

      $(".play_button").click(function () {
        var id = $(this).attr('id');
        id = id.replace(/button_trac_/, "");
        play('next', id);
      });

      // https://developers.google.com/youtube/iframe_api_reference
      var tag = document.createElement('script');
      tag.src = "//www.youtube.com/iframe_api";
      var firstScriptTag = document.getElementsByTagName('script')[0];
      firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
      window.onYouTubeIframeAPIReady = function () {
        player = new YT.Player('video', {
          height: 450,
          width: 800,
          videoId: videoList[index].video.id,
          events: {
            'onStateChange': function (e) {
              var state = e.data;
              if (state === YT.PlayerState.ENDED) {
                next();
              }
            },
            'onError': function () {
              next();
            }
          }
        });
      };
      play('next');
      init = false;
    });
  };

  jQuery(function ($) {
    $("#prev").click(function () {
      prev();
    });
    $("#next").click(function () {
      next();
    });
    $("#show").click(function () {
      window.show();
    });
    $("#content").tabs();
    getList(
      $("meta[name=country]").attr("content"),
      $("meta[name=rank]").attr("content")
    );
  });

})();
