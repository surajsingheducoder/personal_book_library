# personal_book_library
A Flutter application designed to help users manage their personal book collections.


## Getting Started
This project is a starting point for a Flutter application.



## Installation setup
First of all open Android Studio and setup flutter after setup flutter create project personal book library.



## Technologies and Libraries Used:
This project utilizes the following packages:

provider: ^6.1.2        - State management solution for Flutter.
sqflite: ^2.2.8+4       - SQLite plugin for Flutter, used for local data storage.
path_provider: ^2.1.1   - Access commonly used locations on the filesystem.
cached_network_image:   - not using.
path: ^1.8.2            - A Path class for manipulating file paths.
image_picker: ^1.0.0    - Allows users to select images from the gallery or take photos.
shared_preferences: ^2.2.2 - A way to store simple data in the device's local storage used for check user login status.



## This App Allows User to:
Add new books with details such as title, author, genre, cover image, and read/unread status.
View a list of all books in your collection.
Edit or delete book entries.
Filter books by genre or read status.


## Challenges Faced During Development
State Management: Managing the state efficiently while allowing users to manage authentication (Hardcoded), edit and filter their book collections presented a challenge. The provider package helped streamline state management.
Database Handling: Integrating SQLite with the sqflite package required careful handling of data operations (CRUD). Ensuring data consistency and handling potential errors were critical.
User Interface Design: Creating a user-friendly UI that caters to different screen sizes was a challenge, but Flutter's responsive design capabilities eased this process.