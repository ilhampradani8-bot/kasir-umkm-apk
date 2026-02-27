import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart'; // Import Appodeal SDK
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

// ==========================================
// 1. DATA MODELS & GLOBAL VARIABLES
// ==========================================

class Produk {
  String nama;
  double harga;
  int stok;

  Produk({required this.nama, required this.harga, required this.stok});

  Map<String, dynamic> toJson() => {'nama': nama, 'harga': harga, 'stok': stok};
  factory Produk.fromJson(Map<String, dynamic> json) => Produk(
        nama: json['nama'],
        harga: json['harga'],
        stok: json['stok'],
      );
}

class Transaksi {
  String id; // ID Unik untuk hapus data
  String tanggal;
  String jam;
  double total;
  List<String> detailBarang; // Disimpan sebagai text ringkas buat struk

  Transaksi(
      {required this.id,
      required this.tanggal,
      required this.jam,
      required this.total,
      required this.detailBarang});

  Map<String, dynamic> toJson() => {
        'id': id,
        'tanggal': tanggal,
        'jam': jam,
        'total': total,
        'detailBarang': detailBarang
      };
  factory Transaksi.fromJson(Map<String, dynamic> json) => Transaksi(
        id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        tanggal: json['tanggal'],
        jam: json['jam'],
        total: json['total'],
        detailBarang: List<String>.from(json['detailBarang'] ?? []),
      );
}

// Data Global (Disimpan di RAM)
List<Produk> dbProduk = [];
List<Transaksi> dbLaporan = [];
String namaToko = "Toko Saya";
String alamatToko = "Jl. Raya No. 1";
String footerStruk = "Terima Kasih!";

final NumberFormat rpFormat =
    NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

Future<void> main() async {
  // Ensure Flutter bindings are initialized before calling native code
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Appodeal SDK with your App Key
  Appodeal.initialize(
    appKey: "6e21133cccac68be0d4a44e7969f35e12d69a6f704786b97",
    adTypes: [AppodealAdType.Banner],
  );
  
  // Run the main app
  runApp(const AplikasiKasirV3());
}

class AplikasiKasirV3 extends StatelessWidget {
  const AplikasiKasirV3({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kasir Pro V3',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const LoadingScreen(), // Mulai dari Loading Screen dulu
    );
  }
}

// ==========================================
// 2. LOGIC LOAD & SAVE DATA
// ==========================================

Future<void> simpanSemuaData() async {
  final prefs = await SharedPreferences.getInstance();
  // Simpan Produk
  await prefs.setStringList(
      'db_produk', dbProduk.map((e) => jsonEncode(e.toJson())).toList());
  // Simpan Laporan
  await prefs.setStringList(
      'db_laporan', dbLaporan.map((e) => jsonEncode(e.toJson())).toList());
  // Simpan Profil Toko
  await prefs.setString('toko_nama', namaToko);
  await prefs.setString('toko_alamat', alamatToko);
  await prefs.setString('toko_footer', footerStruk);
}

