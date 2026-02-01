import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/core/utils/app_assets.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';

class DoctorChatBotTab extends StatefulWidget {
  const DoctorChatBotTab({super.key});

  @override
  State<DoctorChatBotTab> createState() => _DoctorChatBotTabState();
}

class _DoctorChatBotTabState extends State<DoctorChatBotTab> {
  final TextEditingController _searchController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _onSearch() {
    if (_searchController.text.isEmpty && _selectedImage == null) return;
    
    debugPrint("Clinical Search Triggered: ${_searchController.text}");
    if (_selectedImage != null) debugPrint("Image selected for analysis: ${_selectedImage!.path}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: Text("AI Assistant", style: AppTextStyles.medium18White.copyWith(color: AppColors.primaryBlue)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 40.h),
              
              // Image Preview or Shagy Logo
              if (_selectedImage != null)
                _buildImagePreview()
              else
                _buildShagyLogo(),

              SizedBox(height: 32.h),
              
              Text("Shagy Assistant", style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
              SizedBox(height: 12.h),
              Text("Search clinical records or upload images.", textAlign: TextAlign.center, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              
              SizedBox(height: 40.h),

              // Search & Upload Bar
              _buildSearchInput(),

              SizedBox(height: 24.h),

              // Search Button
              _buildSearchButton(),
              
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 220.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        image: DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15)],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 10, right: 10,
            child: GestureDetector(
              onTap: () => setState(() => _selectedImage = null),
              child: const CircleAvatar(backgroundColor: Colors.red, radius: 15, child: Icon(Icons.close, color: Colors.white, size: 18)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShagyLogo() {
    return Container(
      height: 150.r,
      width: 150.r,
      decoration: BoxDecoration(
        color: AppColors.primaryBlueSoft, 
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
        image: const DecorationImage(
          image: AssetImage(AppImages.shagyLogo),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildSearchInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: [BoxShadow(color: AppColors.shadowColor.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Enter clinical symptoms...",
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(Icons.add_a_photo, color: AppColors.primaryBlue),
            onPressed: () => _showImageSourcePicker(),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return SizedBox(
      width: double.infinity,
      height: 55.h,
      child: ElevatedButton(
        onPressed: _onSearch,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        ),
        child: Text("Analyze", style: AppTextStyles.buttonMedium.copyWith(color: Colors.white)),
      ),
    );
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFF0F7FF), child: Icon(Icons.camera_alt, color: AppColors.primaryBlue)),
              title: const Text("Open Camera"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFF0F7FF), child: Icon(Icons.photo_library, color: AppColors.primaryBlue)),
              title: const Text("Select from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
