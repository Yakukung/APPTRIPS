import 'dart:convert'; 
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/config.dart';
import 'package:flutter_application_1/models/response/customer_idx_get_res.dart';
import 'package:flutter_application_1/pages/login.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  final int idx;

  const ProfilePage({super.key, required this.idx});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late CustomerIdxGetResponse customer;
  late Future<void> loadData;

  TextEditingController nameCtl = TextEditingController();
  TextEditingController phoneCtl = TextEditingController();
  TextEditingController emailCtl = TextEditingController();
  TextEditingController imageCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    log(widget.idx.toString());
    loadData = loadDataAsync();
  }

  @override
  Widget build(BuildContext context) {
    log('Customer id: ${widget.idx}');
    return Scaffold(
      appBar: AppBar(
        title: const Text('ข้อมูลส่วนตัว'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              log(value);
              if (value == 'delete') {
                showDialog(
                  context: context,
                  builder: (context) => SimpleDialog(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'ยืนยันการยกเลิกสมาชิก?',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('ปิด')),
                          FilledButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _deleteProfile();
                              },
                              child: const Text('ยืนยัน'))
                        ],
                      ),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('ยกเลิกสมาชิก'),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                    height: 220,
                    width: 220,
                    child: customer.image.isNotEmpty
                        ? Image.network(
                            customer.image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                  child: Text('ไม่มีรูปโปรไฟล์'));
                            },
                          )
                        : const Center(child: Text('ไม่มีรูปโปรไฟล์')),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ชื่อ-นามสกุล'),
                        TextField(
                          controller: nameCtl,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('โทรศัพท์'),
                        TextField(
                          controller: phoneCtl,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('อีเมล'),
                        TextField(
                          controller: emailCtl,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('รูปภาพ'),
                        TextField(
                          controller: imageCtl,
                        ),
                      ],
                    ),
                  ),
              SizedBox(
                          width: 95,
                          child: FilledButton(
                            onPressed: () {
                       _saveProfile();
                            },
                            child: const Text('บันทึก'),
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

  Future<void> loadDataAsync() async {
    var config = await Configuration.getConfig();
    var url = config['apiEndpoint'];
    var res = await http.get(Uri.parse('$url/customers/${widget.idx}'));
    log(res.body);
    customer = customerIdxGetResponseFromJson(res.body);

    setState(() {
      nameCtl.text = customer.fullname;
      phoneCtl.text = customer.phone;
      emailCtl.text = customer.email;
      imageCtl.text = customer.image;
    });
  }

  Future<void> _saveProfile() async {
    var config = await Configuration.getConfig();
    var url = config['apiEndpoint'];
    var body = jsonEncode({
      'fullname': nameCtl.text,
      'phone': phoneCtl.text,
      'email': emailCtl.text,
      'image': imageCtl.text,
    });

    var res = await http.put(
      Uri.parse('$url/customers/${widget.idx}'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (res.statusCode == 200) {
      log('อัพเดตข้อมูลเรียบร้อย');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('อัพเดตข้อมูลเรียบร้อย')),
      );
      setState(() {
        loadData = loadDataAsync(); // รีเฟรชข้อมูลหลังจากบันทึก
      });
    } else {
      log('อัพเดตข้อมูลไม่ได้');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('อัพเดตข้อมูลไม่ได้ : ${res.reasonPhrase}')),
      );
    }
  }

  Future<void> _deleteProfile() async {
    var config = await Configuration.getConfig();
    var url = config['apiEndpoint'];

    var res = await http.delete(
      Uri.parse('$url/customers/${widget.idx}'),
      headers: {'Content-Type': 'application/json'},
    );

    if (res.statusCode == 200) {
      log('ยกเลิกสมาชิกเรียบร้อย');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ยกเลิกสมาชิกเรียบร้อย')),
      );
     Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ));
    } else {
      log('ยกเลิกสมาชิกไม่ได้');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ยกเลิกสมาชิกไม่ได้: ${res.reasonPhrase}')),
      );
    }
  }
}
