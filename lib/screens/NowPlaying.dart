import 'package:audio/provider/songModelProvider.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

class NowPlaying extends StatefulWidget {
  const NowPlaying(
      {Key? key, required this.songModel, required this.audioPlayer})
      : super(key: key);
  final SongModel songModel;
  final AudioPlayer audioPlayer;

  @override
  _NowPlayingState createState() => _NowPlayingState();
}

class _NowPlayingState extends State<NowPlaying> {
  Duration _duration = Duration();
  Duration _position = Duration();
  bool _isplaying = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    playSong();
  }

  void playSong() {
    try {
      widget.audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(widget.songModel.uri!),
          //this is for audio ackground
          tag: MediaItem(
            id: '${widget.songModel.id}',
            // Metadata to display in the notification:
            album: '${widget.songModel.album}',
            title: '${widget.songModel.displayNameWOExt}',
            artUri: Uri.parse('https://example.com/albumart.jpg'),
          ),
        ),
      );
      widget.audioPlayer.play();
      _isplaying = true;
    } on Exception {
      print("Cannot Parse");
    }
    widget.audioPlayer.durationStream.listen((d) {
      setState(() {
        _duration = d!;
      });
    });
    widget.audioPlayer.positionStream.listen((p) {
      setState(() {
        _position = p;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back_ios)),
              SizedBox(
                height: 30,
              ),
              Center(
                child: Column(
                  children: [
                    Center(
                      child: const ArtWorkWidget(),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Center(
                      child: Text(
                        widget.songModel.displayNameWOExt,
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      widget.songModel.artist.toString() == "<unknown>"
                          ? "Unknown Artist"
                          : widget.songModel.artist.toString(),
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(_position.toString().split(".")[0]),
                        Expanded(
                            child: Slider(
                                min: Duration(microseconds: 0)
                                    .inSeconds
                                    .toDouble(),
                                value: _position.inSeconds.toDouble(),
                                max: _duration.inSeconds.toDouble(),
                                onChanged: (value) {
                                  changetoSeconds(value.toInt());
                                  value = value;
                                })),
                        Text(_duration.toString().split(".")[0]),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.skip_previous,
                              size: 40,
                            )),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                if (_isplaying) {
                                  widget.audioPlayer.pause();
                                } else {
                                  widget.audioPlayer.play();
                                }

                                _isplaying = !_isplaying;
                              });
                            },
                            icon: Icon(
                              _isplaying ? Icons.pause : Icons.play_arrow,
                              size: 40,
                              color: Colors.deepOrangeAccent,
                            )),
                        IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.skip_next,
                              size: 40,
                            )),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void changetoSeconds(int seconds) {
    Duration duration = Duration(seconds: seconds);
    widget.audioPlayer.seek(duration);
  }
}

class ArtWorkWidget extends StatelessWidget {
  const ArtWorkWidget({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    return QueryArtworkWidget(
      id: context.watch<SongModelProvider>().id,
      type: ArtworkType.AUDIO,
      artworkHeight: 200,
      artworkWidth: 200,
      artworkFit: BoxFit.cover ,
      nullArtworkWidget: Icon(
        Icons.music_note,
        size: 50,
      ),
    );
  }
}
