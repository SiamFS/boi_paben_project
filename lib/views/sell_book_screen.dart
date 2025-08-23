import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import '../models/book_model.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/book_viewmodel.dart';
import '../utils/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class SellBookScreen extends StatefulWidget {
  const SellBookScreen({super.key});

  @override
  State<SellBookScreen> createState() => _SellBookScreenState();
}

class _SellBookScreenState extends State<SellBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bookTitleController = TextEditingController();
  final _authorNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _bookDescriptionController = TextEditingController();
  final _publisherController = TextEditingController();
  final _editionController = TextEditingController();
  final _streetAddressController = TextEditingController();
  final _cityTownController = TextEditingController();
  final _districtController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _contactNumberController = TextEditingController();

  String? _selectedCategory = 'Fiction';
  String? _selectedAuthenticity = 'Original';
  String? _selectedCondition = 'Used';
  File? _imageFile;
  bool _isUploading = false;
  bool _useAutoFill = true;

  final List<String> _categories = ['Fiction', 'Non-Fiction', 'Science', 'History', 'Fantasy', 'Biography', 'Education'];
  final List<String> _authenticityOptions = ['Original', 'Photocopy'];
  final List<String> _conditionOptions = ['New', 'Used', 'Good', 'Fair'];

  @override
  void initState() {
    super.initState();
    _loadAutoFillData();
  }

  void _loadAutoFillData() {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    if (authViewModel.autoFillEnabled && _useAutoFill) {
      _streetAddressController.text = authViewModel.savedStreetAddress ?? '';
      _cityTownController.text = authViewModel.savedCityTown ?? '';
      _districtController.text = authViewModel.savedDistrict ?? '';
      _zipCodeController.text = authViewModel.savedZipCode ?? '';
      _contactNumberController.text = authViewModel.savedContactNumber ?? '';
    }
  }

  void _clearAddressFields() {
    _streetAddressController.clear();
    _cityTownController.clear();
    _districtController.clear();
    _zipCodeController.clear();
    _contactNumberController.clear();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    try {
      final cloudinary = CloudinaryPublic('dtxxuzbne', 'boi_paben_books');
      
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(imageFile.path,
          publicId: 'book_${DateTime.now().millisecondsSinceEpoch}',
        ),
      );
      
      return response.secureUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      }
      return null;
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image for the book.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final bookViewModel = Provider.of<BookViewModel>(context, listen: false);

    try {

      final String? imageUrl = await _uploadImageToCloudinary(_imageFile!);

      if (imageUrl == null) {
 
        return;
      }
      final newBook = Book(
        bookTitle: _bookTitleController.text,
        authorName: _authorNameController.text,
        imageURL: imageUrl,
        category: _selectedCategory!,
        price: _priceController.text,
        bookDescription: _bookDescriptionController.text,
        email: authViewModel.user?.email,
        publisher: _publisherController.text.isEmpty ? null : _publisherController.text,
        edition: _editionController.text.isEmpty ? null : _editionController.text,
        streetAddress: _streetAddressController.text,
        cityTown: _cityTownController.text,
        district: _districtController.text,
        zipCode: _zipCodeController.text,
        contactNumber: _contactNumberController.text,
        authenticity: _selectedAuthenticity!,
        productCondition: _selectedCondition!,
        availability: 'available',
        seller: authViewModel.user?.displayName ?? 'Unknown',
      );

      await bookViewModel.uploadBook(newBook);

      if (bookViewModel.errorMessage == null) {
        if (_useAutoFill && authViewModel.autoFillEnabled) {
          await authViewModel.saveUserAddress(
            streetAddress: _streetAddressController.text,
            cityTown: _cityTownController.text,
            district: _districtController.text,
            zipCode: _zipCodeController.text,
            contactNumber: _contactNumberController.text,
          );
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Book uploaded successfully!')),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save book details: ${bookViewModel.errorMessage}')),
          );
        }
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Book', style: GoogleFonts.poppins()),
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Book Details Section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Book Information',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(_bookTitleController, 'Book Title'),
                      _buildTextField(_authorNameController, 'Author Name'),
                      _buildDropdown(_categories, 'Category', _selectedCategory, (val) => setState(() => _selectedCategory = val)),
                      _buildTextField(_priceController, 'Price (৳)', keyboardType: TextInputType.number),
                      _buildTextField(_bookDescriptionController, 'Book Description', maxLines: 3),
                      _buildTextField(_publisherController, 'Publisher'),
                      _buildTextField(_editionController, 'Edition (Optional)', isRequired: false),
                      _buildDropdown(_authenticityOptions, 'Authenticity', _selectedAuthenticity, (val) => setState(() => _selectedAuthenticity = val)),
                      _buildDropdown(_conditionOptions, 'Condition', _selectedCondition, (val) => setState(() => _selectedCondition = val)),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Image Section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Book Image',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildImagePicker(),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Contact & Address Section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Contact & Address',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryOrange,
                            ),
                          ),
                          Consumer<AuthViewModel>(
                            builder: (context, authViewModel, child) {
                              return Row(
                                children: [
                                  Text(
                                    'Auto-fill',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: AppColors.textGray,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Switch(
                                    value: _useAutoFill && authViewModel.autoFillEnabled,
                                    onChanged: (value) {
                                      setState(() {
                                        _useAutoFill = value;
                                      });
                                      if (value) {
                                        _loadAutoFillData();
                                      } else {
                                        _clearAddressFields();
                                      }
                                    },
                                    activeColor: AppColors.primaryOrange,
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(_streetAddressController, 'Street Address'),
                      _buildTextField(_cityTownController, 'City/Town'),
                      _buildTextField(_districtController, 'District'),
                      _buildTextField(_zipCodeController, 'Zip Code', keyboardType: TextInputType.number),
                      _buildTextField(_contactNumberController, 'Contact Number', keyboardType: TextInputType.phone),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Submit Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: _isUploading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Uploading...',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'Upload Book',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isRequired = true, int maxLines = 1, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'Please enter the $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String label, String? selectedValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: label),
        value: selectedValue,
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Please select a $label' : null,
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        if (_imageFile != null) ...[
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryOrange, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                _imageFile!,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: Icon(
              _imageFile != null ? Icons.edit : Icons.camera_alt,
              color: AppColors.white,
            ),
            label: Text(
              _imageFile != null ? 'Change Photo' : 'Upload Photo',
              style: GoogleFonts.poppins(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: _pickImage,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
