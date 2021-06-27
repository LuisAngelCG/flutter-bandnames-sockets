import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:band_names/src/services/socket.dart';

class StatusPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    // socketService.socket.emit('mensaje que ve a a emitir');
    return Scaffold(
      body: Center(
        child: Text('ServerStatus: ${socketService.serverStatus}'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.message),
        onPressed: () {
          //emitir :
          //{nombre: 'Flutter', mensaje: 'Hola desde flutter'}
          socketService.socket.emit('nuevo-mensaje',
              {'nombre': 'FLutter', 'mensaje': 'Hola desde flutter'});
        },
      ),
    );
  }
}
