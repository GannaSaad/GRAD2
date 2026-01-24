import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../api/config/di/di.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../domain/entities/support_ticket_entity.dart';
import 'cubit/admin_support_view_model.dart';

class DoctorSupportTab extends StatefulWidget {
  const DoctorSupportTab({super.key});

  @override
  State<DoctorSupportTab> createState() => _DoctorSupportTabState();
}

class _DoctorSupportTabState extends State<DoctorSupportTab> {
  late AdminSupportViewModel _viewModel;
  final _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<AdminSupportViewModel>();
    _viewModel.fetchTickets('doctor');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _viewModel,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text("Doctor Support", style: AppTextStyles.titleLarge.copyWith(color: AppColors.primaryBlue)),
          centerTitle: true,
        ),
        body: BlocBuilder<AdminSupportViewModel, AdminSupportState>(
          builder: (context, state) {
            if (state is AdminSupportLoading) return const Center(child: CircularProgressIndicator());
            if (state is AdminSupportFailure) return Center(child: Text(state.message));
            
            if (state is AdminSupportSuccess) {
              final tickets = state.tickets;
              if (tickets.isEmpty) {
                return Center(child: Text("No support requests from doctors.", style: AppTextStyles.bodyMedium));
              }
              return ListView.builder(
                padding: EdgeInsets.all(20.r),
                physics: const BouncingScrollPhysics(),
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  return _buildTicketCard(tickets[index]);
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildTicketCard(SupportTicketEntity ticket) {
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
              Text("ID: ${ticket.id.substring(ticket.id.length - 5).toUpperCase()}", 
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary, fontWeight: FontWeight.bold)),
              _buildStatusBadge(ticket.status, statusColor),
            ],
          ),
          SizedBox(height: 12.h),
          Text(ticket.senderName, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
          Text("Doctor Request", style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          Text(ticket.message, style: AppTextStyles.bodyMedium),
          if (ticket.reply != null) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppColors.primaryBlueSoft,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Admin Reply:", style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                  SizedBox(height: 4.h),
                  Text(ticket.reply!, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
          ],
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(DateFormat('dd MMM yyyy').format(ticket.createdAt), 
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
              Row(
                children: [
                  if (ticket.status != 'Resolved')
                    TextButton(
                      onPressed: () => _viewModel.markAsResolved(ticket.id),
                      child: Text("Mark Resolved", style: TextStyle(color: AppColors.success, fontSize: 12.sp)),
                    ),
                  SizedBox(width: 8.w),
                  ElevatedButton(
                    onPressed: () => _showRespondDialog(ticket),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    ),
                    child: Text("View & Respond", style: AppTextStyles.buttonSmall.copyWith(color: Colors.white)),
                  ),
                ],
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        status,
        style: AppTextStyles.labelSmall.copyWith(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showRespondDialog(SupportTicketEntity ticket) {
    _replyController.text = ticket.reply ?? "";
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
              Text("Responding to Doctor", style: AppTextStyles.titleLarge),
              SizedBox(height: 8.h),
              Text("From: ${ticket.senderName}", style: AppTextStyles.bodySmall),
              SizedBox(height: 24.h),
              TextField(
                controller: _replyController,
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
                        if (_replyController.text.isNotEmpty) {
                          _viewModel.respondToTicket(ticket.id, _replyController.text);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Response sent successfully!"), backgroundColor: Colors.green));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: AppColors.primaryGoldLight,
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

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }
}