// ==========================================
// 3. LOADING SCREEN (FIX MASALAH DATA KOSONG)
// ==========================================
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _loadDataAwal();
  }

  Future<void> _loadDataAwal() async {
    final prefs = await SharedPreferences.getInstance();

    // Load Produk
    List<String>? prodStr = prefs.getStringList('db_produk');
    if (prodStr != null) {
      dbProduk = prodStr.map((e) => Produk.fromJson(jsonDecode(e))).toList();
    }

    // Load Laporan
    List<String>? lapStr = prefs.getStringList('db_laporan');
    if (lapStr != null) {
      dbLaporan = lapStr.map((e) => Transaksi.fromJson(jsonDecode(e))).toList();
    }

    // Load Toko
    namaToko = prefs.getString('toko_nama') ?? "Toko Saya";
    alamatToko = prefs.getString('toko_alamat') ?? "Indonesia";
    footerStruk =
        prefs.getString('toko_footer') ?? "Terima Kasih, Datang Kembali!";

    // Pindah ke Halaman Utama setelah selesai
    if (mounted) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const HalamanUtama()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Sedang Memuat Data Toko..."),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 4. HALAMAN UTAMA (NAVIGASI)
// ==========================================
class HalamanUtama extends StatefulWidget {
  const HalamanUtama({super.key});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  int _index = 0;

  // Kita tidak pakai IndexedStack agar halaman selalu refresh saat diklik
  final List<Widget> _pages = [
    const HalamanKasir(),
    const HalamanStok(),
    const HalamanLaporan(),
    const HalamanPengaturan(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Supaya 4 tombol muat
        currentIndex: _index,
        selectedItemColor: Colors.teal,
        onTap: (i) {
          setState(() {
            _index = i;
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.point_of_sale), label: 'Kasir'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Stok'),
          BottomNavigationBarItem(
              icon: Icon(Icons.analytics), label: 'Laporan'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Pengaturan'),
        ],
      ),
    );
  }
}

// ==========================================
// 5. HALAMAN KASIR (DENGAN STRUK)
// ==========================================
class HalamanKasir extends StatefulWidget {
  const HalamanKasir({super.key});

  @override
  State<HalamanKasir> createState() => _HalamanKasirState();
}

class _HalamanKasirState extends State<HalamanKasir> {
  Map<int, int> keranjang = {}; // Key: Index Produk, Value: Jumlah

  void _ubahKeranjang(int index, int delta) {
    setState(() {
      int stokTersedia = dbProduk[index].stok;
      int jumlahDiKeranjang = keranjang[index] ?? 0;

      if (delta > 0) {
        // Tambah
        if (stokTersedia > 0) {
          keranjang[index] = jumlahDiKeranjang + 1;
          dbProduk[index].stok--; // Kurangi visual stok
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Stok Habis!"),
              duration: Duration(milliseconds: 500)));
        }
      } else {
        // Kurang
        if (jumlahDiKeranjang > 0) {
          keranjang[index] = jumlahDiKeranjang - 1;
          dbProduk[index].stok++; // Balikin visual stok
          if (keranjang[index] == 0) keranjang.remove(index);
        }
      }
    });
  }

  void _bayar() {
    double total = 0;
    List<String> detailItems = [];

    keranjang.forEach((idx, qty) {
      double subtotal = dbProduk[idx].harga * qty;
      total += subtotal;
      detailItems
          .add("${dbProduk[idx].nama} x$qty = ${rpFormat.format(subtotal)}");
    });

    // Simpan Transaksi
    final trx = Transaksi(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tanggal: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      jam: DateFormat('HH:mm').format(DateTime.now()),
      total: total,
      detailBarang: detailItems,
    );

    dbLaporan.add(trx);
    simpanSemuaData(); // Simpan Permanen

    // Reset Keranjang
    setState(() {
      keranjang.clear();
    });

    // TAMPILKAN STRUK
    _tampilkanStruk(trx);
  }

  void _tampilkanStruk(Transaksi trx) {
    showDialog(
      context: context,
      barrierDismissible: false, // Harus klik tutup
      builder: (context) => AlertDialog(
        title: const Center(
            child: Icon(Icons.check_circle, color: Colors.green, size: 50)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
                child: Text("PEMBAYARAN SUKSES",
                    style: TextStyle(fontWeight: FontWeight.bold))),
            const Divider(),
            Text(namaToko,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                textAlign: TextAlign.center),
            Text(alamatToko,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center),
            const Divider(),
            Text("Tgl: ${trx.tanggal} ${trx.jam}"),
            const Divider(),
            ...trx.detailBarang
                .map((e) => Text(e, style: const TextStyle(fontSize: 12))),
            const Divider(),
            Text("TOTAL: ${rpFormat.format(trx.total)}",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.right),
            const SizedBox(height: 10),
            Text(footerStruk,
                style:
                    const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Fitur Share Struk (Teks)
              String strukText = "*$namaToko*\n$alamatToko\n----------------\n";
              strukText += "Tgl: ${trx.tanggal} ${trx.jam}\n----------------\n";
              for (var item in trx.detailBarang) {
                strukText += "$item\n";
              }
              strukText +=
                  "----------------\n*TOTAL: ${rpFormat.format(trx.total)}*\n\n$footerStruk";

              Share.share(strukText);
            },
            child: const Text("BAGIKAN / PRINT"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("TUTUP"),
          ),
        ],
      ),
    );
  }

 @override
  Widget build(BuildContext context) {
    // Calculate total payment
    double totalBayar = 0;
    keranjang.forEach((idx, qty) => totalBayar += dbProduk[idx].harga * qty);

    // Return the main scaffold for Kasir UI
    return Scaffold(
      appBar: AppBar(title: const Text("Kasir"), actions: [
        IconButton(
            icon: const Icon(Icons.refresh), onPressed: () => setState(() {}))
      ]),
      body: Column(
        children: [
          // Product grid section
          Expanded(
            child: dbProduk.isEmpty
                ? const Center(
                    child: Text("Barang kosong. Masukkan di menu Stok."))
                : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10),
                    itemCount: dbProduk.length,
                    itemBuilder: (ctx, i) {
                      final produk = dbProduk[i];
                      final qty = keranjang[i] ?? 0;
                      return Card(
                        color: qty > 0 ? Colors.teal[50] : Colors.white,
                        elevation: 3,
                        child: InkWell(
                          onTap: () => _ubahKeranjang(i, 1),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                  backgroundColor: Colors.teal,
                                  child: Text(produk.nama[0],
                                      style: const TextStyle(
                                          color: Colors.white))),
                              const SizedBox(height: 5),
                              Text(produk.nama,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center),
                              Text(rpFormat.format(produk.harga),
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                              Text("Stok: ${produk.stok}",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: produk.stok == 0
                                          ? Colors.red
                                          : Colors.green)),
                              const SizedBox(height: 5),
                              if (qty > 0)
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.teal,
                                      borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  child: Text("${qty}x",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
          // Appodeal Banner Ad placed above the total panel
          const AppodealBanner(
            adSize: AppodealBannerSize.BANNER,
            placement: "default",
          ),

          // Total payment panel section
          Container(
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                  blurRadius: 5, color: Colors.black12, offset: Offset(0, -3))
            ]),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Total Bayar:", style: TextStyle(fontSize: 12)),
                    Text(rpFormat.format(totalBayar),
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal)),
                  ],
                ),
                const Spacer(),
                if (totalBayar > 0)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12)),
                        onPressed: _bayar,
                        icon: const Icon(Icons.print),
                        label: const Text("BAYAR"),
                  )
              ],
            ),
          )
        ],
      ),
    );
  }

