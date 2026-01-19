// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../../data/data_sources/remote/appointment_remote_data_source.dart'
    as _i286;
import '../../../data/data_sources/remote/auth_remote_data_source.dart'
    as _i930;
import '../../../data/repos/appointment_repo_impl.dart' as _i678;
import '../../../data/repos/auth_repo_impl.dart' as _i45;
import '../../../domain/repos/appointment_repo.dart' as _i1054;
import '../../../domain/repos/auth_repo.dart' as _i812;
import '../../../domain/use_cases/book_appointment_use_case.dart' as _i279;
import '../../../domain/use_cases/cancel_appointment_use_case.dart' as _i428;
import '../../../domain/use_cases/get_all_doctors_use_case.dart' as _i286;
import '../../../domain/use_cases/get_booked_slots_use_case.dart' as _i1026;
import '../../../domain/use_cases/get_doctor_appointments_use_case.dart'
    as _i303;
import '../../../domain/use_cases/get_patient_appointments_use_case.dart'
    as _i1010;
import '../../../domain/use_cases/get_today_appointments_use_case.dart'
    as _i229;
import '../../../domain/use_cases/get_user_data_use_case.dart' as _i579;
import '../../../domain/use_cases/login_use_case.dart' as _i798;
import '../../../domain/use_cases/login_with_google_use_case.dart' as _i48;
import '../../../domain/use_cases/register_use_case.dart' as _i311;
import '../../../domain/use_cases/reschedule_appointment_use_case.dart'
    as _i694;
import '../../../features/auth/auth_cubit/auth_cubit.dart' as _i130;
import '../../../features/auth/login/cubit/login_view_model.dart' as _i610;
import '../../../features/auth/register/cubit/register_view_model.dart'
    as _i828;
import '../../../features/doctors/cubit/booking_view_model.dart' as _i184;
import '../../../features/doctors/cubit/doctors_listing_view_model.dart'
    as _i544;
import '../../../features/tabs/activity_tab/cubit/activity_view_model.dart'
    as _i297;
import '../../../features/tabs/doctor_home_tab/cubit/doctor_home_view_model.dart'
    as _i500;
import '../../../features/tabs/home_tab/cubit/patient_home_view_model.dart'
    as _i399;
import '../../../features/tabs/receptionist_tabs/cubit/receptionist_home_view_model.dart'
    as _i265;
import '../../data_sources/remote/appointment_remote_data_source_impl.dart'
    as _i770;
import '../../data_sources/remote/auth_remote_data_source_impl.dart' as _i940;
import 'firebase_module.dart' as _i616;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final firebaseModule = _$FirebaseModule();
    gh.singleton<_i130.AuthCubit>(() => _i130.AuthCubit());
    gh.lazySingleton<_i59.FirebaseAuth>(() => firebaseModule.firebaseAuth);
    gh.lazySingleton<_i974.FirebaseFirestore>(() => firebaseModule.firestore);
    gh.factory<_i930.AuthRemoteDataSource>(
      () => _i940.AuthRemoteDataSourceImpl(
        gh<_i59.FirebaseAuth>(),
        gh<_i974.FirebaseFirestore>(),
      ),
    );
    gh.factory<_i286.AppointmentRemoteDataSource>(
      () =>
          _i770.AppointmentRemoteDataSourceImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.factory<_i812.AuthRepo>(
      () => _i45.AuthRepositoryImpl(gh<_i930.AuthRemoteDataSource>()),
    );
    gh.factory<_i579.GetUserDataUseCase>(
      () => _i579.GetUserDataUseCase(gh<_i812.AuthRepo>()),
    );
    gh.factory<_i798.LoginUseCase>(
      () => _i798.LoginUseCase(gh<_i812.AuthRepo>()),
    );
    gh.factory<_i48.LoginWithGoogleUseCase>(
      () => _i48.LoginWithGoogleUseCase(gh<_i812.AuthRepo>()),
    );
    gh.factory<_i610.LoginViewModel>(
      () => _i610.LoginViewModel(
        gh<_i798.LoginUseCase>(),
        gh<_i48.LoginWithGoogleUseCase>(),
      ),
    );
    gh.factory<_i1054.AppointmentRepo>(
      () => _i678.AppointmentRepoImpl(gh<_i286.AppointmentRemoteDataSource>()),
    );
    gh.factory<_i279.BookAppointmentUseCase>(
      () => _i279.BookAppointmentUseCase(gh<_i1054.AppointmentRepo>()),
    );
    gh.factory<_i428.CancelAppointmentUseCase>(
      () => _i428.CancelAppointmentUseCase(gh<_i1054.AppointmentRepo>()),
    );
    gh.factory<_i1026.GetBookedSlotsUseCase>(
      () => _i1026.GetBookedSlotsUseCase(gh<_i1054.AppointmentRepo>()),
    );
    gh.factory<_i303.GetDoctorAppointmentsUseCase>(
      () => _i303.GetDoctorAppointmentsUseCase(gh<_i1054.AppointmentRepo>()),
    );
    gh.factory<_i1010.GetPatientAppointmentsUseCase>(
      () => _i1010.GetPatientAppointmentsUseCase(gh<_i1054.AppointmentRepo>()),
    );
    gh.factory<_i229.GetTodayAppointmentsUseCase>(
      () => _i229.GetTodayAppointmentsUseCase(gh<_i1054.AppointmentRepo>()),
    );
    gh.factory<_i694.RescheduleAppointmentUseCase>(
      () => _i694.RescheduleAppointmentUseCase(gh<_i1054.AppointmentRepo>()),
    );
    gh.factory<_i297.ActivityViewModel>(
      () => _i297.ActivityViewModel(
        gh<_i1010.GetPatientAppointmentsUseCase>(),
        gh<_i428.CancelAppointmentUseCase>(),
        gh<_i694.RescheduleAppointmentUseCase>(),
        gh<_i1026.GetBookedSlotsUseCase>(),
      ),
    );
    gh.factory<_i286.GetAllDoctorsUseCase>(
      () => _i286.GetAllDoctorsUseCase(gh<_i812.AuthRepo>()),
    );
    gh.factory<_i311.RegisterUseCase>(
      () => _i311.RegisterUseCase(gh<_i812.AuthRepo>()),
    );
    gh.factory<_i184.BookingViewModel>(
      () => _i184.BookingViewModel(
        gh<_i279.BookAppointmentUseCase>(),
        gh<_i1026.GetBookedSlotsUseCase>(),
      ),
    );
    gh.factory<_i828.RegisterViewModel>(
      () => _i828.RegisterViewModel(gh<_i311.RegisterUseCase>()),
    );
    gh.factory<_i544.DoctorsListingViewModel>(
      () => _i544.DoctorsListingViewModel(gh<_i286.GetAllDoctorsUseCase>()),
    );
    gh.factory<_i399.PatientHomeViewModel>(
      () => _i399.PatientHomeViewModel(
        gh<_i1010.GetPatientAppointmentsUseCase>(),
      ),
    );
    gh.factory<_i500.DoctorHomeViewModel>(
      () => _i500.DoctorHomeViewModel(gh<_i303.GetDoctorAppointmentsUseCase>()),
    );
    gh.factory<_i265.ReceptionistHomeViewModel>(
      () => _i265.ReceptionistHomeViewModel(
        gh<_i229.GetTodayAppointmentsUseCase>(),
      ),
    );
    return this;
  }
}

class _$FirebaseModule extends _i616.FirebaseModule {}
