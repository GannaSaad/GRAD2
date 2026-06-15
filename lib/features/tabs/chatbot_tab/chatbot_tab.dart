import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../api/config/di/di.dart';
import '../../../api/web_services.dart';
import '../../../core/core/utils/app_assets.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';

class ChatBotTab extends StatefulWidget {
  const ChatBotTab({super.key});

  @override
  State<ChatBotTab> createState() => _ChatBotTabState();
}

class _ChatBotTabState extends State<ChatBotTab> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // --- 🌐 LOCAL CONNECTION SETTINGS ---
  bool _isLocalMode = true; 
  String _localIp = "10.5.163.132"; // Your backend laptop IP
  String _port = "8000"; 
  // ------------------------------------

  final List<Map<String, String>> _messages = [
    {
      "role": "shagy",
      "content": "Hello! I am Dr. Shagy. I am now connected to your laptop! How can I help you today? ✨"
    }
  ];
  
  bool _isTyping = false;
  final WebServices _cloudWebServices = getIt<WebServices>();

  final List<String> _recommendedQuestions = [
    "How to whiten teeth?",
    "Bleeding gums help",
    "Best brushing habits",
    "Tooth sensitivity tips"
  ];

  WebServices get _activeWebServices {
    if (_isLocalMode && _localIp.isNotEmpty) {
      String baseUrl = _localIp;
      if (!baseUrl.startsWith("http")) {
        baseUrl = "http://$baseUrl:$_port/";
      }
      if (!baseUrl.endsWith("/")) baseUrl += "/";
      return WebServices(getIt<Dio>(), baseUrl: baseUrl);
    }
    return _cloudWebServices;
  }

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
      final response = await _activeWebServices.getShagyReply({"message": text});
      
      if (mounted) {
        setState(() {
          _messages.add({"role": "shagy", "content": response.reply});
          _isTyping = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        String finalAnswer = "";
        
        if (e is DioException) {
          if (e.response != null) {
            finalAnswer = "Parsing Error! 🚨\n\nYour laptop sent data, but I couldn't read it.\n\nRAW DATA: ${e.response?.data}\n\nFIX: Ensure Python returns {'reply': 'text'}";
          } else {
            finalAnswer = "Connection Failed 🚨\n\nCheck:\n1. Same Wi-Fi?\n2. Did you run with --host 0.0.0.0?\n3. Firewall OFF?";
          }
        } else {
          finalAnswer = "Unexpected Error: $e";
        }

        setState(() {
          _messages.add({"role": "shagy", "content": finalAnswer});
          _isTyping = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _showConnectionSettings() {
    final ipController = TextEditingController(text: _localIp);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
          title: Text("Advanced AI Settings", style: AppTextStyles.titleMedium),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text("Use Local Model"),
                value: _isLocalMode,
                activeColor: AppColors.primaryBlue,
                onChanged: (val) => setDialogState(() => _isLocalMode = val),
              ),
              if (_isLocalMode) ...[
                SizedBox(height: 10.h),
                TextField(
                  controller: ipController,
                  decoration: InputDecoration(
                    labelText: "Laptop IP",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _localIp = ipController.text.trim();
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r))),
              child: const Text("Save"),
            ),
          ],
        ),
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
      appBar: AppBar(
        title: GestureDetector(
          onTap: _showConnectionSettings, 
          child: Row(
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
              Text("Dentix Shagy", style: AppTextStyles.titleMedium.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
              if (_isLocalMode) ...[
                SizedBox(width: 6.w),
                const Icon(Icons.lan_outlined, size: 16, color: Colors.orange),
              ],
            ],
          ),
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
