import 'package:flutter/material.dart';
import 'color_schemes.g.dart';

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
        useMaterial3: true,
        colorScheme: lightColorScheme,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
      ),
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
  Hotel hotel = Hotel();
  List<Command> commandList = [];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void retrieveTextCommand(String value) async {
    output = '';
    await calculate(value);
    setState(() {});
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

  Future<void> calculate(String value) async {
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
              for (var i = 1;
                  i <
                      int.parse(element.commandList[1]) *
                              int.parse(element.commandList[2]) +
                          1;
                  i++) {
                hotel.keyCard[i] = false;
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
                hotel.roomList[floor - 1][room - 1].bookedName =
                    element.commandList[2];
                hotel.roomList[floor - 1][room - 1].bookedAge =
                    int.parse(element.commandList[3]);
                for (int keyNumber in hotel.keyCard.keys) {
                  if (!hotel.keyCard[keyNumber]!) {
                    hotel.keyCard[keyNumber] = true;
                    hotel.roomList[floor - 1][room - 1].roomKeyCard = keyNumber;
                    output +=
                        'Room ${element.commandList[1]} is booked by ${element.commandList[2]} with keycard number $keyNumber.\n';
                    break;
                  }
                }
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
            if (int.parse(element.commandList[1]) > hotel.keyCard.length ||
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
                      hotel.keyCard[int.parse(element.commandList[1])] = false;
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
            final guest = <String>{};
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
            final guest = <String>{};
            for (var floorList in hotel.roomList) {
              for (var room in floorList) {
                if (room.isBooked &&
                    comparatorTable[element.commandList[1]]!(
                        room.bookedAge, int.parse(element.commandList[2]))) {
                  guest.add(room.bookedName!);
                }
              }
            }
            if (guest.isEmpty) {
              output +=
                  'Not found guest ${element.commandList[1]} ${element.commandList[2]}.\n';
              break;
            } else {
              output +=
                  '${guest.toString().substring(1, guest.toString().length - 1)}\n';
              break;
            }

          case 'list_guest_by_floor':
            int floor = int.parse(element.commandList[1]);
            if (floor > hotel.roomList.length || floor <= 0) {
              output += 'Not found any guest in floor $floor\n';
              break;
            }
            final guest = <String>{};
            for (var room in hotel.roomList[floor - 1]) {
              if (room.isBooked) {
                guest.add(room.bookedName!);
              }
            }
            if (guest.isNotEmpty) {
              output +=
                  '${guest.toString().substring(1, guest.toString().length - 1)}\n';
              break;
            } else {
              output += 'Not found any guest in floor $floor\n';
              break;
            }

          case 'checkout_guest_by_floor':
            int floor = int.parse(element.commandList[1]);
            if (floor > hotel.roomList.length || floor <= 0) {
              output += 'floor $floor not correct\n';
              break;
            }

            List<String> roomList = [];
            for (var room in hotel.roomList[floor - 1]) {
              if (room.isBooked) {
                hotel.keyCard[room.roomKeyCard!] = false;
                hotel.roomList[floor - 1][room.roomInt - 1].roomKeyCard = null;
                hotel.roomList[floor - 1][room.roomInt - 1].isBooked = false;
                hotel.roomList[floor - 1][room.roomInt - 1].bookedAge = null;
                hotel.roomList[floor - 1][room.roomInt - 1].bookedName = null;
                roomList.add(room.roomIdString);
              }
            }

            output +=
                'Room ${roomList.toString().substring(1, roomList.toString().length - 1)} are checkout.\n';
            break;

          case 'book_by_floor':
            if (hotel.isCreated) {
              int floor = int.parse(element.commandList[1]);
              bool isAllAvailable = true;
              if (floor > hotel.roomList.length || floor < 1) {
                output += 'Floor ${element.commandList[1]} cannot be found!\n';
                break;
              } else {
                for (var room in hotel.roomList[floor - 1]) {
                  if (room.isBooked) {
                    isAllAvailable = false;
                  }
                }
                if (isAllAvailable) {
                  List<String> keyList = [];
                  List<String> roomList = [];
                  int firstAvailableKey = 1;

                  while (hotel.keyCard[firstAvailableKey]!) {
                    firstAvailableKey++;
                  }

                  for (var i = 0; i < hotel.roomList.first.length; i++) {
                    hotel.roomList[floor - 1][i].isBooked = true;
                    hotel.roomList[floor - 1][i].bookedName =
                        element.commandList[2];
                    hotel.roomList[floor - 1][i].bookedAge =
                        int.parse(element.commandList[3]);
                    hotel.keyCard[firstAvailableKey] = true;
                    hotel.roomList[floor - 1][i].roomKeyCard =
                        firstAvailableKey;
                    keyList.add(firstAvailableKey.toString());
                    firstAvailableKey++;
                  }

                  for (var room in hotel.roomList[floor - 1]) {
                    roomList.add(room.roomIdString);
                  }

                  output +=
                      'Room ${roomList.toString().substring(1, roomList.toString().length - 1)} are booked with keycard number ${keyList.toString().substring(1, keyList.toString().length - 1)}\n';
                  break;
                } else {
                  output +=
                      'Cannot book floor $floor for ${element.commandList[2]}.\n';
                  break;
                }
              }
            } else {
              output += 'Hotel has not yet been created!\n';
              break;
            }

          default:
            output += 'Command not found.\n';
            break;
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
  List<List<Room>> roomList = [];
  List<Room> bookedList = [];
  Map<int, bool> keyCard = {};
  Hotel({this.isCreated = false});
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
  '===': (a, b) => a == b,
  '==': (a, b) => a == b,
  '=': (a, b) => a == b,
  '!=': (a, b) => a != b,
  '>': (a, b) => a > b,
  '>=': (a, b) => a >= b,
  '=>': (a, b) => a >= b,
  '<': (a, b) => a < b,
  '<=': (a, b) => a <= b,
  '=<': (a, b) => a <= b,
};

const projectName = 'Hotel Management System by Ittipat Pattum';
const initialInput = '''create_hotel 2 3
book 203 Thor 32
book 101 PeterParker 16
book 102 StephenStrange 36
book 201 TonyStark 48
book 202 TonyStark 48
book 203 TonyStark 48
list_available_rooms
checkout 4 TonyStark
book 103 TonyStark 48
book 101 Thanos 65
checkout 1 TonyStark
checkout 5 TonyStark
checkout 4 TonyStark
list_guest
get_guest_in_room 203
list_guest_by_age < 18
list_guest_by_floor 2
checkout_guest_by_floor 1
book_by_floor 1 TonyStark 48
book_by_floor 2 TonyStark 48''';
