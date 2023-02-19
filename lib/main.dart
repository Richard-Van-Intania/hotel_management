import 'package:flutter/material.dart';

import 'constant.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: projectName,
      theme: ThemeData(
          colorSchemeSeed: const Color.fromARGB(255, 0, 255, 85),
          useMaterial3: true),
      home: const MyHomePage(title: projectName),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final controller = TextEditingController(text: initialInput);
  String output = '';
  Hotel hotel = Hotel(roomList: [], bookedList: []);
  List<Command> commandList = [];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void retrieveTextCommand(String value) {
    setState(() {
      output = '';
      calculate(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
              Container(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Please enter some text',
                      suffix: TextButton(
                          onPressed: () {
                            controller.clear();
                          },
                          child: const Text('Clear'))),
                  maxLines: 22,
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.play_arrow_sharp),
                    title: const Text('Run'),
                    onTap: () {
                      retrieveTextCommand(controller.text.trim());
                    },
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(output),
                    ))),
              )
            ])),
      ),
    );
  }

  void calculate(String value) {
    commandList =
        value.split('\n').map((e) => Command(e.trim().split(' '))).toList();
    for (var element in commandList) {
      try {
        switch (element.commandList.first) {
          case 'create_hotel':
            if (hotel.isCreated) {
              output += 'Hotel already created!\n';
              break;
            } else if (int.parse(element.commandList[1]) <= 0 ||
                int.parse(element.commandList[2]) <= 0) {
              output += 'Floor or Room number not correct\n';
              break;
            } else {
              hotel.isCreated = true;
              for (var f = 1; f < int.parse(element.commandList[1]) + 1; f++) {
                List<Room> floor = [];
                for (var r = 1;
                    r < int.parse(element.commandList[2]) + 1;
                    r++) {
                  floor.add(Room(roomIdString: createRoomString(f, r)));
                }
                hotel.roomList.add(floor);
              }
              output +=
                  'Hotel created with ${element.commandList[1]} floor(s), ${element.commandList[2]} room(s) per floor.\n';
              break;
            }

          case 'book':
            if (hotel.isCreated) {
              int floor = int.parse(element.commandList[1][0]);
              int room = int.parse(element.commandList[1].substring(1));

              if (floor > hotel.roomList.length ||
                  room > hotel.roomList.first.length) {
                output += 'Room ${element.commandList[1]} cannot be found!\n';
                break;
              } else if (hotel.roomList[floor - 1][room - 1].isBooked) {
                output +=
                    'Cannot book room ${element.commandList[1]} for ${element.commandList[2]}, The room is currently booked by ${hotel.roomList[floor - 1][room - 1].bookedName}.\n';
                break;
              } else {
                hotel.roomList[floor - 1][room - 1].isBooked = true;
                hotel.roomList[floor - 1][room - 1].roomKeyCard =
                    hotel.keycardCount;
                hotel.roomList[floor - 1][room - 1].bookedName =
                    element.commandList[2];
                hotel.roomList[floor - 1][room - 1].bookedAge =
                    int.parse(element.commandList[3]);
                output +=
                    'Room ${element.commandList[1]} is booked by ${element.commandList[2]} with keycard number ${hotel.keycardCount}.\n';
                hotel.keycardCount++;
                break;
              }
            } else {
              output += 'Hotel has not yet been created!\n';
              break;
            }

          case 'list_available_rooms':
            List<String> available = [];
            for (var element in hotel.roomList) {
              for (var e in element) {
                if (!e.isBooked) {
                  available.add(e.roomIdString);
                }
              }
            }
            output +=
                '${available.toString().substring(1, available.toString().length - 1)}\n';
            break;

          case 'checkout':
            if (int.parse(element.commandList[1]) > hotel.keycardCount ||
                int.parse(element.commandList[1]) < 1) {
              output +=
                  'Keycard number ${element.commandList[1]} not used yet!\n';
              break;
            } else {
              for (var list in hotel.roomList) {
                for (var e in list) {
                  if (e.isBooked &&
                      e.roomKeyCard == int.parse(element.commandList[1])) {
                    if (e.bookedName == element.commandList[2]) {
                      hotel.roomList[e.floorInt - 1][e.roomInt - 1].isBooked =
                          false;
                      hotel.roomList[e.floorInt - 1][e.roomInt - 1]
                          .roomKeyCard = null;
                      hotel.roomList[e.floorInt - 1][e.roomInt - 1].bookedName =
                          null;
                      hotel.roomList[e.floorInt - 1][e.roomInt - 1].bookedAge =
                          null;
                      output += 'Room ${e.roomIdString} is checkout.\n';
                      break;
                    } else {
                      output +=
                          'Only ${e.bookedName} can checkout with keycard number ${element.commandList[1]}.\n';
                      break;
                    }
                  }
                }
              }
              break;
            }

          case 'list_guest':
            Set<String> guest = {};
            for (var list in hotel.roomList) {
              for (var e in list) {
                if (e.isBooked) {
                  guest.add(e.bookedName!);
                }
              }
            }

            if (guest.isNotEmpty) {
              output +=
                  '${guest.toString().substring(1, guest.toString().length - 1)}\n';
              break;
            } else {
              output += 'Not found any guest\n';
              break;
            }

          case 'get_guest_in_room':
            String? guest;
            for (var floorList in hotel.roomList) {
              for (var room in floorList) {
                if (room.isBooked &&
                    room.roomIdString == element.commandList[1]) {
                  guest = room.bookedName;
                  output += '$guest\n';
                  break;
                }
              }
            }
            if (guest == null) {
              output += 'Room ${element.commandList[1]} not found.\n';
              break;
            }
            break;

          case 'list_guest_by_age':
            Set<String> guest = {};
            for (var floorList in hotel.roomList) {
              for (var room in floorList) {
                if (room.isBooked &&
                    comparatorTable[element.commandList[1]]!(
                        room.bookedAge, int.parse(element.commandList[2]))) {
                  guest.add(room.bookedName!);
                  output +=
                      '${guest.toString().substring(1, guest.toString().length - 1)}\n';
                  break;
                }
              }
            }
            if (guest.isEmpty) {
              output +=
                  'Not found guest ${element.commandList[1]} ${element.commandList[2]}.\n';
              break;
            }
            break;

          default:
        }
      } on Exception catch (e) {
        output += 'Input error $e.\n';
      }
    }
  }
}

