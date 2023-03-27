import 'package:audio/provider/songModelProvider.dart';
import 'package:audio/screens/NowPlaying.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({Key? key}) : super(key: key);

  @override
  _AudioPlayerScreenState createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();

  void playSong(String? uri) {
    try {
      _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(uri!)));
      _audioPlayer.play();
    } on Exception {
      print('Error Playing Song');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestStoragePermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Music Player 2022'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {},
          icon: Icon(Icons.keyboard_arrow_down_rounded),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_horiz),
          ),
        ],
      ),
      body: Container(
          padding: EdgeInsets.all(20),
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xff144771), Color(0xff071A2C)]),
          ),
          child: SafeArea(
            child: FutureBuilder<List<SongModel>>(
                future: _audioQuery.querySongs(
                    sortType: SongSortType.DATE_ADDED,
                    orderType: OrderType.DESC_OR_GREATER,
                    uriType: UriType.EXTERNAL,
                    ignoreCase: true),
                builder: (context, item) {
                  if (item.data == null) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (item.data!.isEmpty) {
                    return Center(child: Text("No Songs Found"));
                  }

                  List<SongModel> songs = item.data!;
                  return ListView.builder(
                      itemCount: songs.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Colors.white54,
                                    width: 1.0,
                                    style: BorderStyle.solid)),
                            child: ListTile(
                              leading: QueryArtworkWidget(
                                id: item.data![index].id,
                                type: ArtworkType.AUDIO,
                                nullArtworkWidget: Icon(Icons.music_note),
                              ),
                              title: Text(
                                songs.elementAt(index).displayName,
                                style: TextStyle(color: Colors.white54),
                              ),
                              trailing: Icon(Icons.more_horiz),
                              onTap: () {
                                context.read<SongModelProvider>().setId(item.data![index].id);
                                // playSong(item.data![index].uri);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NowPlaying(
                                        songModel: item.data![index],
                                        audioPlayer: _audioPlayer,
                                      ),
                                    ));
                              },
                            ),
                          ),
                        );
                      });
                }),
          )),
    );
  }

  void requestStoragePermission() async {
    if (!kIsWeb) {
      bool status = await _audioQuery.permissionsStatus();
      if (!status) {
        await _audioQuery.permissionsRequest();
      }
      setState(() {});
    }
  }
}
