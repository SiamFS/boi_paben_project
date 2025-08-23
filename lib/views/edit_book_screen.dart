import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import '../models/book_model.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/book_viewmodel.dart';
import '../utils/app_theme.dart';

class EditBookScreen extends StatefulWidget {
  final Book? book;
  
  const EditBookScreen({super.key, this.book});

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  
  // Controllers
  late TextEditingController _bookTitleController;
  late TextEditingController _authorNameController;
  late TextEditingController _priceController;
  late TextEditingController _bookDescriptionController;
  late TextEditingController _publisherController;
  late TextEditingController _editionController;
  late TextEditingController _streetAddressController;
  late TextEditingController _cityTownController;
  late TextEditingController _districtController;
  late TextEditingController _zipCodeController;
  late TextEditingController _contactNumberController;

  String? _selectedCategory;
  String? _selectedAuthenticity;
  String? _selectedProductCondition;
  String? _selectedAvailability;

  File? _selectedImage;
  String? _currentImageUrl;
  bool _isUploading = false;

  final List<String> _categories = [
    'Fiction', 
    'Non-Fiction', 
    'Science', 
    'History', 
    'Fantasy', 
    'Biography', 
    'Education',
    'Academic',
    'Children',
    'Textbook',
    'Other'
  ];

  final List<String> _authenticityOptions = ['Original', 'Photocopy'];
  final List<String> _conditionOptions = ['New', 'Used', 'Good', 'Fair'];
  final List<String> _availabilityOptions = ['Available', 'Sold', 'Reserved'];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final book = widget.book;
    
    _bookTitleController = TextEditingController(text: book?.bookTitle ?? '');
    _authorNameController = TextEditingController(text: book?.authorName ?? '');
    _priceController = TextEditingController(text: book?.price ?? '');
    _bookDescriptionController = TextEditingController(text: book?.bookDescription ?? '');
    _publisherController = TextEditingController(text: book?.publisher ?? '');
    _editionController = TextEditingController(text: book?.edition ?? '');
    _streetAddressController = TextEditingController(text: book?.streetAddress ?? '');
    _cityTownController = TextEditingController(text: book?.cityTown ?? '');
    _districtController = TextEditingController(text: book?.district ?? '');
    _zipCodeController = TextEditingController(text: book?.zipCode ?? '');
    _contactNumberController = TextEditingController(text: book?.contactNumber ?? '');

