import 'package:flutter/material.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends List'),
      ),
      body: ListView(
        children: const <Widget>[
          ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('Friend 1'),
          ),
          ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('Friend 2'),
          ),
          ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('Friend 3'),
          ),
        ],
      ),
    );
  }
}
