import 'dart:typed_data';

class FileModel {
  final int? id;
  final String? title;
  final String? author;
  final String? description;
  final String? filePath;
  final String? fileMetaPath;
  final String? coverImagePath;
  final String? publishedDate;
  final String? readStatus;
  final String? downloadDate;
  final int? totalPages;

  FileModel({
    this.id,
    this.title,
    this.author,
    this.description,
    this.filePath,
    this.fileMetaPath,
    this.coverImagePath,
    this.publishedDate,
    this.readStatus,
    this.downloadDate,
    this.totalPages,
  });

  // Convert a map from the database to a FileModel object
  factory FileModel.fromMap(Map<String, dynamic> map) {
    return FileModel(
      id: map['id'],
      title: map['title'],
      author: map['author'],
      description: map['description'],
      filePath: map['filePath'],
      fileMetaPath: map['fileMetaPath'],
      coverImagePath: map['coverImagePath'],
      publishedDate: map['publishedDate'],
      readStatus: map['readStatus'],
      downloadDate: map['downloadDate'],
      totalPages: map['totalPages'],
    );
  }

  // Convert a FileModel object to a map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'filePath': filePath,
      'fileMetaPath': fileMetaPath,
      'coverImagePath': coverImagePath,
      'publishedDate': publishedDate,
      'readStatus': readStatus,
      'downloadDate': downloadDate,
      'totalPages': totalPages,
    };
  }
}
