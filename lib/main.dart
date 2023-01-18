import 'package:clicli_grey/config.dart';
import 'package:clicli_grey/instance.dart';
import 'package:clicli_grey/pages/history_page.dart';
import 'package:clicli_grey/pages/home_stack/bgi_page.dart';
import 'package:clicli_grey/pages/home_stack/home_page.dart';
import 'package:clicli_grey/pages/home_stack/me_page.dart';
import 'package:clicli_grey/pages/home_stack/ugc_page.dart';
import 'package:clicli_grey/pages/login_page.dart';
import 'package:clicli_grey/pages/player_page.dart';
import 'package:clicli_grey/pages/home_stack/time_line_page.dart';
import 'package:clicli_grey/service/events.dart';
import 'package:clicli_grey/service/theme_manager.dart';
import 'package:clicli_grey/utils/toast_utils.dart';
import 'package:clicli_grey/utils/version_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Instances.init();
  // if (!kIsWeb) await FlutterDownloader.initialize(debug: Config.isDev);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  runApp(const CliCliApp());
}

class CliCliApp extends StatefulWidget {
  const CliCliApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CliCliAppState();
}

class _CliCliAppState extends State<CliCliApp> {
  bool isDarkTheme = Instances.sp.getBool('isDarkTheme') ?? false;

  @override
  void initState() {
    super.initState();
    Instances.eventBus.on<ChangeTheme>().listen((e) {
      setState(() {
        isDarkTheme = e.val;
      });
    });
 
    if (!Config.isDev) checkAppUpdate();
  }

  @override
  dispose() {
    Instances.eventBus.destroy();
    super.dispose();
  }

  Route? _onGenerateRoute(RouteSettings settings) {
    final Map? arg = settings.arguments as Map<dynamic, dynamic>?;
    final Map<String, WidgetBuilder> routes = {
      'CliCli://': (_) => const HomePage(),
      'CliCli://home': (_) => const HomePage(),
      'CliCli://player': (_) => PlayerPage(data: arg!['data']),
      'CliCli://fav': (_) => const BgiPage(),
      'CliCli://timeline': (_) => const TimeLinePage(),
      'CliCli://history': (_) => const HistoryPage(),
      'CliCli://login': (_) => const LoginPage(),
    };

    final WidgetBuilder? widget = routes[settings.name!];

    return widget != null
        ? MaterialPageRoute<void>(
            settings: settings,
            builder: widget,
          )
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: Instances.navigatorKey,
      themeMode: isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeManager.lightTheme,
      darkTheme: ThemeManager.darkTheme,
      home: const MyHomePage(),
      title: 'CliCli',
      onGenerateRoute: _onGenerateRoute,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const List<dynamic> pagesIcon = [
    'assets/home-fill.svg',
    'assets/发现.svg',
    'assets/time.svg',
    'assets/mine.svg'
  ];
  final _pages = [
    const HomePage(),
    const UGCPage(),
    const TimeLinePage(),
    const MePage()
  ];

  int _currentPageIndex = 0;
  final _pageController = PageController();

  void _onPageChange(int index) {
    if (index == _currentPageIndex) {
      _toTop(index);
    } else {
      setState(() {
        _currentPageIndex = index;
        _pageController.jumpToPage(index);
      });
    }
  }

  int lastBack = 0;

  Future<bool> _doubleBackExit() {
    final int now = DateTime.now().millisecondsSinceEpoch;
    if (now - lastBack > 1000) {
      showSnackBar('再按一次退出应用', gravity: ToastGravity.CENTER);
      lastBack = DateTime.now().millisecondsSinceEpoch;
      return Future.value(false);
    } else {
      //  SystemNavigator.pop();
      return Future.value(true);
    }
  }

  _toTop(int i) {
    Instances.eventBus.fire(
      MainButtonNavDoubleClickToTop([MainStack.home, MainStack.ugc][i]),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: _doubleBackExit,
      child: Scaffold(
        body: PageView.builder(
          itemCount: pagesIcon.length,
          controller: _pageController,
          itemBuilder: (context, index) => _pages[index],
          physics: const NeverScrollableScrollPhysics(),
        ),
        bottomNavigationBar: BottomAppBar(
          color: const Color.fromRGBO(240, 240, 245, 1),
          elevation: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              pagesIcon.length,
              (i) => Expanded(
                child: IconButton(
                  icon: SvgPicture.asset(
                    pagesIcon[i],
                    color: _currentPageIndex == i
                        ? theme.primaryColor
                        : const Color(0xffb3b3c7),
                    width: 35,
                    height: 35,
                  ),
                  onPressed: () => _onPageChange(i),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
