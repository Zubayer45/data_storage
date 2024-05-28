import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _controller = TextEditingController();
  TextEditingController _updateController = TextEditingController();
  Box<String>? _countryBox;
  @override
  void initState() {
    super.initState();
    _initializeCountryBox();
  }

  Future<void> _initializeCountryBox() async {
    _countryBox = await Hive.openBox<String>('country_list');
    setState(() {}); // Rebuild UI after box is initialized
  }

  @override
  Widget build(BuildContext context) {
    if (_countryBox == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[50],
          title: Text('Local Storage'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[100],
        title: Text('Local Storage'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Write your name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final userData = _controller.text;
                if (userData.isNotEmpty) {
                  _countryBox!.add(userData);
                  _controller.clear(); // Clear the text field after adding data
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[200],
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: Text(
                'Add data',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _countryBox!.listenable(),
                builder: (context, Box<String> box, _) {
                  if (box.isEmpty) {
                    return Center(child: Text('No data available.'));
                  }
                  return ListView.builder(
                    itemCount: box.length,
                    itemBuilder: (context, index) {
                      final country = box.getAt(index) ?? 'Unknown';
                      return Card(
                        child: ListTile(
                          title: Text(country),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  _updateController.text = country;
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              controller: _updateController,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            ElevatedButton(
                                              onPressed: () {
                                                if (_updateController
                                                    .text.isNotEmpty) {
                                                  _countryBox!.putAt(index,
                                                      _updateController.text);
                                                  Navigator.pop(context);
                                                }
                                              },
                                              child: Text('Update data'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                icon: Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                onPressed: () {
                                  try {
                                    _countryBox!.deleteAt(index);
                                  } catch (e) {
                                    print('Error deleting item: $e');
                                  }
                                },
                                icon: Icon(Icons.delete_outline_rounded,
                                    color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
