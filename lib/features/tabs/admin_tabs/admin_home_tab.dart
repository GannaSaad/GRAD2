import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../api/config/di/di.dart';
import '../../../core/core/utils/app_assets.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_routes.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../doctors/cubit/doctors_listing_view_model.dart';
import '../../doctors/doctors_listing_screen.dart';

class AdminHomeTab extends StatefulWidget {
  const AdminHomeTab({super.key});

  @override
  State<AdminHomeTab> createState() => _AdminHomeTabState();
}

class _AdminHomeTabState extends State<AdminHomeTab> {
  // Use getIt to get the view model
  final DoctorsListingViewModel _viewModel = getIt<DoctorsListingViewModel>();
  String selectedFilter = "All";

  @override
  void initState() {
    super.initState();
    // Trigger data fetch
    _viewModel.getAllDoctors();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: _buildAppBar(),
        // Wrap in RefreshIndicator to allow manual reload if the network hangs
        body: RefreshIndicator(
          onRefresh: () async => _viewModel.getAllDoctors(),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildStatsHeader()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  child: Text("Clinic Specialities",
                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                ),
              ),
              SliverToBoxAdapter(child: _buildFilterChips()),
              // This part handles the Loading/Success/Error states
              _buildDoctorsListContent(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Image.asset(AppImages.dentexLogo, height: 40.h),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.addDoctor),
          icon: Icon(Icons.add_circle_outline, color: AppColors.primaryBlue, size: 28.r),
        ),
        SizedBox(width: 10.w),
      ],
    );
  }

  Widget _buildStatsHeader() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(24.r),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8)
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Clinic Overview", style: AppTextStyles.labelMedium.copyWith(color: Colors.white70)),
          SizedBox(height: 8.h),
          Text("Manage your elite medical team and patient flow.",
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ["All", "Oral Surgery & Implantology", "Orthadatory", "Implantologist"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.only(left: 24.w, bottom: 16.h),
      child: Row(
        children: filters.map((filter) {
          bool isSelected = selectedFilter == filter;
          return Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (val) => setState(() => selectedFilter = filter),
              selectedColor: AppColors.primaryBlue,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.bold
              ),
              backgroundColor: AppColors.cardBackground,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                  side: BorderSide(color: AppColors.borderSoft)
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDoctorsListContent() {
    return BlocBuilder<DoctorsListingViewModel, DoctorsListingState>(
      builder: (context, state) {
        if (state is DoctorsListingLoading) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is DoctorsListingSuccess) {
          final doctors = state.doctors.where((doc) {
            return selectedFilter == "All" ||
                doc.specialty.toLowerCase().contains(selectedFilter.toLowerCase());
          }).toList();

          if (doctors.isEmpty) {
            return SliverFillRemaining(
              child: Center(child: Text("No doctors found.", style: AppTextStyles.bodyMedium)),
            );
          }

          return SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildDoctorCard(doctors[index]),
                childCount: doctors.length,
              ),
            ),
          );
        }

        // If it hangs or fails, show an error with a retry button
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Connection Issue or No Data"),
                TextButton(
                    onPressed: () => _viewModel.getAllDoctors(),
                    child: const Text("Retry")
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDoctorCard(Doctor doctor) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundImage: doctor.image.isNotEmpty ? AssetImage(doctor.image) : null,
            child: doctor.image.isEmpty ? const Icon(Icons.person) : null,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Dr. ${doctor.name}", style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                Text(doctor.specialty,
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16.r, color: AppColors.grayColor),
        ],
      ),
    );
  }
}