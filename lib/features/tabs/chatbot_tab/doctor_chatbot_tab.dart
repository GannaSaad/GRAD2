import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../api/config/di/di.dart';
import '../../../api/web_services.dart';
import '../../../api/models/doctor_clinical_response.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../core/core/utils/app_assets.dart';

class DoctorChatBotTab extends StatefulWidget {
  const DoctorChatBotTab({super.key});

  @override
  State<DoctorChatBotTab> createState() => _DoctorChatBotTabState();
}

class _DoctorChatBotTabState extends State<DoctorChatBotTab> {
  final TextEditingController _searchController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String? _analysisResult;

  final WebServices _webServices = getIt<WebServices>();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _analysisResult = null;
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _onSearch() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload a clinical image first")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _analysisResult = null;
    });

    try {
      final response = await _webServices.doctorChatWithImage(
        _selectedImage!,
        _searchController.text.isEmpty ? "Analyze this image" : _searchController.text,
      );

      if (mounted) {
        setState(() {
          if (response.status == "error") {
            _analysisResult = "AI Error: ${response.error ?? 'Unknown failure'}";
          } else {
            _analysisResult = response.answer ?? "Analysis complete, but no report was generated.";
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Dio Error: $e");
      if (mounted) {
        setState(() {
          _analysisResult = "Connection Error: Failed to reach the AI server. Ensure your backend is live.";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: Text("Clinical AI", style: AppTextStyles.medium18White.copyWith(color: AppColors.primaryBlue)),
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
              SizedBox(height: 20.h),
              
              if (_selectedImage != null)
                _buildImagePreview()
              else
                _buildShagyLogo(),

              SizedBox(height: 32.h),
              
              Text("Shagy Diagnostic Assistant", style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
              SizedBox(height: 12.h),
              Text("Upload clinical photos for pathology analysis.", textAlign: TextAlign.center, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              
              SizedBox(height: 30.h),

              _buildSearchInput(),

              SizedBox(height: 20.h),

              _buildAnalyzeButton(),
              
              if (_isLoading)
                Padding(
                  padding: EdgeInsets.only(top: 20.h),
                  child: const CircularProgressIndicator(color: AppColors.primaryBlue),
                ),

              if (_analysisResult != null)
                _buildAnalysisResult(),

              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisResult() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 30.h),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2)),
        boxShadow: [BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.05), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
              SizedBox(width: 8.w),
              Text("Shagy Clinical Report", 
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)
              ),
            ],
          ),
          const Divider(height: 24),
          Text(_analysisResult!, style: AppTextStyles.bodyMedium.copyWith(height: 1.5)),
        ],
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15)],
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
            color: AppColors.shadowColor.withValues(alpha: 0.05),
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
        boxShadow: [BoxShadow(color: AppColors.shadowColor.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Add clinical symptoms/notes...",
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(Icons.add_a_photo, color: AppColors.primaryBlue),
            onPressed: () => _showImageSourcePicker(),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return SizedBox(
      width: double.infinity,
      height: 55.h,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _onSearch,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        ),
        child: Text(_isLoading ? "Analyzing..." : "Start Analysis", 
          style: AppTextStyles.buttonMedium.copyWith(color: Colors.white)
        ),
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
              title: const Text("Capture Photo"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFF0F7FF), child: Icon(Icons.photo_library, color: AppColors.primaryBlue)),
              title: const Text("Pick from Gallery"),
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
