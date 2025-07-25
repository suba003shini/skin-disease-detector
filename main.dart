import 'dart:typed_data';
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(SkinDiseaseApp());
}

class SkinDiseaseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skin Disease Detector',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: SkinHomePage(),
    );
  }
}

class SkinHomePage extends StatefulWidget {
  @override
  _SkinHomePageState createState() => _SkinHomePageState();
}

class _SkinHomePageState extends State<SkinHomePage> {
  io.File? _image;
  Uint8List? _webImageBytes;
  String _result = '';
  String _advice = '';
  final picker = ImagePicker();

  // 🛑 Replace with your actual Flask server IP or domain:
  final String backendUrl = 'http://127.0.0.1:5000/predict';

  Map<String, String> diseaseAdvice = {
    'pimple': 'Pimples usually heal in 3-4 days. Wash your face twice daily and avoid oily food.',
    'scar': 'This looks like a scar. Use vitamin E oil. If it grows or hurts, consult a doctor.',
    'allergy': 'You may have an allergy. Avoid allergens and consider using an antihistamine.',
    'moluscum': 'Moluscum may need medical treatment. It is usually harmless but contagious.',
    'vitiligo': 'Vitiligo needs a dermatologist consultation. Use sunscreen regularly.',
    'wart': 'Warts may go away on their own, but a dermatologist can help remove them safely.',
  };

  Future pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _result = '';
        _advice = '';
      });

      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
        });
        await uploadImageWeb(bytes);
      } else {
        setState(() {
          _image = io.File(pickedFile.path);
        });
        await uploadImage(_image!);
      }
    }
  }

  Future uploadImage(io.File image) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(backendUrl));
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
      var response = await request.send();

      if (response.statusCode == 200) {
        final responseString = await response.stream.bytesToString();
        final decoded = responseString;
        setState(() {
          _result = decoded;
          _advice = diseaseAdvice[_result.toLowerCase()] ?? "No advice available.";
        });
      } else {
        setState(() {
          _result = 'Failed to get prediction';
          _advice = '';
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
        _advice = '';
      });
    }
  }

  Future uploadImageWeb(Uint8List imageBytes) async {
    try {
      var uri = Uri.parse(backendUrl);
      var request = http.MultipartRequest('POST', uri);
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: 'upload.png',
      ));

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseString = await response.stream.bytesToString();
        final decoded = responseString;
        setState(() {
          _result = decoded;
          _advice = diseaseAdvice[_result.toLowerCase()] ?? "No advice available.";
        });
      } else {
        setState(() {
          _result = 'Failed to get prediction';
          _advice = '';
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
        _advice = '';
      });
    }
  }

  Widget imageSection() {
    if (kIsWeb && _webImageBytes != null) {
      return Image.memory(_webImageBytes!, height: 200);
    } else if (!kIsWeb && _image != null) {
      return Image.file(_image!, height: 200);
    } else {
      return Text('No image selected', style: TextStyle(fontSize: 16));
    }
  }

  Widget resultSection() {
    return Column(
      children: [
        Text("Prediction: $_result", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Text("Advice: $_advice", style: TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget buttonSection() {
    return Column(
      children: [
        ElevatedButton.icon(
          icon: Icon(Icons.camera_alt),
          label: Text("Take a Photo"),
          onPressed: () => pickImage(ImageSource.camera),
        ),
        ElevatedButton.icon(
          icon: Icon(Icons.image),
          label: Text("Select from Gallery"),
          onPressed: () => pickImage(ImageSource.gallery),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Skin Disease Detector")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            imageSection(),
            SizedBox(height: 20),
            buttonSection(),
            SizedBox(height: 30),
            resultSection(),
          ],
        ),
      ),
    );
  }
}
