import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/constants.dart';
import 'package:flutter_application_1/utils/MainNavigation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_application_1/providers/product_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_MX', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Stripe.publishableKey = stripePublishableKey;
  MainNavigationScreen();
  await Stripe.instance.applySettings();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ProductProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guillermo Corp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SplashScreen(),
      /* home: const MyHomePage(title: 'Guillermo Corp Home Page'), */
    );
  }
}

/* class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {

      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
 
        title: Text(widget.title),
      ),
      /* body: Center(
      
        child: Column(
         
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times abc:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ), */
        body: const Center(
        child: ActionsExample(),
      ),
    

      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


// A simple model class that notifies listeners when it changes.
class Model {
  final ValueNotifier<bool> isDirty = ValueNotifier<bool>(false);
  final ValueNotifier<int> data = ValueNotifier<int>(0);

  int save() {
    if (isDirty.value) {
      debugPrint('Saved Data: ${data.value}');
      isDirty.value = false;
    }
    return data.value;
  }

  void setValue(int newValue) {
    isDirty.value = data.value != newValue;
    data.value = newValue;
  }

  void dispose() {
    isDirty.dispose();
    data.dispose();
  }
}

class ModifyIntent extends Intent {
  const ModifyIntent(this.value);

  final int value;
}

// An Action that modifies the model by setting it to the value that it gets
// from the Intent passed to it when invoked.
class ModifyAction extends Action<ModifyIntent> {
  ModifyAction(this.model);

  final Model model;

  @override
  void invoke(covariant ModifyIntent intent) {
    model.setValue(intent.value);
  }
}

// An intent for saving data.
class SaveIntent extends Intent {
  const SaveIntent();
}

// An Action that saves the data in the model it is created with.
class SaveAction extends Action<SaveIntent> {
  SaveAction(this.model);

  final Model model;

  @override
  int invoke(covariant SaveIntent intent) => model.save();
}

class SaveButton extends StatefulWidget {
  const SaveButton(this.valueNotifier, {super.key});

  final ValueNotifier<bool> valueNotifier;

  @override
  State<SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton> {
  int _savedValue = 0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.valueNotifier,
      builder: (BuildContext context, Widget? child) {
        return TextButton.icon(
          icon: const Icon(Icons.save),
          label: Text('$_savedValue'),
          style: ButtonStyle(
            foregroundColor: WidgetStatePropertyAll<Color>(
              widget.valueNotifier.value ? Colors.red : Colors.green,
            ),
          ),
          onPressed: () {
            setState(() {
              _savedValue = Actions.invoke(context, const SaveIntent())! as int;
            });
          },
        );
      },
    );
  }
}

class ActionsExample extends StatefulWidget {
  const ActionsExample({super.key});

  @override
  State<ActionsExample> createState() => _ActionsExampleState();
}

class _ActionsExampleState extends State<ActionsExample> {
  final Model _model = Model();
  int _count = 0;

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Actions(
      actions: <Type, Action<Intent>>{
        ModifyIntent: ModifyAction(_model),
        SaveIntent: SaveAction(_model),
      },
      child: Builder(
        builder: (BuildContext context) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              const Spacer(),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.exposure_plus_1),
                    onPressed: () {
                      Actions.invoke(context, ModifyIntent(++_count));
                    },
                  ),
                  ListenableBuilder(
                    listenable: _model.data,
                    builder: (BuildContext context, Widget? child) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Value: ${_model.data.value}',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.exposure_minus_1),
                    onPressed: () {
                      Actions.invoke(context, ModifyIntent(--_count));
                    },
                  ),
                ],
              ),
              SaveButton(_model.isDirty),
              const Spacer(),
            ],
          );
        },
      ),
    );
  }
} */
