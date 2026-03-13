import 'package:flutter/foundation.dart';

@immutable
class CoupleChallenge {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int coinReward;
  final String category;
  final String location;
  final String planning;
  final String timing;
  final String motivation;

  const CoupleChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.coinReward,
    required this.category,
    required this.location,
    required this.planning,
    required this.timing,
    required this.motivation,
  });

  static CoupleChallenge get testChallenge => allChallenges[0];

  static List<CoupleChallenge> get allChallenges => [
        const CoupleChallenge(
          id: 'weekly_challenge_1',
          title: 'Recreando la primera cita',
          description:
              'Vuelvan al lugar donde todo empezó.\n\nTraten de recrear los detalles: la comida, la ropa, las frases, los nervios.\n\nCharlen sobre cómo eran entonces y todo lo que han crecido juntos.\n\nSerá imposible no reírse recordando anécdotas y sentirse agradecidos por lo vivido.',
          icon: '❤️',
          coinReward: 15,
          category: 'Experiencial',
          location: 'Exterior',
          planning: 'Media',
          timing: 'Cualquier momento',
          motivation:
              'A veces volver atrás es la mejor forma de ver cuánto han avanzado juntos.',
        ),
        const CoupleChallenge(
          id: 'weekly_challenge_2',
          title: 'Cena a la luz de las velas',
          description:
              'Solo necesitan unas velas o luces cálidas, una comida y algo rico para tomar.\n\nApaguen las luces, bajen el ritmo, y dejen que el silencio se llene con música suave y miradas.\n\nLo importante no es el menú, sino la presencia del otro.',
          icon: '🕯️',
          coinReward: 15,
          category: 'Romántico',
          location: 'En casa',
          planning: 'Mínima',
          timing: 'Noche',
          motivation:
              'Una cita perfecta para reconectar sin distracciones y recordar por qué se eligen cada día.',
        ),
        const CoupleChallenge(
          id: 'weekly_challenge_3',
          title: 'Lista de sueños compartidos',
          description:
              'Tomen papel y lápiz. Anoten juntos al menos 10 cosas que les gustaría lograr como pareja: viajes, metas o sueños.\n\nLean cada uno en voz alta y guárdenlo como recordatorio.',
          icon: '✨',
          coinReward: 15,
          category: 'Emocional',
          location: 'En casa',
          planning: 'Baja',
          timing: 'Tarde',
          motivation:
              'Tener sueños en común no solo une, sino que da dirección a su historia.',
        ),
        const CoupleChallenge(
          id: 'weekly_challenge_4',
          title: 'Karaoke casero',
          description:
              'Suban el volumen, elijan canciones y dejen que la diversión empiece. No hace falta micrófono ni voz perfecta, solo actitud.\n\nEntre risas van a descubrir lo liberador que es reírse juntos.',
          icon: '🎤',
          coinReward: 15,
          category: 'Lúdico',
          location: 'En casa',
          planning: 'Ninguna',
          timing: 'Noche',
          motivation: 'El amor también se canta desafinando, pero al mismo ritmo.',
        ),
        const CoupleChallenge(
          id: 'weekly_challenge_5',
          title: 'Pintando juntos',
          description:
              'Consigan hojas y pinceles. No importa si no saben dibujar: la idea es soltar la mente, reírse de los trazos y disfrutar del color.\n\nPinten algo que los represente como pareja.',
          icon: '🎨',
          coinReward: 15,
          category: 'Creativo',
          location: 'En casa',
          planning: 'Media',
          timing: 'A definir',
          motivation: 'Porque el arte no busca perfección, busca conexión.',
        ),
        const CoupleChallenge(
          id: 'weekly_challenge_6',
          title: 'Maratón de películas',
          description:
              'Armen su propio cine: luz tenue, mantas, snacks y una lista de películas elegidas por ambos.\n\nVer películas juntos es también mirarse de reojo y reírse en sincronía.',
          icon: '🍿',
          coinReward: 15,
          category: 'Relajado',
          location: 'En casa',
          planning: 'Baja',
          timing: 'Noche',
          motivation: 'Pequeñas cosas que hacen grande el amor.',
        ),
        const CoupleChallenge(
          id: 'weekly_challenge_7',
          title: 'Caminata fotográfica',
          description:
              'Salgan a caminar sin rumbo y busquen capturar lo que pasa desapercibido: una sombra, una sonrisa, un reflejo.\n\nSaquen fotos de lo que los haga detenerse.',
          icon: '📸',
          coinReward: 15,
          category: 'Aventura',
          location: 'Ciudad',
          planning: 'Baja',
          timing: 'Tarde',
          motivation:
              'A veces mirar el mundo a través del lente es la mejor forma de volver a mirarse entre sí.',
        ),
      ];

  static CoupleChallenge get currentWeeklyChallenge {
    final now = DateTime.now();
    final firstDayOfYear = DateTime(now.year, 1, 1);
    final daysSinceStart = now.difference(firstDayOfYear).inDays;
    final weekIndex = (daysSinceStart / 7).floor();

    return allChallenges[weekIndex % allChallenges.length];
  }
}
