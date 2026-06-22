import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../api/config/di/di.dart';
import '../../../api/web_services.dart';
import '../../../core/core/utils/app_assets.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatBotTab extends StatefulWidget {
  const ChatBotTab({super.key});

  @override
  State<ChatBotTab> createState() => _ChatBotTabState();
}

class _ChatBotTabState extends State<ChatBotTab> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> _messages = [
    {
      "role": "shagy",
      "content": "Hello! I am Dr. Shagy, your AI dental assistant. How can I help you today? ✨"
    }
  ];
  
  bool _isTyping = false;
  final WebServices _webServices = getIt<WebServices>();

  final List<String> _recommendedQuestions = [
    "How to whiten teeth?",
    "Bleeding gums help",
    "Best brushing habits",
    "Tooth sensitivity tips"
  ];

  Future<void> _sendMessage([String? textOverride]) async {
    final text = textOverride ?? _chatController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "content": text});
      if (textOverride == null) _chatController.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    try {
      final user = FirebaseAuth.instance.currentUser;
      final body = {
        "message": text,
        "patient_id": user?.uid ?? "",
        "patient_name": user?.displayName ?? "Mobile Patient",
      };

      debugPrint("🔥 CHATBOT BODY = $body");

      final response = await _webServices.getShagyReply(body);
      if (mounted) {
        setState(() {
          _messages.add({"role": "shagy", "content": response.reply});
          _isTyping = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            "role": "shagy",
            "content": "Sorry, I'm having trouble connecting right now. Please try again later."
          });
          _isTyping = false;
        });
        _scrollToBottom();
      }
    }
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
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 32.r,
              width: 32.r,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage(AppImages.shagyLogo),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              "Dentix Shagy",
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white.withValues(alpha: 0.8),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              physics: const BouncingScrollPhysics(),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return _buildTypingIndicator();
                }
                return _buildChatBubble(_messages[index]);
              },
            ),
          ),
          _buildChatInputSection(),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.primaryBlueSoft.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Shagy is thinking", style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryBlue)),
            SizedBox(width: 8.w),
            SizedBox(
              height: 12.h,
              width: 12.w,
              child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(Map<String, String> message) {
    bool isShagy = message["role"] == "shagy";
    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: message["content"]!));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied to clipboard!"), duration: Duration(seconds: 1)));
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: Row(
          mainAxisAlignment: isShagy ? MainAxisAlignment.start : MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isShagy) ...[
              CircleAvatar(
                radius: 16.r,
                backgroundImage: const AssetImage(AppImages.shagyLogo),
                backgroundColor: AppColors.primaryBlueSoft,
              ),
              SizedBox(width: 8.w),
            ],
            Flexible(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isShagy ? Colors.white : AppColors.primaryBlue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                    bottomLeft: Radius.circular(isShagy ? 4.r : 20.r),
                    bottomRight: Radius.circular(isShagy ? 20.r : 4.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Text(
                  message["content"]!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isShagy ? AppColors.textPrimary : Colors.white,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            if (!isShagy) SizedBox(width: 8.w),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInputSection() {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 10.h, top: 10.h, left: 16.w, right: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))
        ],
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30.r), topRight: Radius.circular(30.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _recommendedQuestions.map((q) => _buildQuestionChip(q)).toList(),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundPrimary,
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                  child: TextField(
                    controller: _chatController,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: "Ask Shagy...",
                      hintStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.textTertiary),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    ),
                    style: AppTextStyles.bodyMedium,
                    enabled: !_isTyping,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              GestureDetector(
                onTap: _isTyping ? null : () => _sendMessage(),
                child: CircleAvatar(
                  radius: 24.r,
                  backgroundColor: _isTyping ? AppColors.grayColor : AppColors.primaryBlue,
                  child: Icon(Icons.send_rounded, color: Colors.white, size: 20.r),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionChip(String question) {
    return Padding(
      padding: EdgeInsets.only(right: 10.w),
      child: GestureDetector(
        onTap: () => _sendMessage(question),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.primaryBlueSoft.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1)),
          ),
          child: Text(
            question,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
