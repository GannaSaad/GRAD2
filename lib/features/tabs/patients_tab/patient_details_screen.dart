import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../api/config/di/di.dart';
import '../../../api/web_services.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../core/widgets/advanced_voice_button.dart';
import '../../../domain/entities/medical_record_entity.dart';
import '../../../widgets/widgets/custom_elevated_button.dart';
import '../../../widgets/widgets/custom_text_form_field.dart';
import 'cubit/patient_details_view_model.dart';
import 'widgets/jaw_chart.dart';

class PatientDetailsScreen extends StatefulWidget {
  final String patientName;
  final String patientImage;

  const PatientDetailsScreen({
    super.key, 
    required this.patientName, 
    required this.patientImage,
  });

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  late PatientDetailsViewModel _viewModel;
  int? _selectedToothId;
  
  // Controllers for tooth record editing
  final _diagnosisController = TextEditingController();
  final _procedureController = TextEditingController();
  final _planController = TextEditingController();
  String _selectedStatus = "In Progress";
  
  // Image picker
  final ImagePicker _picker = ImagePicker();
  final List<File> _panoramicImages = [];
  final List<File> _intraoralImages = [];
  bool _imagesUploading = false;
  
  // Voice AI Assistant
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isListening = false;
  String _currentField = '';
  String? _audioPath;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<PatientDetailsViewModel>();
    _viewModel.getMedicalRecords(widget.patientName);
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    _procedureController.dispose();
    _planController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _loadToothData(Map<String, dynamic>? data) {
    if (data != null) {
      _diagnosisController.text = data['diagnosis'] ?? '';
      _procedureController.text = data['procedure'] ?? '';
      _planController.text = data['plan'] ?? '';
      _selectedStatus = data['status'] ?? 'In Progress';
    } else {
      _diagnosisController.clear();
      _procedureController.clear();
      _planController.clear();
      _selectedStatus = 'In Progress';
    }
  }

