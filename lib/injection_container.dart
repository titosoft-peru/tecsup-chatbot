import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/network/api_client.dart';
import 'features/admin/data/datasources/admin_remote_datasource.dart';
import 'features/admin/data/repositories/admin_repository_impl.dart';
import 'features/admin/domain/repositories/admin_repository.dart';
import 'features/admin/domain/usecases/create_user_usecase.dart';
import 'features/admin/presentation/providers/admin_provider.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/chat/data/datasources/chat_remote_datasource.dart';
import 'features/chat/data/repositories/chat_repository_impl.dart';
import 'features/chat/domain/repositories/chat_repository.dart';
import 'features/chat/domain/usecases/process_question_usecase.dart';
import 'features/chat/presentation/providers/chat_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final prefs = await SharedPreferences.getInstance();

  // Core
  sl.registerLazySingleton<ApiClient>(() => ApiClient());

  // Auth — data
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDatasource: sl(), prefs: prefs),
  );

  // Auth — domain
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  // Auth — presentation
  sl.registerFactory(
    () => AuthProvider(
      loginUseCase: sl(),
      logoutUseCase: sl(),
      repository: sl(),
    ),
  );

  // Admin — data
  sl.registerLazySingleton<AdminRemoteDatasource>(
    () => AdminRemoteDatasourceImpl(sl()),
  );
  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(sl()),
  );

  // Admin — domain
  sl.registerLazySingleton(() => CreateUserUseCase(sl()));

  // Admin — presentation
  sl.registerFactory(
    () => AdminProvider(createUser: sl(), apiClient: sl()),
  );

  // Chat — data
  sl.registerLazySingleton<ChatRemoteDatasource>(
    () => ChatRemoteDatasourceImpl(sl()),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(sl()),
  );

  // Chat — domain
  sl.registerLazySingleton(() => ProcessQuestionUseCase(sl()));

  // Chat — presentation
  sl.registerFactory(
    () => ChatProvider(processQuestion: sl(), apiClient: sl()),
  );
}
