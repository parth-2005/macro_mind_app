import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:macro_mind_app/features/cards/card.model.dart';
import 'package:macro_mind_app/features/profile/profile.model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:3000/api', // Use 10.0.2.2 for Android emulator
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  final _storage = const FlutterSecureStorage();

  ApiService._internal() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'accessToken');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            // Attempt refresh
            try {
              final refreshToken = await _storage.read(key: 'refreshToken');
              if (refreshToken != null) {
                // Use a new Dio instance to avoid interceptor loop or just generic post
                // Actually using _dio is fine if we don't attach the same interceptor or be careful.
                // But here the interceptor adds header if accessToken exists.
                // We are calling /refresh-token.
                final response = await _dio.post(
                  '/auth/refresh-token',
                  data: {'refreshToken': refreshToken},
                );

                if (response.statusCode == 200) {
                  final newAccessToken = response.data['accessToken'];
                  final newRefreshToken = response.data['refreshToken'];
                  await _storage.write(
                    key: 'accessToken',
                    value: newAccessToken,
                  );
                  await _storage.write(
                    key: 'refreshToken',
                    value: newRefreshToken,
                  );

                  // Retry original request
                  final opts = e.requestOptions;
                  opts.headers['Authorization'] = 'Bearer $newAccessToken';

                  final cloneReq = await _dio.request(
                    opts.path,
                    options: Options(
                      method: opts.method,
                      headers: opts.headers,
                      contentType: opts.contentType,
                      responseType: opts.responseType,
                    ),
                    data: opts.data,
                    queryParameters: opts.queryParameters,
                  );
                  return handler.resolve(cloneReq);
                }
              }
            } catch (refreshError) {
              // Refresh failed, logout
              await _storage.deleteAll();
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;

  Future<List<CardModel>> getCards() async {
    try {
      final response = await _dio.get('/cards');
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((x) => CardModel.fromJson(x))
            .toList();
      } else {
        throw Exception('Failed to load cards');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Profile API methods
  Future<ProfileModel> getProfile() async {
    try {
      final response = await _dio.get('/profile');
      if (response.statusCode == 200) {
        return ProfileModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<ProfileModel> createProfile(ProfileModel profile) async {
    try {
      final response = await _dio.post('/profile', data: profile.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ProfileModel.fromJson(response.data);
      } else {
        throw Exception('Failed to create profile');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    try {
      final response = await _dio.put('/profile', data: profile.toJson());
      if (response.statusCode == 200) {
        return ProfileModel.fromJson(response.data);
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      rethrow;
    }
  }
}
