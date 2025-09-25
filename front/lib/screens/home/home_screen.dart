import 'dart:developer';

import 'package:front/commons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'home_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends HomeScreenController {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final instruments = snapshot.data!;
          log('Instruments: $instruments');
          return ListView.builder(
            itemCount: instruments.length,
            itemBuilder: ((context, index) {
              final instrument = instruments[index];
              return ListTile(title: Text(instrument['name']));
            }),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          log('Adding new instrument');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
