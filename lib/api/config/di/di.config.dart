// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:dio/dio.dart' as _i361;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../../data/data_sources/remote/appointment_remote_data_source.dart'
    as _i286;
import '../../../data/data_sources/remote/auth_remote_data_source.dart'
    as _i930;
import '../../../data/data_sources/remote/request_remote_data_source.dart'
    as _i824;
import '../../../data/data_sources/remote/support_remote_data_source.dart'
    as _i817;
import '../../../data/repos/appointment_repo_impl.dart' as _i678;
import '../../../data/repos/auth_repo_impl.dart' as _i45;
import '../../../data/repos/inventory_repo_impl.dart' as _i721;
import '../../../data/repos/medical_record_repo_impl.dart' as _i1018;
import '../../../data/repos/prediction_repo_impl.dart' as _i767;
import '../../../data/repos/request_repo_impl.dart' as _i16;
import '../../../data/repos/support_repo_impl.dart' as _i813;
import '../../../domain/repos/appointment_repo.dart' as _i1054;
import '../../../domain/repos/auth_repo.dart' as _i812;
import '../../../domain/repos/inventory_repo.dart' as _i838;
import '../../../domain/repos/medical_record_repo.dart' as _i457;
import '../../../domain/repos/prediction_repo.dart' as _i615;
import '../../../domain/repos/request_repo.dart' as _i566;
import '../../../domain/repos/support_repo.dart' as _i586;
import '../../../domain/use_cases/add_request_use_case.dart' as _i198;
import '../../../domain/use_cases/book_appointment_use_case.dart' as _i279;
import '../../../domain/use_cases/cancel_appointment_use_case.dart' as _i428;
import '../../../domain/use_cases/complete_appointment_use_case.dart' as _i128;
import '../../../domain/use_cases/decrement_inventory_use_case.dart' as _i264;
import '../../../domain/use_cases/get_all_doctors_use_case.dart' as _i286;
import '../../../domain/use_cases/get_booked_slots_use_case.dart' as _i1026;
import '../../../domain/use_cases/get_doctor_appointments_use_case.dart'
    as _i303;
import '../../../domain/use_cases/get_inventory_use_case.dart' as _i708;
import '../../../domain/use_cases/get_medical_records_use_case.dart' as _i369;
import '../../../domain/use_cases/get_no_show_prediction_use_case.dart'
    as _i998;
import '../../../domain/use_cases/get_patient_appointments_use_case.dart'
    as _i1010;
import '../../../domain/use_cases/get_requests_use_case.dart' as _i975;
import '../../../domain/use_cases/get_today_appointments_use_case.dart'
    as _i229;
import '../../../domain/use_cases/get_user_data_use_case.dart' as _i579;
import '../../../domain/use_cases/login_use_case.dart' as _i798;
import '../../../domain/use_cases/login_with_google_use_case.dart' as _i48;
import '../../../domain/use_cases/register_staff_use_case.dart' as _i1047;
import '../../../domain/use_cases/register_use_case.dart' as _i311;
import '../../../domain/use_cases/reschedule_appointment_use_case.dart'
    as _i694;
import '../../../domain/use_cases/save_medical_record_use_case.dart' as _i850;
import '../../../domain/use_cases/send_support_ticket_use_case.dart' as _i879;
import '../../../domain/use_cases/update_availability_use_case.dart' as _i512;
import '../../../domain/use_cases/update_password_use_case.dart' as _i651;
import '../../../domain/use_cases/update_profile_use_case.dart' as _i886;
import '../../../domain/use_cases/update_request_status_use_case.dart' as _i501;
import '../../../features/auth/auth_cubit/auth_cubit.dart' as _i130;
import '../../../features/auth/login/cubit/login_view_model.dart' as _i610;
import '../../../features/auth/register/cubit/register_view_model.dart'
    as _i828;
import '../../../features/doctors/cubit/booking_view_model.dart' as _i184;
import '../../../features/doctors/cubit/doctors_listing_view_model.dart'
    as _i544;
import '../../../features/settings/cubit/password_manager_view_model.dart'
    as _i421;
import '../../../features/tabs/activity_tab/cubit/activity_view_model.dart'
    as _i297;
import '../../../features/tabs/admin_tabs/cubit/admin_home_view_model.dart'
    as _i282;
import '../../../features/tabs/admin_tabs/cubit/admin_patients_view_model.dart'
    as _i878;
import '../../../features/tabs/admin_tabs/cubit/admin_support_view_model.dart'
    as _i1056;
import '../../../features/tabs/availability_tab/cubit/availability_view_model.dart'
    as _i831;
