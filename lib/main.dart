import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fetch_client/fetch_client.dart';

void main() => runApp(PaymentListApp());

final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId:
      "386741301576-u6cobasvgsii4bu3io0fgdunq0iapumd.apps.googleusercontent.com",
  scopes: ['email'],
);

String? idToken = "";

final paymentListAppUrl =
    "https://script.google.com/macros/s/AKfycbzTPz4dr1CJN72j3PE8vHQWmdwcOI0R4rxSLoHY3qpnW5wwmnSSrGTBggKYgvTBFIAEAw/exec"; // Replace with deployed script URL

final groupWiseAppUrl =
    "https://script.google.com/macros/s/AKfycbyT5iNgac-vKmKRAOdRarMWsK4sfaQ4DhmswfFY_1_jl6o6hfirhdR7Zjw9ZJFNoD0z5w/exec";

class PaymentListApp extends StatelessWidget {
  const PaymentListApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sri Vignesh Chits',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SearchPage(),
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<List<dynamic>> results = [];

  final chitIdController = TextEditingController();
  final englishNameController = TextEditingController();
  final areaController = TextEditingController();
  final agentController = TextEditingController();
  final phoneController = TextEditingController();
  final groupController = TextEditingController();

  bool isLoading = false;

  Future<void> search() async {
    setState(() => isLoading = true);

    try {
      // final account = await _googleSignIn.signIn();
      // final auth = await account?.authentication;
      // // 👉 Send idToken to Apps Script backend for verification
      // final idToken = auth?.idToken;

      // final uri = Uri.parse(paymentListAppUrl).replace(
      //   queryParameters: {
      //     'idToken': idToken,
      //     if (chitIdController.text.isNotEmpty) 'chitId': chitIdController.text,
      //     if (englishNameController.text.isNotEmpty)
      //       'englishName': englishNameController.text,
      //     if (areaController.text.isNotEmpty) 'area': areaController.text,
      //     if (agentController.text.isNotEmpty) 'agent': agentController.text,
      //     if (phoneController.text.isNotEmpty) 'phone': phoneController.text,
      //     if (groupController.text.isNotEmpty)
      //       'groupNameList': groupController.text,
      //   },
      // );

      // Initialize the Fetch API architecture
      final client = FetchClient(mode: RequestMode.cors);

      final response = await client.post(
        Uri.parse(paymentListAppUrl),
        headers: {
          // text/plain is mandatory to bypass CORS preflight on Flutter Web
          'Content-Type': 'text/plain',
        },
        body: jsonEncode({
          'idToken': idToken,
          if (chitIdController.text.isNotEmpty) 'chitId': chitIdController.text,
          if (englishNameController.text.isNotEmpty)
            'englishName': englishNameController.text,
          if (areaController.text.isNotEmpty) 'area': areaController.text,
          if (agentController.text.isNotEmpty) 'agent': agentController.text,
          if (phoneController.text.isNotEmpty) 'phone': phoneController.text,
          if (groupController.text.isNotEmpty)
            'groupNameList': groupController.text,
        }),
      );

      // final response = await http.get(uri);
      if (response.statusCode == 200) {
        setState(() {
          results = List<List<dynamic>>.from(json.decode(response.body));
          isLoading = false;
        });
      } else {
        if (mounted) {
          setState(() {
            results = [];
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${response.statusCode}")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  void clearFields() {
    chitIdController.clear();
    englishNameController.clear();
    areaController.clear();
    agentController.clear();
    phoneController.clear();
    groupController.clear();

    setState(() {
      results = []; // optional: clear results too
    });
  }

  void getIdToken() async {
    var account = await _googleSignIn.signInSilently();
    if (!(account != null)) {
      // If not signed in, prompt with Google button
      account = await _googleSignIn.signIn();
    }
    final auth = await account?.authentication;
    idToken = auth?.idToken;

    if (idToken != null) {
      print("Got ID Token: $idToken");
      // Send to backend
    } else {
      print("No ID Token received");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Payment_List Search")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search form
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    controller: chitIdController,
                    decoration: InputDecoration(labelText: "Chit ID"),
                  ),
                  TextField(
                    controller: englishNameController,
                    decoration: InputDecoration(labelText: "English Name"),
                  ),
                  TextField(
                    controller: areaController,
                    decoration: InputDecoration(labelText: "Area"),
                  ),
                  TextField(
                    controller: agentController,
                    decoration: InputDecoration(labelText: "Collection Agent"),
                  ),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(labelText: "Phone Number"),
                  ),
                  TextField(
                    controller: groupController,
                    decoration: InputDecoration(
                      labelText: "Group Specific Name List",
                    ),
                  ),

                  // Add spacing before buttons
                  SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: clearFields,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        child: Text("Clear"),
                      ),
                      SizedBox(width: 16), // spacing between buttons
                      ElevatedButton(onPressed: search, child: Text("Search")),
                      ElevatedButton(
                        onPressed: getIdToken,
                        child: const Text("Sign in with Google"),
                      ),
                    ],
                  ),

                  // Loading indicator
                  if (isLoading)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
            // Results
            results.isEmpty
                ? Text("No results")
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: results.length - 1,
                    itemBuilder: (context, index) {
                      final row = results[index + 1]; // skip header
                      return Card(
                        child: ListTile(
                          title: Text("${row[2]} - ${row[3]}"),
                          subtitle: Text(
                            "Area: ${row[4]}, Agent: ${row[5]}, Phone: ${row[6]}",
                          ),
                          trailing: Text("Group: ${row[19]}"),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailPage(row: row),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final List<dynamic> row;

  const DetailPage({super.key, required this.row});

  @override
  Widget build(BuildContext context) {
    // Split Group Specific Name List by comma
    final groupList = (row[19] ?? "")
        .toString()
        .split(",")
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    // var samp = row[19]
    //     .replaceAll(RegExp(r'[\r\n]+'), '')
    //     .replaceAll(" ", "")
    //     .toString();
    // print("Code: $samp");

    return Scaffold(
      appBar: AppBar(
        title: Text("Details"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Other fields table
            Table(
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(),
              },
              border: TableBorder.all(color: Colors.grey),
              children: [
                _buildRow("Chit ID", row[2]),
                _buildRow("English Name", row[3]),
                _buildRow("Area", row[4]),
                _buildRow("Collection Agent", row[5]),
                _buildRow("Phone Number", row[6]),
                _buildRow("Own House", row[7]),
                _buildRow("Chit Taken", row[17]),
                _buildRow("No. Of Taken Chits", row[18]),
                _buildRow("Group Specific Name List", row[19]),
                _buildRow("No. Of Chits", row[20]),
                _buildRow("Indv Grp Amt", row[21]),
                _buildRow("Grp Amt", row[22]),
                _buildRow("Prev Bal", row[24]),
                _buildRow("Final Amt", row[25]),
                _buildRow("Cash Collected Amt", row[26]),
                _buildRow("Online Collected Amt", row[27]),
                _buildRow("Real Balance", row[28]),
                _buildRow("Previous Bal", row[29]),
              ],
            ),

            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Get Last Bidding Details:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                SizedBox(width: 16),
                InkWell(
                  child: Text(
                    "Click Here",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      // decoration: TextDecoration.underline,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BiddingDetailsPage(
                          groupName: row[19]
                              .replaceAll(RegExp(r'[\r\n]+'), '')
                              .replaceAll(" ", "")
                              .toString(),
                          custName:
                              "${row[2].toString()} : ${row[3].toString()}",
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            SizedBox(height: 20),

            Text(
              "Group Specific Name List:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            // Display each group as a link
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: groupList.map((group) {
                return InkWell(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      group,
                      style: TextStyle(
                        color: Colors.blue,
                        // decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  onTap: () {
                    // Extract text before "-" if present
                    final sheetName = group.contains("-")
                        ? group.split("-")[0].trim()
                        : group;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            GroupDetailsPage(sheetName: sheetName),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildRow(String field, dynamic value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(field, style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(value?.toString() ?? "", softWrap: true),
        ),
      ],
    );
  }
}

class GroupDetailsPage extends StatefulWidget {
  final String sheetName;

  const GroupDetailsPage({super.key, required this.sheetName});

  @override
  State<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  List<List<dynamic>> tableData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGroupData();
  }

  Future<void> fetchGroupData() async {
    try {
      // final account = await _googleSignIn.signIn();
      // final auth = await account?.authentication;
      // // 👉 Send idToken to Apps Script backend for verification
      // final idToken = auth?.idToken;

      // final url = Uri.parse(groupWiseAppUrl).replace(
      //   queryParameters: {'idToken': idToken, 'sheet': widget.sheetName},
      // );

      // final response = await http.get(url);

      // Initialize the Fetch API architecture
      final client = FetchClient(mode: RequestMode.cors);

      final response = await client.post(
        Uri.parse(groupWiseAppUrl),
        headers: {
          // text/plain is mandatory to bypass CORS preflight on Flutter Web
          'Content-Type': 'text/plain',
        },
        body: jsonEncode({'idToken': idToken, 'sheet': widget.sheetName}),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        // Ensure it's a List of Lists
        if (decoded is List) {
          setState(() {
            // Skip the first row (headers)
            tableData = decoded
                .map<List<dynamic>>((row) {
                  return List<dynamic>.from(row);
                })
                .skip(1)
                .toList();
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${response.statusCode}")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Group: ${widget.sheetName}"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal, // allow wide tables
              child: SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.resolveWith<Color?>(
                      (states) => const Color.fromARGB(234, 250, 100, 30),
                    ),
                    border: TableBorder.all(color: Colors.grey),
                    columnSpacing: 8, // tighter spacing
                    columns: [
                      DataColumn(label: Text("Chit ID")),
                      DataColumn(label: Text("English Name")),
                      DataColumn(label: Text("Area")),
                      DataColumn(label: Text("Agent")),
                      DataColumn(label: Text("Taken Date")),
                      DataColumn(label: Text("Month")),
                      DataColumn(label: Text("Disc Amt")),
                      DataColumn(label: Text("Ind kasar")),
                      DataColumn(label: Text("Sett. Amt")),
                    ],
                    rows: List.generate(tableData.length, (rowIndex) {
                      final row = tableData[rowIndex];

                      final mappedRow = [
                        row[1], // Chit ID
                        row[2], // English Name
                        row[3], // Area
                        row[4], // Agent
                        row[6], // Taken Date
                        row[7], // Taken Month
                        row[8], // Disc Amt
                        row[10], // Ind kasar
                        row[9], // Sett. Amt
                      ];

                      return DataRow(
                        color: WidgetStateProperty.resolveWith<Color?>(
                          (states) => rowIndex.isEven
                              ? const Color.fromARGB(255, 255, 255, 255)
                              : const Color.fromARGB(204, 253, 162, 43),
                        ),
                        cells: List.generate(mappedRow.length, (index) {
                          final value = mappedRow[index]?.toString() ?? "";

                          // 👉 Give English Name more width, keep others compact
                          if (index == 1) {
                            return DataCell(
                              SizedBox(
                                width: 200, // wider for names
                                child: Text(value, softWrap: true),
                              ),
                            );
                          } else {
                            return DataCell(
                              SizedBox(
                                width: 70, // compact for numbers/short text
                                child: Text(value, softWrap: true),
                              ),
                            );
                          }
                        }),
                      );
                    }),
                  ),
                ),
              ),
            ),
    );
  }
}

class BiddingDetailsPage extends StatefulWidget {
  final String groupName;
  final String custName;
  const BiddingDetailsPage({
    super.key,
    required this.groupName,
    required this.custName,
  });

  @override
  State<BiddingDetailsPage> createState() => _BiddingDetailsPageState();
}

class _BiddingDetailsPageState extends State<BiddingDetailsPage> {
  List<List<dynamic>> biddingData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBiddingDetails();
  }

  Future<void> fetchBiddingDetails() async {
    try {
      // final account = await _googleSignIn.signIn();
      // final auth = await account?.authentication;
      // // 👉 Send idToken to Apps Script backend for verification
      // final idToken = auth?.idToken;

      // final url = Uri.parse(groupWiseAppUrl).replace(
      //   queryParameters: {
      //     'idToken': idToken,
      //     'func': 'lastBidding',
      //     'groupName': widget.groupName,
      //   },
      // );

      // final response = await http.get(url);

      final client = FetchClient(mode: RequestMode.cors);

      final response = await client.post(
        Uri.parse(groupWiseAppUrl),
        headers: {
          // text/plain is mandatory to bypass CORS preflight on Flutter Web
          'Content-Type': 'text/plain',
        },
        body: jsonEncode({
          'idToken': idToken,
          'func': 'lastBidding',
          'groupName': widget.groupName,
        }),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        setState(() {
          biddingData = decoded.map<List<dynamic>>((row) {
            return List<dynamic>.from(row);
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth),
              child: Text(
                "${widget.custName} - Chit Details",
                softWrap: true,
                overflow: TextOverflow.visible,
                maxLines: 2, // allow wrapping into 2 lines
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
        // title: Text("${widget.custName} - Bidding Details"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.resolveWith<Color?>(
                  (states) => const Color.fromARGB(234, 250, 100, 30),
                ),
                border: TableBorder.all(
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
                columnSpacing: 8, // tighter spacing
                columns: const [
                  DataColumn(
                    label: SizedBox(
                      width: 40, // narrow width
                      child: Text(
                        "Grp",
                        softWrap: true,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 40, // narrow width
                      child: Text(
                        "Date",
                        softWrap: true,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 40, // narrow width
                      child: Text(
                        "Total Mont",
                        softWrap: true,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 55, // narrow width
                      child: Text(
                        "Last Disc Amt",
                        softWrap: true,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 55, // narrow width
                      child: Text(
                        "Last Sett. Amt",
                        softWrap: true,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 55, // narrow width
                      child: Text(
                        "Kasar Bal",
                        softWrap: true,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],

                rows: List.generate(biddingData.length, (rowIndex) {
                  final row = biddingData[rowIndex];

                  final mappedRow = [
                    row[0], // Group
                    row[1].replaceAll("-", "- "), // Date
                    row[2], // Total Month
                    row[3], // Last Disc Amt
                    row[4], // Last Sett. Amt
                    row[5], // Kasar Bal
                  ];

                  return DataRow(
                    color: WidgetStateProperty.resolveWith<Color?>(
                      (states) => rowIndex.isEven
                          ? const Color.fromARGB(255, 255, 255, 255)
                          : const Color.fromARGB(204, 253, 162, 43),
                    ),
                    cells: List.generate(mappedRow.length, (index) {
                      final value = mappedRow[index]?.toString() ?? "";

                      if (index == 0 || index == 1 || index == 2) {
                        return DataCell(
                          SizedBox(
                            width: 40, // wider for names
                            child: Text(value, softWrap: true),
                          ),
                        );
                      } else {
                        return DataCell(
                          SizedBox(
                            width: 55, // compact for numbers/short text
                            child: Text(value, softWrap: true),
                          ),
                        );
                      }
                    }),
                  );
                }),
              ),
            ),
    );
  }
}
