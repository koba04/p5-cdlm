(function() {

  jQuery(function($) {
    "use strict";
    var country, getList, highlight, index, init, next, play, player, prev, rankMax, videoList;
    videoList = [];
    rankMax = 50;
    index = rankMax;
    country = '';
    player = '';
    init = true;
    highlight = function() {
      $("#list").children().css("color", "black");
      return $("#trac_" + videoList[index].rank).css("color", "red");
    };
    play = function(mode, playIndex) {
      var currentHtml, next, nextSongHtml;
      if (playIndex) {
        index = playIndex;
      }
      while (!videoList[index] || !videoList[index].video) {
        if (mode === 'prev') {
          if (index >= rankMax) {
            return;
          }
          ++index;
        } else {
          if (index <= 1) {
            return;
          }
          --index;
        }
      }
      if (!init) {
        player.loadVideoById(videoList[index].video.id);
      }
      currentHtml = '<div class="track">';
      currentHtml += '<span class="rank">' + videoList[index].rank + "&nbsp</span>";
      currentHtml += '<span class="info">' + videoList[index].info.artist.name + " / " + videoList[index].info.name + "</span><br />";
      if (videoList[index].video) {
        currentHtml += '<span class="video_info">(' + videoList[index].video.title + ")</span>";
        $('title').text(videoList[index].video.title);
      }
      currentHtml += '</div>';
      $("#current").html(currentHtml);
      if (videoList[index].rank > 1) {
        next = index - 1;
        nextSongHtml = '';
        if (videoList[next].video) {
          nextSongHtml = '<div id="next_img"><img src="' + videoList[next].video.thumbnail.sqDefault + '" width="120" height="90" /></div>';
        }
        nextSongHtml += '<div class="next_track">';
        nextSongHtml += '<span class="rank">' + videoList[next].rank + '&nbsp</span>';
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
      return history.replaceState(null, "CDLM " + country + ":" + index, "/track/" + country + "/" + index);
    };
    next = function() {
      if (index <= 1) {
        return;
      }
      --index;
      return play('next');
    };
    prev = function() {
      if (index >= rankMax) {
        return;
      }
      ++index;
      return play('prev');
    };
    getList = function(loadCountry, initIndex) {
      country = loadCountry;
      if (initIndex) {
        index = initIndex;
      }
      return $.getJSON("/track/" + country + ".json", {}, function(rs) {
        var firstScriptTag, html, isIndexSet, tag;
        html = "";
        isIndexSet = false;
        $.each(rs.reverse(), function() {
          videoList[this.rank] = this;
          html += '<div id="trac_"' + this.rank + '" class="track">';
          html += '<span class="rank">' + this.rank + "&nbsp</span>";
          html += '<span class="info">' + this.info.artist.name + " / " + this.info.name + "</span><br />";
          if (this.video) {
            html += '<span class="video_info">(' + this.video.title + ")</span>";
            html += '<input type="button" id="button_trac_' + this.rank + '" value="play" class="play_button" />';
            if (!isIndexSet && !initIndex) {
              index = this.rank;
              isIndexSet = true;
            }
          }
          return html += '</div>';
        });
        $("#list").html(html);
        highlight();
        $(".play_button").click(function() {
          var id;
          id = $(this).attr('id');
          id = id.replace(/button_trac_/, "");
          return play('next', id);
        });
        tag = document.createElement('script');
        tag.src = "//www.youtube.com/iframe_api";
        firstScriptTag = document.getElementsByTagName('script')[0];
        firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
        window.onYouTubeIframeAPIReady = function() {
          return player = new YT.Player('video', {
            height: '425',
            width: '760',
            videoId: videoList[index].video.id,
            events: {
              'onStateChange': function(e) {
                var state;
                state = e.data;
                if (state === YT.PlayerState.ENDED) {
                  return next();
                }
              },
              'onError': function() {
                return next();
              }
            }
          });
        };
        play('next');
        return init = false;
      });
    };
    $("#prev").click(function() {
      return prev();
    });
    $("#next").click(function() {
      return next();
    });
    $("#show").click(function() {
      return window.show();
    });
    $("#content").tabs();
    return getList($("meta[name=country]").attr("content"), $("meta[name=rank]").attr("content"));
  });

}).call(this);