import '../../../features/tabs/doctor_home_tab/cubit/doctor_home_view_model.dart'
    as _i500;
import '../../../features/tabs/home_tab/cubit/patient_home_view_model.dart'
    as _i399;
import '../../../features/tabs/nurse_tabs/cubit/clinical_prep_view_model.dart'
    as _i607;
import '../../../features/tabs/nurse_tabs/cubit/inventory_view_model.dart'
    as _i582;
import '../../../features/tabs/nurse_tabs/cubit/request_view_model.dart'
    as _i292;
import '../../../features/tabs/patients_tab/cubit/add_record_view_model.dart'
    as _i20;
import '../../../features/tabs/patients_tab/cubit/patient_details_view_model.dart'
    as _i502;
import '../../../features/tabs/patients_tab/cubit/patients_view_model.dart'
    as _i605;
import '../../../features/tabs/profile_tab/cubit/managerial_staff_view_model.dart'
    as _i908;
import '../../../features/tabs/profile_tab/cubit/profile_view_model.dart'
    as _i438;
import '../../../features/tabs/profile_tab/cubit/support_view_model.dart'
    as _i192;
import '../../../features/tabs/receptionist_tabs/cubit/receptionist_home_view_model.dart'
    as _i265;
import '../../data_sources/remote/appointment_remote_data_source_impl.dart'
    as _i770;
import '../../data_sources/remote/auth_remote_data_source_impl.dart' as _i940;
import '../../data_sources/remote/inventory_remote_data_source_impl.dart'
    as _i174;
import '../../data_sources/remote/medical_record_remote_data_source_impl.dart'
    as _i787;
import '../../data_sources/remote/request_remote_data_source_impl.dart'
    as _i601;
import '../../data_sources/remote/support_remote_data_source_impl.dart'
    as _i808;
