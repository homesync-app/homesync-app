// Configuracion por avatar para la generacion de idle loops con Veo.
//
// keyColor: color de fondo plano que se pide a Veo y luego se elimina por chroma.
//   - 'green'   -> 0x00FF00 (default, mejor soportado por los modelos)
//   - 'magenta' -> 0xFF00FF (para avatares con elementos verdes en el arte)
//
// motion: descripcion especifica del movimiento idle de ese personaje.
//   Mantener SIEMPRE sutil: la animacion vive en un avatar chico del home.

export const KEY_COLORS = {
  green: { hex: '#00FF00', ffmpeg: '0x00FF00', name: 'pure green' },
  magenta: { hex: '#FF00FF', ffmpeg: '0xFF00FF', name: 'pure magenta' },
};

export const AVATARS = [
  {
    id: 'premium_mate_boy',
    keyColor: 'magenta',
    motion:
      'The boy breathes gently, blinks slowly, and takes a tiny sip from his mate gourd once, then smiles softly.',
  },
  {
    id: 'premium_keys_girl',
    keyColor: 'magenta',
    motion:
      'The girl breathes gently, blinks, and softly jingles the house keys in her hand once with a happy expression.',
  },
  {
    id: 'premium_market_dog',
    keyColor: 'magenta',
    // El arte de este perro trae un borde blanco tipo sticker (los otros no);
    // se erosiona el alfa N pasadas para dejarlo al ras como el resto.
    erodeBorder: 6,
    motion:
      'The golden puppy leans over and takes the handle of its shopping bag in its mouth, gives it a small proud lift as if bringing the groceries home, then gently sets the bag back down in the exact same spot and settles back into its original calm sitting pose, tail giving one happy wag. Starts and ends in exactly the input pose.',
  },
  {
    id: 'premium_orange_cat',
    keyColor: 'magenta',
    motion:
      'The orange kitten leans down and gently takes the handle of its grocery bag in its mouth, lifts it just a little as if proudly bringing the groceries home, then carefully sets the bag back down in the exact same spot and settles back into its original calm sitting pose. Starts and ends in exactly the input pose.',
  },
  {
    id: 'premium_paper_plane_kid',
    keyColor: 'magenta',
    motion:
      'The kid breathes gently, blinks, and the paper plane in his hand tilts slightly as if about to fly.',
  },
  {
    id: 'premium_star_girl',
    keyColor: 'magenta',
    motion:
      'The girl breathes gently, blinks, and the star she holds twinkles subtly while she smiles.',
  },
  {
    id: 'premium_key_bird',
    keyColor: 'magenta',
    motion:
      'The little yellow chick breathes gently, blinks softly and tilts its head a little with a happy expression, giving one small cheerful bounce on its feet. Its wing keeps holding the ribbon exactly as in the input the whole time; the bounce naturally makes the key charm dangling from it sway and jingle a little on its own, like a pendant swinging from the motion of the body, not from the wing moving it. Then the chick settles back into its original calm standing pose. Beak stays closed. Starts and ends in exactly the input pose.',
  },
  {
    id: 'premium_tool_adult_man',
    keyColor: 'magenta',
    motion:
      'The man breathes gently, blinks, and gives a small confident nod while holding his tools.',
  },
  {
    id: 'premium_plant_adult',
    keyColor: 'magenta',
    motion:
      'The person breathes gently, blinks, and the plant leaves sway very subtly as if touched by a light breeze.',
  },
  {
    // Chanchito rosa: chroma VERDE (el magenta se confunde con el cuerpo
    // rosado). despill off: la bandana sage es verdosa y el despill la grisea;
    // el borde sticker blanco ya contiene el spill.
    id: 'premium_coin_piggy',
    keyColor: 'green',
    despill: false,
    motion:
      'Timeline: during the first 2 seconds, the chubby pink piglet breathes gently, blinks softly, gives one happy little ear wiggle and a tiny content smile, the golden coin resting untouched by its feet. By second 3 the piglet has fully returned to standing calmly in exactly the same pose as the very first frame. During the entire final second the piglet simply stands completely still, eyes open, mouth closed. The action resolves completely.',
  },
];

