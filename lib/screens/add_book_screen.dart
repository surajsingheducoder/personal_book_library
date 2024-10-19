import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:personal_book_library/widgets/custom_button.dart';
import 'package:personal_book_library/widgets/custom_text_field.dart';
import '../models/book_model.dart';
import '../services/db_helper.dart';

class AddBookScreen extends StatefulWidget {
  final String userEmail;
  final BookModel? book;

  const AddBookScreen({super.key, required this.userEmail, this.book});

  @override
  _AddBookScreenState createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _genreController = TextEditingController();
  String _imagePath = '';
  String _readStatus = 'unread';

  @override
  void initState() {
    super.initState();
    if (widget.book != null) {
      _titleController.text = widget.book!.title;
      _authorController.text = widget.book!.author;
      _genreController.text = widget.book!.genre;
      _imagePath = widget.book!.coverImage;
      _readStatus = widget.book!.isRead ? 'read' : 'unread';
    }
  }


  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = pickedFile.name;
      final savedImagePath = '${appDir.path}/$fileName';

      final File savedImage = await File(pickedFile.path).copy(savedImagePath);

      setState(() {
        _imagePath = savedImage.path;
      });
    }
  }

  void _saveBook(BuildContext context) async {
    if (!_formKey.currentState!.validate() || _imagePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all the fields and select an image.")),
      );
      return;
    }

    final newBook = BookModel(
      title: _titleController.text,
      author: _authorController.text,
      genre: _genreController.text,
      coverImage: _imagePath,
      isRead: _readStatus == 'read',
      userEmail: widget.userEmail,
    );

    if (widget.book == null) {
      await DBHelper.instance.addBook(newBook);
    } else {
      await DBHelper.instance.updateBook(newBook.copyWith(id: widget.book!.id));
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        titleSpacing: 0,
        title: Text(
          widget.book == null ? 'Add Book' : 'Edit Book',
          style: TextStyle(fontSize: screenHeight / 48),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Column(
                children: [
                  CustomTextField(
                    controller: _titleController,
                    label: "Title",
                    iconData: Icons.title,
                    validator: (value) => value == null || value.isEmpty ? 'Please enter title' : null,
                  ),
                  SizedBox(height: screenHeight / 60),
                  CustomTextField(
                    controller: _authorController,
                    label: "Author",
                    iconData: Icons.person,
                    validator: (value) => value == null || value.isEmpty ? 'Please enter author' : null,
                  ),
                  SizedBox(height: screenHeight / 60),
                  CustomTextField(
                    controller: _genreController,
                    label: "Genre",
                    iconData: Icons.generating_tokens_rounded,
                    validator: (value) => value == null || value.isEmpty ? 'Please enter genre' : null,
                  ),
                  SizedBox(height: screenHeight / 60),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text("Status:"),
                      SizedBox(width: screenWidth / 15),
                      Radio<String>(
                        value: 'read',
                        groupValue: _readStatus,
                        onChanged: (value) {
                          setState(() {
                            _readStatus = value!;
                          });
                        },
                      ),
                      const Text('Read'),
                      SizedBox(width: screenWidth / 15),
                      Radio<String>(
                        value: 'unread',
                        groupValue: _readStatus,
                        onChanged: (value) {
                          setState(() {
                            _readStatus = value!;
                          });
                        },
                      ),
                      const Text('Unread'),
                    ],
                  ),
                  SizedBox(height: screenHeight / 60),

                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: screenHeight / 3,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: _imagePath.isNotEmpty && File(_imagePath).existsSync()
                          ? Image.file(File(_imagePath), fit: BoxFit.cover)
                          : const Center(child: Text('Add picture of cover page')),
                    ),
                  ),
                  SizedBox(height: screenHeight / 30),
                  CustomButton(
                    text: "Save",
                    onPressed: () => _saveBook(context),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
