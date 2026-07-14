import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_logger.dart';

class ZakatScreen extends StatefulWidget {
  const ZakatScreen({super.key});

  @override
  State<ZakatScreen> createState() => _ZakatScreenState();
}

class _ZakatScreenState extends State<ZakatScreen> {
  final TextEditingController _goldController = TextEditingController();
  final TextEditingController _silverController = TextEditingController();
  final TextEditingController _cashController = TextEditingController();
  final TextEditingController _savingsController = TextEditingController();
  final TextEditingController _investmentController = TextEditingController();
  final TextEditingController _propertyController = TextEditingController();

  double _totalWealth = 0;
  double _zakatAmount = 0;
  bool _showResult = false;

  // Current nisab values (approximate)
  final double _nisabGold = 85 * 1100000; // 85 gram × Rp 1,100,000/gram
  final double _nisabSilver = 595 * 16000; // 595 gram × Rp 16,000/gram

  @override
  void dispose() {
    _goldController.dispose();
    _silverController.dispose();
    _cashController.dispose();
    _savingsController.dispose();
    _investmentController.dispose();
    _propertyController.dispose();
    super.dispose();
  }

  void _calculateZakat() {
    final gold = double.tryParse(_goldController.text) ?? 0;
    final silver = double.tryParse(_silverController.text) ?? 0;
    final cash = double.tryParse(_cashController.text) ?? 0;
    final savings = double.tryParse(_savingsController.text) ?? 0;
    final investment = double.tryParse(_investmentController.text) ?? 0;
    final property = double.tryParse(_propertyController.text) ?? 0;

    setState(() {
      _totalWealth = gold + silver + cash + savings + investment + property;
      _zakatAmount = _totalWealth * AppConstants.zakatRate;
      _showResult = true;
    });

    AppLogger.info('Zakat calculated: Total $_totalWealth, Zakat $_zakatAmount');
  }

  void _reset() {
    setState(() {
      _goldController.clear();
      _silverController.clear();
      _cashController.clear();
      _savingsController.clear();
      _investmentController.clear();
      _propertyController.clear();
      _totalWealth = 0;
      _zakatAmount = 0;
      _showResult = false;
    });
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.zakatGradient(context),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              _buildAppBar(),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Info Card
                      _buildInfoCard(),

                      const SizedBox(height: 20),

                      // Input Form
                      _buildInputForm(),

                      const SizedBox(height: 20),

                      // Calculate Button
                      _buildCalculateButton(),

                      // Result
                      if (_showResult) ...[
                        const SizedBox(height: 20),
                        _buildResultCard(),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: Text(
              'Kalkulator Zakat',
              style: AppTextStyles.h3(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: _reset,
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Zakat Maal 2.5%',
                  style: AppTextStyles.h4(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Nisab Emas: ${_formatCurrency(_nisabGold)}',
                  style: AppTextStyles.caption(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                Text(
                  'Nisab Perak: ${_formatCurrency(_nisabSilver)}',
                  style: AppTextStyles.caption(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Harta yang Dimiliki',
            style: AppTextStyles.h4(color: AppColors.textPrimary(context)),
          ),
          const SizedBox(height: 16),

          _buildInputField(
            controller: _goldController,
            label: 'Emas & Perhiasan',
            icon: Icons.monetization_on_outlined,
            prefix: 'Rp',
          ),
          const SizedBox(height: 12),

          _buildInputField(
            controller: _silverController,
            label: 'Perak',
            icon: Icons.account_balance_wallet_outlined,
            prefix: 'Rp',
          ),
          const SizedBox(height: 12),

          _buildInputField(
            controller: _cashController,
            label: 'Uang Tunai',
            icon: Icons.payments_outlined,
            prefix: 'Rp',
          ),
          const SizedBox(height: 12),

          _buildInputField(
            controller: _savingsController,
            label: 'Tabungan',
            icon: Icons.savings_outlined,
            prefix: 'Rp',
          ),
          const SizedBox(height: 12),

          _buildInputField(
            controller: _investmentController,
            label: 'Investasi',
            icon: Icons.trending_up,
            prefix: 'Rp',
          ),
          const SizedBox(height: 12),

          _buildInputField(
            controller: _propertyController,
            label: 'Properti (yang siap jual)',
            icon: Icons.home_outlined,
            prefix: 'Rp',
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String prefix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        prefixText: '$prefix ',
        prefixStyle: AppTextStyles.bodyMedium(color: AppColors.textSecondary(context)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.divider(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildCalculateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _calculateZakat,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Hitung Zakat',
          style: AppTextStyles.buttonLarge(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final nisab = _nisabGold < _nisabSilver ? _nisabGold : _nisabSilver;
    final isAboveNisab = _totalWealth >= nisab;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isAboveNisab
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAboveNisab ? Icons.check_circle : Icons.info,
                  color: isAboveNisab ? AppColors.success : AppColors.warning,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isAboveNisab ? 'Wajib Zakat' : 'Belum Mencapai Nisab',
                  style: AppTextStyles.bodyMedium(
                    color: isAboveNisab ? AppColors.success : AppColors.warning,
                    weight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Total Wealth
          Text(
            'Total Harta',
            style: AppTextStyles.caption(color: AppColors.textSecondary(context)),
          ),
          const SizedBox(height: 4),
          Text(
            _formatCurrency(_totalWealth),
            style: AppTextStyles.h2(color: AppColors.textPrimary(context)),
          ),

          const SizedBox(height: 16),

          // Divider
          const Divider(),

          const SizedBox(height: 16),

          // Zakat Amount
          Text(
            'Zakat yang Dikeluarkan (2.5%)',
            style: AppTextStyles.caption(color: AppColors.textSecondary(context)),
          ),
          const SizedBox(height: 4),
          Text(
            _formatCurrency(_zakatAmount),
            style: AppTextStyles.h1(
              color: isAboveNisab ? AppColors.primary : AppColors.textSecondary(context),
            ),
          ),

          if (!isAboveNisab) ...[
            const SizedBox(height: 12),
            Text(
              'Harta Anda belum mencapai nisab (${_formatCurrency(nisab)})',
              style: AppTextStyles.caption(
                color: AppColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