// Movimientos de evento por personaje. Cada clip se nombra
// {id}_{motion}_take{n}.mp4 (el idle conserva {id}_take{n}.mp4).
//   loop 'pingpong' -> ida y vuelta, para estados ambientales sostenidos
//   loop 'oneshot'  -> una sola pasada; el prompt DEBE volver a la pose inicial
// Prompts con TIMELINE explicita (Kling la respeta; Veo la ignoraba):
//  - celebrate/victory: gesto en los primeros ~2.5s, vuelta a la pose inicial
//    hacia el segundo 3, y el ultimo segundo+ completamente quieto.
//  - versus: adopta la pose desafiante y LA SOSTIENE quieta hasta el final
//    (el player retiene el ultimo frame como reposo — nada de trims).
export const EVENT_MOTIONS = {
  premium_market_dog: {
    victory: {
      loop: 'oneshot',
      prompt:
        'Timeline: during the first 2 seconds, the golden puppy gives a happy little victory bounce, ears flopping up, tail wagging fast, lifting one front paw triumphantly with bright sparkling eyes. By second 3 the puppy has fully returned to sitting calmly in exactly the same pose as the very first frame. During the entire final second the puppy simply sits completely still and calm in that exact starting pose, eyes open, mouth closed. The action resolves completely.',
    },
    versus: {
      loop: 'oneshot',
      trimSeconds: 2.2,
      prompt:
        'Timeline: during the first 2 seconds, the golden puppy lowers its front into a playful determined play-bow, tail up, ears alert, with focused competitive eyes. From second 2 until the very end of the video the puppy holds that play-bow pose completely still, frozen in determination, eyes open and mouth closed. The final frame is the puppy holding the play-bow perfectly still.',
    },
    celebrate: {
      loop: 'pingpong',
      trimSeconds: 2.6,
      prompt:
        'Timeline: during the first 2 seconds, the golden puppy does a happy full-body wiggle of joy, tail wagging in circles and ears bouncing. By second 3 the puppy has fully returned to sitting calmly in exactly the same pose as the very first frame. During the entire final second the puppy simply sits completely still and calm in that exact starting pose, eyes open, mouth closed. The action resolves completely.',
    },
  },
  premium_key_bird: {
    victory: {
      loop: 'oneshot',
      prompt:
        'Timeline: during the first 2 seconds, the little yellow chick does a joyful victory hop with a quick flap of its tiny wings, puffing its chest proudly, the key charm on its ribbon swinging from the motion. By second 3 the chick has fully returned to standing calmly in exactly the same pose as the very first frame, wing holding the ribbon exactly as in the input. During the entire final second the chick simply stands completely still, eyes open, beak closed. The action resolves completely.',
    },
    versus: {
      loop: 'oneshot',
      trimSeconds: 2.2,
      prompt:
        'Timeline: during the first 2 seconds, the little yellow chick leans forward with its wings slightly spread and a determined confident look, ready for a friendly contest. From second 2 until the very end of the video the chick holds that determined leaning pose completely still, eyes open and beak closed. The final frame is the chick holding the determined pose perfectly still.',
    },
    celebrate: {
      loop: 'pingpong',
      trimSeconds: 2.6,
      prompt:
        'Timeline: during the first 2 seconds, the little yellow chick flaps its wings excitedly with a cheerful little jump, the key charm on its ribbon swinging happily from the body motion. By second 3 the chick has fully returned to standing calmly in exactly the same pose as the very first frame. During the entire final second the chick simply stands completely still, eyes open, beak closed. The action resolves completely.',
    },
  },
  premium_tool_adult_man: {
    victory: {
      loop: 'oneshot',
      prompt:
        'The man gives a proud confident victory gesture: he raises his hand holding the toolbox slightly and gives a satisfied approving nod with a big warm smile and bright happy eyes, like a job well done, then settles back into exactly his original calm pose.',
    },
    versus: {
      loop: 'oneshot',
      trimSeconds: 2.2,
      prompt:
        'The man leans slightly forward with a determined, friendly competitive look, raising one eyebrow with a confident smirk as if ready to take on a challenge, holding his tools steadily.',
    },
    celebrate: {
      loop: 'pingpong',
      trimSeconds: 2.6,
      prompt:
        'The man does a cheerful little celebration: a happy shoulder shrug and an enthusiastic nod with a bright joyful smile, then returns to exactly his original calm pose.',
    },
  },
  premium_coin_piggy: {
    victory: {
      loop: 'oneshot',
      prompt:
        'Timeline: during the first 2 seconds, the chubby pink piglet does a happy little victory bounce, ears perking up, with bright sparkling proud eyes and a big happy smile, the golden coin staying on the ground by its feet. By second 3 the piglet has fully returned to standing calmly in exactly the same pose as the very first frame. During the entire final second the piglet simply stands completely still, eyes open, mouth closed. The action resolves completely.',
    },
    versus: {
      loop: 'oneshot',
      trimSeconds: 2.2,
      prompt:
        'Timeline: during the first 2 seconds, the chubby pink piglet leans slightly forward with playful determined competitive eyes and puffed cheeks, ears tilting forward, ready for a friendly contest. From second 2 until the very end of the video the piglet holds that determined leaning pose completely still, eyes open and mouth closed. The final frame is the piglet holding the determined pose perfectly still.',
    },
    celebrate: {
      loop: 'pingpong',
      trimSeconds: 2.6,
      prompt:
        'Timeline: during the first 2 seconds, the chubby pink piglet does a joyful little happy dance, wiggling its body and ears with delight, eyes sparkling with joy, the golden coin staying on the ground by its feet. By second 3 the piglet has fully returned to standing calmly in exactly the same pose as the very first frame. During the entire final second the piglet simply stands completely still, eyes open, mouth closed. The action resolves completely.',
    },
  },
  premium_orange_cat: {
    // Gesto "ta-da" de presentacion para el paywall premium. NO usar
    // pingpong (el owner no quiere movimientos en reversa): el asentado a
    // pose estable lo resuelve el player fundiendo al PNG al terminar.
    tada: {
      loop: 'oneshot',
      // El player sostiene el ULTIMO frame como pose de reposo: el prompt
      // usa una linea de tiempo explicita para que el gesto termine ANTES
      // del final y el ultimo segundo sea pose sentada quieta, ojos abiertos.
      // (Los takes sin timeline quedaban cortados a mitad de gesto.)
      prompt:
        'Timeline: during the first 2 seconds, the orange kitten does one quick joyful bounce and a short excited ta-da gesture with its front paws, eyes wide open and sparkling, with a big warm delighted smile, celebrating wonderful news. By second 3 the kitten has fully returned to sitting calmly in exactly the same pose as the very first frame: front paws resting down, eyes wide open, happy gentle smile. During the entire final second of the video the kitten simply sits completely still and calm in that exact starting pose. The action resolves completely — no gesture is left unfinished at the end of the video.',
    },
    victory: {
      loop: 'oneshot',
      prompt:
        'Timeline: during the first 2 seconds, the orange kitten does a small joyful victory hop and raises one front paw triumphantly with bright sparkling happy eyes and a big smile. By second 3 the kitten has fully returned to sitting calmly in exactly the same pose as the very first frame. During the entire final second the kitten simply sits completely still and calm in that exact starting pose, eyes wide open, smiling. The action resolves completely.',
    },
    versus: {
      loop: 'oneshot',
      trimSeconds: 2.2,
      prompt:
        'Timeline: during the first 2 seconds, the orange kitten leans slightly forward with playful competitive eyes and a determined confident smirk, tail flicking once. From second 2 until the very end of the video the kitten holds that determined leaning pose completely still, eyes open. The final frame is the kitten holding the determined pose perfectly still.',
    },
    celebrate: {
      loop: 'pingpong',
      trimSeconds: 2.6,
      prompt:
        'Timeline: during the first 2 seconds, the orange kitten happily pats its front paws together in a cheerful little celebration and does a tiny joyful wiggle. By second 3 the kitten has fully returned to sitting calmly in exactly the same pose as the very first frame. During the entire final second the kitten simply sits completely still and calm in that exact starting pose, eyes wide open, smiling. The action resolves completely.',
    },
  },
};

