import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/config.dart';
import 'package:flutter_application_1/models/request/Trips_Get_Res.dart';
import 'package:flutter_application_1/pages/profile.dart';
import 'package:flutter_application_1/pages/trip.dart';
import 'package:http/http.dart' as http;

class ShowTrip extends StatefulWidget {
  final int cid;
  const ShowTrip({super.key, required this.cid});

  @override
  State<ShowTrip> createState() => _ShowTripState();
}

class _ShowTripState extends State<ShowTrip> {
  List<TripsGetRequest> trips = [];
  List<String> destinationList = [];
  late Future<void> loadData;
  String url = '';

  @override
  void initState() {
    super.initState();
    log('Show User idx: ${widget.cid}');
    loadData = loadDataAsync();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการทริป'),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              log(value);
              if (value == 'profile') {
                log('Profile page called with idx: ${widget.cid}');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      idx: widget.cid,
                    ),
                  ),
                );
              } else if (value == 'logout') {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'profile',
                child: Text('ข้อมูลส่วนตัว'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('ออกจากระบบ'),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'ปลายทาง',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 95,
                          child: FilledButton(
                            onPressed: () {
                              all(); // Show all trips
                            },
                            child: const Text('ทั้งหมด'),
                          ),
                        ),
                        ...destinationList.map((zone) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 3),
                            child: SizedBox(
                              child: FilledButton(
                                onPressed: () {
                                  getTrips(zone);
                                },
                                child: Text(zone),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: trips
                            .map((trip) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                          height: 200,
                                          width: 380,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  255, 236, 229, 246),
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      18, 13, 18, 0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    trip.name,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 15),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        SizedBox(
                                                          height: 120,
                                                          width: 160,
                                                          child: trip.coverimage
                                                                  .isNotEmpty
                                                              ? (Image.network(
                                                                  trip.coverimage,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  errorBuilder:
                                                                      (context,
                                                                          error,
                                                                          stackTrace) {
                                                                    return const Center(
                                                                        child: Text(
                                                                            'ไม่มีรูปภาพ'));
                                                                  },
                                                                ))
                                                              : (const Center(
                                                                  child: Text(
                                                                      'ไม่มีรูปภาพ'))),
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'ประเทศ${trip.country}',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                              ),
                                                            ),
                                                            Text(
                                                              'ระยะเวลา ${trip.duration} วัน',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                              ),
                                                            ),
                                                            Text(
                                                              'ราคา ${trip.price} บาท',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                              ),
                                                            ),
                                                            FilledButton(
                                                              onPressed: () =>
                                                                  goToTripPage(
                                                                      trip.idx),
                                                              child: const Text(
                                                                  'รายละเอียดเพิ่มเติม'),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void getTrips(String zone) {
    log('Fetching trips with zone: $zone'); // Log the zone being used
    http.get(Uri.parse('$url/trips')).then(
      (value) {
        trips = tripsGetRequestFromJson(value.body);
        log('Filtering by zone: $zone');
        if (zone == 'ทั้งหมด') {
          // Show all trips
          setState(() {
            // If "ทั้งหมด" is selected, don't filter trips
            trips = tripsGetRequestFromJson(value.body);
          });
        } else {
          // Filter trips by zone
          trips = trips.where((trip) => trip.destinationZone == zone).toList();
        }
        setState(() {});
      },
    ).catchError((err) {
      log(err.toString());
    });
  }

  void all() {
    getTrips('ทั้งหมด');
  }

  Future<void> loadDataAsync() async {
    var config = await Configuration.getConfig();
    url = config['apiEndpoint'];

    var res = await http.get(Uri.parse('$url/trips'));
    setState(() {
      trips = tripsGetRequestFromJson(res.body);
      destinationList = trips.map((trip) => trip.destinationZone).toSet().toList();
    });
  }

  void goToTripPage(int idx) {
    log('Navigating to trip page with idx: $idx');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripPage(idx: idx),
      ),
    );
  }
}
