import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mario_provider/common/base.dart';
import 'package:mario_provider/common/dialog.dart';
import 'package:mario_provider/repositories/users/user_repo.dart';
import 'package:mario_provider/utils/snack_util.dart';

class Documents extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DocumentState();
  }
}

class DocumentState extends State<Documents> {
  final UserRepo _userRepo = new UserRepo();
  Map<String, dynamic> _documents = {};
  bool loading = true;
  MultipartFile multipartFile;
  File file;
  @override
  void initState() {
    getDocs();
    // userDetailBloc.add(BLoadData());
    super.initState();
  }

  getDocs() async {
    _documents = await _userRepo.getDocument();
    print(_documents);

    setState(() {
      loading = false;
    });
  }

  @override
  void dispose() {
    // userDetailBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Documents"),
      ),
      body:
          // BlocBuilder(
          // builder: (context, state) {
          // if (state is BLoadedState || state is UserDetailUpdatedState) {
          loading
              ? Center(child: CircularProgressIndicator())
              : Container(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _documents['documents'].length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () => _showImagePicker(context),
                        child: Container(
                          width: double.infinity,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              file == null || multipartFile == null
                                  ? CachedNetworkImage(
                                      imageUrl: _documents['documents'][index]
                                          ['url'],

                                      // userDetailModel.picture ?? "",
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          Icon(
                                        Icons.person,
                                        size: 75,
                                      ),
                                      width: 75,
                                      height: 75,
                                    )
                                  : Image.file(file),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                _documents['documents'][index]['name'],
                                style: TextStyle(
                                  fontFamily: 'Metropolis',
                                  fontSize: 14,
                                  color: const Color(0xff4a4b4d),
                                  fontWeight: FontWeight.w700,
                                  height: 1.4285714285714286,
                                ),
                                textHeightBehavior: TextHeightBehavior(
                                    applyHeightToFirstAscent: false),
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                _documents['documents'][index]['type'],
                                style: TextStyle(
                                  fontFamily: 'Metropolis',
                                  fontSize: 14,
                                  color: const Color(0xff4a4b4d),
                                  fontWeight: FontWeight.w700,
                                  height: 1.4285714285714286,
                                ),
                                textHeightBehavior: TextHeightBehavior(
                                    applyHeightToFirstAscent: false),
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Divider(
                                thickness: 2,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      // } else
      // return Container();
      // },
      // bloc: BlocProvider.of<UserDetailBloc>(context),
    );
  }

  void _showImagePicker(BuildContext context) async {
    DialogUtils.showImageSourceDialog(
      context,
      (path) {
        if (path != null) {
          uploadDocument(path, context);
          print(path);
          _setImage(path);
        }
        // profilePageBloc.add(
        //   UploadImage(path: path),
        // );
      },
    );
  }

  Future<void> _setImage(String path) async {
    multipartFile = await MultipartFile.fromFile(path);
    file = File(path);
  }

  void uploadDocument(String path, BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context2) {
          return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                  child: Center(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                    CircularProgressIndicator(),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      'Uploading',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ]))));
        });
    Map<String, dynamic> _response = await _userRepo.uploadDocument(path);
    Navigator.pop(context);
    if (_response['success']) {
      showSnackSuccess(context, _response['message']);
      setState(() {
        loading = true;
      });
      getDocs();
    } else {
      showSnackError(context, _response['message']);
    }
  }
}

class DocumentIcon extends StatelessWidget {
  final String imageUrl;
  final String type;
  final String text;
  final Function() onTap;

  const DocumentIcon({
    Key key,
    this.imageUrl,
    this.text,
    this.onTap,
    this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                placeholder: (context, url) =>
                    Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            SizedBox(
              height: 12,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'Metropolis',
                  fontSize: 14,
                  color: const Color(0xff4a4b4d),
                  fontWeight: FontWeight.w700,
                  height: 1.4285714285714286,
                ),
                textHeightBehavior:
                    TextHeightBehavior(applyHeightToFirstAscent: false),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(
              height: 6,
            ),
            Text(
              type,
              style: TextStyle(
                fontFamily: 'Metropolis',
                fontSize: 10,
                color: const Color(0xffb6b7b7),
                height: 1.7,
              ),
              textHeightBehavior:
                  TextHeightBehavior(applyHeightToFirstAscent: false),
              textAlign: TextAlign.left,
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
