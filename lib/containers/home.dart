import 'package:flutter/material.dart';
import 'package:linka/containers/cards.dart';
import 'package:linka/containers/settings.dart';


class _Page {
  _Page({ this.label, this.name });
  final String label;
  final String name;
  String get id => label[0];
  @override
  String toString() => '$runtimeType("$label")';
}

final Map<_Page, String> _allPages = <_Page, String>{
  _Page(label: 'Cards'): "items",
  _Page(label: 'Photos'): "photos",
};

class TabsDemo extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _allPages.length,
      child: Scaffold(     
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                child: SliverAppBar(
                  title: const Text('Linka'),
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(Icons.settings),
                      tooltip: 'Settings',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SettingsScreen()),
                        );
                      },
                    ),
                  ],
                  pinned: true,
                  // expandedHeight: 150.0,
                  forceElevated: innerBoxIsScrolled,
                  bottom: TabBar(
                    tabs: _allPages.keys.map<Widget>(
                      (_Page page) => Tab(text: page.label),
                    ).toList(),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: _allPages.keys.map<Widget>((_Page page) {
              return SafeArea(
                top: true,
                bottom: true,
                child: Builder(
                  builder: (BuildContext context) {
                    return Padding( 
                      padding:const EdgeInsets.only(top: 112.0),
                      child: ItemsListScreen(_allPages[page])                    
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}