import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/signin_screen.dart';
import '../services/db_helper.dart';
import '../models/book_model.dart';
import '../providers/auth_provider.dart';
import 'add_book_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userEmail;
  const HomeScreen({required this.userEmail, Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<BookModel> _books = [];
  List<BookModel> _filteredBooks = [];
  String? _selectedGenre;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    final books = await DBHelper.instance.getUserBooks(widget.userEmail);
    setState(() {
      _books = books;
      _filteredBooks = books;
    });
  }

  void _filterBooks() {
    setState(() {
      _filteredBooks = _books.where((book) {
        final matchesGenre =
            _selectedGenre == null || book.genre == _selectedGenre;
        final matchesStatus = _selectedStatus == null ||
            (_selectedStatus == 'read' && book.isRead) ||
            (_selectedStatus == 'unread' && !book.isRead);
        return matchesGenre && matchesStatus;
      }).toList();
    });
  }

  Future<void> _onRefresh() async => _fetchBooks();

  Future<void> logoutPref() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn',false);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: _buildAppBar(screenHeight, screenWidth, authProvider),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: _filteredBooks.isEmpty
            ? _buildEmptyBooksMessage(screenHeight)
            : _buildBooksListView(screenHeight, screenWidth),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddBookScreen(userEmail: widget.userEmail),
            ),
          ).then((_) => _fetchBooks());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  AppBar _buildAppBar(
      double screenHeight, double screenWidth, AuthProvider authProvider) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.black,
      title: FittedBox(
        child: Row(
          children: [
            Icon(Icons.person_pin, size: screenHeight / 25),
            SizedBox(width: screenWidth / 40),
            Text(
              widget.userEmail,
              overflow: TextOverflow.fade,
              style: TextStyle(fontSize: screenHeight / 58),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: _showFilterBottomSheet,
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => _showLogoutConfirmationDialog(authProvider),
        ),
      ],
    );
  }

  Widget _buildEmptyBooksMessage(double screenHeight) {
    return Center(
      child: Text(
        'No books available.',
        style: TextStyle(fontSize: screenHeight / 40, color: Colors.grey),
      ),
    );
  }

  ListView _buildBooksListView(double screenHeight, double screenWidth) {
    return ListView.builder(
      itemCount: _filteredBooks.length,
      itemBuilder: (context, index) {
        final book = _filteredBooks[index];
        return _buildBookCard(context, book, screenWidth, screenHeight);
      },
    );
  }

  Widget _buildBookCard(
      BuildContext context, BookModel book, double screenWidth, double screenHeight) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        shadowColor: Colors.grey,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          horizontalTitleGap: 10,
          leading: _buildBookCover(book, screenWidth, screenHeight),
          title: Text("Title: ${book.title}", overflow: TextOverflow.ellipsis),
          subtitle: _buildBookDetails(book, screenHeight),
          trailing: IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () => _showBottomSheet(context, book),
          ),
        ),
      ),
    );
  }

  Widget _buildBookCover(BookModel book, double screenWidth, double screenHeight) {
    return book.coverImage.isNotEmpty
        ? ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.file(
        File(book.coverImage),
        width: screenWidth / 6,
        height: screenHeight / 5,
        fit: BoxFit.cover,
      ),
    )
        : Container(
      width: screenWidth / 5,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          'No Image',
          style: TextStyle(fontSize: screenHeight / 40, color: Colors.grey),
        ),
      ),
    );
  }

  Column _buildBookDetails(BookModel book, double screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Author: ${book.author}", style: TextStyle(fontSize: screenHeight / 60)),
        Text("Genre: ${book.genre}", style: TextStyle(fontSize: screenHeight / 60)),
        Text(book.isRead ? "Status: Read" : "Status: Unread",
            style: TextStyle(fontSize: screenHeight / 60)),
      ],
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(width: 30, height: 5, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              const Text('Filter Books',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildFilterOptions(),
              const SizedBox(height: 16),
              _buildClearFiltersButton(),
            ],
          ),
        );
      },
    );
  }

  Column _buildFilterOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButton<String>(
          isExpanded: true,
          hint: const Text('Select Genre'),
          value: _selectedGenre,
          onChanged: (value) {
            setState(() {
              _selectedGenre = value;
              _filterBooks();
              Navigator.pop(context);
            });
          },
          items: _books.map((book) => book.genre).toSet().map((genre) {
            return DropdownMenuItem(value: genre, child: Text(genre));
          }).toList(),
        ),
        const SizedBox(height: 16),
        const Text('Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ToggleButtons(
          isSelected: [_selectedStatus == 'read', _selectedStatus == 'unread'],
          onPressed: (index) {
            setState(() {
              _selectedStatus = index == 0 ? 'read' : 'unread';
              _filterBooks();
              Navigator.pop(context);
            });
          },
          children: const [Text('Read'), Text('Unread')],
        ),
      ],
    );
  }


  Widget _buildClearFiltersButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          setState(() {
            _selectedGenre = null;
            _selectedStatus = null;
            _filterBooks();
            Navigator.pop(context);
          });
        },
        child: const Text('Clear All Filters',
            style: TextStyle(fontSize: 16, color: Colors.red)),
      ),
    );
  }


  void _showBottomSheet(BuildContext context, BookModel book) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.blue),
            title: const Text("Edit"),
            onTap: () => _editBook(book),
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text("Delete"),
            onTap: () async {
              Navigator.pop(context);
              await Future.delayed(const Duration(milliseconds: 100));
              _confirmDelete(book);
            },
          ),
        ],
      ),
    );
  }

  void _editBook(BookModel book) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBookScreen(userEmail: widget.userEmail, book: book),
      ),
    ).then((_) => _fetchBooks());
  }

  void _confirmDelete(BookModel book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this book?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await DBHelper.instance.deleteBook(book.id!);
              _fetchBooks();
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmationDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await logoutPref();
              authProvider.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const SignInScreen()),
                    (route) => false,
              );
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

