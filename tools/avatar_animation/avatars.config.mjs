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
      'The golden puppy slowly wags its tail, its floppy ears perk up for a moment, it blinks, and tilts its head curiously toward the grocery bag it holds, then settles. Mouth stays closed in a calm happy expression.',
  },
  {
    id: 'premium_orange_cat',
    keyColor: 'magenta',
    motion:
      'The orange kitten breathes gently, blinks slowly like a content cat, and its tail sways softly side to side.',
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
      'The little yellow chick ruffles its feathers, gives a tiny hop, blinks, and the house key on the ribbon it holds swings softly side to side. Beak stays closed in a calm happy expression.',
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
];

// Movimientos de evento por personaje. Cada clip se nombra
// {id}_{motion}_take{n}.mp4 (el idle conserva {id}_take{n}.mp4).
//   loop 'pingpong' -> ida y vuelta, para estados ambientales sostenidos
//   loop 'oneshot'  -> una sola pasada; el prompt DEBE volver a la pose inicial
export const EVENT_MOTIONS = {
  premium_market_dog: {
    victory: {
      loop: 'oneshot',
      prompt:
        'The golden puppy gives a happy little victory bounce, its ears flop up, tail wagging fast, and it lifts one front paw triumphantly with bright sparkling eyes, then settles back down into exactly its original calm sitting pose. Mouth stays closed.',
    },
    versus: {
      loop: 'pingpong',
      prompt:
        'The golden puppy lowers its front into a playful determined play-bow, tail up and wagging, ears alert, with focused competitive eyes, like it is about to win a friendly game. Mouth stays closed.',
    },
    celebrate: {
      loop: 'pingpong',
      trimSeconds: 2.6,
      prompt:
        'The golden puppy does a happy full-body wiggle of joy, tail wagging in circles and ears bouncing, then returns to exactly its original calm sitting pose. Mouth stays closed.',
    },
  },
  premium_key_bird: {
    victory: {
      loop: 'oneshot',
      prompt:
        'The little yellow chick does a joyful victory hop with a quick flap of its tiny wings, puffing its chest proudly, the house key jingling, then settles back into exactly its original standing pose. Beak stays closed.',
    },
    versus: {
      loop: 'pingpong',
      prompt:
        'The little yellow chick leans forward with its wings slightly spread and a determined confident look, holding the house key up like a trophy, ready for a friendly contest. Beak stays closed.',
    },
    celebrate: {
      loop: 'pingpong',
      trimSeconds: 2.6,
      prompt:
        'The little yellow chick flaps its wings excitedly with a cheerful little jump, the house key swinging happily, then returns to exactly its original standing pose. Beak stays closed.',
    },
  },
  premium_tool_adult_man: {
    victory: {
      loop: 'oneshot',
      prompt:
        'The man gives a proud confident victory gesture: he raises his hand holding the toolbox slightly and gives a satisfied approving nod with a big warm smile and bright happy eyes, like a job well done, then settles back into exactly his original calm pose.',
    },
    versus: {
      loop: 'pingpong',
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
  premium_orange_cat: {
    victory: {
      loop: 'oneshot',
      prompt:
        'The orange kitten does a small joyful victory hop, raises one front paw triumphantly with bright sparkling happy eyes and a big smile, then settles back down into exactly its original calm sitting pose.',
    },
    versus: {
      loop: 'pingpong',
      prompt:
        'The orange kitten leans slightly forward with playful competitive eyes and a determined confident smirk, tail flicking side to side, like it is about to win a friendly game.',
    },
    celebrate: {
      // El take no vuelve a la pose neutral por si solo: recortado a la
      // subida de patitas + ping-pong = festeja y baja sin salto.
      loop: 'pingpong',
      trimSeconds: 2.6,
      prompt:
        'The orange kitten happily pats its front paws together in a cheerful little celebration and does a tiny joyful wiggle, then returns to exactly its original calm sitting pose.',
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
      ? 'The animation must end with the character in exactly the same pose as the very first frame.'
      : '',
    'Preserve the exact art style, colors, proportions and lighting of the input image.',
    `The background is a completely flat, uniform, solid ${key.name} color (${key.hex}) with no gradients, no shadows, no vignette and no texture.`,
    'Camera is completely static and locked. No camera movement, no zoom, no pan.',
    'The scene is completely silent: the character does not speak, talk, sing or make any vocal sound, mouth stays closed.',
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
  'speaking, talking, singing, humming, voice, vocal sounds, open mouth';
