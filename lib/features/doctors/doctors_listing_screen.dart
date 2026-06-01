import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../api/config/di/di.dart';
import '../../../core/core/utils/app_assets.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../domain/entities/user_entity.dart';
import 'cubit/doctors_listing_view_model.dart';
import 'doctor_profile_screen.dart';

class Doctor {
  final String id;
  final String name;
  final String rank;
  final String specialty;
  final String bio;
  final String image;
  final String experience;
  final String rating;
  final String reviews;
  final String clinic;
  final String location;
  final double latitude;
  final double longitude;
  final String availability;
  final List<String> education;
  final List<String> languages;
  final List<String> certifications;
  final List<String> affiliations;
  final List<String> awards;
  final List<String> researchRoles;
  bool isFavorite;
  double? distance;

  Doctor({
    required this.id,
    required this.name,
    required this.rank,
    required this.specialty,
    required this.bio,
    required this.image,
    required this.experience,
    required this.rating,
    required this.reviews,
    required this.clinic,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.availability,
    required this.education,
    required this.languages,
    required this.certifications,
    required this.affiliations,
    this.awards = const [],
    this.researchRoles = const [],
    this.isFavorite = false,
    this.distance,
  });

  factory Doctor.fromEntity(UserEntity entity, int index) {
    final name = entity.fullName ?? "Doctor";
    final ranks = ["Professor & Consultant", "Senior Specialist", "Consultant Surgeon", "Lead Orthodontist", "Clinical Director"];
    final locations = [
      {"name": "Maadi, Cairo", "lat": 29.9602, "lng": 31.2569},
      {"name": "Zamalek, Cairo", "lat": 30.0631, "lng": 31.2209},
      {"name": "Sheikh Zayed, Giza", "lat": 30.0481, "lng": 30.9936},
      {"name": "New Cairo, Cairo", "lat": 30.0299, "lng": 31.4913},
    ];
    final loc = locations[index % locations.length];

    String imagePath = "assets/images/doctor.jpg";
    if (name.toLowerCase().contains("maha") || name.toLowerCase().contains("shahd") || name.toLowerCase().contains("sara") || name.toLowerCase().contains("layla")) {
      final femaleImages = ["assets/images/doctor3.png", "assets/images/doctor4.png", "assets/images/doctor5.png"];
      imagePath = femaleImages[index % femaleImages.length];
    } else {
      final maleImages = ["assets/images/doctor.jpg", "assets/images/doctor1.png", "assets/images/doctor2.jpg", "assets/images/doctor6.jpg", "assets/images/doctor7.jpg"];
      imagePath = maleImages[index % maleImages.length];
    }
    
    // UPDATED SPECIALTY DEFAULT
    String specialty = entity.speciality ?? "Oral Surgery & Implantology";
    if (specialty.toLowerCase() == "dermatology") {
      specialty = "Oral Surgery & Implantology";
    }

    return Doctor(
      id: entity.uid,
      name: name,
      rank: ranks[index % ranks.length],
      specialty: specialty,
      bio: "Senior dental specialist dedicated to providing elite clinical care at Dentix.",
      image: imagePath,
      experience: "${10 + (index % 10)} years",
      rating: (4.5 + (index % 5) / 10).toStringAsFixed(1),
      reviews: (80 + index * 5).toString(),
      clinic: "Dentix Specialized Clinic",
      location: loc["name"] as String,
      latitude: loc["lat"] as double,
      longitude: loc["lng"] as double,
      availability: index % 2 == 0 ? "Available Today" : "Next: Mon",
      education: ["Specialized Degree in Dentistry"],
      languages: ["Arabic", "English"],
      certifications: ["Certified by Medical Board"],
      affiliations: ["Dentix Medical Network"],
    );
  }
}

class DoctorsListingScreen extends StatefulWidget {
  final bool isInsideNavbar;
  const DoctorsListingScreen({super.key, this.isInsideNavbar = false});

