import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<StaffMember>> futureStaff;

  @override
  void initState() {
    super.initState();
    futureStaff = fetchStaff();
  }

  Future<List<StaffMember>> fetchStaff() async {
    final response = await http
        .get(Uri.parse('https://hp-api.onrender.com/api/characters/staff'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => StaffMember.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load staff data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Unit 7 - API Calls"),
      ),
      body: FutureBuilder<List<StaffMember>>(
        future: futureStaff,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final staffList = snapshot.data!;
            return ListView.builder(
              itemCount: staffList.length,
              itemBuilder: (context, index) {
                final staff = staffList[index];
                final controller =
                    ExpandedTileController(); // Create a controller for each tile

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: ExpandedTile(
                    controller: controller,
                    title: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(staff.image),
                          radius: 30,
                          onBackgroundImageError: (error, stackTrace) =>
                              const Icon(Icons.image_not_supported, size: 30),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          staff.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    content: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Description",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            staff.description,
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No staff data available'));
          }
        },
      ),
    );
  }
}

class StaffMember {
  final String name;
  final String image;
  final String description;

  StaffMember(
      {required this.name, required this.image, required this.description});

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      name: json['name'],
      image: json['image'],
      description: json['species'] ?? 'No description available',
    );
  }
}
