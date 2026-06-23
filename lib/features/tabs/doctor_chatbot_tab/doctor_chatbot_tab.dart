import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../api/config/di/di.dart';
import '../../../api/web_services.dart';
import '../../../core/core/utils/app_assets.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';

class DoctorChatBotTab extends StatefulWidget {
  const DoctorChatBotTab({super.key});

  @override
  State<DoctorChatBotTab> createState() => _DoctorChatBotTabState();
}

class _DoctorChatBotTabState extends State<DoctorChatBotTab> with TickerProviderStateMixin {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  final List<Map<String, dynamic>> _messages = [];
  
  bool _isTyping = false;
  bool _showWelcome = true;
  File? _selectedImage;
  final WebServices _webServices = getIt<WebServices>();

  final List<Map<String, dynamic>> _quickActions = [
    {"icon": Icons.description_outlined, "text": "Diagnosis help", "query": "Help me with diagnosis"},
    {"icon": Icons.medical_services, "text": "Treatment plan", "query": "Suggest treatment plan"},
    {"icon": Icons.science, "text": "Clinical decision", "query": "Clinical guidelines"},
    {"icon": Icons.image_search, "text": "Image analysis", "isImage": true},
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _messages.add({
            "role": "doctor_ai",
            "content": "Hello Doctor! I'm Dr. Shagy, your AI clinical assistant. I can help you with clinical decisions, treatment planning, and image analysis. How can I assist you today? 🩺",
            "type": "text"
          });
          _showWelcome = false;
        });
        _scrollToBottom();
      }
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar("Failed to pick image: $e");
    }
  }

  Future<void> _sendMessage([String? textOverride]) async {
    final text = textOverride ?? _chatController.text.trim();
    
    // Text-only message
    if (_selectedImage == null) {
      if (text.isEmpty) return;

      setState(() {
        _messages.add({"role": "user", "content": text, "type": "text"});
        if (textOverride == null) _chatController.clear();
        _isTyping = true;
      });

      _scrollToBottom();

      try {
        final response = await _webServices.getDoctorReply({
          "message": text,
          "history": []
        });
        
        if (mounted) {
          setState(() {
            _messages.add({
              "role": "doctor_ai",
              "content": response.response,
              "type": "text",
              "model": response.model ?? "unknown"
            });
            _isTyping = false;
          });
          _scrollToBottom();
        }
      } catch (e) {
        print("❌ Doctor chat error: $e");
        if (mounted) {
          setState(() {
            _messages.add({
              "role": "doctor_ai",
              "content": "I apologize, but I'm having trouble processing your request right now. Please try again in a moment.",
              "type": "text"
            });
            _isTyping = false;
          });
          _scrollToBottom();
        }
      }
    } 
    // Image + optional text message
    else {
      setState(() {
        _messages.add({
          "role": "user",
          "content": text.isEmpty ? "Analyze this image" : text,
          "type": "image",
          "image": _selectedImage
        });
        if (textOverride == null) _chatController.clear();
        _isTyping = true;
      });

      _scrollToBottom();

      try {
        final response = await _webServices.doctorChatWithImage(
          _selectedImage!,
          text.isEmpty ? null : text,
        );
        
        if (mounted) {
          setState(() {
            _messages.add({
              "role": "doctor_ai",
              "content": response.response,
              "type": "text",
              "model": response.model ?? "gemini"
            });
            _isTyping = false;
            _selectedImage = null;
          });
          _scrollToBottom();
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _messages.add({
              "role": "doctor_ai",
              "content": "I apologize, but I'm having trouble analyzing the image right now. Please try again in a moment.",
              "type": "text"
            });
            _isTyping = false;
            _selectedImage = null;
          });
          _scrollToBottom();
        }
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryBlueSoft.withOpacity(0.1),
              AppColors.backgroundPrimary,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAdvancedAppBar(),
              Expanded(
                child: _showWelcome 
                    ? _buildWelcomeScreen()
                    : _buildChatList(),
              ),
              _buildAdvancedInputSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancedAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 45.r,
            width: 45.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primaryBlue, AppColors.primaryBlue.withOpacity(0.7)],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(3.r),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(AppImages.shagyLogo),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dr. Shagy",
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8.r,
                      height: 8.r,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      "AI Assistant • Online",
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.primaryBlueSoft.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.info_outline,
              color: AppColors.primaryBlue,
              size: 20.r,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120.r,
            height: 120.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primaryBlue, AppColors.primaryBlue.withOpacity(0.6)],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.4),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 30.h),
          Text(
            "Initializing Dr. Shagy...",
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      physics: const BouncingScrollPhysics(),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length) {
          return _buildAdvancedTypingIndicator();
        }
        return _buildAdvancedChatBubble(_messages[index], index);
      },
    );
  }

  Widget _buildAdvancedTypingIndicator() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 16.r,
            backgroundImage: AssetImage(AppImages.shagyLogo),
          ),
          SizedBox(width: 12.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryBlueSoft.withOpacity(0.3),
                  AppColors.primaryBlueSoft.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
                bottomRight: Radius.circular(20.r),
                bottomLeft: Radius.circular(4.r),
              ),
              border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                SizedBox(width: 6.w),
                _buildDot(1),
                SizedBox(width: 6.w),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + (index * 200)),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -5 * (0.5 - (value - 0.5).abs()) * 2),
          child: Container(
            width: 8.r,
            height: 8.r,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.3 + (value * 0.7)),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdvancedChatBubble(Map<String, dynamic> message, int index) {
    bool isDoctor = message["role"] == "doctor_ai";
    bool hasImage = message["type"] == "image" && message["image"] != null;
    
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 300),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onLongPress: () {
          HapticFeedback.mediumImpact();
          Clipboard.setData(ClipboardData(text: message["content"]!));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12.w),
                  const Text("Copied to clipboard!"),
                ],
              ),
              backgroundColor: AppColors.primaryBlue,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Row(
            mainAxisAlignment: isDoctor ? MainAxisAlignment.start : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isDoctor) ...[
                CircleAvatar(
                  radius: 16.r,
                  backgroundImage: AssetImage(AppImages.shagyLogo),
                  backgroundColor: AppColors.primaryBlueSoft,
                ),
                SizedBox(width: 12.w),
              ],
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    gradient: isDoctor
                        ? LinearGradient(
                            colors: [Colors.white, AppColors.primaryBlueSoft.withOpacity(0.1)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [AppColors.primaryBlue, AppColors.primaryBlue.withOpacity(0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isDoctor ? 20.r : 20.r),
                      topRight: Radius.circular(20.r),
                      bottomLeft: Radius.circular(isDoctor ? 4.r : 20.r),
                      bottomRight: Radius.circular(isDoctor ? 20.r : 4.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isDoctor ? Colors.black : AppColors.primaryBlue).withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      )
                    ],
                    border: isDoctor ? Border.all(color: AppColors.borderSoft.withOpacity(0.5)) : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasImage) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.file(
                            message["image"],
                            height: 200.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 8.h),
                      ],
                      Text(
                        message["content"]!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDoctor ? AppColors.textPrimary : Colors.white,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isDoctor) SizedBox(width: 12.w),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancedInputSection() {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 12.h,
        top: 16.h,
        left: 20.w,
        right: 20.w,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quick action chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _quickActions.map((action) => _buildQuickActionChip(action)).toList(),
            ),
          ),
          SizedBox(height: 16.h),
          
          // Selected image preview
          if (_selectedImage != null) ...[
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.file(
                    _selectedImage!,
                    height: 120.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, color: Colors.white, size: 16.r),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
          ],
          
          // Input field with advanced design
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundPrimary,
                    borderRadius: BorderRadius.circular(25.r),
                    border: Border.all(
                      color: AppColors.primaryBlue.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _chatController,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: _selectedImage != null 
                                ? "Ask about this image..."
                                : "Ask clinical questions...",
                            hintStyle: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textTertiary,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 14.h,
                            ),
                          ),
                          style: AppTextStyles.bodyMedium,
                          enabled: !_isTyping,
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlueSoft.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.image, color: AppColors.primaryBlue),
                            onPressed: _pickImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // Advanced send button
              GestureDetector(
                onTap: _isTyping ? null : () => _sendMessage(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 56.r,
                  height: 56.r,
                  decoration: BoxDecoration(
                    gradient: _isTyping
                        ? LinearGradient(
                            colors: [AppColors.grayColor, AppColors.grayColor.withOpacity(0.8)],
                          )
                        : LinearGradient(
                            colors: [AppColors.primaryBlue, AppColors.primaryBlue.withOpacity(0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    shape: BoxShape.circle,
                    boxShadow: _isTyping
                        ? []
                        : [
                            BoxShadow(
                              color: AppColors.primaryBlue.withOpacity(0.4),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                  ),
                  child: Icon(
                    _isTyping ? Icons.hourglass_empty_rounded : Icons.send_rounded,
                    color: Colors.white,
                    size: 24.r,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionChip(Map<String, dynamic> action) {
    final bool isImageAction = action["isImage"] == true;
    
    return Padding(
      padding: EdgeInsets.only(right: 10.w),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          if (isImageAction) {
            _pickImage();
          } else {
            _sendMessage(action["query"]);
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryBlueSoft.withOpacity(0.4),
                AppColors.primaryBlueSoft.withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: AppColors.primaryBlue.withOpacity(0.15),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                action["icon"],
                size: 18.r,
                color: AppColors.primaryBlue,
              ),
              SizedBox(width: 8.w),
              Text(
                action["text"],
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