class Command {
  final List<String> commandList;
  const Command(this.commandList);
}

class Hotel {
  bool isCreated;
  List<List<Room>> roomList;
  List<Room> bookedList;
  int keycardCount = 1;
  Hotel(
      {this.isCreated = false,
      required this.roomList,
      required this.bookedList});
}

class Room {
  final String roomIdString;
  late final int roomIdInt;
  late final int floorInt;
  late final int roomInt;
  int? roomKeyCard;
  bool isBooked;
  String? bookedName;
  int? bookedAge;

  Room(
      {required this.roomIdString,
      this.roomKeyCard,
      this.isBooked = false,
      this.bookedName,
      this.bookedAge}) {
    roomIdInt = int.parse(roomIdString);
    floorInt = int.parse(roomIdString[0]);
    roomInt = int.parse(roomIdString.substring(1));
  }
}

String createRoomString(int floor, int room) {
  if (room < 10) {
    return '${floor}0$room';
  } else {
    return '$floor$room';
  }
}

final comparatorTable = <String, bool Function(dynamic, dynamic)>{
  '==': (a, b) => a == b,
  '=': (a, b) => a == b,
  '!=': (a, b) => a != b,
  '>': (a, b) => a > b,
  '>=': (a, b) => a >= b,
  '<': (a, b) => a < b,
  '<=': (a, b) => a <= b,
};