export function buildPrompt(avatar, { motionText, oneshot = false } = {}) {
  const key = KEY_COLORS[avatar.keyColor];
  return [
    oneshot
      ? 'Short, charming gesture animation of this exact 3D rendered character.'
      : 'Subtle, seamless idle animation of this exact 3D rendered character.',
    motionText ?? avatar.motion,
    'The character stays perfectly centered and does not move from its position.',
    oneshot
      ? 'The gesture finishes early: the character returns to exactly the same pose as the very first frame BEFORE the video ends, and holds that pose completely still for the final part of the video. The last frame is identical to the first frame.'
      : '',
    'Preserve the exact art style, colors, proportions and lighting of the input image.',
    `The background is a completely flat, uniform, solid ${key.name} color (${key.hex}) with no gradients, no shadows, no vignette and no texture.`,
    'Camera is completely static and locked. No camera movement, no zoom, no pan.',
    // Silencio: evita el filtro de audio de Veo y el look de "hablar". No se
    // fuerza la boca cerrada aqui: los animales pueden abrirla para una accion
    // (ej. agarrar la bolsa). Para HUMANOS, agregar "mouth/lips stay closed"
    // en su prompt especifico.
    'The scene is completely silent: the character does not speak, talk, sing or make any vocal sound.',
    oneshot
      ? 'Gentle, friendly motion. Soft and warm mood.'
      : 'Slow, calm, loopable motion. Soft and friendly mood.',
  ]
    .filter(Boolean)
    .join(' ');
}

export const NEGATIVE_PROMPT =
  'camera movement, zoom, pan, background change, gradients, shadows on background, ' +
  'extra limbs, deformation, style change, text, watermark, fast motion, jump cut, ' +
  'speaking, talking, singing, humming, voice, vocal sounds, ' +
  'abrupt ending, motion cut off mid-gesture, unfinished movement, closed eyes at the end, ' +
  'harsh lighting, character partially out of frame';
