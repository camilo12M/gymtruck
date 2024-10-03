import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatBotService {
  final String token = 'R5O363B6LMDWERZA2CUQ5PPBRRL7JOZP'; // Tu token aquí

  Future<String> getResponse(String message) async {
    final url = 'https://api.wit.ai/message?v=20240929&q=$message';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Imprimir la respuesta completa para entender su estructura
      print(data); // Esto te ayudará a ver la estructura de la respuesta

      final intent =
          data['intents'].isNotEmpty ? data['intents'][0]['name'] : null;

      // Ajusta este campo según la respuesta de la API
      switch (intent) {
        case 'saludo':
          return '¡Hola! ¿En qué puedo ayudarte hoy?';
        case 'nutricion':
          return "la nutricion es bueno para que puedas mantener un cuerpo fitness";
        case 'ejercicio_abdominales':
          return 'Te recomiendo hacer planchas y crunches. Ambos son excelentes para fortalecer el abdomen.';

        case 'rutina_principiantes':
          return 'Para principiantes, una rutina de cuerpo completo que incluya sentadillas, flexiones y abdominales es ideal.';
        case 'consejo_nutricion':
          return 'Es importante comer una mezcla de proteínas, carbohidratos y grasas saludables. Considera incluir pollo, arroz integral y verduras.';
        case 'ejercicio_fuerza':
          return 'Los ejercicios de fuerza como levantamiento de pesas y push-ups son efectivos para aumentar la masa muscular.';
        case 'consejo_cardio':
          return 'El cardio de alta intensidad, como el HIIT, es muy efectivo para perder peso rápidamente.';
        case 'ejercicio_piernas':
          return 'Para las piernas, prueba hacer sentadillas, peso muerto y zancadas.';
        case 'consejo_recuperacion':
          return 'Asegúrate de descansar adecuadamente y mantenerte hidratado para una buena recuperación.';
        case 'error_entrenamiento':
          return 'Algunos errores comunes son no calentar adecuadamente, usar una técnica incorrecta y no permitir tiempo de recuperación.';
        case 'consejo_hidratacion':
          return 'Es fundamental beber suficiente agua antes, durante y después de tus entrenamientos. Al menos 2 litros al día es una buena meta.';
        case 'ejercicio_cardiovascular':
          return 'Ejercicios como correr, nadar y montar en bicicleta son excelentes para mejorar tu salud cardiovascular.';
        case 'consejo_calentamiento':
          return 'Siempre realiza un calentamiento de al menos 10 minutos antes de comenzar tu rutina de ejercicios para prevenir lesiones.';
        case 'rutina_avanzada':
          return 'Para una rutina avanzada, puedes incorporar supersets y circuitos de entrenamiento para mayor intensidad.';
        case 'consejo_general':
          return 'Recuerda escuchar a tu cuerpo, mantenerte consistente y disfrutar del proceso de acondicionamiento físico.';
        default:
          return 'No entiendo, pero puedo ayudarte con ejercicios y recomendaciones de fitness. ¿Qué necesitas saber?';
      }
    } else {
      throw Exception('Error al comunicarse con el bot');
    }
  }
}
