import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ku celebrate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: initializeRemoteConfig(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return TabScreen(remoteConfig: remoteConfig);
          } else {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }

  Future<void> initializeRemoteConfig() async {
    await remoteConfig.fetchAndActivate();
  }
}

class TabScreen extends StatefulWidget {
  final FirebaseRemoteConfig remoteConfig;

  TabScreen({required this.remoteConfig});

  @override
  _TabScreenState createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late List<String> _webviewUrls;
  late WebViewController controller;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _webviewUrls = [
      widget.remoteConfig.getString('weblink1'),
      widget.remoteConfig.getString('weblink2'),
      widget.remoteConfig.getString('weblink3'),
      widget.remoteConfig.getString('weblink4'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ku celebrate'),
        centerTitle: true,
        backgroundColor: Colors.deepOrangeAccent.withOpacity(0.5),
        bottom: TabBar(
          dividerColor: Colors.indigoAccent,
          controller: _tabController,
          unselectedLabelColor: Colors.white,
          labelColor: Colors.indigoAccent,
          indicatorColor: Colors.indigoAccent,
          tabs: const [
            Tab(icon: Icon(Icons.home)),
            Tab(icon: Icon(Icons.login)),
            Tab(icon: Icon(Icons.logout)),
            Tab(icon: Icon(CupertinoIcons.person)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildWebView(_webviewUrls[0]),
          buildWebView(_webviewUrls[1]),
          buildWebView(_webviewUrls[2]),
          buildWebView(_webviewUrls[3]),
        ],
      ),
    );
  }

  Widget buildWebView(String url) {
    return WebViewWidget(controller: WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url)));
  }
}