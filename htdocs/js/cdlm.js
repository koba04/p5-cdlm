(function() {

  jQuery(function($) {
    "use strict";
    var CDLM, cdlm;
    CDLM = (function() {

      CDLM.prototype.rankMax = 50;

      function CDLM(country, rank) {
        this.videoList = [];
        this.index = rank || this.rankMax;
        this.country = country;
        this.player = '';
        this.init = true;
      }

      CDLM.prototype.play = function(mode, playIndex) {
        var currentHtml, next, nextSongHtml;
        if (playIndex) {
          this.index = playIndex;
        }
        while (!this.videoList[this.index] || !this.videoList[this.index].video) {
          if (mode === 'prev') {
            if (this.index >= this.rankMax) {
              return;
            }
            ++this.index;
          } else {
            if (this.index <= 1) {
              return;
            }
            --this.index;
          }
        }
        if (!this.init) {
          this.player.loadVideoById(this.videoList[this.index].video.id);
        }
        currentHtml = "<div class=\"track\">\n<span class=\"rank\">" + this.videoList[this.index].rank + "&nbsp</span>\n<span class=\"info\">" + this.videoList[this.index].info.artist.name + "&nbsp/&nbsp" + this.videoList[this.index].info.name + "</span><br />";
        if (this.videoList[this.index].video) {
          currentHtml += "<span class=\"video_info\">(" + this.videoList[this.index].video.title + ")</span>";
          $('title').text(this.videoList[this.index].video.title);
        }
        currentHtml += '</div>';
        $("#current").html(currentHtml);
        if (this.videoList[this.index].rank > 1) {
          next = this.index - 1;
          nextSongHtml = '';
          if (this.videoList[next].video) {
            nextSongHtml += "<div id=\"next_img\"><img src=\"" + this.videoList[next].video.thumbnail.sqDefault + "\" width=\"120\" height=\"90\" /></div>\n<div class=\"next_track\">\n<span class=\"rank\">" + this.videoList[next].rank + "&nbsp</span>\n<span class=\"info\">" + this.videoList[next].info.artist.name + "&nbsp/&nbsp" + this.videoList[next].info.name + "</span><br />\n<span class=\"video_info\">(" + this.videoList[next].video.title + ")</span>\n</div>";
          }
          $("#next_song").html(nextSongHtml);
        } else {
          $("#next_song").html("");
        }
        this.highlight();
        return history.replaceState(null, "CDLM " + this.country + ":" + this.index, "/track/" + this.country + "/" + this.index);
      };

      CDLM.prototype.next = function() {
        if (this.index <= 1) {
          return;
        }
        --this.index;
        return this.play('next');
      };

      CDLM.prototype.prev = function() {
        if (this.index >= this.rankMax) {
          return;
        }
        ++this.index;
        return this.play('prev');
      };

      CDLM.prototype.highlight = function() {
        $("#list").children().css("color", "black");
        return $("#trac_" + this.videoList[this.index].rank).css("color", "red");
      };

      CDLM.prototype.getList = function() {
        var _this = this;
        return $.getJSON("/track/" + this.country + ".json", {}, function(rs) {
          var firstScriptTag, html, isIndexSet, tag, track, _i, _len, _ref;
          html = "";
          isIndexSet = false;
          _ref = rs.reverse();
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            track = _ref[_i];
            _this.videoList[track.rank] = track;
            html += "<div id=\"trac_" + track.rank + "\" class=\"track\">\n<span class=\"rank\">" + track.rank + "&nbsp</span>\n<span class=\"info\">" + track.info.artist.name + "&nbsp;/&nbsp;" + track.info.name + "</span><br />";
            if (track.video) {
              html += "<span class=\"video_info\">(" + track.video.title + ")</span>\n<input type=\"button\" id=\"button_trac_" + track.rank + "\" value=\"play\" class=\"play_button\" />";
              if (!isIndexSet && _this.index) {
                _this.index = track.rank;
                isIndexSet = true;
              }
            }
            html += '</div>';
          }
          $("#list").html(html);
          _this.highlight();
          $(".play_button").click(function(e) {
            var id;
            id = $(e.target).attr('id');
            id = id.replace(/button_trac_/, "");
            return _this.play('next', id);
          });
          tag = document.createElement('script');
          tag.src = "//www.youtube.com/iframe_api";
          firstScriptTag = document.getElementsByTagName('script')[0];
          firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
          window.onYouTubeIframeAPIReady = function() {
            return _this.player = new YT.Player('video', {
              height: '425',
              width: '760',
              videoId: _this.videoList[_this.index].video.id,
              events: {
                'onStateChange': function(e) {
                  var state;
                  state = e.data;
                  if (state === YT.PlayerState.ENDED) {
                    return _this.next();
                  }
                },
                'onError': function() {
                  return this.next();
                }
              }
            });
          };
          _this.play('next');
          return _this.init = false;
        });
      };

      return CDLM;

    })();
    cdlm = new CDLM($("meta[name=country]").attr("content"), $("meta[name=rank]").attr("content"));
    cdlm.getList();
    $("#prev").click(function() {
      return cdlm.prev();
    });
    $("#next").click(function() {
      return cdlm.next();
    });
    $("#show").click(function() {
      return window.show();
    });
    return $("#content").tabs();
  });

}).call(this);
