import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: RoomImageUploadPage(),
    );
  }
}

class RoomImageUploadPage extends StatefulWidget {
  RoomImageUploadPage({
    Key? key,
  }) : super(key: key);

  @override
  _RoomImageUploadPageState createState() => _RoomImageUploadPageState();
}

class _RoomImageUploadPageState extends State<RoomImageUploadPage> {
  XFile? pickedFile = null;
  final picker = ImagePicker();
  Future getImage() async {
    final images = await picker.pickImage(
      maxWidth: 720,
      maxHeight: 576,
      imageQuality: 80,
      source: ImageSource.gallery,
    );
    if (images == null) {
      return;
    } else {
      pickedFile = images;
      setState(() {});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final node = FocusScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Room Images'),
      ),
      body: Container(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Form(
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Upload wide images for better view [ 16:9 ]"),
                SizedBox(height: 10),
                InkWell(
                  onTap: () {
                    getImage();
                  },
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    height: 40,
                    width: 125,
                    child: Center(
                      child: Row(
                        children: [
                          Icon(
                            Icons.photo_library,
                          ),
                          Text(
                            'Select Images',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                if (pickedFile != null) Image.file(File(pickedFile!.path)),
                SizedBox(height: 40),
                InkWell(
                  onTap: () async {
                    if (pickedFile == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please select an image'),
                        ),
                      );
                    } else {
                      try {
                        MultipartFile? img;

                        if (pickedFile != null) {
                          img = await MultipartFile.fromFile(
                            pickedFile!.path,
                            filename: pickedFile!.path.split('/').last,
                          );
                        }

                        final formData = FormData.fromMap({"image": img});
                        print(formData);

                        final resp = await Dio().post(
                          "http://127.0.0.1:8000/api/",
                          data: formData,
                          options: Options(
                            contentType: 'multipart/form-data',
                          ),
                        );

                        if (resp.statusCode == 200 || resp.statusCode == 201) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(resp.data['label'].toString()),
                                  content: Text("Accuracy " +
                                      (double.parse(resp.data['accuracy']
                                                  .toString()) *
                                              100)
                                          .toStringAsFixed(2) +
                                      "%"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text("Ok"),
                                    ),
                                  ],
                                );
                              });
                        }
                      } on DioError catch (e) {
                        final response = e.response;
                        if (response == null) print(e.toString());
                      } catch (e) {
                        print("suii");
                      }
                    }
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => RoomImageUploadPage(),
                    //   ),
                    //
                  },
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.blue,
                    ),
                    height: 40,
                    width: 125,
                    child: Center(
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
