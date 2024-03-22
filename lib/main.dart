import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bluetooth',
      home: Blue(),
    );
  }
}

class Blue extends StatefulWidget {
  const Blue({super.key});

  @override
  _BlueState createState() => _BlueState();
}

class _BlueState extends State<Blue> {
  FlutterBluePlus flutterBluePlus = FlutterBluePlus();
  List<ScanResult> dispositivo = [];
  bool scanning = false;
  BluetoothDevice? connectedDevice;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  _startScan() {
    setState(() {
      scanning = true;
    });
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));

    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        dispositivo = results;
      });
    });
  }

  _connectToDevice(BluetoothDevice device) async {
    // ignore: deprecated_member_use
    if (connectedDevice != null && connectedDevice!.id == device.id) {
      await connectedDevice!.disconnect();
      setState(() {
        connectedDevice = null;
      });
    } else {
      try {
        await device.connect();
        setState(() {
          connectedDevice = device;
        });
      } catch (error) {
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error de conexión'),
              content: const Text(
                  'No se pudo conectar con el dispositivo. Inténtalo de nuevo más tarde.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Aceptar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispositivos Bluetooth'),
      ),
      body: ListView.builder(
        itemCount: dispositivo.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(dispositivo[index].device.name),
            subtitle: Text(dispositivo[index].device.id.toString()),
            trailing: ElevatedButton(
              onPressed: () => _connectToDevice(dispositivo[index].device),
              child: connectedDevice != null &&
                      connectedDevice!.id == dispositivo[index].device.id
                  ? const Text('Desconectar')
                  : const Text('Conectar'),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startScan(),
        child: const Icon(Icons.bluetooth_searching),
      ),
    );
  }
}
