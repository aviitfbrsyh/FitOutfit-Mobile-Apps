import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/auth/custom_text_field.dart';
import '../../widgets/auth/auth_button.dart';
import '../../widgets/auth/social_login_button.dart';
import '../../services/auth_service.dart';
import '../../utils/validators.dart';
import 'login_page.dart'; 

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _birthDateController = TextEditingController(); // ✅ NEW: Birth date controller

  final _fullNameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _birthDateFocusNode = FocusNode(); // ✅ NEW: Birth date focus node

  late AnimationController _logoController;
  late AnimationController _formController;
  late AnimationController _strengthController;
  late Animation<double> _logoAnimation;
  late Animation<Offset> _formAnimation;
  late Animation<double> _strengthAnimation;

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _acceptTerms = false;
  PasswordStrength _passwordStrength = PasswordStrength.weak;
  DateTime? _selectedBirthDate; // ✅ NEW: Selected birth date

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _passwordController.addListener(_updatePasswordStrength);
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _formController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _strengthController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));
    _formAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _formController, curve: Curves.easeOutCubic),
    );
    _strengthAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _strengthController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _formController.forward();
    });
  }

  void _updatePasswordStrength() {
    final newStrength = Validators.getPasswordStrength(
      _passwordController.text,
    );
    if (newStrength != _passwordStrength) {
      setState(() {
        _passwordStrength = newStrength;
      });
      _strengthController.reset();
      _strengthController.forward();
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _formController.dispose();
    _strengthController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _birthDateController.dispose(); // ✅ NEW: Dispose birth date controller
    _fullNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _birthDateFocusNode.dispose(); // ✅ NEW: Dispose birth date focus node
    super.dispose();
  }

  // ✅ NEW: Birth date picker
  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // Default to 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 13)), // Minimum 13 years old
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4A90E2),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
        _birthDateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      _showErrorSnackBar('Please accept the Terms & Conditions to continue');
      return;
    }

    if (_selectedBirthDate == null) {
      _showErrorSnackBar('Please select your birth date');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ✅ UPDATED: Pass birth date to registration
      await AuthService.signUpWithEmailPassword(
        email: _emailController.text,
        password: _passwordController.text,
        fullName: _fullNameController.text,
        birthDate: _selectedBirthDate!, // ✅ NEW: Pass birth date
      );
      if (mounted) {
        setState(() => _isLoading = false);
        _showSuccessAnimation();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar(e.toString());
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);

    final result = await AuthService.signInWithGoogle();

    if (mounted) {
      setState(() => _isGoogleLoading = false);

      if (result.success) {
        _navigateToLogin(); // Ubah dari _navigateToHome() ke _navigateToLogin()
      } else {
        _showErrorSnackBar(result.error!);
      }
    }
  }

  void _showSuccessAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Account Created!',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please sign in to continue',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context); // Tutup dialog
        _navigateToLogin(); // Navigasi ke login page
      }
    });
  }

  // Ganti fungsi _navigateToHome() dengan _navigateToLogin()
  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFFD0021B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFAF9F6), Color(0xFFF8F8FF)],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _logoAnimation,
      child: Column(
        children: [
          Text(
            'Create Account',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Join FitOutfit and start your fashion journey',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SlideTransition(
      position: _formAnimation,
      child: FadeTransition(
        opacity: _formController,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                label: 'Full Name',
                hint: 'Enter your full name',
                controller: _fullNameController,
                focusNode: _fullNameFocusNode,
                validator: Validators.validateFullName,
                textInputAction: TextInputAction.next,
                onEditingComplete: () => _emailFocusNode.requestFocus(),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Email',
                hint: 'Enter your email address',
                controller: _emailController,
                focusNode: _emailFocusNode,
                isEmail: true,
                validator: Validators.validateEmail,
                textInputAction: TextInputAction.next,
                onEditingComplete: () => _birthDateFocusNode.requestFocus(), // ✅ UPDATED: Focus to birth date
              ),
              const SizedBox(height: 20),
              // ✅ NEW: Birth Date Field
              _buildBirthDateField(),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Password',
                hint: 'Create a strong password',
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                isPassword: true,
                validator: Validators.validatePassword,
                textInputAction: TextInputAction.next,
                onEditingComplete:
                    () => _confirmPasswordFocusNode.requestFocus(),
              ),
              const SizedBox(height: 8),
              _buildPasswordStrengthIndicator(),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Confirm Password',
                hint: 'Confirm your password',
                controller: _confirmPasswordController,
                focusNode: _confirmPasswordFocusNode,
                isPassword: true,
                validator:
                    (value) => Validators.validateConfirmPassword(
                      value,
                      _passwordController.text,
                    ),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 20),
              _buildTermsCheckbox(),
              const SizedBox(height: 32),
              AuthButton(
                text: 'Create Account',
                onPressed: _handleRegister,
                isLoading: _isLoading,
                gradientColors: const [Color(0xFFF5A623), Color(0xFFE8940F)],
              ),
              const SizedBox(height: 24),
              _buildDivider(),
              const SizedBox(height: 24),
              SocialLoginButton(
                text: 'Continue with Google',
                iconPath: 'assets/google_icon.png',
                onPressed: _handleGoogleSignIn,
                isLoading: _isGoogleLoading,
              ),
              const SizedBox(height: 32),
              _buildSignInLink(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ NEW: Build birth date field
  Widget _buildBirthDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Birth Date',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _birthDateController,
          focusNode: _birthDateFocusNode,
          readOnly: true,
          onTap: _selectBirthDate,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select your birth date';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Select your birth date',
            hintStyle: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            suffixIcon: const Icon(
              Icons.calendar_today,
              color: Color(0xFF4A90E2),
              size: 20,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD0021B), width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD0021B), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[800],
          ),
        ),
        if (_selectedBirthDate != null) ...[
          const SizedBox(height: 4),
          Text(
            'Age: ${_calculateAge(_selectedBirthDate!)} years old',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  // ✅ NEW: Calculate age helper
  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Widget _buildPasswordStrengthIndicator() {
    if (_passwordController.text.isEmpty) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _strengthAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: Colors.grey[300],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: _getStrengthColor(),
                          ),
                        ),
                      ),
                      if (_passwordStrength == PasswordStrength.medium ||
                          _passwordStrength == PasswordStrength.strong) ...[
                        const SizedBox(width: 2),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: _getStrengthColor(),
                            ),
                          ),
                        ),
                      ],
                      if (_passwordStrength == PasswordStrength.strong) ...[
                        const SizedBox(width: 2),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: _getStrengthColor(),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _getStrengthText(),
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: _getStrengthColor(),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      builder: (context, child) {
        return FadeTransition(opacity: _strengthAnimation, child: child);
      },
    );
  }

  Color _getStrengthColor() {
    switch (_passwordStrength) {
      case PasswordStrength.weak:
        return const Color(0xFFD0021B);
      case PasswordStrength.medium:
        return const Color(0xFFF5A623);
      case PasswordStrength.strong:
        return Colors.green;
    }
  }

  String _getStrengthText() {
    switch (_passwordStrength) {
      case PasswordStrength.weak:
        return 'Weak password';
      case PasswordStrength.medium:
        return 'Medium strength';
      case PasswordStrength.strong:
        return 'Strong password';
    }
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Transform.scale(
          scale: 1.2,
          child: Checkbox(
            value: _acceptTerms,
            onChanged: (value) {
              setState(() {
                _acceptTerms = value ?? false;
              });
            },
            activeColor: const Color(0xFF4A90E2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _acceptTerms = !_acceptTerms;
              });
            },
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                children: [
                  const TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms & Conditions',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF4A90E2),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF4A90E2),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[300])),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or continue with',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey[300])),
      ],
    );
  }

  Widget _buildSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'Sign In',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF4A90E2),
            ),
          ),
        ),
      ],
    );
  }
}