// ==========================================
// 6. HALAMAN STOK (SAMA TAPI LEBIH STABIL)
// ==========================================
class HalamanStok extends StatefulWidget {
  const HalamanStok({super.key});

  @override
  State<HalamanStok> createState() => _HalamanStokState();
}

class _HalamanStokState extends State<HalamanStok> {
  void _formBarang({Produk? barang, int? index}) {
    final namaC = TextEditingController(text: barang?.nama ?? "");
    final hargaC =
        TextEditingController(text: barang?.harga.toStringAsFixed(0) ?? "");
    final stokC = TextEditingController(text: barang?.stok.toString() ?? "");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(barang == null ? "Tambah Barang" : "Edit Barang"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: namaC,
                decoration: const InputDecoration(labelText: "Nama Barang")),
            TextField(
                controller: hargaC,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Harga")),
            TextField(
                controller: stokC,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Stok Awal")),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              final newProd = Produk(
                nama: namaC.text,
                harga: double.tryParse(hargaC.text) ?? 0,
                stok: int.tryParse(stokC.text) ?? 0,
              );
              setState(() {
                if (barang == null) {
                  dbProduk.add(newProd);
                } else {
                  dbProduk[index!] = newProd;
                }
              });
              simpanSemuaData();
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stok Barang")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _formBarang(),
        child: const Icon(Icons.add),
      ),
      body: ListView.separated(
        itemCount: dbProduk.length,
        separatorBuilder: (c, i) => const Divider(),
        itemBuilder: (c, i) {
          final p = dbProduk[i];
          return ListTile(
            title: Text(p.nama,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${rpFormat.format(p.harga)} | Stok: ${p.stok}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _formBarang(barang: p, index: i)),
                IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() => dbProduk.removeAt(i));
                      simpanSemuaData();
                    }),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
// 7. HALAMAN LAPORAN
// ==========================================
class HalamanLaporan extends StatelessWidget {
  const HalamanLaporan({super.key});

  @override
  Widget build(BuildContext context) {
    // Hitung Omzet Hari Ini
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    double omzetHariIni = dbLaporan
        .where((t) => t.tanggal == today)
        .fold(0, (sum, t) => sum + t.total);

    return Scaffold(
      appBar: AppBar(title: const Text("Laporan Singkat")),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.teal,
            child: Column(
              children: [
                const Text("Omzet Hari Ini",
                    style: TextStyle(color: Colors.white70)),
                Text(rpFormat.format(omzetHariIni),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                  "Total ${dbLaporan.length} Transaksi tersimpan.\nLihat detail di menu Pengaturan.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey)),
            ),
          )
        ],
      ),
    );
  }
}

// ==========================================
// 8. HALAMAN PENGATURAN (BARU!)
// ==========================================
class HalamanPengaturan extends StatelessWidget {
  const HalamanPengaturan({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pengaturan & Riwayat")),
      body: ListView(
        children: [
          const Padding(
              padding: EdgeInsets.all(16),
              child: Text("Menu Kasir",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey))),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text("Atur Header Struk"),
            subtitle: const Text("Nama Toko & Alamat"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (c) => const AturStrukPage())),
          ),
          const Divider(),
          const Padding(
              padding: EdgeInsets.all(16),
              child: Text("Data Transaksi",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey))),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("Riwayat Transaksi"),
            subtitle: const Text("Lihat, Hapus, atau Cetak Ulang"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (c) => const RiwayatPage())),
          ),
        ],
      ),
    );
  }
}

