import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'otp_prefs.dart';

enum _OtpStep { phone, code, verified }

/// Simulated phone verification flow. No real SMS is sent — any 6-digit
/// numeric code is accepted as valid. Real SMS delivery is out of scope
/// for this slice.
class OtpVerifyScreen extends ConsumerStatefulWidget {
  const OtpVerifyScreen({super.key});

  @override
  ConsumerState<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends ConsumerState<OtpVerifyScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  _OtpStep _step = _OtpStep.phone;
  String? _codeError;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _sendCode() {
    setState(() {
      _step = _OtpStep.code;
      _codeError = null;
    });
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    final isValid = RegExp(r'^\d{6}$').hasMatch(code);
    if (!isValid) {
      setState(() {
        _codeError = 'Must be exactly 6 digits';
      });
      return;
    }
    await ref.read(otpPrefsProvider).setVerified();
    if (!mounted) return;
    setState(() {
      _step = _OtpStep.verified;
      _codeError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Verify')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: switch (_step) {
          _OtpStep.phone => _buildPhoneStep(),
          _OtpStep.code => _buildCodeStep(),
          _OtpStep.verified => _buildVerifiedStep(),
        },
      ),
    );
  }

  Widget _buildPhoneStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Phone number', style: AppTextStyles.bodyRegular.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          key: const Key('phoneField'),
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            hintText: 'e.g. 5551234567',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            key: const Key('sendCodeButton'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.ctaBlack),
            onPressed: _sendCode,
            child: const Text('Send code'),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Enter the 6-digit code', style: AppTextStyles.bodyRegular.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          key: const Key('codeField'),
          controller: _codeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: InputDecoration(
            hintText: '123456',
            border: const OutlineInputBorder(),
            errorText: _codeError,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            key: const Key('verifyButton'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.ctaBlack),
            onPressed: _verifyCode,
            child: const Text('Verify'),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifiedStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Verified ✓', style: AppTextStyles.headingDisplay.copyWith(color: AppColors.semanticChill, fontSize: 22)),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.ctaBlack),
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('Done'),
          ),
        ),
      ],
    );
  }
}
