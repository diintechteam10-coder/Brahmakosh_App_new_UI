import 'package:brahmakosh/core/common_imports.dart';
import 'package:brahmakosh/features/profile/viewmodels/profile_viewmodel.dart';
import 'package:brahmakosh/core/localization/translate_helper.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class UpdateProfileView extends StatefulWidget {
  const UpdateProfileView({super.key});

  @override
  State<UpdateProfileView> createState() => _UpdateProfileViewState();
}

class _UpdateProfileViewState extends State<UpdateProfileView> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _timeController;
  late TextEditingController _placeController;
  late TextEditingController _gowthraController;

  @override
  void initState() {
    super.initState();
    final vm = Provider.of<ProfileViewModel>(context, listen: false);
    final profile = vm.profile?.profile;

    _nameController = TextEditingController(text: profile?.name ?? '');
    
    // Format DOB if exists
    String dob = '';
    if (profile?.dob != null) {
       try {
         final date = DateTime.parse(profile!.dob!);
         dob = DateFormat('yyyy-MM-dd').format(date);
       } catch (e) {
         dob = profile!.dob!;
       }
    }
    _dobController = TextEditingController(text: dob);
    
    _timeController = TextEditingController(text: profile?.timeOfBirth ?? '');
    _placeController = TextEditingController(text: profile?.placeOfBirth ?? '');
    _gowthraController = TextEditingController(text: profile?.gowthra ?? '');
    
    // Translate dynamic data from API if locale is Hindi
    _translateInitialData();
  }

  Future<void> _translateInitialData() async {
    if (Get.locale?.languageCode == 'hi') {
      final translatedPlace = await TranslateHelper.translate(_placeController.text);
      final translatedGowthra = await TranslateHelper.translate(_gowthraController.text);
      final translatedName = await TranslateHelper.translate(_nameController.text);
      
      if (mounted) {
        setState(() {
          _placeController.text = translatedPlace;
          _gowthraController.text = translatedGowthra;
          _nameController.text = translatedName;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _timeController.dispose();
    _placeController.dispose();
    _gowthraController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFD4AF37), // Gold
              onPrimary: Colors.black,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF1E1E1E),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFD4AF37), // Gold
              onPrimary: Colors.black,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF1E1E1E),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background
      appBar: AppBar(
        title: Text(
          'update_profile'.tr,
          style: GoogleFonts.lora(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<ProfileViewModel>(
        builder: (context, vm, child) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField("full_name".tr, _nameController, Icons.person_outline),
                      const SizedBox(height: 16),
                      _buildTextField(
                        "dob".tr, 
                        _dobController, 
                        Icons.calendar_today,
                        isReadOnly: true,
                        onTap: () => _selectDate(context),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        "tob".tr, 
                        _timeController, 
                        Icons.access_time,
                        isReadOnly: true,
                        onTap: () => _selectTime(context),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField("pob".tr, _placeController, Icons.place_outlined),
                      const SizedBox(height: 16),
                      _buildTextField("profession".tr, _gowthraController, Icons.auto_awesome_outlined),
                      
                      const SizedBox(height: 48),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: vm.isLoading ? null : () {
                            if (_formKey.currentState!.validate()) {
                              final body = {
                                "name": _nameController.text.trim(),
                                "dob": _dobController.text.trim(),
                                "timeOfBirth": _timeController.text.trim(),
                                "placeOfBirth": _placeController.text.trim(),
                                "gowthra": _gowthraController.text.trim(),
                                "imageFileName": "", 
                                "imageContentType": "" 
                              };
                              vm.updateProfile(body).then((_) {
                                if (vm.errorMessage == null) {
                                   Navigator.pop(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(vm.errorMessage!)),
                                  );
                                }
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4AF37), // Gold background
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: vm.isLoading 
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)
                                )
                              : Text(
                                  "save_changes".tr, 
                                  style: GoogleFonts.poppins(
                                    fontSize: 16, 
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black
                                  )
                                ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField(
    String label, 
    TextEditingController controller, 
    IconData icon, 
    {bool isReadOnly = false, VoidCallback? onTap}
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: isReadOnly,
          onTap: onTap,
          validator: (value) => value == null || value.isEmpty ? "$label ${'is_required'.tr}" : null,
          style: GoogleFonts.poppins(color: Colors.white),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: GoogleFonts.poppins(color: Colors.white38),
            prefixIcon: Icon(icon, color: Colors.white70, size: 20),
            filled: true,
            fillColor: const Color(0xFF141414), // Dark input background
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white10, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white10, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}
