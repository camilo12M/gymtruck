import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymtrack/infrastructure/models/exercises_models.dart';
import 'package:gymtrack/infrastructure/models/exercises_setmodels.dart';
import 'package:gymtrack/infrastructure/models/gym_item_model.dart';
import 'package:intl/intl.dart';

class DailyWorkout {
  final DateTime date;
  final List<Exercise> exercises;

  DailyWorkout({required this.date, required this.exercises});
}

Future<List<DailyWorkout>> getExercisesGroupedByDate() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception('User not logged in');

  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('exercises')
      .where('userId', isEqualTo: user.uid)
      .orderBy('timestamp', descending: true)
      .get();

  Map<DateTime, List<Exercise>> exercisesByDate = {};
  for (var doc in querySnapshot.docs) {
    var data = doc.data() as Map<String, dynamic>;
    String documentId = doc.id; // Obtén el ID del documento
    Exercise exercise = Exercise.fromFirestore(
        data, documentId); // Pásalo al constructor fromFirestore

    DateTime date = DateTime(
      exercise.timestamp!.year,
      exercise.timestamp!.month,
      exercise.timestamp!.day,
    );

    if (!exercisesByDate.containsKey(date)) {
      exercisesByDate[date] = [];
    }
    exercisesByDate[date]!.add(exercise);
  }

  return exercisesByDate.entries
      .map((entry) => DailyWorkout(date: entry.key, exercises: entry.value))
      .toList();
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DailyWorkout> dailyWorkouts = [];

  Widget buildExerciseCard(Exercise exercise, GymItem gymItem,
      int recordSetWeightLowReps, DateTime date) {
    try {
      print(
          'Construyendo tarjeta para: ${exercise.name}'); // Imprimir para verificar que se entre aquí

      // Aquí devolvemos el Container directamente.
      return Dismissible(
        key: Key(exercise.id),
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          // Muestra un diálogo de confirmación
          final bool confirm = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirmar'),
                    content: const Text(
                        '¿Quieres confirmar que quieres eliminar este elemento?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Eliminar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancelar'),
                      ),
                    ],
                  );
                },
              ) ??
              false; // El '?? false' es para manejar el caso en que showDialog() sea null

          // Si el usuario confirma, procede con la eliminación
          if (confirm) {
            FirebaseFirestore.instance
                .collection('exercises')
                .doc(exercise.id)
                .delete()
                .then((_) {
              deleteExercise(exercise.id, date);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exercise deleted')));
            }).catchError((error) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to delete exercise')));
            });
          }
          return confirm;
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.brown.shade300.withOpacity(0.20),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/icons/${exercise.exerciseIcon}', // Ruta al ícono del ejercicio
                      width: 30,
                      height: 30,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.name, // Nombre del ejercicio
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontFamily: 'Geologica',
                                fontWeight: FontWeight.w700),
                          ),
                          Text(
                            gymItem.name, // Nombre del GymItem asociado
                            style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontFamily: 'Geologica',
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            '$recordSetWeightLowReps', // Muestra el valor de recordSetWeightLowReps
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize:
                                  27, // Cambia esto para ajustar el tamaño del texto
                              fontFamily: 'Geologica',
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'KG',
                            style: TextStyle(
                              color: Colors.brown.shade200,
                              fontSize:
                                  19, // Cambia esto para ajustar el tamaño del texto
                              fontFamily: 'Geologica',
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Contenedor para el icono y el texto verde
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                        child: const Row(
                          children: [
                            // Añadir el icono de gráfico aquí
                            Icon(
                              Icons.arrow_drop_up,
                              color: Colors.green,
                              size: 20,
                            ), // Ejemplo con un ícono incorporado
                            // Texto "10.3%" en verde
                            Text(
                              '10.3%',
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 10,
                                  fontFamily: 'Geologica',
                                  fontWeight: FontWeight.w700),
                            ),
                            SizedBox(
                                width:
                                    5), // Espacio entre la fila superior y los sets
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: exercise.sets.asMap().entries.map((entry) {
                          int setIndex = entry.key;
                          ExerciseSet set = entry.value;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  'Set ${setIndex + 1}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 7,
                                      fontFamily: 'Geologica',
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                              Text(
                                '${set.weight} KG, ${set.reps} reps',
                                style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 7,
                                    fontFamily: 'Geologica',
                                    fontWeight: FontWeight.w600),
                              ),
                              if (set.assists > 0)
                                Text(
                                  ' (${set.assists})',
                                  style: const TextStyle(
                                      color: Colors.blueAccent,
                                      fontSize: 7,
                                      fontFamily: 'Geologica',
                                      fontWeight: FontWeight.w700),
                                ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Aquí puedes añadir más información sobre el ejercicio si es necesario
            ],
          ),
        ),
      );
    } catch (e) {
      print('Error al construir la tarjeta de ejercicio: $e');
      return const SizedBox(); // Devuelve un widget vacío si hay un error
    }
  }

  void deleteExercise(String documentId, DateTime date) {
    setState(() {
      // Encuentra y elimina el ejercicio de la lista correspondiente al 'date'
      dailyWorkouts = dailyWorkouts.map((dailyWorkout) {
        if (dailyWorkout.date == date) {
          dailyWorkout.exercises
              .removeWhere((exercise) => exercise.id == documentId);
        }
        return dailyWorkout;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 27, 20, 18),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/images/logo.png', // Reemplaza con la ruta de tu logo.
                    height: 50, // Ajusta la altura según sea necesario.
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle,
                        color: Colors.white.withOpacity(0.9)),
                    onPressed: () {
                      // Acciones cuando se presione el botón de agregar.
                    },
                  ),
                ],
              ),
            ),

            // Se reemplaza el Expanded con FutureBuilder
            Expanded(
              child: FutureBuilder<List<DailyWorkout>>(
                future: getExercisesGroupedByDate(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No exercises found'));
                  }

                  // Datos están disponibles y no son vacíos
                  List<DailyWorkout> dailyWorkouts = snapshot.data!;

                  print(
                      'Daily workouts: $dailyWorkouts'); // Agregar esta línea para depurar

                  // Se construye una lista de Widgets basada en los DailyWorkout
                  List<Widget> workoutWidgets =
                      dailyWorkouts.map((dailyWorkout) {
                    // Formatear la fecha como "Lunes 18"
                    String formattedDate = DateFormat('EEEE d')
                        .format(dailyWorkout.date)
                        .capitalize();
                    // Crea un Widget para el encabezado de la fecha
                    List<Widget> exerciseWidgets = [
                      Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Text(formattedDate,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'Geologica',
                                fontWeight: FontWeight.w700)),
                      ),
                    ];
                    // Crea un listado de Widgets para los ejercicios del día
                    exerciseWidgets
                        .addAll(dailyWorkout.exercises.map((exercise) {
                      // Asegúrate de pasar la fecha aquí
                      return buildExerciseCard(exercise, exercise.gymItem,
                          exercise.recordSetWeightLowReps, dailyWorkout.date);
                    }).toList());

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: exerciseWidgets,
                    );
                  }).toList();

                  print(
                      'Workout widgets: $workoutWidgets'); // Agregar esta línea para depurar

                  return SingleChildScrollView(
                    child: Column(
                      children: workoutWidgets,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