// SUB-HALAMAN: ATUR STRUK
class AturStrukPage extends StatefulWidget {
  const AturStrukPage({super.key});
  @override
  State<AturStrukPage> createState() => _AturStrukPageState();
}

class _AturStrukPageState extends State<AturStrukPage> {
  final _namaC = TextEditingController(text: namaToko);
  final _alamatC = TextEditingController(text: alamatToko);
  final _footerC = TextEditingController(text: footerStruk);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Struk")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: _namaC,
                decoration:
                    const InputDecoration(labelText: "Nama Toko (Header)")),
            TextField(
                controller: _alamatC,
                decoration: const InputDecoration(labelText: "Alamat Toko")),
            TextField(
                controller: _footerC,
                decoration:
                    const InputDecoration(labelText: "Pesan Bawah (Footer)")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  namaToko = _namaC.text;
                  alamatToko = _alamatC.text;
                  footerStruk = _footerC.text;
                });
                simpanSemuaData();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Pengaturan Struk Disimpan!")));
                Navigator.pop(context);
              },
              child: const Text("SIMPAN PENGATURAN"),
            )
          ],
        ),
      ),
    );
  }
}

// SUB-HALAMAN: RIWAYAT
class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});
  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  @override
  Widget build(BuildContext context) {
    // Urutkan dari yang terbaru
    final List<Transaksi> list = List.from(dbLaporan.reversed);

    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Transaksi")),
      body: list.isEmpty
          ? const Center(child: Text("Belum ada transaksi"))
          : ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                final t = list[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ExpansionTile(
                    leading: const Icon(Icons.receipt_long, color: Colors.teal),
                    title: Text("Rp ${rpFormat.format(t.total)}"),
                    subtitle: Text("${t.tanggal} - ${t.jam}"),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        color: Colors.grey[50],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...t.detailBarang.map((e) =>
                                Text(e, style: const TextStyle(fontSize: 12))),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.share, size: 16),
                                  label: const Text("Share Struk"),
                                  onPressed: () {
                                    // Logika Share sama seperti saat bayar
                                    String strukText =
                                        "*$namaToko*\n$alamatToko\n----------------\n";
                                    strukText +=
                                        "Tgl: ${t.tanggal} ${t.jam}\n----------------\n";
                                    for (var item in t.detailBarang) {
                                      strukText += "$item\n";
                                    }
                                    strukText +=
                                        "----------------\n*TOTAL: ${rpFormat.format(t.total)}*\n\n$footerStruk";
                                    Share.share(strukText);
                                  },
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red, size: 16),
                                  label: const Text("Hapus",
                                      style: TextStyle(color: Colors.red)),
                                  onPressed: () {
                                    // HAPUS DATA
                                    showDialog(
                                        context: context,
                                        builder: (c) => AlertDialog(
                                              title: const Text(
                                                  "Hapus Transaksi?"),
                                              content: const Text(
                                                  "Data laporan & uang akan berkurang."),
                                              actions: [
                                                TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(c),
                                                    child: const Text("Batal")),
                                                TextButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        dbLaporan.removeWhere(
                                                            (element) =>
                                                                element.id ==
                                                                t.id);
                                                      });
                                                      simpanSemuaData();
                                                      Navigator.pop(
                                                          c); // Tutup Dialog
                                                      // Refresh Halaman ini akan otomatis karena setState
                                                    },
                                                    child: const Text("HAPUS",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.red))),
                                              ],
                                            ));
                                  },
                                )
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }
}
