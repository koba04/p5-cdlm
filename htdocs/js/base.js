var video_list = [];
var rank_max = 50;
var index = rank_max;
var country;
var player;
var init = true;
function get_list(load_country, init_index) {
    country = load_country;
    if (init_index) {
        index = init_index;
    }
    $.getJSON("/track/" + country + ".json", {}, function(rs) {
          var html = "";
          var is_index_set = false;
          $.each(rs.reverse(), function(i, v){
              video_list[this.rank] = this;
              html += '<div id="trac_"' + this.rank  + '" class="track">';
              html += '<span class="rank">' + this.rank + "&nbsp;</span>";
              html += '<span class="info">' + this.info.artist.name + " / " + this.info.name + "</span><br />";
              if ( this.video ) {
                  html += '<span class="video_info">(' + this.video.title + ")</span>";
                  html += '<input type="button" id="button_trac_' + this.rank + '" value="play" class="play_button" />';
                  // 最初に再生可能なインデックス
                  if ( !is_index_set && !init_index) {
                      index = this.rank;
                      is_index_set = true;
                  }
              }
              html += '</div>';
          });
          $("#list").html(html);
          highlight();

          $(".play_button").click(function() {
              var id = $(this).attr('id');
              id = id.replace(/button_trac_/,"")
              play('next', id);
          });

        // https://developers.google.com/youtube/iframe_api_reference
        var tag = document.createElement('script');
        tag.src = "//www.youtube.com/iframe_api";
        var firstScriptTag = document.getElementsByTagName('script')[0];
        firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
        window.onYouTubeIframeAPIReady = function() {
            player = new YT.Player('video', {
                height: 480 * 0.7,
                width: 854 * 0.7,
                videoId: video_list[index].video.id,
                events: {
                    'onStateChange': function(e) {
                        var state = e.data;
                        if (state == YT.PlayerState.ENDED) {
                            next();
                        }
                    },
                    'onError': function(e) {
                        next();
                    }
                }
            });
        }
        play('next');
        init = false;
    });
}

function next() {
    if ( index <= 1 ) {
        return;
    }
    --index;
    play('next');
}
function prev() {
    if ( index >= rank_max ) {
        return;
    }
    ++index;
    play('prev');
}

function play(mode, play_index) {
    if ( play_index ) {
        index = play_index;
    }

    // 動画なかったらさらに次へ
    while ( !video_list[index] || !video_list[index].video ) {
        if ( mode == 'prev' ) {
            // これ以上戻れない
            if ( index >= rank_max ) {
                return;
            }
            ++index;
        } else {
            // これ以上先はない
            if ( index <= 1 ) {
                return;
            }
            --index;
        }
    }

    if ( !init ) {
        player.loadVideoById(video_list[index].video.id);
    }

    var current_html = '<div class="track">';
    current_html += '<span class="rank">' + video_list[index].rank + "&nbsp;</span>";
    current_html += '<span class="info">' + video_list[index].info.artist.name + " / " + video_list[index].info.name + "</span><br />";
    if ( video_list[index].video ) {
        current_html += '<span class="video_info">(' +  video_list[index].video.title + ")</span>";
    }
    current_html += '</div>';
    $("#current").html(current_html);
    if ( video_list[index].rank > 1 ) {
        var next = index - 1;
        if ( video_list[next].video ) {
            next_song_html = '<div id="next_img"><img src="' + video_list[next].video.thumbnail.sqDefault + '" width="120" height="90" /></div>';
        }
        next_song_html += '<div class="next_track">';
        next_song_html += '<span class="rank">'  + video_list[next].rank + '&nbsp;</span>';
        next_song_html += '<span class="info">' + video_list[next].info.artist.name + " / " + video_list[next].info.name + "</span><br />";
        if ( video_list[next].video ) {
            next_song_html += '<span class="video_info">(' + video_list[next].video.title + ")</span>";
        }
        next_song_html += '</div>';
        $("#next_song").html(next_song_html);
    } else {
        $("#next_song").html("");
    }
    highlight();
    history.replaceState(null, "CDLM " + country + ":" + index, "/track/" + country + "/" + index);
}
function highlight() {
    $("#list").children().css("color", "black");
    $("#trac_" + video_list[index].rank).css("color", "red");
}
