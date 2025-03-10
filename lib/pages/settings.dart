import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';
import 'package:medicare/pages/bottomnav.dart';
import 'package:medicare/pages/login_screen.dart';
import 'package:medicare/utils/colors.dart';
import 'package:medicare/utils/dimensions.dart';
import 'package:medicare/utils/loading.dart';
import 'package:medicare/utils/name.dart';
import 'package:medicare/utils/theme_change_provider.dart';
import 'package:medicare/utils/url.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:toastification/toastification.dart';

class Settings extends StatefulWidget {
  const Settings({
    super.key,
  });

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  bool svalue = false;
  Uint8List? image;
  File? imageFile;
  String showImage = "";
  late SharedPreferences sp;
  bool isEditing = false; // Flag to control editing state

  // Image selection method (Camera/Gallery)
  void selectImage(ImageSource source) async {
    try {
      PermissionStatus status;

      // Check for permissions based on the source (camera or gallery)
      if (source == ImageSource.camera) {
        status = await Permission.camera.request();
      } else {
        status = await Permission.storage.request();
      }

      // Handle permission responses
      if (status.isGranted) {
        final pickedFile = await ImagePicker().pickImage(source: source);
        if (pickedFile != null) {
          setState(() {
            imageFile = File(pickedFile.path);
          });
          await saveImageToDatabase();
          await getUserImage(email);
        }
      } else if (status.isDenied) {
        // Permission denied, show error
        toastification.show(
          context: context,
          title: const Text('Permission Denied'),
          autoCloseDuration: const Duration(seconds: 2),
          style: ToastificationStyle.flatColored,
          icon: const Icon(Ionicons.close_circle, color: Colors.red),
          type: ToastificationType.error,
          pauseOnHover: true,
        );
      } else if (status.isPermanentlyDenied) {
        // Permission permanently denied, ask the user to open app settings
        toastification.show(
          context: context,
          title: const Text(
              'Permission Permanently Denied. Go to Settings to Enable.'),
          autoCloseDuration: const Duration(seconds: 3),
          style: ToastificationStyle.flatColored,
          icon: const Icon(Ionicons.close_circle, color: Colors.red),
          type: ToastificationType.error,
          pauseOnHover: true,
        );
        await openAppSettings();
      }
    } catch (e) {
      // Handle any other errors
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

  Future<void> saveImageToDatabase() async {
    if (imageFile == null) {
      toastification.show(
        context: context, // optional if you use ToastificationWrapper
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
        Uri.parse("${mainurl}upload_image.php"),
      );
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageFile!.readAsBytesSync(),
          filename: imageFile!.path.split("/").last,
        ),
      );
      request.fields['id'] = id;

      var response = await request.send();
      var responded = await http.Response.fromStream(response);
      var jsondata = jsonDecode(responded.body);

      Navigator.pop(context);
      toastification.show(
        context: context, // optional if you use ToastificationWrapper
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
        context: context, // optional if you use ToastificationWrapper
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

  Future<void> getUserImage(String email) async {
    Map data = {'email': email};

    try {
      var response = await http.post(
        Uri.parse("${mainurl}get_user_image.php"),
        body: data,
      );
      var jsondata = jsonDecode(response.body);
      if (jsondata['status'] == true) {
        setState(() {
          showImage = jsondata['image'].toString();
        });
      } else {
        setState(() {
          showImage = "";
        });
        toastification.show(
          context: context, // optional if you use ToastificationWrapper
          title: Text(jsondata['msg']),

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
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteImage() async {
    Map data = {'id': id};

    try {
      var response = await http.post(
        Uri.parse("${mainurl}delete_image.php"),
        body: data,
      );
      var jsondata = jsonDecode(response.body);
      if (jsondata['status'] == true) {
        toastification.show(
          context: context, // optional if you use ToastificationWrapper
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

        setState(() {
          image = null;
          showImage = "";
        });
      } else {
        toastification.show(
          context: context, // optional if you use ToastificationWrapper
          title: Text(jsondata['msg']),

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
      }
    } catch (e) {
      print(e);
    }
  }

  void showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Help & Support'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Contact Support'),
                onTap: () {
                  Fluttertoast.showToast(
                      msg: "Support email: support@example.com");
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('FAQs'),
                onTap: () {
                  Fluttertoast.showToast(msg: "Opening FAQs...");
                },
              ),
              ListTile(
                leading: const Icon(Icons.article_outlined),
                title: const Text('User Guide'),
                onTap: () {
                  Fluttertoast.showToast(msg: "Opening User Guide...");
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteAccount() async {
    // API call to delete the account.
    final response = await http.post(
      Uri.parse("${mainurl}delete_account.php"),
      body: {'email': emailController.text},
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Account deleted successfully!");
      logOut(); // Logs out after deletion.
    } else {
      Fluttertoast.showToast(msg: "Failed to delete account. Try again.");
    }
  }

  void showConfirmationDialog(String action) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$action Confirmation'),
          content: Text(
            'Are you sure you want to $action your account? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                deleteAccount();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void showImageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose an option'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera,
                    color: Colors.blue, size: Dimensions.icon35),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  selectImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.image,
                    color: Colors.greenAccent, size: Dimensions.icon35),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  selectImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete,
                    color: Colors.redAccent, size: Dimensions.icon35),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.of(context).pop();
                  deleteImage();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String email = "";
  String username = "";
  String id = "";

  Future<void> getData() async {
    sp = await SharedPreferences.getInstance();
    setState(() {
      email = sp.getString('email') ?? '';
      emailController.text = email;
      username = sp.getString('username') ?? '';
      nameController.text = username;
      id = sp.getString('user_id') ?? '';
      svalue = sp.getBool('night') ?? false;
    });
  }

  @override
  void initState() {
    getData().whenComplete(() => getUserImage(email));

    super.initState();
  }

  void logOut() async {
    sp = await SharedPreferences.getInstance();
    sp.clear();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.logout,
              size: Dimensions.icon50,
              color: Colors.redAccent,
            ),
            SizedBox(height: Dimensions.height10),
            Text(
              'L O G O U T',
              style: TextStyle(
                fontSize: Dimensions.font24,
                fontWeight: FontWeight.bold,
                // color: Colors.black,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to logout?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: Dimensions.font16,
            // color: Colors.black54,
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actionsPadding: EdgeInsets.symmetric(vertical: Dimensions.height15),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              minimumSize: Size(Dimensions.width100, Dimensions.height40),
              elevation: 3,
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.black,
                fontSize: Dimensions.font14,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: logOut,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              minimumSize: Size(Dimensions.width100, Dimensions.height40),
              elevation: 3,
            ),
            child: Text(
              'Continue',
              style: TextStyle(
                color: Colors.black,
                fontSize: Dimensions.font14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> updateUserProfile(String name) async {
    Map data = {
      'username': name,
      'user_id': id,
    };
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const LoadingDialog();
        });
    try {
      var response = await http
          .post(Uri.parse("${mainurl}user_profile_update.php"), body: data);
      var jsondata = jsonDecode(response.body);
      if (jsondata['status']) {
        sp = await SharedPreferences.getInstance();
        setState(() {
          sp.setString("username", jsondata['data']['user_name']);
          username = jsondata['data']['user_name']; // Update local state
        });
        toastification.show(
          context: context, // optional if you use ToastificationWrapper
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

        Navigator.pop(context);
        setState(() {
          isEditing = false; // Disable editing after update
        });
      } else {
        Navigator.pop(context);
        toastification.show(
          context: context, // optional if you use ToastificationWrapper
          title: Text(jsondata['msg']),

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
      }
    } catch (e) {
      Navigator.pop(context);
      toastification.show(
        context: context, // optional if you use ToastificationWrapper
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

  void showAboutUs(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Colors.blueAccent,
              ),
              SizedBox(width: Dimensions.width8),
              Text(
                'About Us',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Medicare is a trusted healthcare app that helps you book appointments with top doctors, manage your medical records, and receive expert healthcare advice, all in one place.",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: Dimensions.font16,
                ),
              ),
              SizedBox(height: Dimensions.height10),
              Text(
                "Our Mission:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "To provide seamless and affordable healthcare services for everyone, anytime, everywhere.",
                style: TextStyle(
                  fontSize: Dimensions.font14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeChangeProvider changeTheme =
        Provider.of<ThemeChangeProvider>(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: PopScope(
        onPopInvoked: (didPop) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Nav()),
          );
        },
        canPop: false,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: settings,
            backgroundColor: pColor,
            actions: [
              Switch.adaptive(
                  inactiveTrackColor: wColor,
                  inactiveThumbColor: bColor,
                  thumbIcon: svalue
                      ? const WidgetStatePropertyAll(Icon(
                          Icons.mode_night,
                          color: Colors.white,
                        ))
                      : const WidgetStatePropertyAll(Icon(
                          Icons.sunny,
                          color: wColor,
                        )),
                  activeColor: Colors.amber,
                  value: svalue,
                  onChanged: (value) async {
                    sp = await SharedPreferences.getInstance();
                    setState(() {
                      svalue = value;
                      if (value) {
                        changeTheme.setThemeMode(ThemeMode.dark);
                      } else {
                        changeTheme.setThemeMode(ThemeMode.light);
                      }
                      sp.setBool("night", value);
                    });
                  }),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Dimensions.height20),
              Center(
                child: GestureDetector(
                  onTap: showImageDialog,
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
              ),
              SizedBox(height: Dimensions.height10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isEditing
                      ? Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: Dimensions.width50),
                            child: TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: 'Name',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.only(left: Dimensions.width30),
                          child: Text(
                            "Name: $username",
                            style: TextStyle(fontSize: Dimensions.font16),
                          ),
                        ),
                  Padding(
                    padding: EdgeInsets.only(right: Dimensions.width15),
                    child: IconButton(
                      icon: Icon(isEditing
                          ? Icons.check
                          : Icons.edit), // Change icon based on editing state
                      onPressed: () {
                        if (isEditing) {
                          // Save changes when in editing mode
                          updateUserProfile(nameController.text);
                        } else {
                          setState(() {
                            isEditing = true; // Enable editing
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              Center(
                child: Text(
                  "Email: $email",
                  style: TextStyle(fontSize: Dimensions.font16),
                ),
              ),
              SizedBox(height: Dimensions.height30),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Settings',
                    style: TextStyle(
                        fontSize: Dimensions.font20,
                        fontWeight: FontWeight.w400)),
              ),
              SizedBox(height: Dimensions.height20),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => showConfirmationDialog('Delete'),
                      child: Row(
                        children: [
                          Container(
                            width: Dimensions.width50,
                            height: Dimensions.height50,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Ionicons.trash_outline,
                              color: Colors.blueAccent,
                              size: Dimensions.icon30,
                            ),
                          ),
                          SizedBox(width: Dimensions.width6),
                          Text('Delete Account',
                              style: TextStyle(
                                  fontSize: Dimensions.font18,
                                  fontWeight: FontWeight.w400)),
                          const Spacer(),
                          const Icon(Icons.arrow_forward_ios),
                        ],
                      ),
                    ),
                    SizedBox(height: Dimensions.height5),
                    InkWell(
                      onTap: () => showHelpDialog(context),
                      child: Row(
                        children: [
                          Container(
                            width: Dimensions.width50,
                            height: Dimensions.height50,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.help_outline_rounded,
                              color: Colors.blueAccent,
                              size: Dimensions.icon30,
                            ),
                          ),
                          SizedBox(width: Dimensions.width6),
                          Text('Help',
                              style: TextStyle(
                                  fontSize: Dimensions.font18,
                                  fontWeight: FontWeight.w400)),
                          const Spacer(),
                          const Icon(Icons.arrow_forward_ios),
                        ],
                      ),
                    ),
                    SizedBox(height: Dimensions.height5),
                    InkWell(
                      onTap: () => showAboutUs(context),
                      child: Row(
                        children: [
                          Container(
                            width: Dimensions.width50,
                            height: Dimensions.height50,
                            decoration: BoxDecoration(
                              color: Colors.blue
                                  .shade100, // Subtle blue for a healthcare theme
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.info_outline_rounded,
                              color: Colors.blueAccent, // Enhancing visibility
                              size: Dimensions
                                  .icon30, // Slightly increasing icon size for better focus
                            ),
                          ),
                          SizedBox(
                              width: Dimensions
                                  .width8), // Slightly increased spacing for balance
                          Text(
                            'About Us',
                            style: TextStyle(
                              fontWeight: FontWeight
                                  .w400, // Slightly bolder for emphasis
                              fontSize: Dimensions.font18,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.arrow_forward_ios,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: Dimensions.height5),
                    InkWell(
                      onTap: () => showAlertDialog(context),
                      child: Row(
                        children: [
                          Container(
                            width: Dimensions.width50,
                            height: Dimensions.height50,
                            decoration: BoxDecoration(
                              color: Colors.blue
                                  .shade100, // Subtle blue for a healthcare theme
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Ionicons.log_out_outline,
                              color: Colors.blueAccent, // Enhancing visibility
                              size: Dimensions
                                  .icon30, // Slightly increasing icon size for better focus
                            ),
                          ),
                          SizedBox(
                              width: Dimensions
                                  .width8), // Slightly increased spacing for balance
                          Text(
                            'Logout',
                            style: TextStyle(
                              fontWeight: FontWeight
                                  .w400, // Slightly bolder for emphasis
                              fontSize: Dimensions.font18,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.arrow_forward_ios,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
