import 'package:flutter/material.dart';
import 'package:linka/domain/models/linka_item.dart';


enum TtsState { playing, stopped }

class LinkaCard extends StatefulWidget {
  final LinkaItem item;

  LinkaCard(this.item);

  @override
  State<StatefulWidget> createState() => _LinkaCardState();
}

class _LinkaCardState extends State<LinkaCard>
{
  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;

  @override
  Widget build(BuildContext context) =>
   Container(
     alignment: Alignment.bottomCenter,      
      decoration: BoxDecoration(
        image: new DecorationImage(
          image: Image.network(widget.item.downloadUrl).image,
          fit: BoxFit.cover,
        ),
      ),
      child: new Text(widget.item.title ??"default Title",
        style: new TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20.0,
        )
      ),
    );

}