    _selectedCategory = _categories.contains(book?.category) ? book?.category : null;
    _selectedAuthenticity = _authenticityOptions.contains(book?.authenticity) ? book?.authenticity : null;
    _selectedProductCondition = _conditionOptions.contains(book?.productCondition) ? book?.productCondition : null;
    _selectedAvailability = _availabilityOptions.contains(book?.availability) ? book?.availability : 'Available';
    _currentImageUrl = book?.imageURL;
  }

  @override
  void dispose() {
    _bookTitleController.dispose();
    _authorNameController.dispose();
    _priceController.dispose();
    _bookDescriptionController.dispose();
    _publisherController.dispose();
    _editionController.dispose();
    _streetAddressController.dispose();
    _cityTownController.dispose();
    _districtController.dispose();
    _zipCodeController.dispose();
    _contactNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.book == null ? 'Sell Book' : 'Edit Book',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: AppColors.white,
      ),
      body: Consumer2<AuthViewModel, BookViewModel>(
        builder: (context, authViewModel, bookViewModel, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageSection(),
                  const SizedBox(height: 24),
                  _buildBookInfoSection(),
                  const SizedBox(height: 24),
                  _buildLocationSection(authViewModel),
                  const SizedBox(height: 24),
                  _buildSubmitButton(authViewModel, bookViewModel),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Book Image',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 200,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        )
                      : _currentImageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(_currentImageUrl!, fit: BoxFit.cover),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt, size: 48, color: Colors.grey.shade600),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap to select image',
                                  style: GoogleFonts.poppins(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Book Information',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField('Book Title', _bookTitleController, isRequired: true),
            const SizedBox(height: 16),
            _buildTextField('Author Name', _authorNameController, isRequired: true),
            const SizedBox(height: 16),
            _buildDropdown('Category', _selectedCategory, _categories, (value) {
              setState(() => _selectedCategory = value);
            }),
            const SizedBox(height: 16),
            _buildTextField('Price (৳)', _priceController, 
              isRequired: true, keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            _buildTextField('Description', _bookDescriptionController, 
              isRequired: true, maxLines: 3),
            const SizedBox(height: 16),
            _buildTextField('Publisher', _publisherController),
            const SizedBox(height: 16),
            _buildTextField('Edition', _editionController),
            const SizedBox(height: 16),
            _buildDropdown('Authenticity', _selectedAuthenticity, _authenticityOptions, (value) {
              setState(() => _selectedAuthenticity = value);
            }),
            const SizedBox(height: 16),
            _buildDropdown('Condition', _selectedProductCondition, _conditionOptions, (value) {
              setState(() => _selectedProductCondition = value);
            }),
            const SizedBox(height: 16),
            _buildDropdown('Availability', _selectedAvailability, _availabilityOptions, (value) {
              setState(() => _selectedAvailability = value);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection(AuthViewModel authViewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location & Contact',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField('Street Address', _streetAddressController, isRequired: true),
            const SizedBox(height: 16),
            _buildTextField('City/Town', _cityTownController, isRequired: true),
            const SizedBox(height: 16),
            _buildTextField('District', _districtController, isRequired: true),
            const SizedBox(height: 16),
            _buildTextField('Zip Code', _zipCodeController, isRequired: true),
            const SizedBox(height: 16),
            _buildTextField('Contact Number', _contactNumberController, 
              isRequired: true, keyboardType: TextInputType.phone),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, 
      {bool isRequired = false, int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label + (isRequired ? ' *' : ''),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: isRequired ? (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label is required';
        }
        return null;
      } : null,
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> options, 
      void Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: '$label *',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: options.map((option) => DropdownMenuItem(
        value: option,
        child: Text(option),
      )).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label is required';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton(AuthViewModel authViewModel, BookViewModel bookViewModel) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isUploading || bookViewModel.isLoading 
            ? null 
            : () => _submitBook(authViewModel, bookViewModel),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryOrange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isUploading || bookViewModel.isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                widget.book == null ? 'Upload Book' : 'Update Book',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<String?> _uploadImageToCloudinary() async {
    if (_selectedImage == null) return _currentImageUrl;

    try {
      setState(() => _isUploading = true);

      final cloudinary = CloudinaryPublic('dtkojcug3', 'boipaben_upload');
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(_selectedImage!.path),
      );

      return response.secureUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
      return null;
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _submitBook(AuthViewModel authViewModel, BookViewModel bookViewModel) async {
    if (!_formKey.currentState!.validate()) return;

    if (!authViewModel.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to continue'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    if (_selectedImage == null && _currentImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a book image'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    try {
      final imageUrl = await _uploadImageToCloudinary();
      if (imageUrl == null) return;

      final book = Book(
        id: widget.book?.id,
        bookTitle: _bookTitleController.text.trim(),
        authorName: _authorNameController.text.trim(),
        imageURL: imageUrl,
        category: _selectedCategory!,
        price: _priceController.text.trim(),
        bookDescription: _bookDescriptionController.text.trim(),
        email: authViewModel.user?.email,
        publisher: _publisherController.text.trim().isEmpty ? null : _publisherController.text.trim(),
        edition: _editionController.text.trim().isEmpty ? null : _editionController.text.trim(),
        streetAddress: _streetAddressController.text.trim(),
        cityTown: _cityTownController.text.trim(),
        district: _districtController.text.trim(),
        zipCode: _zipCodeController.text.trim(),
        contactNumber: _contactNumberController.text.trim(),
        authenticity: _selectedAuthenticity!,
        productCondition: _selectedProductCondition!,
        availability: _selectedAvailability,
        seller: authViewModel.user?.displayName,
      );

      if (widget.book == null) {
        await bookViewModel.uploadBook(book);
      } else {
        await bookViewModel.updateBook(book);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.book == null ? 'Book uploaded successfully!' : 'Book updated successfully!'),
            backgroundColor: AppColors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }
}
