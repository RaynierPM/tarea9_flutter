import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:http/http.dart' as apis;

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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

  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController latitudController = TextEditingController();
  final TextEditingController longitudController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: "Nombre",
                  hintText: "Ej: pedro",
                ),

                validator: validatorForm,
              ), 
              getSpacer(10.0),
              TextFormField(
                controller: apellidoController,
                decoration: const InputDecoration(
                  labelText: "Apellido",
                  hintText: "Ej: Martinez",
                ),

                validator: validatorForm,
              ), 
              getSpacer(10.0),
              TextFormField(
                controller: latitudController,
                decoration: const InputDecoration(
                  labelText: "Latitud",
                  hintText: "Ej: 10.000",
                ),

                validator: validatorFormNumber,
              ), 
              getSpacer(10.0),
              TextFormField(
                controller: longitudController,
                decoration: const InputDecoration(
                  labelText: "Longitud",
                  hintText: "Ej: -69.00",
                ),

                validator: validatorFormNumber,
              ), 
              getSpacer(10.0),

              ElevatedButton(onPressed: () {

                if (_form.currentState!.validate()) {

                  Datos datos = Datos(
                    nombre: nombreController.text, 
                    apellido: apellidoController.text, 
                    latitud: double.parse(latitudController.text),
                    longitud: double.parse(longitudController.text)
                  );

                  showDialog(context: context, builder: (BuildContext context) => Scaffold(
                    appBar: AppBar(title: Text("Mapa ")),
                    body: Maps(datos: datos),
                  ));
                }

              },
                child:const Text("Ver mapa"))
            ],
          ),
        )
        
      ),
    );
  }

  String? validatorForm(value) {
    if (value!.isEmpty) {
      return "No deje el campo vacio";
    }
    return null;
  }
  
  
  String? validatorFormNumber(value) {
    if (value!.isEmpty) {
      return "No deje el campo vacio";
    }

    try {
      double.parse(value);
    } catch (e) {
      return "El dato debe ser numerico";
    }

    return null;
  }
}


Widget getSpacer(double height) => SizedBox(height: height);


class Datos {
  Datos({required this.nombre,required this.apellido,required this.latitud,required this.longitud});



  final String nombre;
  final String apellido;
  final double latitud;
  final double longitud;

  String? city;

  LatLng getUbication() => LatLng(latitud, longitud);

  Future<String?> getCity() async {
    final request = await apis.get(Uri.parse("https://geocode.maps.co/reverse?lat=${latitud}&lon=${longitud}"));
    
    return jsonDecode(request.body)["display_name"];
  }
} 


class Maps extends StatefulWidget {
  Maps({super.key, required this.datos}) {
    initialPosition =  CameraPosition(
      target: datos.getUbication(),
      zoom: 13.5,
      
    );
  }

  Datos datos;

  CameraPosition? initialPosition;

  @override
  State<Maps> createState() => _MapsState();
}

class _MapsState extends State<Maps> {

  String? ciudad = "Cargando..."; 

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getCiudad();
  }


  Future<void> getCiudad() async {
    final cityName = await widget.datos.getCity();

    setState(() {
      ciudad = cityName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: widget.initialPosition!,
      markers: {Marker(markerId: MarkerId("${widget.datos.nombre} _ ${widget.datos.apellido}"),
          position: widget.datos.getUbication(),
          infoWindow: InfoWindow(title: "${widget.datos.nombre} ${widget.datos.apellido}", snippet: "Ciudad: $ciudad")
        )
      },
      
    );
  }
}