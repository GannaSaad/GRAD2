import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../api/config/di/di.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_routes.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../domain/entities/user_entity.dart';
import 'cubit/admin_home_view_model.dart';

class AdminHomeTab extends StatefulWidget {
  const AdminHomeTab({super.key});

  @override
  State<AdminHomeTab> createState() => _AdminHomeTabState();
}

class _AdminHomeTabState extends State<AdminHomeTab> {
  late AdminHomeViewModel _viewModel;
  String searchQuery = '';
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<AdminHomeViewModel>();
    _viewModel.getAllDoctors();
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
          title: Text("Admin Dashboard", style: AppTextStyles.titleLarge.copyWith(color: AppColors.primaryBlue)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add_alt_1_outlined, color: AppColors.primaryBlue),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.addDoctor);
              },
            ),
          ],
        ),
        body: Column(
          children: [
            _buildSearchAndFilter(),
            Expanded(
              child: BlocBuilder<AdminHomeViewModel, AdminHomeState>(
                builder: (context, state) {
                  if (state is AdminHomeLoading) return const Center(child: CircularProgressIndicator());
                  if (state is AdminHomeFailure) return Center(child: Text(state.message));
                  
                  List<UserEntity> doctors = [];
                  if (state is AdminHomeSuccess) {
                    doctors = state.doctors.where((doc) {
                      bool matchesSearch = doc.fullName?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false;
                      bool matchesFilter = selectedFilter == 'All' || (doc.speciality?.toLowerCase() == selectedFilter.toLowerCase());
                      return matchesSearch && matchesFilter;
                    }).toList();
                  }

                  if (doctors.isEmpty) {
                    return Center(child: Text("No doctors found matching criteria", style: AppTextStyles.bodyMedium));
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    physics: const BouncingScrollPhysics(),
                    itemCount: doctors.length,
                    itemBuilder: (context, index) => _buildAdminDoctorCard(doctors[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Column(
        children: [
          TextField(
            onChanged: (val) => setState(() => searchQuery = val),
            decoration: InputDecoration(
              hintText: "Search by name or specialty...",
              prefixIcon: const Icon(Icons.search, color: AppColors.primaryBlue),
              filled: true,
              fillColor: AppColors.cardBackground,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
            ),
          ),
          SizedBox(height: 12.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ["All", "Implantology", "Dermatology", "Endocrinology"].map((filter) {
                bool isSelected = selectedFilter == filter;
                return GestureDetector(
                  onTap: () => setState(() => selectedFilter = filter),
                  child: Container(
                    margin: EdgeInsets.only(right: 8.w),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryBlue : AppColors.primaryBlueSoft,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(filter, style: AppTextStyles.labelSmall.copyWith(color: isSelected ? Colors.white : AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminDoctorCard(UserEntity doctor) {
    final String initials = (doctor.fullName ?? "?").trim().split(' ').map((l) => l[0]).take(2).join().toUpperCase();

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: AppColors.shadowColor, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30.r,
                backgroundColor: AppColors.primaryBlueSoft,
                child: Text(initials, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctor.fullName ?? "Unnamed", style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                    Text("${doctor.speciality ?? 'Specialist'} • Cairo", style: AppTextStyles.bodySmall),
                    SizedBox(height: 4.h),
                    Text("Staff Sync Enabled", style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryBlue)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.adminDoctorDetail, arguments: {
                      'name': doctor.fullName ?? 'Unknown Doctor',
                      'field': doctor.speciality ?? 'General Dentist',
                      'location': 'Maadi, Cairo',
                      'patients': '0',
                      'image': 'assets/images/doctor.jpg'
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    side: const BorderSide(color: AppColors.primaryBlue),
                  ),
                  child: Text("View Details", style: AppTextStyles.buttonSmall.copyWith(color: AppColors.primaryBlue)),
                ),
              ),
              SizedBox(width: 12.w),
              IconButton(
                onPressed: () {
                  _showDeleteConfirm(context, doctor.fullName ?? "this doctor", doctor.uid);
                },
                icon: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12.r)),
                  child: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, String name, String uid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Doctor"),
        content: Text("Are you sure you want to remove Dr. $name from the clinic system? This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              _viewModel.deleteDoctor(uid);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Doctor record deleted."), backgroundColor: Colors.red),
              );
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