import '../../web_services.dart' as _i288;
import 'network_module.dart' as _i567;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final networkModule = _$NetworkModule();
    gh.lazySingleton<_i59.FirebaseAuth>(() => _i59.FirebaseAuth.instance);
    gh.lazySingleton<_i974.FirebaseFirestore>(() => _i974.FirebaseFirestore.instance);
    gh.lazySingleton<_i361.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i288.WebServices>(
        () => networkModule.getWebServices(gh<_i361.Dio>()));
    gh.factory<_i817.SupportRemoteDataSource>(
        () => _i808.SupportRemoteDataSourceImpl(gh<_i974.FirebaseFirestore>()));
    gh.factory<_i586.SupportRepo>(
        () => _i813.SupportRepositoryImpl(gh<_i817.SupportRemoteDataSource>()));
    gh.factory<_i930.AuthRemoteDataSource>(() => _i940.AuthRemoteDataSourceImpl(
          gh<_i59.FirebaseAuth>(),
          gh<_i974.FirebaseFirestore>(),
        ));
    gh.factory<_i787.MedicalRecordRemoteDataSource>(() =>
        _i787.MedicalRecordRemoteDataSourceImpl(gh<_i974.FirebaseFirestore>()));
    gh.factory<_i286.AppointmentRemoteDataSource>(() =>
        _i770.AppointmentRemoteDataSourceImpl(gh<_i974.FirebaseFirestore>()));
    gh.factory<_i174.InventoryRemoteDataSource>(() =>
        _i174.InventoryRemoteDataSourceImpl(gh<_i974.FirebaseFirestore>()));
    gh.factory<_i1054.AppointmentRepo>(() =>
        _i678.AppointmentRepoImpl(gh<_i286.AppointmentRemoteDataSource>()));
    gh.factory<_i512.UpdateAvailabilityUseCase>(
        () => _i512.UpdateAvailabilityUseCase(gh<_i1054.AppointmentRepo>()));
    gh.factory<_i812.AuthRepo>(
        () => _i45.AuthRepositoryImpl(gh<_i930.AuthRemoteDataSource>()));
    gh.factory<_i579.GetUserDataUseCase>(
        () => _i579.GetUserDataUseCase(gh<_i812.AuthRepo>()));
    gh.factory<_i798.LoginUseCase>(
        () => _i798.LoginUseCase(gh<_i812.AuthRepo>()));
    gh.factory<_i48.LoginWithGoogleUseCase>(
        () => _i48.LoginWithGoogleUseCase(gh<_i812.AuthRepo>()));
    gh.factory<_i615.PredictionRepo>(
        () => _i767.PredictionRepoImpl(gh<_i288.WebServices>()));
    gh.factory<_i879.SendSupportTicketUseCase>(
        () => _i879.SendSupportTicketUseCase(gh<_i586.SupportRepo>()));
    gh.factory<_i457.MedicalRecordRepo>(() => _i1018.MedicalRecordRepoImpl(
        gh<_i787.MedicalRecordRemoteDataSource>()));
    gh.factory<_i838.InventoryRepo>(
        () => _i721.InventoryRepoImpl(gh<_i174.InventoryRemoteDataSource>()));
    gh.factory<_i824.RequestRemoteDataSource>(
        () => _i601.RequestRemoteDataSourceImpl(gh<_i974.FirebaseFirestore>()));
    gh.factory<_i369.GetMedicalRecordsUseCase>(
        () => _i369.GetMedicalRecordsUseCase(gh<_i457.MedicalRecordRepo>()));
    gh.factory<_i850.SaveMedicalRecordUseCase>(
        () => _i850.SaveMedicalRecordUseCase(gh<_i457.MedicalRecordRepo>()));
    gh.factory<_i1056.AdminSupportViewModel>(
        () => _i1056.AdminSupportViewModel(gh<_i586.SupportRepo>()));
    gh.factory<_i582.InventoryViewModel>(
        () => _i582.InventoryViewModel(gh<_i838.InventoryRepo>()));
    gh.factory<_i998.GetNoShowPredictionUseCase>(
        () => _i998.GetNoShowPredictionUseCase(gh<_i615.PredictionRepo>()));
    gh.factory<_i878.AdminPatientsViewModel>(() => _i878.AdminPatientsViewModel(
          gh<_i812.AuthRepo>(),
          gh<_i1054.AppointmentRepo>(),
          gh<_i998.GetNoShowPredictionUseCase>(),
        ));
    gh.singleton<_i130.AuthCubit>(
        () => _i130.AuthCubit(gh<_i579.GetUserDataUseCase>()));
    gh.factory<_i279.BookAppointmentUseCase>(
        () => _i279.BookAppointmentUseCase(gh<_i1054.AppointmentRepo>()));
    gh.factory<_i428.CancelAppointmentUseCase>(
        () => _i428.CancelAppointmentUseCase(gh<_i1054.AppointmentRepo>()));
    gh.factory<_i128.CompleteAppointmentUseCase>(
        () => _i128.CompleteAppointmentUseCase(gh<_i1054.AppointmentRepo>()));
    gh.factory<_i1026.GetBookedSlotsUseCase>(
        () => _i1026.GetBookedSlotsUseCase(gh<_i1054.AppointmentRepo>()));
    gh.factory<_i303.GetDoctorAppointmentsUseCase>(
        () => _i303.GetDoctorAppointmentsUseCase(gh<_i1054.AppointmentRepo>()));
    gh.factory<_i1010.GetPatientAppointmentsUseCase>(() =>
        _i1010.GetPatientAppointmentsUseCase(gh<_i1054.AppointmentRepo>()));
    gh.factory<_i229.GetTodayAppointmentsUseCase>(
        () => _i229.GetTodayAppointmentsUseCase(gh<_i1054.AppointmentRepo>()));
    gh.factory<_i694.RescheduleAppointmentUseCase>(
        () => _i694.RescheduleAppointmentUseCase(gh<_i1054.AppointmentRepo>()));
    gh.factory<_i184.BookingViewModel>(() => _i184.BookingViewModel(
          gh<_i279.BookAppointmentUseCase>(),
          gh<_i1026.GetBookedSlotsUseCase>(),
        ));
    gh.factory<_i500.DoctorHomeViewModel>(() =>
        _i500.DoctorHomeViewModel(gh<_i303.GetDoctorAppointmentsUseCase>()));
    gh.factory<_i399.PatientHomeViewModel>(() =>
        _i399.PatientHomeViewModel(gh<_i1010.GetPatientAppointmentsUseCase>()));
    gh.factory<_i502.PatientDetailsViewModel>(() =>
        _i502.PatientDetailsViewModel(
            gh<_i369.GetMedicalRecordsUseCase>(),
            gh<_i850.SaveMedicalRecordUseCase>()));
    gh.factory<_i192.SupportViewModel>(
        () => _i192.SupportViewModel(gh<_i879.SendSupportTicketUseCase>()));
    gh.factory<_i264.DecrementInventoryUseCase>(
        () => _i264.DecrementInventoryUseCase(gh<_i838.InventoryRepo>()));
    gh.factory<_i708.GetInventoryUseCase>(
        () => _i708.GetInventoryUseCase(gh<_i838.InventoryRepo>()));
    gh.factory<_i286.GetAllDoctorsUseCase>(
        () => _i286.GetAllDoctorsUseCase(gh<_i812.AuthRepo>()));
    gh.factory<_i1047.RegisterStaffUseCase>(
        () => _i1047.RegisterStaffUseCase(gh<_i812.AuthRepo>()));
    gh.factory<_i311.RegisterUseCase>(
        () => _i311.RegisterUseCase(gh<_i812.AuthRepo>()));
    gh.factory<_i651.UpdatePasswordUseCase>(
        () => _i651.UpdatePasswordUseCase(gh<_i812.AuthRepo>()));
    gh.factory<_i886.UpdateProfileUseCase>(
        () => _i886.UpdateProfileUseCase(gh<_i812.AuthRepo>()));
    gh.factory<_i282.AdminHomeViewModel>(
        () => _i282.AdminHomeViewModel(gh<_i812.AuthRepo>()));
    gh.factory<_i831.AvailabilityViewModel>(() => _i831.AvailabilityViewModel(
          gh<_i1054.AppointmentRepo>(),
          gh<_i512.UpdateAvailabilityUseCase>(),
        ));
    gh.factory<_i610.LoginViewModel>(() => _i610.LoginViewModel(
          gh<_i798.LoginUseCase>(),
          gh<_i48.LoginWithGoogleUseCase>(),
        ));
    gh.factory<_i605.PatientsViewModel>(() => _i605.PatientsViewModel(
          gh<_i303.GetDoctorAppointmentsUseCase>(),
          gh<_i428.CancelAppointmentUseCase>(),
          gh<_i128.CompleteAppointmentUseCase>(),
          gh<_i998.GetNoShowPredictionUseCase>(),
          gh<_i1054.AppointmentRepo>(),
        ));
    gh.factory<_i265.ReceptionistHomeViewModel>(() =>
        _i265.ReceptionistHomeViewModel(
            gh<_i229.GetTodayAppointmentsUseCase>()));
    gh.factory<_i607.ClinicalPrepViewModel>(() => _i607.ClinicalPrepViewModel(
          gh<_i264.DecrementInventoryUseCase>(),
          gh<_i708.GetInventoryUseCase>(),
        ));
    gh.factory<_i828.RegisterViewModel>(
        () => _i828.RegisterViewModel(gh<_i311.RegisterUseCase>()));
    gh.factory<_i566.RequestRepo>(
        () => _i16.RequestRepoImpl(gh<_i824.RequestRemoteDataSource>()));
    gh.factory<_i421.PasswordManagerViewModel>(() =>
        _i421.PasswordManagerViewModel(gh<_i651.UpdatePasswordUseCase>()));
    gh.factory<_i20.AddRecordViewModel>(
        () => _i20.AddRecordViewModel(gh<_i850.SaveMedicalRecordUseCase>()));
    gh.factory<_i297.ActivityViewModel>(() => _i297.ActivityViewModel(
          gh<_i1010.GetPatientAppointmentsUseCase>(),
          gh<_i428.CancelAppointmentUseCase>(),
          gh<_i694.RescheduleAppointmentUseCase>(),
          gh<_i1026.GetBookedSlotsUseCase>(),
        ));
    gh.factory<_i908.ManagerialStaffViewModel>(() =>
        _i908.ManagerialStaffViewModel(gh<_i1047.RegisterStaffUseCase>()));
    gh.factory<_i544.DoctorsListingViewModel>(
        () => _i544.DoctorsListingViewModel(gh<_i286.GetAllDoctorsUseCase>()));
    gh.factory<_i198.AddRequestUseCase>(
        () => _i198.AddRequestUseCase(gh<_i566.RequestRepo>()));
    gh.factory<_i975.GetRequestsUseCase>(
        () => _i975.GetRequestsUseCase(gh<_i566.RequestRepo>()));
    gh.factory<_i501.UpdateRequestStatusUseCase>(
        () => _i501.UpdateRequestStatusUseCase(gh<_i566.RequestRepo>()));
    gh.factory<_i438.ProfileViewModel>(
        () => _i438.ProfileViewModel(gh<_i886.UpdateProfileUseCase>()));
    gh.factory<_i292.RequestViewModel>(() => _i292.RequestViewModel(
          gh<_i975.GetRequestsUseCase>(),
          gh<_i198.AddRequestUseCase>(),
          gh<_i501.UpdateRequestStatusUseCase>(),
        ));
    return this;
  }
}

class _$NetworkModule extends _i567.NetworkModule {}
