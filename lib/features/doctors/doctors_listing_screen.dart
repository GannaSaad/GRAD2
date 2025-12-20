import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';
import 'doctor_profile_screen.dart';

class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String bio;
  final String image;
  final String experience;
  final String rating;
  final String reviews;
  final String clinic;
  bool isFavorite;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.bio,
    required this.image,
    required this.experience,
    required this.rating,
    required this.reviews,
    required this.clinic,
    this.isFavorite = false,
  });
}

class DoctorsListingScreen extends StatefulWidget {
  final bool isInsideNavbar;
  const DoctorsListingScreen({super.key, this.isInsideNavbar = false});

  @override
  State<DoctorsListingScreen> createState() => _DoctorsListingScreenState();
}

class _DoctorsListingScreenState extends State<DoctorsListingScreen> {
  String selectedSort = 'Default';
  String searchQuery = '';
  bool isSearching = false;

  final List<Doctor> doctors = [
    Doctor(
      id: "1",
      name: "Dr. Hazem EL Beltagy, Ph.D.",
      specialty: "Implantology & Smile Design",
      experience: "18 years",
      rating: "4.9",
      reviews: "96",
      clinic: "Cairo University Dental Center – Cairo",
      bio: "Senior dental implant specialist with extensive experience in advanced implant procedures, bone grafting, and full-mouth rehabilitation, known for precision-driven treatment planning and long-term implant success.",
      image: "assets/images/doctor.jpg",
    ),
    Doctor(
      id: "2",
      name: "Dr. Michael Davidson, M.D.",
      specialty: "Solar Dermatology",
      experience: "14 years",
      rating: "4.8",
      reviews: "89",
      clinic: "Maadi Skin & Laser Clinic – Maadi",
      bio: "Board-certified dermatologist focused on skin health, sun damage prevention, and treatment of pigment disorders, with strong emphasis on patient education and long-term skin care.",
      image: "assets/images/doctor1.png",
    ),
    Doctor(
      id: "3",
      name: "Dr. Olivia Turner, M.D.",
      specialty: "Dermato-Endocrinology",
      experience: "12 years",
      rating: "4.7",
      reviews: "156",
      clinic: "Zamalek Medical Hub – Zamalek",
      bio: "Specialist in hormonal-related skin conditions including acne, hair loss, and metabolic skin disorders, combining dermatology and endocrinology for root-cause treatments.",
      image: "assets/images/doctor3.png",
    ),
    Doctor(
      id: "4",
      name: "Dr. Sophia Martinez, Ph.D.",
      specialty: "Cosmetic Bioengineering",
      experience: "10 years",
      rating: "4.8",
      reviews: "102",
      clinic: "Sheikh Zayed Aesthetic Clinic – Sheikh Zayed",
      bio: "Expert in aesthetic treatments and skin regeneration technologies, focusing on non-invasive cosmetic solutions, skin rejuvenation, and advanced bioengineered therapies.",
      image: "assets/images/doctor4.png",
    ),
    Doctor(
      id: "5",
      name: "Dr. Ahmed El-Sherif, Ph.D.",
      specialty: "Oral & Maxillofacial Surgery",
      experience: "20 years",
      rating: "4.9",
      reviews: "141",
      clinic: "Nasr City Oral Surgery Center – Nasr City",
      bio: "Highly experienced oral surgeon specializing in complex extractions, jaw surgery, and facial trauma cases, with a strong focus on precision and patient safety.",
      image: "assets/images/doctor5.png",
    ),
    Doctor(
      id: "6",
      name: "Dr. Mariam Hassan, M.D.",
      specialty: "Periodontology",
      experience: "13 years",
      rating: "4.8",
      reviews: "96",
      clinic: "Heliopolis Dental Clinic – Heliopolis",
      bio: "Gum disease specialist with extensive experience in periodontal treatments, gum surgery, and oral health preservation.",
      image: "assets/images/doctor6.jpg",
    ),
    Doctor(
      id: "7",
      name: "Dr. Youssef Abdelrahman, M.D.",
      specialty: "Prosthodontics",
      experience: "11 years",
      rating: "4.7",
      reviews: "84",
      clinic: "Dokki Advanced Dental Care – Dokki",
      bio: "Expert in crowns, bridges, veneers, and full smile rehabilitation, combining functional restoration with natural aesthetics.",
      image: "assets/images/doctor7.jpg",
    ),
    Doctor(
      id: "8",
      name: "Dr. Lina Fathy, Ph.D.",
      specialty: "Pediatric Dentistry",
      experience: "9 years",
      rating: "4.8",
      reviews: "118",
      clinic: "New Cairo Kids Dental Center – New Cairo",
      bio: "Dedicated pediatric dentist focused on preventive care and creating a comfortable, positive dental experience for children.",
      image: "assets/images/doctor3.png",
    ),
  ];

