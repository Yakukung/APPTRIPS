import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/response/trip_idx_get_res.dart';
import 'package:flutter_application_1/config/config.dart';
import 'package:http/http.dart' as http;

class TripPage extends StatefulWidget {
  final int idx;

  const TripPage({super.key, required this.idx});

  @override
  State<TripPage> createState() => _TripPage();
}

class _TripPage extends State<TripPage> {
  late Future<TripIdxGetResponse> loadData;

  @override
  void initState() {
    super.initState();
    log(widget.idx.toString());
    loadData = loadDataAsync();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('รายละเอียดทริป'),
          ],
        ),
      ),
      body: FutureBuilder<TripIdxGetResponse>(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('โหลดข้อมูลไม่สำเร็จ: ${snapshot.error}'));
          }

          final trip = snapshot.data;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    trip!.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'ประเทศ${trip.country}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                trip.coverimage.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.network(
                          trip.coverimage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(child: Text('ไม่มีรูปภาพ'));
                          },
                        ),
                      )
                    : const Center(child: Text('ไม่มีรูปภาพ')),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('ราคา ${trip.price.toString()} บาท'),
                          Text('โซน${trip.destinationZone}'),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: Text(trip.detail),
                      ),
                      Center(
                        child: FilledButton(
                          onPressed: () {
                            // Implement booking action here
                          },
                          child: const Text('จองทริปนี้'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<TripIdxGetResponse> loadDataAsync() async {
    try {
      var value = await Configuration.getConfig();
      var url = value['apiEndpoint'];
      var response = await http.get(Uri.parse('$url/trips/${widget.idx}'));

      if (response.statusCode == 200) {
        return tripIdxGetResponseFromJson(response.body);
      } else {
        throw Exception('โหลดข้อมูลไม่สำเร็จ');
      }
    } catch (e) {
      log(': $e');
      rethrow;
    }
  }
}
