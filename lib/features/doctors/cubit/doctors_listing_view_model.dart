import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import '../../../../domain/entities/user_entity.dart';
import '../../../../domain/use_cases/get_all_doctors_use_case.dart';
import '../doctors_listing_screen.dart';

abstract class DoctorsListingState {}

class DoctorsListingInitial extends DoctorsListingState {}

class DoctorsListingLoading extends DoctorsListingState {}

class DoctorsListingSuccess extends DoctorsListingState {
  final List<Doctor> doctors;
  final bool isLocationLoading;
  DoctorsListingSuccess(this.doctors, {this.isLocationLoading = false});
}

class DoctorsListingFailure extends DoctorsListingState {
  final String message;
  DoctorsListingFailure(this.message);
}

@injectable
class DoctorsListingViewModel extends Cubit<DoctorsListingState> {
  final GetAllDoctorsUseCase _getAllDoctorsUseCase;

  DoctorsListingViewModel(this._getAllDoctorsUseCase) : super(DoctorsListingInitial());

  List<Doctor> _allDoctors = [];
  String _searchQuery = '';
  String _selectedSort = 'Default';
  Position? _userPosition;
  final Set<String> _favoriteIds = {};

  void getAllDoctors() async {
    emit(DoctorsListingLoading());
    try {
      final List<UserEntity> entities = await _getAllDoctorsUseCase.call();
      _allDoctors = entities.asMap().entries.map((entry) {
        final doctor = Doctor.fromEntity(entry.value, entry.key);
        doctor.isFavorite = _favoriteIds.contains(doctor.id);
        return doctor;
      }).toList();
      _applyFilters();
    } catch (e) {
      emit(DoctorsListingFailure(e.toString()));
    }
  }

  void searchDoctors(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void toggleFavorite(String doctorId) {
    if (_favoriteIds.contains(doctorId)) {
      _favoriteIds.remove(doctorId);
    } else {
      _favoriteIds.add(doctorId);
    }
    for (var doctor in _allDoctors) {
      if (doctor.id == doctorId) {
        doctor.isFavorite = _favoriteIds.contains(doctorId);
      }
    }
    _applyFilters();
  }

  void setSort(String sort) {
    if (_selectedSort == sort) {
      _selectedSort = 'Default';
    } else {
      _selectedSort = sort;
    }
    _applyFilters();
  }

  Future<void> handleLocationSort() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(DoctorsListingFailure("Location services are disabled. Please enable GPS."));
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(DoctorsListingFailure("Location permission denied."));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        emit(DoctorsListingFailure("Location permissions are permanently denied. Please enable them in settings."));
        return;
      }

      if (state is DoctorsListingSuccess) {
        emit(DoctorsListingSuccess((state as DoctorsListingSuccess).doctors, isLocationLoading: true));
      } else {
        emit(DoctorsListingLoading());
      }

      Position? position;
      try {
        // Increased timeout and using lower accuracy fallback for faster results on emulators
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: const Duration(seconds: 15),
        );
      } on TimeoutException {
        position = await Geolocator.getLastKnownPosition();
      } catch (e) {
        position = await Geolocator.getLastKnownPosition();
      }
      
      if (position == null) {
        emit(DoctorsListingFailure("Could not determine location. Please ensure GPS is active and has a signal."));
        _applyFilters();
        return;
      }

      _userPosition = position;
      _selectedSort = 'Location';
      _applyFilters();
    } catch (e) {
      emit(DoctorsListingFailure("Location Error: ${e.toString()}"));
      _applyFilters();
    }
  }

  void _applyFilters() {
    List<Doctor> filtered = List.from(_allDoctors);

    if (_userPosition != null) {
      for (var doctor in filtered) {
        doctor.distance = Geolocator.distanceBetween(
              _userPosition!.latitude,
              _userPosition!.longitude,
              doctor.latitude,
              doctor.longitude,
            ) /
            1000;
      }
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((d) =>
              d.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              d.specialty.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_selectedSort == 'Favorites') {
      filtered = filtered.where((d) => d.isFavorite).toList();
    } else if (_selectedSort == 'A-Z') {
      filtered.sort((a, b) =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } else if (_selectedSort == 'Location' && _userPosition != null) {
      filtered.sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));
    }

    emit(DoctorsListingSuccess(filtered, isLocationLoading: false));
  }

  String get selectedSort => _selectedSort;
  Set<String> get favoriteIds => _favoriteIds;
}