  List<Doctor> get filteredDoctors {
    List<Doctor> list = List.from(doctors);
    
    if (searchQuery.isNotEmpty) {
      list = list.where((d) => d.name.toLowerCase().contains(searchQuery.toLowerCase()) || d.specialty.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }

    if (selectedSort == 'Favorites') {
      list = list.where((d) => d.isFavorite).toList();
    }

    if (selectedSort == 'A-Z') {
      list.sort((a, b) => a.name.compareTo(b.name));
    }
    
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: !widget.isInsideNavbar,
        leading: widget.isInsideNavbar 
            ? null 
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
        title: isSearching 
            ? TextField(
                autofocus: true,
                decoration: const InputDecoration(hintText: "Search doctor...", border: InputBorder.none),
                onChanged: (val) => setState(() => searchQuery = val),
              )
            : Text("Doctors", style: AppTextStyles.titleLarge),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search, color: AppColors.textPrimary),
            onPressed: () => setState(() {
              isSearching = !isSearching;
              if (!isSearching) searchQuery = '';
            }),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSortAndFilterRow(),
          Expanded(
            child: filteredDoctors.isEmpty 
                ? Center(child: Text("No doctors found", style: AppTextStyles.bodyMedium))
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredDoctors.length,
                    itemBuilder: (context, index) {
                      return _buildDoctorCard(filteredDoctors[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortAndFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        children: [
          Text("Sort By", style: AppTextStyles.titleSmall),
          SizedBox(width: 12.w),
          _buildSortChip("A-Z"),
          SizedBox(width: 8.w),
          _buildSortChip("Location"),
          SizedBox(width: 8.w),
          _buildSortChip("Favorites"),
          SizedBox(width: 8.w),
          _buildFieldDropdown(),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label) {
    bool isSelected = selectedSort == label;
    return GestureDetector(
      onTap: () {
        if (label == "Location") {
          _requestLocationPermission();
        } else {
          setState(() {
            if (isSelected) {
              selectedSort = 'Default';
            } else {
              selectedSort = label;
            }
          });
        }
      },
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
  }

  void _requestLocationPermission() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Location Permission"),
        content: const Text("Dentix needs access to your location to find nearby doctors."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Deny")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => selectedSort = "Location");
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Location access granted!")));
            },
            child: const Text("Allow"),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldDropdown() {
    final List<String> fields = [
      "All Fields",
      "Implantology",
      "Dermatology",
      "Endocrinology",
      "Oral Surgery",
      "Periodontology",
      "Prosthodontics",
      "Pediatric"
    ];

    return PopupMenuButton<String>(
      onSelected: (String value) {
        setState(() {
          if (value == "All Fields") {
            searchQuery = '';
          } else {
            searchQuery = value;
          }
        });
      },
      itemBuilder: (BuildContext context) {
        return fields.map((String field) {
          return PopupMenuItem<String>(
            value: field,
            child: Text(field, style: AppTextStyles.labelMedium),
          );
        }).toList();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.borderSoft),
        ),
        child: Row(
          children: [
            Text("Field", style: AppTextStyles.labelMedium),
            Icon(Icons.arrow_drop_down, size: 20.r, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard(Doctor doctor) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                Text(doctor.name, style: AppTextStyles.titleMedium),
                Text(doctor.specialty, style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
                SizedBox(height: 8.h),
                Text(
                  doctor.bio,
                  style: AppTextStyles.bodySmall,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    SizedBox(
                      height: 32.h,
                      width: 80.w,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DoctorProfileScreen(doctor: doctor),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text("Info", style: AppTextStyles.buttonSmall),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _showReviewDialog(doctor),
                      child: Icon(Icons.question_answer_outlined, color: AppColors.primaryBlue, size: 20.r),
                    ),
                    SizedBox(width: 12.w),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          doctor.isFavorite = !doctor.isFavorite;
                        });
                      },
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

  void _showReviewDialog(Doctor doctor) {
    int selectedStars = 0;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
              title: Text("Rate ${doctor.name}", style: AppTextStyles.titleMedium),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < selectedStars ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 30.r,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedStars = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Add a comment (optional)",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel", style: TextStyle(color: AppColors.grayColor)),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Logic to save review
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Review submitted successfully!")),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
                  child: const Text("Submit"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
