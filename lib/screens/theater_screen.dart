import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class TheaterPage extends StatefulWidget {
  const TheaterPage({Key? key}) : super(key: key);

  @override
  State<TheaterPage> createState() => _TheaterPageState();
}

class _TheaterPageState extends State<TheaterPage> {
  String? selectedCity = "Medan"; // Default Medan setelah login
  bool isLoadingLocation = false;

  final List<String> cities = [
    "Medan",
    "Jakarta",
    "Bandung",
    "Surabaya",
    "Yogyakarta",
  ];

  final Map<String, List<String>> theaters = {
    "Medan": [
      "XI CINEMA",
      "PONDOK KELAPA 21",
      "CGV",
      "CINEPOLIS",
      "CP MALL",
      "HERMES"
    ],
    "Jakarta": ["XXI Plaza Senayan", "CGV Grand Indonesia", "Kota Kasablanka"],
    "Bandung": ["CGV Paris Van Java", "XXI Cihampelas Walk"],
    "Surabaya": ["XXI Tunjungan", "CGV Pakuwon"],
    "Yogyakarta": ["XXI Ambarukmo Plaza", "CGV Jogja City Mall"],
  };

  @override
  void initState() {
    super.initState();
    _determinePosition(); // otomatis deteksi lokasi saat dibuka
  }

  Future<void> _determinePosition() async {
    setState(() => isLoadingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          isLoadingLocation = false;
          selectedCity = "Medan"; // fallback
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            isLoadingLocation = false;
            selectedCity = "Medan";
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          isLoadingLocation = false;
          selectedCity = "Medan";
        });
        return;
      }

      // Ambil koordinat pengguna
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Deteksi kota manual (mock berdasarkan range koordinat)
      String detectedCity =
          _detectCityByCoordinates(position.latitude, position.longitude);

      setState(() {
        selectedCity = detectedCity;
        isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        selectedCity = "Medan";
        isLoadingLocation = false;
      });
    }
  }

  // Fungsi deteksi kota sederhana berdasarkan koordinat
  String _detectCityByCoordinates(double lat, double lon) {
    if (lat > 3.0 && lat < 4.0 && lon > 98.0 && lon < 99.0) return "Medan";
    if (lat > -7.0 && lat < -6.0 && lon > 106.0 && lon < 108.0) return "Jakarta";
    if (lat > -7.0 && lat < -6.7 && lon > 107.0 && lon < 108.0) return "Bandung";
    if (lat > -8.0 && lat < -7.0 && lon > 112.0 && lon < 113.0) return "Surabaya";
    if (lat > -8.0 && lat < -7.0 && lon > 110.0 && lon < 111.0) return "Yogyakarta";
    return "Medan";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF232547),
        title: const Text(
          "THEATER",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoadingLocation
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text(
                    "Mendeteksi lokasi...",
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Dropdown Kota
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E2C54),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.deepPurpleAccent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              dropdownColor: const Color(0xFF2E2C54),
                              value: selectedCity,
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white,
                                size: 28,
                              ),
                              isExpanded: true,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              items: cities.map((city) {
                                return DropdownMenuItem<String>(
                                  value: city,
                                  child: Text(
                                    city.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedCity = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 🔹 Daftar bioskop
                  Expanded(
                    child: ListView.builder(
                      itemCount: theaters[selectedCity]?.length ?? 0,
                      itemBuilder: (context, index) {
                        final theaterName = theaters[selectedCity]![index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          color: Colors.grey[200], // warna abu-abu lembut
                          child: ExpansionTile(
                            title: Text(
                              theaterName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  "Informasi jadwal tayang untuk $theaterName akan segera tersedia.",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
