import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  final String name;
  final String phone;
  final String email;

  UserProfilePage({
    required this.name,
    required this.phone,
    this.email = '',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildProfileInfo(context),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 50, color: Colors.black),
            ),
            SizedBox(height: 10),
            Text(
              name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoTile(Icons.phone, 'Phone', phone),
          _buildInfoTile(Icons.email, 'Email', email.isNotEmpty ? email : 'Not set'),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54),
          SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        ElevatedButton.icon(
          icon: Icon(Icons.camera_alt),
          label: Text('Change Profile Picture'),
          onPressed: () {
            // TODO: Implement profile picture change functionality
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Profile picture change not implemented yet')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        SizedBox(height: 10),
        ElevatedButton.icon(
          icon: Icon(Icons.email),
          label: Text('Add/Change Email'),
          onPressed: () {
            // TODO: Implement email change functionality
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Email change not implemented yet')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        SizedBox(height: 10),
        ElevatedButton.icon(
          icon: Icon(Icons.lock),
          label: Text('Change Password'),
          onPressed: () {
            // TODO: Implement password change functionality
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Password change not implemented yet')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }
}