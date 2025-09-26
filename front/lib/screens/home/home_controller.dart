part of 'home_screen.dart';

abstract class HomeScreenController extends State<HomeScreen> {
  late final Future<List<dynamic>> _future = Supabase.instance.client
      .from('instruments')
      .select();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
