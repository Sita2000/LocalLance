import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  bool _isFreelancer = true;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  String? _selectedGender;
  String? _workExperience;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Success',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white 
                : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'You have successfully signed up!',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white70 
                : Colors.black87,
            ),
          ),
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: const Color(0xFF1E3A5F),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if dark mode is enabled
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Set colors based on theme
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final cardColor = isDarkMode ? Colors.grey[850] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final hintTextColor = isDarkMode ? Colors.grey[400] : Colors.grey;
    final primaryColor = const Color(0xFF1E3A5F);
    final secondaryBackgroundColor = isDarkMode ? Colors.grey[800] : Colors.grey[200];
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'Sign Up', 
          style: TextStyle(
            color: textColor, 
            fontWeight: FontWeight.bold, 
            fontSize: 20
          )
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isDarkMode 
                  ? [] 
                  : [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subtitle
                    Center(
                      child: Text(
                        'Create an account and get started!',
                        style: TextStyle(
                          fontSize: 14,
                          color: hintTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Toggle button for Freelancer/Recruiter
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: secondaryBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          // Freelancer button
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isFreelancer = true;
                                });
                              },
                              child: Container(
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  color: _isFreelancer ? primaryColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    'Freelancer',
                                    style: TextStyle(
                                      color: _isFreelancer 
                                        ? Colors.white 
                                        : (isDarkMode ? Colors.white : Colors.black),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Recruiter button
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isFreelancer = false;
                                });
                              },
                              child: Container(
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  color: !_isFreelancer ? primaryColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    'Recruiter',
                                    style: TextStyle(
                                      color: !_isFreelancer 
                                        ? Colors.white 
                                        : (isDarkMode ? Colors.white : Colors.black),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Full Name field
                    Text(
                      'Full Name',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Enter your name',
                        hintStyle: TextStyle(color: hintTextColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: isDarkMode ? Colors.grey[700]! : Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: isDarkMode ? Colors.grey[700]! : Colors.grey),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        filled: isDarkMode,
                        fillColor: isDarkMode ? Colors.grey[800] : null,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Email Address field
                    Text(
                      'Email Address',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        hintStyle: TextStyle(color: hintTextColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: isDarkMode ? Colors.grey[700]! : Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: isDarkMode ? Colors.grey[700]! : Colors.grey),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        filled: isDarkMode,
                        fillColor: isDarkMode ? Colors.grey[800] : null,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        // Email regex validation
                        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Phone field
                    Text(
                      'Phone Number',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Enter your phone number',
                        hintStyle: TextStyle(color: hintTextColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: isDarkMode ? Colors.grey[700]! : Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: isDarkMode ? Colors.grey[700]! : Colors.grey),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        filled: isDarkMode,
                        fillColor: isDarkMode ? Colors.grey[800] : null,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        // Phone number validation: must be 10 digits
                        if (value.replaceAll(RegExp(r'\D'), '').length != 10) {
                          return 'Please enter a valid 10-digit phone number';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Password field
                    Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_passwordVisible,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        hintStyle: TextStyle(color: hintTextColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: isDarkMode ? Colors.grey[700]! : Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: isDarkMode ? Colors.grey[700]! : Colors.grey),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible ? Icons.visibility : Icons.visibility_off,
                            color: hintTextColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        filled: isDarkMode,
                        fillColor: isDarkMode ? Colors.grey[800] : null,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Confirm Password field
                    Text(
                      'Confirm Password',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: !_confirmPasswordVisible,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Confirm your password',
                        hintStyle: TextStyle(color: hintTextColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: isDarkMode ? Colors.grey[700]! : Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: isDarkMode ? Colors.grey[700]! : Colors.grey),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: hintTextColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _confirmPasswordVisible = !_confirmPasswordVisible;
                            });
                          },
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        filled: isDarkMode,
                        fillColor: isDarkMode ? Colors.grey[800] : null,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Gender Selection
                    Text(
                      'Gender',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedGender = 'Male';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedGender == 'Male' 
                                  ? primaryColor.withOpacity(0.1) 
                                  : secondaryBackgroundColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _selectedGender == 'Male' 
                                    ? primaryColor 
                                    : (isDarkMode ? Colors.grey[700]! : Colors.grey[400]!),
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Male',
                                  style: TextStyle(
                                    color: _selectedGender == 'Male' 
                                      ? primaryColor 
                                      : textColor,
                                    fontWeight: _selectedGender == 'Male' 
                                      ? FontWeight.bold 
                                      : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedGender = 'Female';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedGender == 'Female' 
                                  ? primaryColor.withOpacity(0.1) 
                                  : secondaryBackgroundColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _selectedGender == 'Female' 
                                    ? primaryColor 
                                    : (isDarkMode ? Colors.grey[700]! : Colors.grey[400]!),
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Female',
                                  style: TextStyle(
                                    color: _selectedGender == 'Female' 
                                      ? primaryColor 
                                      : textColor,
                                    fontWeight: _selectedGender == 'Female' 
                                      ? FontWeight.bold 
                                      : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    _selectedGender == null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                          child: Text(
                            'Please select your gender',
                            style: TextStyle(
                              color: Colors.red[300],
                              fontSize: 12.0,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                    
                    const SizedBox(height: 24),
                    
                    // Work Experience
                    Text(
                      'Work Experience',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    RadioListTile<String>(
                      title: Text(
                        'As an Experienced',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                        ),
                      ),
                      value: 'Experienced',
                      groupValue: _workExperience,
                      activeColor: primaryColor,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                      tileColor: secondaryBackgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _workExperience = value;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 8),
                    
                    RadioListTile<String>(
                      title: Text(
                        'As a Freshers',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                        ),
                      ),
                      value: 'Freshers',
                      groupValue: _workExperience,
                      activeColor: primaryColor,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                      tileColor: secondaryBackgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _workExperience = value;
                        });
                      },
                    ),
                    
                    _workExperience == null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                          child: Text(
                            'Please select your work experience',
                            style: TextStyle(
                              color: Colors.red[300],
                              fontSize: 12.0,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                    
                    const SizedBox(height: 24),
                    
                    // Sign Up button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // Validate form
                          if (_formKey.currentState!.validate() && 
                              _selectedGender != null && 
                              _workExperience != null) {
                            // Show success dialog
                            _showSuccessDialog();
                          } else {
                            // Update state to show validation errors
                            setState(() {});
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Terms and Privacy Policy
                    Center(
                      child: Text(
                        'By signing up, you agree to our Terms & Privacy Policy',
                        style: TextStyle(
                          fontSize: 12,
                          color: hintTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
