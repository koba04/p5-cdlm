var video_list = [];
var rank_max = 50;
var index = rank_max;
var init = true;
function get_list(country) {
    $.getJSON("/cdlm/track/" + country + ".json", {},
        function(rs) {
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
                    if ( !is_index_set ) {
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

            swfobject.embedSWF("http://www.youtube.com/v/" + video_list[index].video.id + "?enablejsapi=1&playerapiid=player",
                              "video", 854 * 0.7, 480 * 0.7, "8", null, null, { allowScriptAccess: "always" }, { id: "player" });
            play('next');
            init = false;
       }
    );
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

function show() {
    $("#list").toggle();
}

function play(mode, play_index) {
    if ( play_index ) {
        index = play_index;
    }

    // 動画なかったらさらに次へ
    while ( index > 1 && (!video_list[index] || !video_list[index].video) ) {
        if ( mode == 'prev' ) {
            ++index;
        } else {
            --index;
        }
    }

    if (!init) {
        document.getElementById("player").loadVideoById(video_list[index].video.id);
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
}
function highlight() {
   $("#list").children().css("color", "black");
    $("#trac_" + video_list[index].rank).css("color", "red");
}
