import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/driver.dart';
import '../models/bus.dart';
import '../models/bus_route.dart';
import '../models/schedule.dart';
import '../models/location_data.dart';
import '../models/sensor_data.dart';

class DatabaseService {
  static const String _baseUrl = 'http://localhost:3060/api'; // Your MySQL API endpoint
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  // Authentication
  Future<Map<String, dynamic>?> authenticateUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Authentication failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Database connection error: $e');
    }
  }

  Future<Map<String, dynamic>?> registerUser(String email, String password, String name) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Database connection error: $e');
    }
  }

  // Driver Management
  Future<List<Driver>> getDrivers() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/drivers'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Driver.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch drivers: ${response.body}');
      }
    } catch (e) {
      throw Exception('Database connection error: $e');
    }
  }

  Future<Driver?> getDriverById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/drivers/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return Driver.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to fetch driver: ${response.body}');
      }
    } catch (e) {
      throw Exception('Database connection error: $e');
    }
  }

  Future<Driver> createDriver(Driver driver) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/drivers'),
        headers: _headers,
        body: jsonEncode(driver.toJson()),
      );

      if (response.statusCode == 201) {
        return Driver.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create driver: ${response.body}');
      }
    } catch (e) {
      throw Exception('Database connection error: $e');
    }
  }

  Future<Driver> updateDriver(String id, Driver driver) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/drivers/$id'),
        headers: _headers,
        body: jsonEncode(driver.toJson()),
      );

      if (response.statusCode == 200) {
        return Driver.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update driver: ${response.body}');
      }
    } catch (e) {
      throw Exception('Database connection error: $e');
    }
  }

  Future<void> deleteDriver(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/drivers/$id'),
        headers: _headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete driver: ${response.body}');
      }
    } catch (e) {
      throw Exception('Database connection error: $e');
    }
  }

  // Bus Management
  Future<List<Bus>> getBuses() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/buses'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Bus.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch buses: ${response.body}');
      }
    } catch (e) {
      throw Exception('Database connection error: $e');
    }
  }

  Future<Bus?> getBusById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/buses/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return Bus.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to fetch bus: ${response.body}');
      }
    } catch (e) {
      throw Exception('Database connection error: $e');
    }
  }

  Future<Bus> createBus(Bus bus) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/buses'),
        headers: _headers,
        body: jsonEncode(bus.toJson()),
      );

      if (response.statusCode == 201) {
        return Bus.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create bus: ${response.body}');
      }
    } catch (e) {
      throw Exception('Database connection error: $e');
    }
  }

  Future<Bus> updateBus(String id, Bus bus) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/buses/$id'),
        headers: _headers,
        body: jsonEncode(bus.toJson()),
      );

      if (response.statusCode == 200) {
        return Bus.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update bus: ${response.body}');
      }
    } catch (e) {
      throw Exception('Database connection error: $e');
    }
  }

  Future<void> deleteBus(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/buses/$id'),
        headers: _headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete bus: ${response.body}');
      }
    } catch (e) {
      throw Exception('Database connection error: $e');
    }
  }

  // Location Data Management
  Future<void> saveLocationData(LocationData locationData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/locations'),
        headers: _headers,
        body: jsonEncode(locationData.toJson()),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to save location data: ${response.body}');
      }
    } catch (e) {
      throw Exception('Database connection error: $e');
    }
  }

  Future<List<LocationData>> getLocationHistory(String busId, DateTime start, DateTime end) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/locations/$busId?start=${start.toIso8601String()}&end=${end.toIso8601String()}'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => LocationData.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch location history: ${response.body}');
      }
    } catch (e) {
      throw Exception('Database connection error: $e');
    }
  }

  // Sensor Data Management
  Future<void> saveSensorData(SensorData sensorData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/sensors'),
        headers: _headers,
        body: jsonEncode(sensorData.toJson()),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to save sensor data: ${response.body}');
      }
    } catch (e) {
      throw Exception('Database connection error: $e');
    }
  }

  Future<List<SensorData>> getSensorHistory(String busId, DateTime start, DateTime end) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/sensors/$busId?start=${start.toIso8601String()}&end=${end.toIso8601String()}'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => SensorData.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch sensor history: ${response.body}');
      }
    } catch (e) {
      throw Exception('Database connection error: $e');
    }
  }

  // Route Management
  Future<List<BusRoute>> getRoutes() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/routes'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => BusRoute.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch routes: ${response.body}');
      }
    } catch (e) {
      throw Exception('Database connection error: $e');
    }
  }

  Future<BusRoute> createRoute(BusRoute route) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/routes'),
        headers: _headers,
        body: jsonEncode(route.toJson()),
      );

      if (response.statusCode == 201) {
        return BusRoute.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create route: ${response.body}');
      }
    } catch (e) {
      throw Exception('Database connection error: $e');
    }
  }

  // Schedule Management
  Future<List<Schedule>> getSchedules() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/schedules'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Schedule.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch schedules: ${response.body}');
      }
    } catch (e) {
      throw Exception('Database connection error: $e');
    }
  }

  Future<Schedule> createSchedule(Schedule schedule) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/schedules'),
        headers: _headers,
        body: jsonEncode(schedule.toJson()),
      );

      if (response.statusCode == 201) {
        return Schedule.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create schedule: ${response.body}');
      }
    } catch (e) {
      throw Exception('Database connection error: $e');
    }
  }

  // Analytics and Reports
  Future<Map<String, dynamic>> getAnalytics(DateTime start, DateTime end) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/analytics?start=${start.toIso8601String()}&end=${end.toIso8601String()}'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch analytics: ${response.body}');
      }
    } catch (e) {
      throw Exception('Database connection error: $e');
    }
  }

  // Health Check
  Future<bool> isConnected() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/health'),
        headers: _headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