  Future<void> _pickImages(bool isPanoramic) async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        if (isPanoramic) {
          _panoramicImages.addAll(images.map((e) => File(e.path)));
        } else {
          _intraoralImages.addAll(images.map((e) => File(e.path)));
        }
      });
    }
  }

  Future<void> _startListening(String field) async {
    print('DEBUG: _startListening called with field: $field');
    
    try {
      // Request microphone permission
      final status = await Permission.microphone.request();
      print('DEBUG: Microphone permission status: $status');
      
      if (!status.isGranted) {
        print('DEBUG: Permission not granted');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Microphone permission is required for voice recording"),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      print('DEBUG: Starting recording...');
      // Get temporary directory for audio file
      final directory = await getTemporaryDirectory();
      _audioPath = '${directory.path}/dental_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      print('DEBUG: Audio path: $_audioPath');

      // Start recording
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _audioPath!,
      );

      setState(() {
        _isListening = true;
        _currentField = field;
      });
      print('DEBUG: Recording started successfully');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🎤 Recording started..."),
            backgroundColor: AppColors.primaryBlue,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('DEBUG: Error starting recording: $e');
      print('DEBUG: Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to start recording: $e"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _stopListening() async {
    try {
      // Stop recording
      await _audioRecorder.stop();
      
      setState(() {
        _isListening = false;
        _isProcessing = true;
      });

      if (_audioPath == null || !File(_audioPath!).existsSync()) {
        throw Exception("Audio file not found");
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Processing audio... This may take 30-60 seconds"),
            backgroundColor: AppColors.primaryBlue,
            duration: Duration(seconds: 5),
          ),
        );
      }

      // Send audio to backend with longer timeout for Whisper processing
      final webServices = getIt<WebServices>();
      print('DEBUG: Sending audio to API (port 8003)...');
      print('DEBUG: Audio file size: ${File(_audioPath!).lengthSync()} bytes');
      
      final response = await webServices.voiceToRecord(File(_audioPath!))
          .timeout(
            const Duration(seconds: 120), // 2 minutes for first-time model loading
            onTimeout: () {
              throw Exception('Request timeout after 2 minutes. The Whisper model may still be loading on first use.');
            },
          );
          
      print('DEBUG: API Response received!');
      print('DEBUG: Response: $response');
      print('DEBUG: diagnosis: ${response['diagnosis']}');
      print('DEBUG: procedure_performed: ${response['procedure_performed']}');
      print('DEBUG: treatment_plan: ${response['treatment_plan']}');

      // Parse response and fill fields
      _fillFieldsFromTranscript({
        'diagnosis': response['diagnosis'] ?? '',
        'procedure': response['procedure_performed'] ?? '',
        'plan': response['treatment_plan'] ?? '',
      });

      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Voice transcribed successfully!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }

      // Clean up audio file
      if (_audioPath != null) {
        try {
          File(_audioPath!).delete();
        } catch (e) {
          print('DEBUG: Failed to delete audio file: $e');
        }
      }
    } catch (e, stackTrace) {
      print('DEBUG: Error in _stopListening: $e');
      print('DEBUG: Stack trace: $stackTrace');
      
      setState(() {
        _isProcessing = false;
      });
      
      String errorMsg = e.toString();
      if (errorMsg.contains('Connection closed') || errorMsg.contains('SocketException')) {
        errorMsg = 'Speech-to-Text API connection failed. Service may be down.';
      } else if (errorMsg.contains('timeout') || errorMsg.contains('90 seconds')) {
        errorMsg = 'Processing is taking longer than expected. The service may be loading models or the audio is too long.';
      } else if (errorMsg.contains('404')) {
        errorMsg = 'Speech-to-Text endpoint not found on port 8003. Check if service is running.';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to process audio:\n$errorMsg"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    }
  }

  void _fillFieldsFromTranscript(Map<String, String> extractedData) {
    print('DEBUG: _fillFieldsFromTranscript called with: $extractedData');
    print('DEBUG: diagnosis isEmpty: ${extractedData['diagnosis']?.isEmpty}');
    print('DEBUG: procedure isEmpty: ${extractedData['procedure']?.isEmpty}');
    print('DEBUG: plan isEmpty: ${extractedData['plan']?.isEmpty}');
    
    setState(() {
      if (extractedData['diagnosis']?.isNotEmpty ?? false) {
        print('DEBUG: Setting diagnosis to: ${extractedData['diagnosis']}');
        _diagnosisController.text = extractedData['diagnosis']!;
      }
      if (extractedData['procedure']?.isNotEmpty ?? false) {
        print('DEBUG: Setting procedure to: ${extractedData['procedure']}');
        _procedureController.text = extractedData['procedure']!;
      }
      if (extractedData['plan']?.isNotEmpty ?? false) {
        print('DEBUG: Setting plan to: ${extractedData['plan']}');
        _planController.text = extractedData['plan']!;
      }
    });
    print('DEBUG: After setState - diagnosis controller: ${_diagnosisController.text}');
    print('DEBUG: After setState - procedure controller: ${_procedureController.text}');
    print('DEBUG: After setState - plan controller: ${_planController.text}');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _viewModel,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        body: BlocListener<PatientDetailsViewModel, PatientDetailsState>(
          listener: (context, state) {
            if (state is PatientDetailsSaveSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Tooth record updated successfully!"), backgroundColor: Colors.green),
              );
            } else if (state is PatientDetailsSuccess && _imagesUploading) {
              // Images uploaded and stream updated with new data
              setState(() {
                _panoramicImages.clear();
                _intraoralImages.clear();
                _imagesUploading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Images uploaded successfully!"), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
              );
              // Force UI rebuild to show new images
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) setState(() {});
              });
            } else if (state is PatientDetailsFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error: ${state.message}"), backgroundColor: Colors.red),
              );
              setState(() => _imagesUploading = false);
            }
          },
          child: BlocBuilder<PatientDetailsViewModel, PatientDetailsState>(
            builder: (context, state) {
              List<MedicalRecordEntity> records = [];
              if (state is PatientDetailsSuccess || state is PatientDetailsSaveSuccess) {
                records = state is PatientDetailsSuccess ? state.records : (state as PatientDetailsSaveSuccess).records;
              }

              final Map<int, Map<String, dynamic>> toothDataMap = {};
              for (var record in records) {
                if (record.toothId != null) {
                  toothDataMap[record.toothId!] = {
                    'status': record.treatmentStatus,
                    'diagnosis': record.toothDiagnosis,
                    'procedure': record.toothProcedure,
                    'plan': record.toothPlan,
                  };
                }
              }

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildSliverAppBar(context),
                  if (state is PatientDetailsLoading || state is PatientDetailsUploadingImages)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(color: AppColors.primaryBlue),
                            SizedBox(height: 16.h),
                            Text(
                              state is PatientDetailsUploadingImages ? "Uploading images..." : "Loading...",
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (state is PatientDetailsFailure)
                    SliverFillRemaining(child: Center(child: Text(state.message))),
                  if (state is PatientDetailsSuccess || state is PatientDetailsInitial || state is PatientDetailsSaveSuccess)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(20.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildQuickStats(),
                            SizedBox(height: 30.h),
                            
                            _buildSectionTitle("Medical Overview"),
                            SizedBox(height: 16.h),
                            _buildMedicalOverviewCard(),
                            
                            SizedBox(height: 30.h),
                            
                            _buildSectionTitle("X-Rays & Imaging"),
                            SizedBox(height: 16.h),
                            _buildImagingSection(records),
                            
                            SizedBox(height: 30.h),
                            
                            _buildSectionTitle("Dental Chart"),
                            SizedBox(height: 16.h),
                            JawChart(
                              selectedTooth: _selectedToothId,
                              onToothTap: (id) {
                                setState(() {
                                  _selectedToothId = id;
                                  _loadToothData(toothDataMap[id]);
                                });
                              },
                              toothData: toothDataMap,
                            ),
                            
                            if (_selectedToothId != null) ...[
                              SizedBox(height: 24.h),
                              _buildEditableToothPanel(),
                            ],
                            
                            SizedBox(height: 100.h),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200.h,
      pinned: true,
      backgroundColor: AppColors.primaryBlue,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          widget.patientName,
          style: AppTextStyles.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        background: Container(color: AppColors.primaryBlue),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatItem("Age", "28", Icons.cake_outlined),
        _buildStatItem("Gender", "Female", Icons.person_outline),
        _buildStatItem("Blood", "A+", Icons.bloodtype_outlined),
      ],
    );
  }

  Widget _buildVoiceAIAssistantCard() {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryBlue.withOpacity(0.1), AppColors.primaryBlueSoft],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.psychology, color: Colors.white, size: 24.r),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Voice AI Assistant",
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    Text(
                      _isListening 
                          ? "Listening for ${_currentField}..." 
                          : "Tap mic to dictate notes",
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (_selectedToothId != null) ...[
            SizedBox(height: 20.h),
            Text(
              "Dictate for Tooth #$_selectedToothId:",
              style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AdvancedVoiceButton(
                  label: "Diagnosis",
                  isActive: _isListening && _currentField == 'diagnosis',
                  onTap: () {
                    if (_isListening && _currentField == 'diagnosis') {
                      _stopListening();
                    } else {
                      _startListening('diagnosis');
                    }
                  },
                ),
                AdvancedVoiceButton(
                  label: "Procedure",
                  isActive: _isListening && _currentField == 'procedure',
                  onTap: () {
                    if (_isListening && _currentField == 'procedure') {
                      _stopListening();
                    } else {
                      _startListening('procedure');
                    }
                  },
                ),
                AdvancedVoiceButton(
                  label: "Plan",
                  isActive: _isListening && _currentField == 'plan',
                  onTap: () {
                    if (_isListening && _currentField == 'plan') {
                      _stopListening();
                    } else {
                      _startListening('plan');
                    }
                  },
                ),
              ],
            ),
          ] else ...[
            SizedBox(height: 16.h),
            Center(
              child: Text(
                "Select a tooth from the dental chart to use voice dictation",
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      width: 110.w,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 20.r),
          SizedBox(height: 8.h),
          Text(value, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold)),
          Text(label, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary));
  }

  Widget _buildMedicalOverviewCard() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        children: [
          _buildOverviewRow("Allergies", "Penicillin", Colors.red),
          const Divider(height: 24),
          _buildOverviewRow("Condition", "Healthy", Colors.green),
        ],
      ),
    );
  }

  Widget _buildOverviewRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        Text(value, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildImagingSection(List<MedicalRecordEntity> records) {
    // Separate panoramic and intraoral images
    final List<String> panoramicImages = [];
    final List<String> intraoralImages = [];
    
    for (var record in records) {
      if (record.panoramicImages != null) panoramicImages.addAll(record.panoramicImages!);
      if (record.intraoralImages != null) intraoralImages.addAll(record.intraoralImages!);
    }
    
    print('DEBUG: Total records: ${records.length}');
    print('DEBUG: Panoramic images: ${panoramicImages.length}');
    print('DEBUG: Intraoral images: ${intraoralImages.length}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Upload buttons
        Row(
          children: [
            Expanded(
              child: _buildUploadButton(
                label: "Upload Panoramic",
                icon: Icons.panorama_horizontal_select,
                onTap: () => _pickImages(true),
                count: _panoramicImages.length,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildUploadButton(
                label: "Upload Intraoral",
                icon: Icons.center_focus_strong_outlined,
                onTap: () => _pickImages(false),
                count: _intraoralImages.length,
              ),
            ),
          ],
        ),
        
        // Show selected images preview
        if (_panoramicImages.isNotEmpty || _intraoralImages.isNotEmpty) ...[
          SizedBox(height: 16.h),
          _buildSelectedImagesPreview(),
          SizedBox(height: 16.h),
          CustomElevatedButton(
            buttonText: "Upload Images (${_panoramicImages.length + _intraoralImages.length})",
            onPressed: () {
              setState(() => _imagesUploading = true);
              _viewModel.uploadImages(
                patientName: widget.patientName,
                panoramicImages: _panoramicImages.isEmpty ? null : _panoramicImages,
                intraoralImages: _intraoralImages.isEmpty ? null : _intraoralImages,
              );
            },
            backgroundColor: AppColors.primaryBlue,
          ),
        ],
        
        SizedBox(height: 24.h),
        
        // Panoramic X-Rays Section
        _buildImageCategorySection(
          title: "Panoramic X-Rays",
          icon: Icons.panorama_horizontal_select,
          images: panoramicImages,
          emptyMessage: "No panoramic X-rays uploaded yet",
        ),
        
        SizedBox(height: 24.h),
        
        // Intraoral Images Section
        _buildImageCategorySection(
          title: "Intraoral Images",
          icon: Icons.center_focus_strong_outlined,
          images: intraoralImages,
          emptyMessage: "No intraoral images uploaded yet",
        ),
      ],
    );
  }

  Widget _buildImageCategorySection({
    required String title,
    required IconData icon,
    required List<String> images,
    required String emptyMessage,
  }) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: AppColors.primaryBlue, size: 20.r),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    "${images.length} ${images.length == 1 ? 'image' : 'images'}",
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // Images grid or empty state
          if (images.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Column(
                  children: [
                    Icon(
                      icon,
                      size: 48.r,
                      color: AppColors.textSecondary.withOpacity(0.3),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      emptyMessage,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            _buildImagingGrid(images),
        ],
      ),
    );
  }

  Widget _buildUploadButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required int count,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: count > 0 ? AppColors.primaryBlueSoft : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: count > 0 ? AppColors.primaryBlue : AppColors.borderSoft),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 24.r),
            SizedBox(height: 8.h),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (count > 0) ...[
              SizedBox(height: 4.h),
              Text(
                "$count selected",
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedImagesPreview() {
    final allSelected = [..._panoramicImages, ..._intraoralImages];
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Selected Images (${allSelected.length})",
            style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 80.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: allSelected.length,
              itemBuilder: (context, index) {
                final isPanoramic = index < _panoramicImages.length;
                final file = allSelected[index];
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.file(file, width: 80.w, height: 80.h, fit: BoxFit.cover),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isPanoramic) {
                                _panoramicImages.removeAt(index);
                              } else {
                                _intraoralImages.removeAt(index - _panoramicImages.length);
                              }
                            });
                          },
                          child: Container(
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            child: Icon(Icons.close, size: 18.r, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagingGrid(List<String> allImages) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: allImages.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12.r,
        crossAxisSpacing: 12.r,
      ),
      itemBuilder: (context, index) => _buildActualImageTile(allImages[index]),
    );
  }

  Widget _buildActualImageTile(String url) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
    );
  }

  Widget _buildEditableToothPanel() {
    Color statusColor = _selectedStatus == 'Completed' ? Colors.green : Colors.red;

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Tooth #$_selectedToothId Details",
                style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  _selectedStatus,
                  style: AppTextStyles.labelSmall.copyWith(color: statusColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          
          Text("Treatment Status", style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildStatusChip("In Progress", Colors.red),
              SizedBox(width: 12.w),
              _buildStatusChip("Completed", Colors.green),
            ],
          ),
          
          SizedBox(height: 20.h),
          Text("Diagnosis", style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          CustomTextFormField(
            hintText: "Enter tooth diagnosis",
            controller: _diagnosisController,
            prefixIcon: const Icon(Icons.assignment_outlined),
          ),
          
          SizedBox(height: 16.h),
          Text("Procedure Performed", style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          CustomTextFormField(
            hintText: "Enter procedure performed",
            controller: _procedureController,
            prefixIcon: const Icon(Icons.medical_services_outlined),
          ),
          
          SizedBox(height: 16.h),
          Text("Treatment Plan", style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          CustomTextFormField(
            hintText: "Enter treatment plan",
            controller: _planController,
            prefixIcon: const Icon(Icons.next_plan_outlined),
          ),
          
          SizedBox(height: 24.h),
          
          // Single Voice Dictation Button
          _buildSingleVoiceDictationButton(),
          
          SizedBox(height: 16.h),
          CustomElevatedButton(
            buttonText: "Save Tooth Record",
            onPressed: () {
              if (_diagnosisController.text.isEmpty && _procedureController.text.isEmpty && _planController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill at least one field"), backgroundColor: Colors.orange),
                );
                return;
              }
              _viewModel.updateToothRecord(
                patientName: widget.patientName,
                toothId: _selectedToothId!,
                diagnosis: _diagnosisController.text,
                procedure: _procedureController.text,
                plan: _planController.text,
                status: _selectedStatus,
              );
            },
            backgroundColor: AppColors.primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildSingleVoiceDictationButton() {
    final isActive = _isListening || _isProcessing;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                  offset: const Offset(0, 4),
                )
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                )
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (_isListening) {
              _stopListening();
            } else {
              _startListening('recording');
            }
          },
          borderRadius: BorderRadius.circular(20.r),
          child: Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              gradient: _isListening
                  ? LinearGradient(
                      colors: [
                        AppColors.primaryBlue,
                        AppColors.primaryBlue.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [
                        Colors.white,
                        AppColors.primaryBlueSoft.withOpacity(0.3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: _isListening 
                    ? Colors.white.withOpacity(0.3)
                    : AppColors.primaryBlue.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                // Top section with icon and title
                Row(
                  children: [
                    // Animated mic icon with ripple effect
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer ripple
                        if (_isListening)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 1000),
                            width: 80.r,
                            height: 80.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        // Middle ripple
                        if (_isListening)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 800),
                            width: 65.r,
                            height: 65.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.15),
                            ),
                          ),
                        // Inner circle
                        Container(
                          width: 50.r,
                          height: 50.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: _isListening
                                ? LinearGradient(
                                    colors: [Colors.white, Colors.white.withOpacity(0.8)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : LinearGradient(
                                    colors: [
                                      AppColors.primaryBlue,
                                      AppColors.primaryBlue.withOpacity(0.8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                            boxShadow: [
                              BoxShadow(
                                color: _isListening 
                                    ? Colors.white.withOpacity(0.4)
                                    : AppColors.primaryBlue.withOpacity(0.4),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isListening ? Icons.mic : Icons.mic_none_rounded,
                            color: _isListening ? AppColors.primaryBlue : Colors.white,
                            size: 28.r,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 20.w),
                    // Title and description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 18.r,
                                color: _isListening ? Colors.white : AppColors.primaryBlue,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                "AI Voice Assistant",
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: _isListening ? Colors.white : AppColors.primaryBlue,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            _isListening
                                ? "Listening to your voice..."
                                : "Intelligent voice-to-text",
                            style: AppTextStyles.bodySmall.copyWith(
                              color: _isListening 
                                  ? Colors.white.withOpacity(0.9)
                                  : AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                if (_isListening) ...[
                  SizedBox(height: 20.h),
                  // Animated waveform
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300 + (index * 100)),
                        curve: Curves.easeInOut,
                        margin: EdgeInsets.symmetric(horizontal: 3.w),
                        width: 4.w,
                        height: _isListening ? (20 + (index % 3) * 10).h : 10.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    "Tap to stop and process",
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ] else ...[
                  SizedBox(height: 16.h),
                  // Feature indicators
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlueSoft.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColors.primaryBlue.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildFeatureIndicator(Icons.description_outlined, "Diagnosis"),
                        Container(width: 1, height: 20.h, color: AppColors.borderSoft),
                        _buildFeatureIndicator(Icons.medical_services_outlined, "Procedure"),
                        Container(width: 1, height: 20.h, color: AppColors.borderSoft),
                        _buildFeatureIndicator(Icons.assignment_outlined, "Plan"),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.touch_app, size: 16.r, color: AppColors.primaryBlue.withOpacity(0.6)),
                      SizedBox(width: 6.w),
                      Text(
                        "Tap to start recording",
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureIndicator(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 18.r, color: AppColors.primaryBlue),
        SizedBox(height: 4.h),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 9.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required String field,
  }) {
    bool isActiveField = _isListening && _currentField == field;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isActiveField ? AppColors.primaryBlue : AppColors.borderSoft,
          width: isActiveField ? 2 : 1,
        ),
        boxShadow: isActiveField
            ? [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                )
              ]
            : [],
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomTextFormField(
              hintText: hintText,
              controller: controller,
              prefixIcon: Icon(icon),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (isActiveField) {
                _stopListening();
              } else {
                _startListening(field);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: isActiveField ? AppColors.primaryBlue : AppColors.primaryBlueSoft,
                shape: BoxShape.circle,
                boxShadow: isActiveField
                    ? [
                        BoxShadow(
                          color: AppColors.primaryBlue.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        )
                      ]
                    : [],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (isActiveField)
                    Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  Icon(
                    isActiveField ? Icons.mic : Icons.mic_none_outlined,
                    color: isActiveField ? Colors.white : AppColors.primaryBlue,
                    size: 20.r,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, Color activeColor) {
    bool isSelected = _selectedStatus == status;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedStatus = status),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: isSelected ? activeColor : AppColors.borderSoft),
          ),
          child: Center(
            child: Text(
              status,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
