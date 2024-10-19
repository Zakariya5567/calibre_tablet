import 'dart:io';

import 'package:flutter/material.dart';

class PdfMetadataDisplay extends StatelessWidget {
  final Map<String, dynamic> pdfMetadata;

  PdfMetadataDisplay({required this.pdfMetadata});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.file(File(pdfMetadata['thumbnail'])), // Display the thumbnail
        Text('Name: ${pdfMetadata['name']}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text('Author: ${pdfMetadata['author']}',
            style: TextStyle(fontSize: 16)),
        Text('Description: ${pdfMetadata['description']}',
            style: TextStyle(fontSize: 14)),
      ],
    );
  }
}
