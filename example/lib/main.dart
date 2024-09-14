import 'package:flutter/material.dart';
import 'package:teleprompter/teleprompter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const String text =
        '''PASTE YOUR TEXT HERE''';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.dark().copyWith(
        textTheme: ThemeData.dark().textTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
      ),
      home: const HomeScreen(
        text: text,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String text;

  const HomeScreen({
    required this.text,
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textEditingController.text = widget.text;
    textEditingController.selection =
        const TextSelection(baseOffset: 0, extentOffset: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const RecordingScreen(),
              ),
            ),
            icon: const Icon(Icons.timer),
          ),
          title: const Text('Teleprompter'),
        ),
        body: Container(
          margin: const EdgeInsets.all(10),
          child: TextField(
            controller: textEditingController,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              hintText: "Text for teleprompter",
            ),
            scrollPadding: const EdgeInsets.all(20.0),
            keyboardType: TextInputType.multiline,
            maxLines: 99999,
            autofocus: true,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.play_arrow),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TeleprompterWidget(
                text: textEditingController.text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({
    super.key,
  });

  @override
  _RecordingScreenState createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  bool started = false;
  bool showHours = true;
  bool showMinutes = true;
  bool showSeconds = true;
  bool showMilliseconds = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: showHours,
                    onChanged: (val) {
                      setState(() {
                        showHours = val!;
                      });
                    },
                  ),
                  const Text('Hours'),
                  Checkbox(
                    value: showMinutes,
                    onChanged: (val) {
                      setState(() {
                        showMinutes = val!;
                      });
                    },
                  ),
                  const Text('Minutes'),
                  Checkbox(
                    value: showSeconds,
                    onChanged: (val) {
                      setState(() {
                        showSeconds = val!;
                      });
                    },
                  ),
                  const Text('Seconds'),
                  Checkbox(
                    value: showMilliseconds,
                    onChanged: (val) {
                      setState(() {
                        showMilliseconds = val!;
                      });
                    },
                  ),
                  const Text('Milliseconds'),
                ],
              ),
            ),
            const Text(
              'Stopwatch',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            if (!started) ...[
              const SizedBox(height: 10),
              ElevatedButton(
                child: const Text('Start'),
                onPressed: () {
                  started = true;
                  setState(() {});
                },
              ),
            ],
            if (started) ...[
              StopwatchWidget(
                showHours: showHours,
                showMinutes: showMinutes,
                showSeconds: showSeconds,
                showMilliseconds: showMilliseconds,
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                child: const Text('Hide'),
                onPressed: () {
                  started = false;
                  setState(() {});
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
