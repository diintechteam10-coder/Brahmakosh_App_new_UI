import 'package:brahmakosh/core/common_imports.dart';
import 'package:brahmakosh/features/profile/viewmodels/profile_viewmodel.dart';
import 'package:intl/intl.dart';

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
            colorScheme: const ColorScheme.light(
              primary: Color(0xff5D4037),
              onPrimary: Colors.white,
              onSurface: Color(0xff5D4037),
            ),
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
            colorScheme: const ColorScheme.light(
              primary: Color(0xff5D4037),
              onPrimary: Colors.white,
              onSurface: Color(0xff5D4037),
            ),
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
      backgroundColor: const Color(0xFFFAF3E0), // Light background
      appBar: AppBar(
        title: Text(
          'Update Profile',
          style: GoogleFonts.cinzel(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xff5D4037),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFAF3E0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff5D4037)),
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
                      _buildTextField("Name", _nameController, Icons.person_outline),
                      const SizedBox(height: 16),
                      _buildTextField(
                        "Date of Birth", 
                        _dobController, 
                        Icons.calendar_today,
                        isReadOnly: true,
                        onTap: () => _selectDate(context),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        "Time of Birth", 
                        _timeController, 
                        Icons.access_time,
                        isReadOnly: true,
                        onTap: () => _selectTime(context),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField("Place of Birth", _placeController, Icons.place_outlined),
                      const SizedBox(height: 16),
                      _buildTextField("Profession", _gowthraController, Icons.auto_awesome_outlined),
                      
                      const SizedBox(height: 32),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: vm.isLoading ? null : () {
                            if (_formKey.currentState!.validate()) {
                              final body = {
                                "name": _nameController.text.trim(),
                                "dob": _dobController.text.trim(),
                                "timeOfBirth": _timeController.text.trim(),
                                "placeOfBirth": _placeController.text.trim(),
                                "gowthra": _gowthraController.text.trim(),
                                // Passing empty/dummy image data as per existing structure requirements
                                // or if image picker is implemented later
                                "imageFileName": "", // or handle differently
                                "imageContentType": "" 
                              };
                              vm.updateProfile(body).then((_) {
                                if (vm.errorMessage == null) {
                                   Navigator.pop(context);
                                }
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff5D4037),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: vm.isLoading 
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  "Save Changes", 
                                  style: GoogleFonts.inter(
                                    fontSize: 16, 
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white
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
    return TextFormField(
      controller: controller,
      readOnly: isReadOnly,
      onTap: onTap,
      validator: (value) => value == null || value.isEmpty ? "$label is required" : null,
      style: GoogleFonts.inter(color: const Color(0xff5D4037)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: const Color(0xff8D6E63)),
        prefixIcon: Icon(icon, color: const Color(0xff8D6E63)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xff5D4037), width: 1.5),
        ),
      ),
    );
  }
}
