import 'package:flutter/material.dart';

class Modern3DBottomNavBar extends StatefulWidget {
  final Function(int) onItemSelected;

  const Modern3DBottomNavBar({Key? key, required this.onItemSelected}) : super(key: key);

  @override
  _Modern3DBottomNavBarState createState() => _Modern3DBottomNavBarState();
}

class _Modern3DBottomNavBarState extends State<Modern3DBottomNavBar> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.onItemSelected(index);
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: Colors.black,  // Make the container transparent
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.home, 'Home'),
              _buildNavItem(1, Icons.analytics, 'Analytics'),
            ],
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: _selectedIndex * (MediaQuery.of(context).size.width / 2),
            child: Container(
              width: MediaQuery.of(context).size.width / 2,
              height: 50,
              child: Center(
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: 60,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2), // Semi-transparent selection indicator
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: MediaQuery.of(context).size.width / 2,
        height: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey,
              size: isSelected ? 32 : 28,
            ),
            if (isSelected)
              AnimatedOpacity(
                opacity: isSelected ? 1.0 : 0.0,
                duration: Duration(milliseconds: 300),
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
