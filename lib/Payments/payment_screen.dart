import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  final String planName; // เช่น 'Monthly ($49.99)' หรือ 'Yearly ($129.99)'
  final double price;    // 49.99 หรือ 129.99

  const PaymentScreen({
    super.key,
    required this.planName,
    required this.price,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // วิธีจ่าย: 0 = Mastercard, 1 = PayPal, 2 = ApplePay
  int _payMethod = 0;

  // ทำเป็น List ปกติเพื่อให้เพิ่มบัตรใหม่ได้
  final List<_MockCard> _cards = [
    const _MockCard(
      bank: 'FYI BANK',
      brand: 'VISA',
      number: '0000 2363 8364 8269',
      validThru: '5/23',
      cvv: '633',
      holder: 'George Josure',
      colors: [Color(0xFFE91E63), Color(0xFF7B1FA2)],
    ),
    const _MockCard(
      bank: 'TheraPay',
      brand: 'MASTER',
      number: '5555 2200 9900 1111',
      validThru: '8/26',
      cvv: '421',
      holder: 'George Josure',
      colors: [Color(0xFF283593), Color(0xFF1E88E5)],
    ),
    const _MockCard(
      bank: 'Sky Bank',
      brand: 'VISA',
      number: '4111 8888 2222 3333',
      validThru: '12/27',
      cvv: '802',
      holder: 'George Josure',
      colors: [Color(0xFF00897B), Color(0xFF26A69A)],
    ),
  ];

  final _pageCtrl = PageController(viewportFraction: 0.90);
  int _page = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vat = (widget.price * 0.07);
    final total = widget.price + vat;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            // App bar
            Row(
              children: [
                _roundIcon(
                  Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Payment options',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // วิธีจ่าย
            Row(
              children: [
                _payChip(
                  selected: _payMethod == 0,
                  child: _brandIcon('MC'),
                  onTap: () => setState(() => _payMethod = 0),
                ),
                const SizedBox(width: 12),
                _payChip(
                  selected: _payMethod == 1,
                  child: _brandIcon('PP'),
                  onTap: () => setState(() => _payMethod = 1),
                ),
                const SizedBox(width: 12),
                _payChip(
                  selected: _payMethod == 2,
                  child: _brandIcon('AP'),
                  onTap: () => setState(() => _payMethod = 2),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // หัวข้อ Select your card + ปุ่มเพิ่มบัตร
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Select your card',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
                InkWell(
                  onTap: _openAddCardSheet,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.06),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Color(0xFF00B2E3)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Card carousel
            SizedBox(
              height: 210,
              child: PageView.builder(
                controller: _pageCtrl,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _cards.length,
                itemBuilder: (_, i) => _CreditCard(card: _cards[i]),
              ),
            ),
            const SizedBox(height: 8),
            _dots(count: _cards.length, index: _page),

            const SizedBox(height: 24),

            // สรุปยอด
            _rowPrice(widget.planName, widget.price),
            _rowPrice('Vat 7%', vat),
            const Divider(height: 20),
            _rowPrice('Total amount', total, bold: true),

            const SizedBox(height: 24),

            // ปุ่ม Continue
            SizedBox(
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B2E3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  final method = ['Mastercard', 'PayPal', 'Apple Pay'][_payMethod];
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Pay with $method • Total \$${total.toStringAsFixed(2)}'),
                    ),
                  );
                  // TODO: เรียก payment flow ของจริง
                },
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
            ),

            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 140,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFF6B4A3A),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // เปิดฟอร์มเพิ่มบัตร
  void _openAddCardSheet() {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final numberCtrl = TextEditingController();
    final expiryCtrl = TextEditingController();
    final cvvCtrl = TextEditingController();
    bool agree = false;
    bool saveCard = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final bottom = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: bottom + 16, top: 16),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Enter card details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),
                  _input(
                    label: 'Card name',
                    controller: nameCtrl,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter card holder name' : null,
                  ),
                  const SizedBox(height: 12),
                  _input(
                    label: 'Card number',
                    controller: numberCtrl,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final t = v?.replaceAll(' ', '') ?? '';
                      if (t.length < 13) return 'Card number is invalid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _input(
                          label: 'Expiry date',
                          hint: 'MM/YY',
                          controller: expiryCtrl,
                          keyboardType: TextInputType.datetime,
                          validator: (v) => (v == null || !RegExp(r'^\d{1,2}/\d{2}$').hasMatch(v))
                              ? 'Invalid date'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _input(
                          label: 'CVV',
                          controller: cvvCtrl,
                          keyboardType: TextInputType.number,
                          obscure: true,
                          validator: (v) => (v == null || v.length < 3) ? 'Invalid CVV' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  StatefulBuilder(
                    builder: (ctx, setSB) => Column(
                      children: [
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          value: agree,
                          onChanged: (v) => setSB(() => agree = v ?? false),
                          title: Row(
                            children: const [
                              Text('I agree to the '),
                              Text(
                                'Terms and Conditions',
                                style: TextStyle(
                                  color: Color(0xFF00A3D4),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          value: saveCard,
                          onChanged: (v) => setSB(() => saveCard = v ?? false),
                          title: const Text('Save card details'),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B2E3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        if (!agree) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please agree to the Terms and Conditions')),
                          );
                          return;
                        }

                        // เดา brand จากเลขขึ้นต้น (5 = MasterCard, 4 = Visa)
                        final digits = numberCtrl.text.replaceAll(' ', '');
                        final brand = digits.startsWith('5')
                            ? 'MASTER'
                            : digits.startsWith('4')
                                ? 'VISA'
                                : 'CARD';

                        final newCard = _MockCard(
                          bank: 'New Bank',
                          brand: brand,
                          number: _formatCardNumber(numberCtrl.text),
                          validThru: expiryCtrl.text,
                          cvv: cvvCtrl.text,
                          holder: nameCtrl.text,
                          colors: const [Color(0xFF6A11CB), Color(0xFF2575FC)], // ไล่เฉดม่วง-ฟ้า
                        );

                        setState(() {
                          _cards.add(newCard);
                        });

                        // เลื่อนไปการ์ดล่าสุด
                        Navigator.pop(context);
                        Future.delayed(const Duration(milliseconds: 120), () {
                          _pageCtrl.animateToPage(
                            _cards.length - 1,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        });
                      },
                      child: const Text(
                        'Confirm',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ---- helpers ----
  static Widget _input({
    required String label,
    String? hint,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF7F8FA),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00B2E3)),
            ),
          ),
        ),
      ],
    );
  }

  static String _formatCardNumber(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i != 0 && i % 4 == 0) buf.write(' ');
      buf.write(digits[i]);
    }
    return buf.toString();
  }

  // --- small helpers UI ---
  static Widget _roundIcon(IconData icon, {VoidCallback? onTap}) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, size: 20, color: Colors.black87),
        ),
      );

  static Widget _brandIcon(String tag) {
    switch (tag) {
      case 'MC':
        return const Icon(Icons.account_balance_wallet_rounded, color: Colors.red, size: 28);
      case 'PP':
        return const Icon(Icons.payments_rounded, color: Color(0xFF0A66C2), size: 28);
      case 'AP':
        return const Icon(Icons.phone_iphone_rounded, color: Colors.black87, size: 28);
      default:
        return const Icon(Icons.credit_card, size: 28);
    }
  }

  static Widget _payChip({
    required bool selected,
    required Widget child,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? const Color(0xFF00B2E3) : const Color(0xFFE6E9EF),
              width: selected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(child: child),
        ),
      ),
    );
  }

  static Widget _rowPrice(String title, double amount, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
                color: const Color(0xFF303030),
              ),
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w800,
              color: const Color(0xFF303030),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _dots({required int count, required int index}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == index ? 28 : 10,
          height: 6,
          decoration: BoxDecoration(
            color: i == index ? const Color(0xFF00B2E3) : const Color(0xFFCBD6E2),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

// ----- card widgets & models -----
class _MockCard {
  final String bank;
  final String brand;
  final String number;
  final String validThru;
  final String cvv;
  final String holder;
  final List<Color> colors;

  const _MockCard({
    required this.bank,
    required this.brand,
    required this.number,
    required this.validThru,
    required this.cvv,
    required this.holder,
    required this.colors,
  });
}

class _CreditCard extends StatelessWidget {
  final _MockCard card;
  const _CreditCard({required this.card});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: card.colors),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.12),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // top row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  card.bank,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                Text(
                  card.brand,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              card.number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                letterSpacing: 1.2,
                fontFeatures: [FontFeature.tabularFigures()],
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _mini('VALID\nTHRU', card.validThru),
                const SizedBox(width: 20),
                _mini('', card.cvv),
                const Spacer(),
                const Icon(Icons.wifi_tethering_rounded, color: Colors.white),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  card.holder,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  card.brand,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  static Widget _mini(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(.8),
              fontSize: 10,
              height: 1.1,
            ),
          ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
