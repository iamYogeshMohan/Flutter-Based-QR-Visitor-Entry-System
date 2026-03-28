import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'qr_generator_screen.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _purposeController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final visitor = await ApiService.registerVisitor({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'purpose': _purposeController.text,
        'date': _selectedDate.toIso8601String(),
        'time': _selectedTime.format(context),
      });

      setState(() => _isLoading = false);

      if (visitor != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QRGeneratorScreen(visitor: visitor),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to register visitor')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register Visitor')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Visitor Name', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Enter name' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
                validator: (val) => val!.isEmpty ? 'Enter phone' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _purposeController,
                decoration: InputDecoration(labelText: 'Purpose of Visit', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Enter purpose' : null,
              ),
              SizedBox(height: 24),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                        child: Text('Register & Generate QR', style: TextStyle(fontSize: 16)),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
