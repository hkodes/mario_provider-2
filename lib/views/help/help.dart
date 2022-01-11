import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mario_provider/common/base.dart';
import 'package:mario_provider/repositories/help/help.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HelpPageState();
  }
}

class HelpPageState extends State<HelpPage> {
  Map<String, dynamic> _help = {};
  final HelpRepo _repo = new HelpRepo();
  bool isLoading = true;
  @override
  void initState() {
    getHelp();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Help"),
        ),
        body: isLoading ? CircularProgressIndicator() : HelpUi(_help));
  }

  void getHelp() async {
    _help = await _repo.getHelp();

    setState(() {
      isLoading = false;
    });
  }
}

class HelpUi extends StatelessWidget {
  final Map<String, dynamic> _allHelp = {};

  HelpUi(_allHelp);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              children: [
                _allHelp['contact_number'] != null
                    ? StripContainer(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.email,
                                    size: 12,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    "Contact Number",
                                    style: TextStyle(
                                      fontFamily: 'Segoe',
                                      fontSize: 14,
                                      color: const Color(0xff000000),
                                      fontWeight: FontWeight.w700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                  ),
                                  TextButton(
                                      onPressed: () => launch("tel://" +
                                          _allHelp['contact_number']),
                                      child: Text(
                                          _allHelp['contact_number'] ?? "")),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(),
                _allHelp['contact_email'] != null
                    ? StripContainer(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.email,
                                    size: 12,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    "Email",
                                    style: TextStyle(
                                      fontFamily: 'Segoe',
                                      fontSize: 14,
                                      color: const Color(0xff000000),
                                      fontWeight: FontWeight.w700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                  ),
                                  TextButton(
                                    onPressed: () => launch(
                                        'mailto:${_allHelp['contact_email']}?subject=This is Subject Title&body=This is Body of Email'),
                                    child:
                                        Text(_allHelp['contact_email'] ?? ""),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(),
                SizedBox(
                  height: 6,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
