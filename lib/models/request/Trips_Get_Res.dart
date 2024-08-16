// To parse this JSON data, do
//
//     final tripsGetRequest = tripsGetRequestFromJson(jsonString);

import 'dart:convert';

List<TripsGetRequest> tripsGetRequestFromJson(String str) => List<TripsGetRequest>.from(json.decode(str).map((x) => TripsGetRequest.fromJson(x)));

String tripsGetRequestToJson(List<TripsGetRequest> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TripsGetRequest {
    int idx;
    String name;
    String country;
    String coverimage;
    String detail;
    int price;
    int duration;
    String destinationZone;

    TripsGetRequest({
        required this.idx,
        required this.name,
        required this.country,
        required this.coverimage,
        required this.detail,
        required this.price,
        required this.duration,
        required this.destinationZone,
    });

    factory TripsGetRequest.fromJson(Map<String, dynamic> json) => TripsGetRequest(
        idx: json["idx"],
        name: json["name"],
        country: json["country"],
        coverimage: json["coverimage"],
        detail: json["detail"],
        price: json["price"],
        duration: json["duration"],
        destinationZone: json["destination_zone"],
    );

    Map<String, dynamic> toJson() => {
        "idx": idx,
        "name": name,
        "country": country,
        "coverimage": coverimage,
        "detail": detail,
        "price": price,
        "duration": duration,
        "destination_zone": destinationZone,
    };
}
