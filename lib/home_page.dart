// ignore_for_file: unnecessary_null_comparison, depend_on_referenced_packages, prefer_interpolation_to_compose_strings

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // * API implementation ->
  String url = "https://owlbot.info/api/v4/dictionary/";
  String token = "b8c8ac75dc5d6f48fbef2cc34275fafbca0178ab";

  // ** Text editing controller for storing whar user has searched ->
  final TextEditingController _textEditingController = TextEditingController();

  late StreamController _streamController;
  late Stream _stream;

  // ??? Timer for finishing showinf the indicator when search function is over ->
  late Timer _debounce;

  // *** search method for searching meaning ->

  _search() async {
    if (_textEditingController == null || _textEditingController.text.isEmpty) {
      _streamController.add(null);
      return;
    }

    // * show if we have to wait for meaning to be feached ->
    _streamController.add('waiting');

    // ? API calling ->
    Response response = await get(
      Uri.parse(url + _textEditingController.text.trim()),
      headers: {"Authorization": "Token $token"},
    );
    _streamController.add(json.decode(response.body));
  }

  //* init state function ->
  @override
  void initState() {
    super.initState();

    // ? initializing the objects ->
    _streamController = StreamController();
    _stream = _streamController.stream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(252, 0, 120, 212),
        title: const Text('Dictionary'),
        centerTitle: true,
        elevation: 25.0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Row(
            children: <Widget>[
              Expanded(
                // * this container is for yhe white background
                child: Container(
                  margin: const EdgeInsets.only(left: 12.0, bottom: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  child: TextFormField(
                    // ? on changed function for timer ->
                    onChanged: (String text) {
                      if (_debounce.isActive) _debounce.cancel();
                      _debounce = Timer(const Duration(milliseconds: 1000), () {
                        _search();
                      });
                    },

                    // ? controller ->
                    controller: _textEditingController,

                    //* box decoration ->
                    decoration: const InputDecoration(
                      hintText: 'Search a word..',
                      hintStyle: TextStyle(
                        color: Color.fromARGB(182, 218, 210, 210),
                      ),
                      contentPadding: EdgeInsets.only(left: 24.0),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),

              //* icon button for seraching
              IconButton(
                onPressed: () {
                  _search();
                },
                icon: const Icon(Icons.search),
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),

      // ? meaning part ->
      body: Container(
        margin: const EdgeInsets.all(8.0),
        child: StreamBuilder(
          stream: _stream,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return const Center(
                child: Text('Enter a word..'),
              );
            }

            // ?? to checj=k for waiting ->
            if (snapshot.data == 'waiting') {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return ListView.builder(
                itemCount: snapshot.data["definitions"].length,
                itemBuilder: (context, int index) {
                  return ListBody(
                    children: <Widget>[
                      Container(
                        color: const Color.fromARGB(214, 14, 13, 13),
                        child: ListTile(
                          // **** if word has a image the to diaplay ->
                          leading: snapshot.data["definitions"][index]
                                      ["image_url"] ==
                                  null
                              ? null
                              : CircleAvatar(
                                  backgroundImage: NetworkImage(snapshot
                                      .data["definitions"][index]["image_url"]),
                                ),

                          // ?? to check for POS ->
                          title: Text(_textEditingController.text.trim() +
                              "(" +
                              snapshot.data["definitions"][index]["type"] +
                              ")"),
                        ),
                      ),

                      // ? For meaning ->
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          snapshot.data["definitions"][index]["definition"],
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  );
                });
          },
        ),
      ),
    );
  }
}
