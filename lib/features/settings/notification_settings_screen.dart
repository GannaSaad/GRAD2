import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final Map<String, bool> _settings = {
    "General Notification": true,
    "Sound": true,
    "Sound Call": false,
    "Vibrate": true,
    "Special Offers": false,
    "Payments": true,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Notification Setting", style: AppTextStyles.titleLarge.copyWith(color: AppColors.primaryColor)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: _settings.keys.map((key) {
              return _buildToggleItem(key);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleItem(String label) {
    return Column(
      children: [
        ListTile(
          title: Text(label, style: AppTextStyles.bodyLarge),
          trailing: Switch(
            value: _settings[label]!,
            onChanged: (val) {
              setState(() {
                _settings[label] = val;
              });
            },
            activeColor: AppColors.primaryColor,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        ),
        if (label != _settings.keys.last) const Divider(height: 1),
      ],
    );
  }
}
