import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kaf8/Service/api_service.dart';

// Vehicle type data: [typeKey, emoji, label]
const _kTypes = [
  ['truck',     '🚛', 'Truck'],
  ['van',       '🚚', 'Van'],
  ['motorbike', '🏍️', 'Motorbike'],
  ['bike',      '🚲', 'Bicycle'],
  ['car',       '🚗', 'Car'],
  ['pickup',    '🛻', 'Pickup'],
];

/// Multi-step bottom sheet for adding a new vehicle.
/// Returns the created vehicle Map on success, null on cancel.
class AddVehicleSheet extends StatefulWidget {
  const AddVehicleSheet({super.key});

  @override
  State<AddVehicleSheet> createState() => _AddVehicleSheetState();
}

class _AddVehicleSheetState extends State<AddVehicleSheet> {
  int _step = 0;
  String? _selectedType;

  final _brandCtrl       = TextEditingController();
  final _modelCtrl       = TextEditingController();
  final _plateCtrl       = TextEditingController();

  File? _proofFile;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _brandCtrl.addListener(() => setState(() {}));
    _plateCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _plateCtrl.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _brandCtrl.text.trim().isNotEmpty && _plateCtrl.text.trim().isNotEmpty;

  Future<void> _pickProof() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _proofFile = File(picked.path));
  }

  Future<void> _save() async {
    if (!_canSave || _selectedType == null) return;
    setState(() => _isSaving = true);
    final res = await ApiService.createVehicle(
      type: _selectedType!,
      brand: _brandCtrl.text.trim(),
      registration: _plateCtrl.text.trim(),
      model: _modelCtrl.text.trim().isEmpty ? null : _modelCtrl.text.trim(),
    );
    if (!mounted) return;
    if (res['success'] != true) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res['message'] ?? 'Failed to add vehicle'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final vehicle = res['data'] as Map<String, dynamic>? ?? {};

    // Upload proof if provided
    if (_proofFile != null) {
      final vehicleId = vehicle['id']?.toString() ?? '';
      if (vehicleId.isNotEmpty) {
        await ApiService.uploadVehicleProof(vehicleId, _proofFile!.path);
      }
    }

    if (mounted) Navigator.pop(context, vehicle);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _step == 0 ? _buildTypeStep(theme) : _buildDetailsStep(theme),
      ),
    );
  }

  // ── Step 0: vehicle type selection ─────────────────────────────────────────
  Widget _buildTypeStep(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Add a Vehicle',
              style: GoogleFonts.inter(
                  fontSize: 18, fontWeight: FontWeight.w700, color: theme.textTheme.titleLarge?.color)),
          const SizedBox(height: 4),
          Text('Select the type of vehicle you want to add',
              style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[500])),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.0,
            children: _kTypes.map((t) {
              final key   = t[0];
              final emoji = t[1];
              final label = t[2];
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedType = key;
                  _step = 1;
                }),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.dividerColor),
                    boxShadow: [BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2))],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 32)),
                      const SizedBox(height: 6),
                      Text(label,
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.87))),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Step 1: details form ────────────────────────────────────────────────────
  Widget _buildDetailsStep(ThemeData theme) {
    final typeLabel = _kTypes.firstWhere(
      (t) => t[0] == _selectedType,
      orElse: () => ['', '', _selectedType ?? ''],
    )[2];
    final typeEmoji = _kTypes.firstWhere(
      (t) => t[0] == _selectedType,
      orElse: () => ['', '🚗', ''],
    )[1];

    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            GestureDetector(
              onTap: () => setState(() => _step = 0),
              child: Icon(Icons.arrow_back_ios_new, size: 18, color: theme.iconTheme.color),
            ),
            const SizedBox(width: 10),
            Text('$typeEmoji  $typeLabel Details',
                style: GoogleFonts.inter(
                    fontSize: 17, fontWeight: FontWeight.w700, color: theme.textTheme.titleLarge?.color)),
          ]),
          const SizedBox(height: 20),

          _label('Brand *', theme),
          const SizedBox(height: 6),
          _field(_brandCtrl, 'e.g. Toyota', theme),
          const SizedBox(height: 14),

          _label('Model (optional)', theme),
          const SizedBox(height: 6),
          _field(_modelCtrl, 'e.g. Corolla 2021', theme),
          const SizedBox(height: 14),

          _label('License Plate *', theme),
          const SizedBox(height: 6),
          _field(_plateCtrl, 'e.g. AB-123-CD', theme),
          const SizedBox(height: 20),

          // Proof upload (optional)
          GestureDetector(
            onTap: _pickProof,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                border: Border.all(
                    color: _proofFile != null
                        ? Colors.green
                        : theme.dividerColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: theme.dividerColor)),
                  child: _proofFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(_proofFile!, fit: BoxFit.cover))
                      : Icon(Icons.upload_file_outlined,
                          color: Colors.grey[400], size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _proofFile != null
                            ? _proofFile!.path.split('/').last
                            : 'Upload Ownership Proof (optional)',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: theme.textTheme.bodyLarge?.color?.withOpacity(0.87)),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text('JPEG · PNG',
                          style: GoogleFonts.inter(
                              fontSize: 11, color: Colors.grey[400])),
                    ],
                  ),
                ),
              ]),
            ),
          ),

          const SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSave && !_isSaving ? _save : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                disabledBackgroundColor: isDark ? Colors.white10 : Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Add Vehicle',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text, ThemeData theme) => Text(text,
      style: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w500, color: theme.textTheme.bodyLarge?.color?.withOpacity(0.87)));

  Widget _field(TextEditingController ctrl, String hint, ThemeData theme) => TextField(
        controller: ctrl,
        style: GoogleFonts.inter(fontSize: 14, color: theme.textTheme.bodyLarge?.color),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14),
          filled: true,
          fillColor: theme.cardColor,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.green, width: 1.5)),
        ),
      );
}
