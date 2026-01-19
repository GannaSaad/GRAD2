import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';

class SupportTicket {
  final String id;
  final String doctorName;
  final String category;
  final String subject;
  final String status; // 'Pending', 'In Progress', 'Resolved'
  final String date;

  SupportTicket({
    required this.id,
    required this.doctorName,
    required this.category,
    required this.subject,
    required this.status,
    required this.date,
  });
}

class DoctorSupportTab extends StatefulWidget {
  const DoctorSupportTab({super.key});

  @override
  State<DoctorSupportTab> createState() => _DoctorSupportTabState();
}

class _DoctorSupportTabState extends State<DoctorSupportTab> {
  final List<SupportTicket> _tickets = [
    SupportTicket(
      id: "TKT-1024",
      doctorName: "Dr. Hazem EL Beltagy",
      category: "Technical",
      subject: "Calendar sync issue with external website",
      status: "Pending",
      date: "24 Dec 2024",
    ),
    SupportTicket(
      id: "TKT-1025",
      doctorName: "Dr. Mohamed Hamdy",
      category: "Operational",
      subject: "Request for new dental mirror stock approval",
      status: "In Progress",
      date: "23 Dec 2024",
    ),
    SupportTicket(
      id: "TKT-1026",
      doctorName: "Dr. Samia Abu Zeed",
      category: "Billing",
      subject: "Incorrect patient insurance deduction",
      status: "Resolved",
      date: "22 Dec 2024",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Doctor Support", style: AppTextStyles.titleLarge.copyWith(color: AppColors.primaryBlue)),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(20.r),
        physics: const BouncingScrollPhysics(),
        itemCount: _tickets.length,
        itemBuilder: (context, index) {
          return _buildTicketCard(_tickets[index]);
        },
      ),
    );
  }

  Widget _buildTicketCard(SupportTicket ticket) {
    Color statusColor;
    switch (ticket.status) {
      case 'Pending': statusColor = AppColors.warning; break;
      case 'In Progress': statusColor = AppColors.primaryBlue; break;
      case 'Resolved': statusColor = AppColors.success; break;
      default: statusColor = AppColors.textSecondary;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: AppColors.shadowColor, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(ticket.id, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary, fontWeight: FontWeight.bold)),
              _buildStatusBadge(ticket.status, statusColor),
            ],
          ),
          SizedBox(height: 12.h),
          Text(ticket.doctorName, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
          Text(ticket.category, style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          Text(ticket.subject, style: AppTextStyles.bodyMedium),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(ticket.date, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
              ElevatedButton(
                onPressed: () => _showRespondDialog(ticket),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                ),
                child: Text("View & Respond", style: AppTextStyles.buttonSmall),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        status,
        style: AppTextStyles.labelSmall.copyWith(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showRespondDialog(SupportTicket ticket) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30.r))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Responding to ${ticket.id}", style: AppTextStyles.titleLarge),
              SizedBox(height: 8.h),
              Text("From: ${ticket.doctorName}", style: AppTextStyles.bodySmall),
              SizedBox(height: 24.h),
              TextField(
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Enter your response here...",
                  filled: true,
                  fillColor: AppColors.backgroundPrimary,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: const Text("Dismiss"),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Response sent successfully!")));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: const Text("Send Response"),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
