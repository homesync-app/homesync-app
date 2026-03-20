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
        const CoupleChallenge(
          id: 'weekly_challenge_8',
          title: 'Picnic improvisado',
          description:
              'Una manta, algo para picar, bebidas frescas y ganas de compartir.\n\nEncuentren un parque, una plaza o incluso el patio de casa, acomódense y dejen que la charla fluya.\n\nAgreguen un juego de cartas, un libro o simplemente miren el cielo.',
          icon: '🧺',
          coinReward: 15,
          category: 'Experiencial',
          location: 'Al aire libre',
          planning: 'Ligera',
          timing: 'Tarde',
          motivation: 'No hace falta ir lejos para sentir que se escapan del mundo.',
        ),
        const CoupleChallenge(
          id: 'weekly_challenge_9',
          title: 'Cartas que no se borran',
          description:
              'Escriban una carta al otro. No en el celular: con papel y tinta.\n\nPongan música suave, preparen algo rico y déjense llevar.\n\nEscriban lo que admiran, lo que agradecen, lo que sueñan.\n\nAl final, intercámbienlas y lean en voz alta.',
          icon: '✉️',
          coinReward: 15,
          category: 'Emocional',
          location: 'En casa',
          planning: 'Sin preparación',
          timing: 'Noche',
          motivation:
              'Las cartas quedan, las palabras se leen, pero lo que más perdura es cómo te hacen sentir.',
        ),
        const CoupleChallenge(
          id: 'weekly_challenge_10',
          title: 'Desconexión total',
          description:
              'Apaguen los celulares, la tele y cualquier notificación del mundo exterior por una noche.\n\nLean, cocinen, hablen, jueguen o simplemente abrácense sin interrupciones.\n\nVan a descubrir que cuando el ruido digital se apaga, aparece un silencio distinto: el que deja lugar a la presencia.',
          icon: '📵',
          coinReward: 15,
          category: 'Emocional',
          location: 'En casa',
          planning: 'Sin preparación',
          timing: 'Noche',
          motivation: 'Esta cita no se mide en minutos, sino en conexión real.',
        ),
        const CoupleChallenge(
          id: 'weekly_challenge_11',
          title: 'Frasco de preguntas',
          description:
              'En un frasco, pongan papelitos con preguntas divertidas o profundas.\n\n"¿Qué es lo primero que pensaste cuando me conociste?" o "¿Qué sueño aún no te animás a contarme?".\n\nSáquenlas al azar y respondan sin filtros. Van a terminar entre risas y miradas largas.',
          icon: '🏺',
          coinReward: 15,
          category: 'Lúdico',
          location: 'En casa',
          planning: 'Sin preparación',
          timing: 'Cualquier momento',
          motivation: 'Algunas charlas no surgen hasta que se invitan.',
        ),
        const CoupleChallenge(
          id: 'weekly_challenge_23',
          title: 'Desayuno con vista',
          description:
              'Cambien el escenario del desayuno: preparen algo rico y salgan a buscar una vista. Puede ser un parque, una terraza o un banco en una plaza.\n\nTómense el tiempo de saborear el aire fresco y el café sin mirar el reloj.',
          icon: '🥐',
          coinReward: 15,
          category: 'Exploración',
          location: 'Exterior',
          planning: 'Ligera',
          timing: 'Mañana',
          motivation: 'El café sabe mejor cuando el horizonte es el límite.',
        ),
        const CoupleChallenge(
          id: 'weekly_challenge_24',
          title: 'A la orilla del mundo',
          description:
              'Elijan un lugar donde el horizonte se sienta infinito: una orilla, un río o una laguna. Lleven algo para sentarse y simplemente miren cómo se va el sol.\n\nEscriban juntos una nota sobre lo que sueñan y guárdenla para el futuro.',
          icon: '🌊',
          coinReward: 15,
          category: 'Emocional',
          location: 'Naturaleza',
          planning: 'Media',
          timing: 'Atardecer',
          motivation: 'El silencio compartido frente al agua dice más que mil palabras.',
        ),
        const CoupleChallenge(
          id: 'weekly_challenge_25',
          title: 'Destino incierto',
          description:
              'Salgan a caminar sin mapa ni GPS. Elijan una dirección al azar y, cada 5 cuadras, uno de los dos decide hacia dónde girar.\n\nDescubran rincones nuevos de su ciudad como si fueran turistas perdidos.',
          icon: '🧭',
          coinReward: 15,
          category: 'Exploración',
          location: 'Ciudad',
          planning: 'Ninguna',
          timing: 'Tarde',
          motivation: 'Perderse juntos es la mejor forma de encontrarse.',
        ),
        const CoupleChallenge(
          id: 'weekly_challenge_26',
          title: 'Ritual del presente',
          description:
              'Preparen un espacio con luz cálida y música suave. Cada uno escriba en un papel tres cosas que quiere dejar atrás (miedos, enojos) y tres que agradece del otro.\n\nQuemen lo que quieren soltar y guarden los agradecimientos en un frasco.',
          icon: '🔥',
          coinReward: 15,
          category: 'Emocional',
          location: 'En casa',
          planning: 'Mínima',
          timing: 'Noche',
          motivation: 'Limpiar el pasado deja lugar para un futuro más brillante.',
        ),
        const CoupleChallenge(
          id: 'weekly_challenge_27',
          title: 'Arquitecto de sorpresas',
          description:
              'Uno de los dos organiza una sorpresa pequeña: una nota en la almohada, su comida favorita preparada en secreto o una mini pista para una aventura.\n\nLa clave es el misterio y el detalle pensado exclusivamente para el otro.',
          icon: '🎁',
          coinReward: 15,
          category: 'Detallista',
          location: 'Cualquier lugar',
          planning: 'Media',
          timing: 'Sorpresa',
          motivation: 'El amor vive en los detalles que dicen "pensé en vos".',
        ),
        const CoupleChallenge(
          id: 'weekly_challenge_28',
          title: 'Al servicio del amor',
          description:
              'Turnense para "atender" al otro durante un rato: preparen un baño, den un masaje o cocinen sin que el otro mueva un dedo.\n\nNo es servidumbre, es cuidar al otro desde la ternura y la entrega consciente.',
          icon: '💝',
          coinReward: 15,
          category: 'Cotidiano',
          location: 'En casa',
          planning: 'Mínima',
          timing: 'Noche',
          motivation: 'Cuidar es una forma silenciosa y poderosa de amar.',
        ),
        const CoupleChallenge(
          id: 'weekly_challenge_29',
          title: 'Historias en escena',
          description:
              'Elijan una escena famosa de una película y traten de recrearla con lo que tengan en casa. No busquen la perfección, sino la risa y la complicidad.\n\nAl final, pueden inventar el final de esa historia juntos.',
          icon: '🎭',
          coinReward: 15,
          category: 'Lúdico',
          location: 'En casa',
          planning: 'Mínima',
          timing: 'Cualquier momento',
          motivation: 'Jugar a ser otros ayuda a redescubrir quiénes son ustedes.',
        ),
        const CoupleChallenge(
          id: 'weekly_challenge_30',
          title: 'Sabores con historia',
          description:
              'Elijan tres sabores (vinos, chocolates, quesos) y, ante cada uno, cuenten un recuerdo personal vinculado a él: un viaje, la infancia o una persona.\n\nDejen que el paladar despierte anécdotas que aún no han compartido.',
          icon: '🍷',
          coinReward: 15,
          category: 'Experiencial',
          location: 'Cualquier lugar',
          planning: 'Media',
          timing: 'Noche',
          motivation: 'Cada bocado es una puerta abierta a un recuerdo.',
        ),
        const CoupleChallenge(
          id: 'weekly_challenge_31',
          title: 'El arte de no hacer nada',
          description:
              'Apaguen alarmas y pendientes. Pasen un día sin horarios: lean en la cama, miren series viejas o charlen sin rumbo.\n\nPermítanse el lujo de habitar el tiempo sin la presión de ser productivos.',
          icon: '🛌',
          coinReward: 15,
          category: 'Relajado',
          location: 'En casa',
          planning: 'Ninguna',
          timing: 'Todo el día',
          motivation: 'El tiempo "perdido" juntos es tiempo ganado en conexión.',
        ),
        const CoupleChallenge(
          id: 'weekly_challenge_32',
          title: 'Domingo de mercado',
          description:
              'Vayan a un mercado local con bolsas de tela y mate. No busquen comprar mucho, sino disfrutar del color, los aromas y la gente.\n\nElijan un ingrediente raro para cocinar algo nuevo al volver a casa.',
          icon: '🥬',
          coinReward: 15,
          category: 'Exploración',
          location: 'Ciudad',
          planning: 'Baja',
          timing: 'Mañana',
          motivation: 'La rutina también tiene su propia magia artesanal.',
        ),
        const CoupleChallenge(
          id: 'weekly_challenge_33',
          title: 'Bajo las estrellas',
          description:
              'Busquen un punto alejado de las luces de la ciudad. Lleven una manta, cielo abierto y silencio.\n\nCuenten estrellas, inventen sus propias constelaciones o simplemente sientan la inmensidad juntos.',
          icon: '🌌',
          coinReward: 15,
          category: 'Romántico',
          location: 'Naturaleza',
          planning: 'Media',
          timing: 'Noche',
          motivation: 'El universo entero cabe en el espacio entre los dos.',
        ),
        const CoupleChallenge(
          id: 'weekly_challenge_34',
          title: 'Noche de los sentidos',
          description:
              'Preparen una mesa con texturas, aromas y sabores misteriosos. Con los ojos cerrados, el otro debe adivinar qué está sintiendo.\n\nUna dinámica para entregarse a las sensaciones sin necesidad de palabras.',
          icon: '👂',
          coinReward: 15,
          category: 'Sensoral',
          location: 'En casa',
          planning: 'Media',
          timing: 'Noche',
          motivation: 'El amor se saborea, se huele y se toca.',
        ),
        const CoupleChallenge(
          id: 'weekly_challenge_35',
          title: 'Lectura compartida',
          description:
              'Elijan un libro, poema o artículo y léanlo en voz alta, alternándose secciones. Escuchen el tono y la pausa del otro.\n\nAl terminar, compartan qué les hizo pensar o sentir esa historia.',
          icon: '📖',
          coinReward: 15,
          category: 'Intelectual',
          location: 'Tranquilo',
          planning: 'Mínima',
          timing: 'Noche',
          motivation: 'Las palabras son el puente que une dos mentes.',
        ),
        const CoupleChallenge(
          id: 'weekly_challenge_36',
          title: 'Microteatro en pareja',
          description:
              'Busquen una función de microteatro o una obra corta. Vivan la intensidad de una historia cercana y vibrante.\n\nCaminen después comentando la obra: lo que los hizo reír, llorar o reflexionar.',
          icon: '🎟️',
          coinReward: 15,
          category: 'Cultural',
          location: 'Ciudad',
          planning: 'Media',
          timing: 'Noche',
          motivation: 'Vivir mil vidas en una noche, siempre de la mano.',
        ),
        const CoupleChallenge(
          id: 'weekly_challenge_37',
          title: 'Viaje sin maletas',
          description:
              'Elijan un país y transformen su casa en ese destino por una noche: menú típico, música y ambientación del lugar.\n\nViajen sin pasaporte, imaginando qué harían si realmente estuvieran allí.',
          icon: '✈️',
          coinReward: 15,
          category: 'Creativo',
          location: 'En casa',
          planning: 'Alta',
          timing: 'Noche',
          motivation: 'El mejor destino es aquel que crean entre los dos.',
        ),
        const CoupleChallenge(
          id: 'weekly_challenge_38',
          title: 'El sobre secreto',
          description:
              'Uno prepara tres sobres con instrucciones que se abren por etapas: un outfit, un lugar de encuentro y un cierre especial.\n\nLa magia está en la expectativa de no saber qué viene después.',
          icon: '✉️',
          coinReward: 15,
          category: 'Aventura',
          location: 'Sorpresa',
          planning: 'Media',
          timing: 'Toda la tarde',
          motivation: 'Cada sobre es un "te pensé" esperando ser abierto.',
        ),
        const CoupleChallenge(
          id: 'weekly_challenge_39',
          title: 'Propósitos al alba',
          description:
              'Suban a un lugar alto para ver salir el sol. En el momento en que aparezca el primer rayo, prometan algo pequeño para su relación.\n\nUn hábito, un deseo o un cambio que quieran iniciar con el nuevo día.',
          icon: '🌅',
          coinReward: 15,
          category: 'Emocional',
          location: 'Exterior',
          planning: 'Media',
          timing: 'Alba',
          motivation: 'Cada amanecer es la oportunidad de empezar de nuevo.',
        ),
        const CoupleChallenge(
          id: 'weekly_challenge_40',
          title: 'Construyendo paciencia',
          description:
              'Pasen la tarde armando un rompecabezas juntos, con mate o vino de acompañamiento.\n\nEntre pieza y pieza, dejen que fluyan charlas tranquilas y silencios cómodos.',
          icon: '🧩',
          coinReward: 15,
          category: 'Relajado',
          location: 'En casa',
          planning: 'Baja',
          timing: 'Tarde',
          motivation: 'Armar lo pequeño es practicar la paciencia para lo grande.',
        ),
        const CoupleChallenge(
          id: 'weekly_challenge_41',
          title: 'Día de gratitud absoluta',
          description:
              'El reto de hoy: pasar 24 horas sin una sola queja. Cada vez que alguien se queje, debe compensarlo diciendo algo que agradece.\n\nAl final del día, repasen todas las cosas buenas que descubrieron.',
          icon: '🙏',
          coinReward: 15,
          category: 'Emocional',
          location: 'Cualquier lugar',
          planning: 'Ninguna',
          timing: 'Todo el día',
          motivation: 'Cambiar el foco cambia la relación entera.',
        ),
        const CoupleChallenge(
          id: 'weekly_challenge_42',
          title: 'Cápsula del tiempo',
          description:
              'Elijan cinco objetos que representen su presente: una foto, un ticket, una nota. Guárdenlos en una caja y séllenla con una fecha de apertura futura.\n\nEscriban una carta para sus "yo del futuro" describiendo cómo se sienten hoy.',
          icon: '📦',
          coinReward: 15,
          category: 'Emocional',
          location: 'En casa',
          planning: 'Media',
          timing: 'Noche',
          motivation: 'Guardar el presente es dejarle un regalo al futuro.',
        ),
        const CoupleChallenge(
          id: 'weekly_challenge_43',
          title: 'Pintura a ciegas',
          description:
              'Uno se tapa los ojos y el otro lo guía con la voz para trazar líneas y colores en un papel. Luego inviertan los roles.\n\nConfíen en la voz del otro y ríanse del resultado abstracto y compartido.',
          icon: '🙈',
          coinReward: 15,
          category: 'Lúdico',
          location: 'En casa',
          planning: 'Baja',
          timing: 'Cualquier momento',
          motivation: 'El amor también se pinta con los ojos cerrados.',
        ),
        const CoupleChallenge(
          id: 'weekly_challenge_44',
          title: 'Nuestro propio Podcast',
          description:
              'Grábense hablando como si estuvieran en un podcast. Elijan un tema: su historia, un viaje o qué han aprendido del amor.\n\nNo busquen sonar perfectos, busquen sonar auténticos. Guárdenlo como una cápsula de voz.',
          icon: '🎙️',
          coinReward: 15,
          category: 'Creativo',
          location: 'Tranquilo',
          planning: 'Ninguna',
          timing: 'Cualquier momento',
          motivation: 'Grabar la voz del amor es guardar una memoria viva.',
        ),
        const CoupleChallenge(
          id: 'weekly_challenge_45',
          title: 'Mensajes diferidos',
          description:
              'Escriban cada uno una carta al otro pero no la lean ahora. Intercambíenlas y pongan una fecha para abrirla dentro de una semana.\n\nDisfruten de la dulce espera y de saber que hay un mensaje de amor aguardando.',
          icon: '⏳',
          coinReward: 15,
          category: 'Emocional',
          location: 'En casa',
          planning: 'Baja',
          timing: 'Noche',
          motivation: 'El amor también se escribe en tiempo diferido.',
        ),
        const CoupleChallenge(
          id: 'weekly_challenge_46',
          title: 'Proyección de recuerdos',
          description:
              'Busquen fotos, videos y mensajes de cuando se conocieron. Proyecten o miren juntos cómo han crecido y qué obstáculos han superado.\n\nRedescubran juntos el camino que los trajo hasta el día de hoy.',
          icon: '🎞️',
          coinReward: 15,
          category: 'Emocional',
          location: 'En casa',
          planning: 'Baja',
          timing: 'Noche',
          motivation: 'Mirar atrás es la mejor forma de valorar el presente.',
        ),
        const CoupleChallenge(
          id: 'weekly_challenge_47',
          title: 'El día del "Sí"',
          description:
              'Durante un día entero, la consigna es decir que sí a todas las propuestas razonables del otro: un helado, un paseo, una siesta.\n\nDéjense llevar por la fluidez de un día sin negativas.',
          icon: '✅',
          coinReward: 15,
          category: 'Lúdico',
          location: 'Cualquier lugar',
          planning: 'Ninguna',
          timing: 'Todo el día',
          motivation: 'La estructura cansa, la fluidez conecta.',
        ),
        const CoupleChallenge(
          id: 'weekly_challenge_48',
          title: 'Brindis por el futuro',
          description:
              'Preparen su bebida favorita y brinden mirando al otro a los ojos. Escriban juntos un propósito para la próxima etapa: un viaje o una meta común.\n\nSellen el brindis con una sonrisa que diga "gracias por estar".',
          icon: '🥂',
          coinReward: 15,
          category: 'Emocional',
          location: 'Cualquier lugar',
          planning: 'Media',
          timing: 'Noche',
          motivation: 'Brindar por lo que viene es honrar lo que ya son.',
        ),
        const CoupleChallenge(
          id: 'weekly_challenge_49',
          title: 'Cocina experimental',
          description:
              'Elijan tres ingredientes al azar que tengan en casa y traten de crear un plato nuevo entre los dos.\n\nNo vale buscar recetas: usen la intuición, prueben y ríanse si el experimento sale raro.',
          icon: '🍳',
          coinReward: 15,
          category: 'Creativo',
          location: 'Cocina',
          planning: 'Ninguna',
          timing: 'Almuerzo/Cena',
          motivation: 'El sabor de lo improvisado siempre tiene un toque especial.',
        ),
        const CoupleChallenge(
          id: 'weekly_challenge_50',
          title: 'Muro de los deseos',
          description:
              'Peguen notas adhesivas con deseos, agradecimientos o metas en una pared o espejo. Dejen que el muro crezca durante la semana.\n\nLean cada nota al final y guárdenlas como testigos de sus intenciones.',
          icon: '🖼️',
          coinReward: 15,
          category: 'Detallista',
          location: 'En casa',
          planning: 'Baja',
          timing: 'Toda la semana',
          motivation: 'Hacer visible el deseo es empezar a cumplirlo.',
        ),
      ];

  static CoupleChallenge currentWeeklyChallenge([DateTime? householdCreatedAt]) {
    final index = currentWeeklyChallengeIndex(householdCreatedAt);
    return allChallenges[index];
  }

  static int currentWeeklyChallengeIndex([DateTime? householdCreatedAt]) {
    final now = DateTime.now();
    
    // Si no hay fecha de creación, usamos el lunes de esta semana como referencia 
    // para que sea consistente para todos los nuevos. 
    // Pero el usuario quiere que arranque por la primera al instalar.
    final referenceDate = householdCreatedAt ?? DateTime(now.year, 1, 1);
    
    // Calculamos semanas transcurridas desde la fecha de referencia
    final difference = now.difference(referenceDate);
    final weekIndex = (difference.inDays / 7).floor();
    return weekIndex % allChallenges.length;
  }
}
