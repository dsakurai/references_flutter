import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class ReferenceItem
 {
  String? title;
  String? authors;

  ReferenceItem copy() => ReferenceItem(
    title: title,
    authors: authors
  );

  // Generative constor with default param values
  ReferenceItem({this.title, this.authors});

  bool matches(ReferenceItem that) {
    return 
      // Strings are immutable, so comparison by object adresses are fine.
      (title   == that.title) &&
      (authors == that.authors)
    ;
  }
}

class ReferenceItemWidget extends StatefulWidget {

  final ReferenceItem referenceItem;

  const ReferenceItemWidget({
    super.key,
    required this.referenceItem
  });

  @override
  ReferenceItemWidgetState createState() => ReferenceItemWidgetState();
}

class ReferenceItemWidgetState extends State<ReferenceItemWidget> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add A New Reference"),
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              children: [
                Text("Title: "),
                Expanded(child: TextFormField(
                    initialValue: widget.referenceItem.title,
                    onChanged: (value) {
                      setState(() {
                        widget.referenceItem.title = value;
                      });
                    },
                ))
              ],
              // TextFormField(initialValue: "test",),
            ),
            // Title
            Row(
              children: [
                Text("Authors: "),
                  Expanded(child: TextFormField(
                    initialValue: widget.referenceItem.authors,
                    onChanged: (value) {
                      setState(() {
                        widget.referenceItem.authors = value;
                      });
                    },
                  ))
              ]
            )
          ]
        )
      )
    );
  }
}

class _ExplorerWidget extends StatefulWidget {

  @override
  _ExplorerState createState() => _ExplorerState();
}

Future<bool?> _popConfirmationDialog (BuildContext context) async {

  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title:   Text('Abandon Edit?'),
        content: Text('Do you really want to abandon the edit?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text('Stay safe')
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text('Abandon edit')
          ),
        ]
      );
    }
  );
}

void _popIfFine(ReferenceItem itemOriginal,
              ReferenceItem itemEdited,
              context, result) async {

  if (! itemEdited.matches(itemOriginal)) {
    // user edited this reference => ask the user

    bool? doAbandon = await _popConfirmationDialog(context); // Abandon the edit? 

    if (!context.mounted) {return;} // Dialog failed => do nothing

    if (doAbandon != true) {return;} // Don't abandon edit
  }

  Navigator.of(context).pop(result); // Abandon edit (i.e. close the child widget)

}

class _ExplorerState extends State<_ExplorerWidget> {

  List<ReferenceItem> _allItems = [
    ReferenceItem(
      title: "Test Title",
      authors: "Test Author",
    ),
    ReferenceItem(
      title: "Test Title 01",
      authors: "Test Author 01",
    ),
    ReferenceItem(
      title: "Test Title 02",
      authors: "Test Author",
    ),
  ];

  List<ReferenceItem> _filteredItems = [];

  // TODO remove this
  @override
  void initState() {
    super.initState();
    _filterItems("");
  }

  void _filterItems(String query) {

    List<ReferenceItem> results = [];

    if (query.isEmpty) {
      results = _allItems;
    } else {
      results = _allItems
      .where((item) {

        if (item.title case var itemTitle?) {
          return itemTitle.toLowerCase().contains(query.toLowerCase());
        }

        return false;
      })
      .toList();
    }

    setState(() {
      _filteredItems = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(

      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[

          TextField(
                        onChanged: (text) {
                          _filterItems(text); // Perform search on text change
                        },
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),

          Expanded (
                child:
                  ListView.builder(
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_filteredItems[index].title ?? ""),
                        trailing:
                          ElevatedButton(
                            onPressed: () {

                              var itemOriginal = _filteredItems[index];
                              var itemForEdit   = itemOriginal.copy();

                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: 
                                  (context) =>
                                  PopScope(
                                    canPop: false,

                                    // get user confirmation to pop this widget
                                    onPopInvokedWithResult: (didPop, result) async {
                                      if (didPop) {return;} // too late => do nothing
                                      _popIfFine(itemOriginal, itemForEdit, context, result);
                                    },

                                    child: ReferenceItemWidget(referenceItem: itemForEdit)
                                  )
                                )
                              ).then(
                                (_) { setState(() {}); }  // reload this page after coming back from the page
                              );
                            },
                            child: Text("Go"))
                      );
                    },
                  )
          )
    ],);
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body:
        _ExplorerWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ReferenceItemWidget(referenceItem: ReferenceItem(),)),
          ).then(
            (_){setState(() {});} // reload this page after coming back from the page
          );
        },
        tooltip: 'Add a new reference',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
