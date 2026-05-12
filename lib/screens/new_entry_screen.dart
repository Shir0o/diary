import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../helpers/font_helper.dart';
import '../models/diary_entry.dart';
import '../providers/diary_provider.dart';

class NewEntryScreen extends StatefulWidget {
  final DateTime? initialDate;
  const NewEntryScreen({super.key, this.initialDate});

  @override
  State<NewEntryScreen> createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  final TextEditingController _controller = TextEditingController();
  late final DateTime _now;
  String _selectedMood = '😊'; // Default mood
  final List<String> _moods = [
    '😊', '😢', '😡', '😴', '🥳', '🤔', '😎', '🤢', '🚀', '☕', '📝', '🌈'
  ];
  String? _currentLocation;
  bool _isLoadingLocation = false;
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  final List<String> _selectedTags = [];
  final List<String> _availableTags = [
    'Personal', 'Work', 'Travel', 'Food', 'Health', 'Ideas'
  ];

  @override
  void initState() {
    super.initState();
    _now = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImages.add(image);
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied';
      }

      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _currentLocation = '${place.locality}, ${place.country}';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  void _showMoodPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How are you feeling?',
                style: safeGoogleFont(
                  'IBM Plex Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: _moods.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedMood = _moods[index];
                      });
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _selectedMood == _moods[index]
                            ? const Color(0xFF6750A4).withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedMood == _moods[index]
                              ? const Color(0xFF6750A4)
                              : Colors.transparent,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _moods[index],
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _showTagPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Tags',
                    style: safeGoogleFont(
                      'IBM Plex Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableTags.map((tag) {
                      final isSelected = _selectedTags.contains(tag);
                      return FilterChip(
                        label: Text(tag),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            if (selected) {
                              _selectedTags.add(tag);
                            } else {
                              _selectedTags.remove(tag);
                            }
                          });
                          setState(() {}); // Update main screen
                        },
                        selectedColor: const Color(0xFF6750A4).withValues(alpha: 0.2),
                        checkmarkColor: const Color(0xFF6750A4),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _saveEntry() {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something before saving.')),
      );
      return;
    }

    final entry = DiaryEntry(
      id: const Uuid().v4(),
      date: _now,
      title: _controller.text.split('\n').first, // Simple title from first line
      content: _controller.text,
      mood: _selectedMood,
      location: _currentLocation,
      imageUrls: _selectedImages.map((file) => file.path).toList(),
      tags: _selectedTags,
    );

    Provider.of<DiaryProvider>(context, listen: false).addEntry(entry);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEF7FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'New Entry',
          style: safeGoogleFont(
            'IBM Plex Sans',
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: _saveEntry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6750A4),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: const Text('Save'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    DateFormat('MMM dd, yyyy').format(_now),
                    style: safeGoogleFont(
                      'IBM Plex Sans',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        DateFormat('h:mm a').format(_now),
                        style: safeGoogleFont(
                          'IBM Plex Sans',
                          fontSize: 18,
                          color: const Color(0xFF79747E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '•',
                        style: TextStyle(color: Color(0xFF79747E)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('EEEE').format(_now),
                        style: safeGoogleFont(
                          'IBM Plex Sans',
                          fontSize: 18,
                          color: const Color(0xFF79747E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: _showMoodPicker,
                        child: Text(
                          _selectedMood,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ],
                  ),
                  if (_currentLocation != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Color(0xFF79747E),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _currentLocation!,
                            style: safeGoogleFont(
                              'IBM Plex Sans',
                              fontSize: 14,
                              color: const Color(0xFF79747E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_selectedTags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Wrap(
                        spacing: 4,
                        children: _selectedTags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6750A4).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '#$tag',
                              style: safeGoogleFont(
                                'IBM Plex Sans',
                                fontSize: 12,
                                color: const Color(0xFF6750A4),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  if (_selectedImages.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(_selectedImages[index].path),
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedImages.removeAt(index);
                                        });
                                      },
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _controller,
                    maxLines: null,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Write your heart out...',
                      hintStyle: safeGoogleFont(
                        'IBM Plex Sans',
                        fontSize: 18,
                        color: const Color(0xFF79747E).withValues(alpha: 0.6),
                      ),
                      border: InputBorder.none,
                    ),
                    style: safeGoogleFont(
                      'IBM Plex Sans',
                      fontSize: 18,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF7FF).withValues(alpha: 0.9),
              border: Border(
                top: BorderSide(
                  color: const Color(0xFF79747E).withValues(alpha: 0.1),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: _pickImage,
                        child: const Icon(
                          Icons.image_outlined,
                          color: Color(0xFF6750A4),
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: _showTagPicker,
                        child: Icon(
                          _selectedTags.isNotEmpty
                              ? Icons.label
                              : Icons.label_outlined,
                          color: const Color(0xFF6750A4),
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: _showMoodPicker,
                        child: const Icon(
                          Icons.mood_outlined,
                          color: Color(0xFF6750A4),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 1,
                        height: 24,
                        color: const Color(0xFF79747E).withValues(alpha: 0.2),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: _getCurrentLocation,
                        child: Icon(
                          _currentLocation != null
                              ? Icons.location_on
                              : Icons.location_on_outlined,
                          color: _isLoadingLocation
                              ? Colors.grey
                              : const Color(0xFF6750A4),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.cloud_upload_outlined,
                      size: 16,
                      color: Color(0xFF79747E),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Saving...',
                      style: safeGoogleFont(
                        'IBM Plex Sans',
                        fontSize: 12,
                        color: const Color(0xFF79747E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