  @override
  State<DoctorsListingScreen> createState() => _DoctorsListingScreenState();
}

class _DoctorsListingScreenState extends State<DoctorsListingScreen> {
  final DoctorsListingViewModel _viewModel = getIt<DoctorsListingViewModel>();
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
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
          automaticallyImplyLeading: !widget.isInsideNavbar,
          leading: widget.isInsideNavbar 
              ? null 
              : IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.primaryColor),
                  onPressed: () => Navigator.pop(context),
                ),
          title: isSearching 
              ? TextField(
                  autofocus: true,
                  style: AppTextStyles.bodyLarge,
                  decoration: const InputDecoration(hintText: "Search doctor...", border: InputBorder.none),
                  onChanged: (val) => _viewModel.searchDoctors(val),
                )
              : Text("Doctors", style: AppTextStyles.titleLarge),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(isSearching ? Icons.close : Icons.search, color: AppColors.textPrimary),
              onPressed: () => setState(() {
                isSearching = !isSearching;
                if (!isSearching) _viewModel.searchDoctors('');
              }),
            ),
          ],
        ),
        body: BlocListener<DoctorsListingViewModel, DoctorsListingState>(
          listener: (context, state) {
            if (state is DoctorsListingFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: Column(
            children: [
              _buildSortAndFilterRow(context),
              Expanded(
                child: BlocBuilder<DoctorsListingViewModel, DoctorsListingState>(
                  builder: (context, state) {
                    if (state is DoctorsListingLoading) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
                    }
                    
                    final List<Doctor> currentDoctors = (state is DoctorsListingSuccess) ? state.doctors : [];

                    if (currentDoctors.isEmpty && state is DoctorsListingSuccess) {
                      return Center(child: Text("No doctors found", style: AppTextStyles.bodyMedium));
                    }

                    return ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                      physics: const BouncingScrollPhysics(),
                      itemCount: currentDoctors.length,
                      itemBuilder: (context, index) {
                        return _buildDoctorCard(context, currentDoctors[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortAndFilterRow(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 12.w),
            child: Image.asset(AppImages.dentexLogo, height: 30.h, color: AppColors.primaryBlue),
          ),
          SizedBox(width: 12.w),
          Text("Sort By", style: AppTextStyles.titleSmall),
          SizedBox(width: 12.w),
          _buildSortChip("A-Z", () => _viewModel.setSort("A-Z")),
          SizedBox(width: 8.w),
          _buildSortChip("Location", () => _viewModel.handleLocationSort()),
          SizedBox(width: 8.w),
          _buildSortChip("Favorites", () => _viewModel.setSort("Favorites")),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, VoidCallback onTap) {
    return BlocBuilder<DoctorsListingViewModel, DoctorsListingState>(
      builder: (context, state) {
        bool isSelected = _viewModel.selectedSort == label;
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryBlue : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: isSelected ? AppColors.primaryBlue : AppColors.borderSoft),
            ),
            child: Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDoctorCard(BuildContext context, Doctor doctor) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: AppColors.shadowColor, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 35.r,
            backgroundColor: AppColors.primaryBlueSoft,
            backgroundImage: AssetImage(doctor.image),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Dr. ${doctor.name}", style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                          Text(doctor.rank, style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(8.r)),
                      child: Text(
                        doctor.availability,
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 9.sp),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(doctor.specialty, style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 14.r, color: AppColors.primaryGold),
                    SizedBox(width: 4.w),
                    Expanded(child: Text(doctor.location, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary))),
                    if (doctor.distance != null)
                      Text("${doctor.distance!.toStringAsFixed(1)} km", style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    SizedBox(
                      height: 32.h,
                      width: 80.w,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => DoctorProfileScreen(doctor: doctor)));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text("Profile", style: AppTextStyles.buttonSmall),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _viewModel.toggleFavorite(doctor.id),
                      child: Icon(
                        doctor.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: doctor.isFavorite ? Colors.red : AppColors.primaryBlue,
                        size: 20.r,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
