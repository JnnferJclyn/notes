


import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes/models/note.dart';
import 'package:notes/services/note_service.dart';

class NoteDialog extends StatefulWidget {
  //final Map<String, dynamic>? note; //bs null atau tidak = ?
  final Note? note;

  const NoteDialog({super.key, this.note});

  @override
  State<NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<NoteDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      //note dkbs akses lgsgkrn pisah class, mk akses pke widget dlu
      _titleController.text = widget.note!.title;
      _descriptionController.text = widget.note!.description;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.camera); //bs .gallerry
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //copy dri note_list_screen : ALertDialog, bs add / update ssuai dmn ditarok jdi buat if
    //update ssuai id, jdi klo ad input id, brrti update
    return AlertDialog(
      title: Text(widget.note == null
          ? 'Add Notes'
          : 'Update Notes'), //jika noteId == null maka'Add Notes' jika tidak 'Update Notes'
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Title: ',
            textAlign: TextAlign.start,
          ),
          TextField(
            controller: _titleController,
          ),
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text('Description: ', textAlign: TextAlign.start),
          ),
          TextField(
            controller: _descriptionController,
          ),
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text('Image : '),
          ),
          Expanded(
            child: _imageFile != null
                ? Image.file(
                    _imageFile!,
                    fit: BoxFit.cover,
                  )
                : (widget.note?.imageUrl != null &&
                        Uri.parse(widget.note!.imageUrl!).isAbsolute
                    ? Image.network(
                        widget.note!.imageUrl!,
                        fit: BoxFit.cover,
                      )
                    : Container()),
          ), //img network : klo img ny sdh ad link (sdh prnh diupload), img file : img lokal/dipilih dr galeri
          TextButton(
            onPressed: _pickImage,
            child: const Text('Pick Image'),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            String? imageUrl;
            if (_imageFile != null) {
              imageUrl = await NoteService.uploadImage(_imageFile!);
            }
            Note note = Note(
                id: widget.note?.id,
                title: _titleController.text,
                description: _descriptionController.text,
                imageUrl: imageUrl!,
                createdAt: widget.note?.createdAt);
            if (widget.note == null) {
              NoteService.addNote(note).whenComplete(() {
                Navigator.of(context).pop(); //klo sdh selesai, keluar
              });
            } else {
              NoteService.updateNote(note)
                  .whenComplete(() => Navigator.of(context).pop());
            }
          },
          child: Text(widget.note == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }
}
