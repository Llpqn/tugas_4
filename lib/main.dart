import 'package:flutter/material.dart';

void main() {
  runApp(const ShoppingCartApp());
}

// ============================================================
// APP ROOT
// ============================================================

class ShoppingCartApp extends StatelessWidget {
  const ShoppingCartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping Cart App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryBlue),
      ),
      home: const CartScreen(),
    );
  }
}

// ============================================================
// THEME (palet warna terpusat, disamakan dengan contoh gambar)
// ============================================================

class AppColors {
  AppColors._();

  static const Color primaryBlue = Color(0xFF2F80ED);
  static const Color background = Color(0xFFF5F6FA);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF8B8B9E);
  static const Color heartRed = Color(0xFFEB5757);
  static const Color selectedBorder = Color(0xFF2F80ED);
  static const Color badgeRed = Color(0xFFEB5757);
}

// ============================================================
// UTIL: format Rupiah, misal 8100000 -> "Rp 8.100.000"
// ============================================================

String formatRupiah(int amount) {
  final buffer = StringBuffer();
  final digits = amount.toString();
  final reversed = digits.split('').reversed.toList();

  for (int i = 0; i < reversed.length; i++) {
    buffer.write(reversed[i]);
    final isGroupEnd = (i + 1) % 3 == 0 && i + 1 != reversed.length;
    if (isGroupEnd) buffer.write('.');
  }

  final grouped = buffer.toString().split('').reversed.join();
  return 'Rp $grouped';
}

// ============================================================
// MODEL: Product
// ============================================================

/// Model data untuk satu produk di dalam keranjang belanja.
///
/// Menyimpan informasi statis (nama, brand, harga, gambar) dan state
/// yang bisa berubah akibat interaksi pengguna (jumlah like, kuantitas,
/// status dipilih/highlight).
class Product {
  final String id;
  final String name;
  final String brand;
  final int price; // dalam Rupiah, misal 1899000
  final String imageAsset;

  int likes;
  int quantity;
  bool isSelected;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.imageAsset,
    this.likes = 0,
    this.quantity = 1,
    this.isSelected = false,
  });

  /// Subtotal harga untuk produk ini (harga x kuantitas).
  int get subtotal => price * quantity;
}

// ============================================================
// SCREEN: CartScreen (StatefulWidget utama)
// ============================================================

/// Layar utama aplikasi: daftar produk di keranjang + ringkasan total.
///
/// StatefulWidget karena daftar produk (kuantitas, like, status pilih)
/// berubah akibat interaksi pengguna dan perlu memicu rebuild lewat
/// setState(). Tiga gesture wajib ditangani lewat GestureDetector di
/// [ProductCard]: Tap (pilih/highlight), Double Tap (tambah like), dan
/// Long Press (tampilkan info) — plus tombol +/- kuantitas.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Data awal 3 produk (syarat minimal 3 produk).
  final List<Product> _products = [
    Product(
      id: 'p1',
      name: 'Logitech G PRO Mechanical Gaming Keyboard',
      brand: 'Logitech G',
      price: 1899000,
      imageAsset: 'assets/images/pngwing.com (99).png',
      likes: 12,
      quantity: 1,
    ),
    Product(
      id: 'p2',
      name: 'Acer Predator GX 792',
      brand: 'Acer Predator',
      price: 24999000,
      imageAsset: 'assets/images/pngwing.com (98).png',
      likes: 8,
      quantity: 1,
    ),
    Product(
      id: 'p3',
      name: 'Razer Kraken 7.1',
      brand: 'Razer',
      price: 1250000,
      imageAsset: 'assets/images/pngwing.com (97).png',
      likes: 5,
      quantity: 1,
    ),
  ];

  int get _totalItems => _products.fold(0, (sum, p) => sum + p.quantity);

  int get _totalPrice => _products.fold(0, (sum, p) => sum + p.subtotal);

  /// Menambah kuantitas satu produk lalu memicu rebuild lewat setState,
  /// sehingga subtotal produk dan total keranjang ikut ter-update.
  void _incrementQuantity(String productId) {
    setState(() {
      final product = _products.firstWhere((p) => p.id == productId);
      product.quantity += 1;
    });
  }

  /// Mengurangi kuantitas satu produk, dengan batas minimum 1.
  void _decrementQuantity(String productId) {
    setState(() {
      final product = _products.firstWhere((p) => p.id == productId);
      if (product.quantity > 1) {
        product.quantity -= 1;
      }
    });
  }

  /// Interaksi #1 — Tap: toggle status "dipilih" pada produk sehingga
  /// border/background kartu berubah (highlight).
  void _toggleSelected(String productId) {
    setState(() {
      final product = _products.firstWhere((p) => p.id == productId);
      product.isSelected = !product.isSelected;
    });
  }

  /// Interaksi #2 — Double Tap: menambah jumlah like produk.
  void _incrementLike(String productId) {
    setState(() {
      final product = _products.firstWhere((p) => p.id == productId);
      product.likes += 1;
    });
  }

  /// Interaksi #3 — Long Press: menampilkan pesan informasi (toast)
  /// bahwa produk ini dipilih, meniru contoh gambar yang diberikan.
  void _showProductInfo(Product product) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1A1A2E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.greenAccent, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Produk dipilih!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '${product.name} telah dipilih.',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Aksi tombol Checkout: sekadar menampilkan ringkasan akhir, karena
  /// alur pembayaran sungguhan berada di luar cakupan tugas ini.
  void _handleCheckout() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Checkout: $_totalItems produk, total ${formatRupiah(_totalPrice)}',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const CartHeader(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 4, bottom: 12),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return ProductCard(
                    product: product,
                    onTap: () => _toggleSelected(product.id),
                    onDoubleTap: () => _incrementLike(product.id),
                    onLongPress: () => _showProductInfo(product),
                    onIncrement: () => _incrementQuantity(product.id),
                    onDecrement: () => _decrementQuantity(product.id),
                  );
                },
              ),
            ),
            CartSummaryBar(
              totalItems: _totalItems,
              totalPrice: _totalPrice,
              onCheckout: _handleCheckout,
            ),
            AppBottomNav(cartBadgeCount: _products.length),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// WIDGET: CartHeader ("My Cart" + subjudul + ikon search)
