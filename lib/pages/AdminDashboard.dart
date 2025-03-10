import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';
import 'package:medicare/utils/dimensions.dart';
import 'package:medicare/utils/loading.dart';
import 'package:medicare/utils/url.dart';
import 'package:toastification/toastification.dart';

class Admindashboard extends StatefulWidget {
  const Admindashboard({super.key});

  @override
  _AdmindashboardState createState() => _AdmindashboardState();
}

class _AdmindashboardState extends State<Admindashboard> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController specializationController = TextEditingController();
  TextEditingController ratingController = TextEditingController();
  TextEditingController aboutController = TextEditingController();
  TextEditingController patientsController = TextEditingController();
  TextEditingController experienceController = TextEditingController();
  TextEditingController feeController = TextEditingController();
  TextEditingController daysController = TextEditingController();
  TextEditingController timeController = TextEditingController();

  bool isLoading = false;
  Uint8List? image;
  File? imageFile;
  String showImage = "";

  Future<void> addDoctors() async {
    setState(() {
      isLoading = true;
    });

    Map data = {
      "name": nameController.text,
      "specialization": specializationController.text,
      "rating": ratingController.text,
      "about": aboutController.text,
      "patients": patientsController.text,
      "experience": experienceController.text,
      "fee": feeController.text,
      "days": daysController.text,
      "time": timeController.text,
    };

    try {
      var response = await http.post(
        Uri.parse("${mainurl}add_doctors.php"),
        body: data,
      );

      var jsonData = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonData['status'] == true) {
        String doctorId = jsonData['doctorid'].toString(); // Get doctor ID

        if (context.mounted) {
          await saveImageToDatabase(doctorId); // Upload image

          // Clear text fields and image after successful submission
          nameController.clear();
          specializationController.clear();
          ratingController.clear();
          aboutController.clear();
          patientsController.clear();
          experienceController.clear();
          feeController.clear();
          daysController.clear();
          timeController.clear();
          setState(() {
            imageFile = null;
            image = null;
            showImage = "";
          });

          toastification.show(
            context: context,
            title: const Text('Doctor added successfully'),
            autoCloseDuration: const Duration(seconds: 4),
            style: ToastificationStyle.flatColored,
            applyBlurEffect: true,
            type: ToastificationType.success,
            icon: const Icon(Ionicons.checkmark_circle, color: Colors.green),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(jsonData['message'] ?? 'Failed to add doctor'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> saveImageToDatabase(String doctorId) async {
    if (imageFile == null) {
      toastification.show(
        context: context,
        title: const Text("No image selected."),
        autoCloseDuration: const Duration(seconds: 2),
        style: ToastificationStyle.flatColored,
        applyBlurEffect: true,
        icon: const Icon(
          Ionicons.close_circle,
          color: Colors.red,
        ),
        type: ToastificationType.error,
        pauseOnHover: true,
      );
      return;
    }

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const LoadingDialog();
        });

    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("${mainurl}add_doctors_image.php"),
      );
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageFile!.readAsBytesSync(),
          filename: imageFile!.path.split("/").last,
        ),
      );
      request.fields['doctorid'] =
          doctorId; // Use doctor ID instead of admin ID

      var response = await request.send();
      var responded = await http.Response.fromStream(response);
      var jsondata = jsonDecode(responded.body);

      Navigator.pop(context);
      toastification.show(
        context: context,
        title: Text(jsondata['msg']),
        autoCloseDuration: const Duration(seconds: 2),
        style: ToastificationStyle.flatColored,
        applyBlurEffect: true,
        icon: const Icon(
          Ionicons.checkmark_circle,
          color: Colors.green,
        ),
        type: ToastificationType.success,
        pauseOnHover: true,
      );
    } catch (e) {
      Navigator.pop(context);
      toastification.show(
        context: context,
        title: Text(e.toString()),
        autoCloseDuration: const Duration(seconds: 3),
        style: ToastificationStyle.flatColored,
        applyBlurEffect: true,
        icon: const Icon(
          Ionicons.close_circle,
          color: Colors.red,
        ),
        type: ToastificationType.error,
        pauseOnHover: true,
      );
    }
  }

  void selectImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        Uint8List bytes =
            await pickedFile.readAsBytes(); // Convert to Uint8List
        setState(() {
          imageFile = File(pickedFile.path);
          image = bytes; // Update image variable for display
        });
      }
    } catch (e) {
      toastification.show(
        context: context,
        title: Text('Error: $e'),
        autoCloseDuration: const Duration(seconds: 3),
        style: ToastificationStyle.flatColored,
        icon: const Icon(Ionicons.close_circle, color: Colors.red),
        type: ToastificationType.error,
        pauseOnHover: true,
      );
    }
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? "Please enter $label" : null,
      ),
    );
  }

  Widget buildImagePicker() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            selectImage();
          },
          child: CircleAvatar(
            radius: Dimensions.width80,
            backgroundImage: image != null
                ? MemoryImage(image!)
                : showImage.isNotEmpty
                    ? NetworkImage(showImage)
                    : const AssetImage('assets/images/profile.png')
                        as ImageProvider,
          ),
        ),
        SizedBox(height: Dimensions.height10),
        TextButton(
          onPressed: () {
            selectImage();
          },
          child: Text('Select Image'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Add Doctor"), backgroundColor: Colors.blueAccent),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(nameController, "Doctor's Name", Icons.person),
              _buildTextField(specializationController, "Specialization",
                  Icons.local_hospital),
              _buildTextField(ratingController, "Rating (1-5)", Icons.star,
                  isNumber: true),
              _buildTextField(aboutController, "About", Icons.info),
              _buildTextField(
                  patientsController, "No. of Patients", Icons.people),
              _buildTextField(
                  experienceController, "Experience (Years)", Icons.work),
              _buildTextField(
                  feeController, "Consultation Fee", Icons.attach_money,
                  isNumber: true),
              _buildTextField(
                  daysController, "Available Days", Icons.calendar_today),
              _buildTextField(
                  timeController, "Available Time", Icons.access_time),
              const SizedBox(height: 10),
              buildImagePicker(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    addDoctors().then((_) {
                      FocusScope.of(context).unfocus();
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(Dimensions.width200, Dimensions.height40),
                  backgroundColor: Colors.blueAccent[400],
                ),
                child: Text(
                  'Submit',
                  style: TextStyle(
                      fontSize: Dimensions.font18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
