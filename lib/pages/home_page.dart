import 'package:flutter/material.dart';

import '../services/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;
  String _message = 'Welcome to RobBianco!';

  Future<void> _testApi() async {
    setState(() {
      _isLoading = true;
      _message = 'Testing API...';
    });

    try {
      // Esempio di chiamata API
      final response = await ApiService.get('/Hardware/sensors');
      final data = ApiService.handleResponse(response);

      setState(() {
        _message = 'API Response: ${data.toString()}';
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _message = 'API Error: ${e.message}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _message = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RobBianco'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.web, size: 100, color: Colors.blue.shade800),
            SizedBox(height: 20),
            Text(
              _message,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            if (_isLoading)
              CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _testApi,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: Text('Test API'),
              ),
          ],
        ),
      ),
    );
  }
}