// ============================================================

class CartHeader extends StatelessWidget {
  const CartHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.shopping_bag_rounded,
                        color: AppColors.primaryBlue, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'My Cart',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Belanja lebih mudah setiap hari',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.search, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// WIDGET: ProductCard (kartu produk + gesture handling)
// ============================================================

/// Kartu satu baris produk di dalam daftar keranjang.
///
/// Murni presentasi (StatelessWidget) — semua perubahan data (like,
/// kuantitas, status pilih) dikelola oleh parent ([_CartScreenState])
/// lewat [Product] yang di-pass masuk beserta callback.
///
/// GestureDetector di sini menangani 3 interaksi wajib: onTap (pilih /
/// highlight), onDoubleTap (tambah like), dan onLongPress (tampilkan
/// info) — masing-masing logic-nya berada di parent.
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onIncrement,
    this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
            product.isSelected ? AppColors.selectedBorder : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProductThumbnail(imageAsset: product.imageAsset),
            const SizedBox(width: 12),
            Expanded(child: _ProductInfo(product: product)),
            const SizedBox(width: 8),
            _QuantityStepper(
              quantity: product.quantity,
              onIncrement: onIncrement,
              onDecrement: onDecrement,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductThumbnail extends StatelessWidget {
  final String imageAsset;

  const _ProductThumbnail({required this.imageAsset});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 72,
        height: 72,
        color: AppColors.background,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Image.asset(imageAsset, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class _ProductInfo extends StatelessWidget {
  final Product product;

  const _ProductInfo({required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          product.brand,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 6),
        Text(
          formatRupiah(product.price),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              product.likes > 0 ? Icons.favorite : Icons.favorite_border,
              size: 16,
              color: AppColors.heartRed,
            ),
            const SizedBox(width: 4),
            Text(
              '${product.likes}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  const _QuantityStepper({
    required this.quantity,
    this.onIncrement,
    this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepperButton(icon: Icons.remove, onTap: onDecrement),
        SizedBox(
          width: 20,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        _StepperButton(icon: Icons.add, onTap: onIncrement, filled: true),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool filled;

  const _StepperButton({required this.icon, this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: filled ? AppColors.primaryBlue : AppColors.background,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 14,
          color: filled ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ============================================================
// WIDGET: CartSummaryBar (total item, total harga, tombol checkout)
// ============================================================

/// Bar ringkasan di bagian bawah daftar produk: menampilkan jumlah
/// produk beserta total harga keseluruhan, dan tombol checkout.
///
/// Memenuhi requirement "Informasi jumlah barang dan total harga" —
/// widget ini murni presentasi, nilainya dihitung oleh screen induk.
class CartSummaryBar extends StatelessWidget {
  final int totalItems;
  final int totalPrice;
  final VoidCallback? onCheckout;

  const CartSummaryBar({
    super.key,
    required this.totalItems,
    required this.totalPrice,
    this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total ($totalItems produk)',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  formatRupiah(totalPrice),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onCheckout,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// WIDGET: AppBottomNav (Beranda, Kategori, Keranjang, Akun)
// ============================================================

/// Bottom navigation bar statis meniru contoh gambar. Tidak ada
/// navigasi sungguhan antar halaman karena scope tugas ini hanya satu
/// layar keranjang — item lain sekadar dekoratif agar tampilan sesuai
/// contoh.
class AppBottomNav extends StatelessWidget {
  final int cartBadgeCount;

  const AppBottomNav({super.key, required this.cartBadgeCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(top: BorderSide(color: Color(0xFFEDEDF2), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const _NavItem(icon: Icons.home_rounded, label: 'Beranda', active: true),
          const _NavItem(icon: Icons.grid_view_rounded, label: 'Kategori'),
          _NavItem(
            icon: Icons.shopping_cart_rounded,
            label: 'Keranjang',
            badgeCount: cartBadgeCount,
          ),
          const _NavItem(icon: Icons.person_rounded, label: 'Akun'),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final int? badgeCount;

  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primaryBlue : AppColors.textSecondary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, color: color, size: 24),
            if (badgeCount != null && badgeCount! > 0)
              Positioned(
                right: -6,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.badgeRed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: color)),
      ],
    );
  }
}

