import 'dart:io';

import 'package:band_names/src/models/band.dart';
import 'package:band_names/src/services/socket.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];
  late SocketService socketService;

  @override
  void initState() {
    socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands',_handleActiveBands);
    super.initState();
  }

  _handleActiveBands(dynamic payload){
    this.bands = (payload as List)
        .map((band) => Band.fromMap(band))
        .toList();
      setState(() {});
  }

  @override
  void dispose() {
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    socketService = Provider.of<SocketService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('BandNames', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: AnimatedSwitcher(
              duration: const Duration(microseconds: 1000),
              child: test(),
            )            
          )
        ],
      ),
      body: Column(
        children: [
          _showGraph(),
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, int i) => _bandTile(bands[i]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 1,
        onPressed: addNewBand,
      ),
    );
  }

  Widget _bandTile(Band band) {
    socketService = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) =>socketService.socket.emit('delete-band', {'id': band.id}),
      background: Container(
        padding: EdgeInsets.only(left: 8.0),
        color: Colors.red,
        child: Align(
            alignment: Alignment.centerLeft,
            child: Icon(Icons.delete, color: Colors.white)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0, 2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text(
          '${band.votes}',
          style: TextStyle(fontSize: 20),
        ),
        onTap: () => socketService.socket.emit('vote-band', {'id' : band.id}),
      ),
    );
  }
  Widget test(){
    switch (socketService.serverStatus) {
      case ServerStatus.Online:
        return Container(key: Key('1'), child: Icon(Icons.check_circle, color: Colors.blue[300]));
      case ServerStatus.Offline:
        return Container(key: Key('2'), child: Icon(Icons.offline_bolt, color: Colors.red));
      default: return Container(key: Key('3'), child: Icon(Icons.warning, color: Colors.amber));
    }
  }

  addNewBand() {
    final textController = new TextEditingController();
    if (Platform.isAndroid) {
      return showDialog(
        //para android
        context: context,
        builder: (_) => AlertDialog(
            title: Text('New Band Name'),
            content: TextField(
              controller: textController,
            ),
            actions: <Widget>[
              MaterialButton(
                child: Text('add'),
                elevation: 5,
                textColor: Colors.blue,
                onPressed: () => addBandToList(textController.text),
              )
            ],
          ),
      );
    }
    showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
            title: Text('New Band Name'),
            content: CupertinoTextField(
              controller: textController,
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text('Add'),
                onPressed: () => addBandToList(textController.text),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: Text('Dissmiss'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          )
        );
  }

  void addBandToList(String name) {
    socketService = Provider.of<SocketService>(context, listen: false);
    if (name.length > 1) {
      socketService.socket.emit('add-band', {'name': name});
    }

    Navigator.pop(context);
  }

  Widget _showGraph(){
    Map<String, double> dataMap = {};
    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });

    final List<Color> colorList = [
      Colors.blue[50]!,
      Colors.blue[200]!,
      Colors.pink[50]!,
      Colors.pink[200]!,
      Colors.green[50]!,
      Colors.green[200]!,
      Colors.yellow[50]!,
      Colors.yellow[200]!,
    ];
    return Container(
      padding: EdgeInsets.all(15),
      width: double.infinity,
      height: 200,
      child: PieChart(
        dataMap: dataMap,
        animationDuration: const Duration(milliseconds: 200),
        chartValuesOptions: ChartValuesOptions(showChartValuesInPercentage: true, showChartValuesOutside: false, showChartValues: true),
        chartType: ChartType.ring,
        colorList: colorList,
      ),
    );
  }
}
