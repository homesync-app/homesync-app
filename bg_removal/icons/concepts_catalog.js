// Catálogo de CONCEPTOS (premios, logros, duelos, metas de ahorro).
// A diferencia de los productos, acá los iconos representan ideas/acciones,
// así que el "noun" describe un objeto-símbolo concreto que la evoca.
//
// Estructura: [clave, emojiQueReemplaza, noun]
// - clave: id estable para el PNG y el manifest (carpeta concepts/)
// - emoji: el emoji del sistema que hoy se usa (para el mapeo emoji->PNG)
// - noun: descripción para el generador
//
// El PILOTO usa la propiedad `pilot: true` (15 representativos de cada tipo).

const concepts = [
  // ---------- PREMIOS / REWARDS (pickers couple + family + templates) ----------
  ['gift', '🎁', 'a wrapped gift box with a ribbon bow', true],
  ['coffee_treat', '☕', 'a cozy cup of coffee with steam', true],
  ['massage', '💆', 'a relaxed face enjoying a head massage, spa vibe', true],
  ['movie_night', '🎬', 'a film clapperboard', true],
  ['ice_cream_cone', '🍦', 'a soft-serve ice cream cone', false],
  ['love_note', '💌', 'a love letter envelope with a heart', true],
  ['chocolate_treat', '🍫', 'a chocolate bar with one piece broken off', false],
  ['wine_glass', '🍷', 'a glass of red wine', false],
  ['bath', '🛁', 'a relaxing bathtub with bubbles', false],
  ['sunset', '🌅', 'a calm sunset over hills', false],
  ['heart_gift', '💝', 'a heart-shaped gift with a bow', true],
  ['dinner_out', '🍽️', 'a dinner plate with fork and knife', true],
  ['pizza', '🍕', 'a slice of pizza', false],
  ['gaming', '🎮', 'a game controller', true],
  ['board_game', '🎲', 'a pair of dice', false],
  ['picnic', '🧺', 'a picnic basket', false],
  ['star_reward', '⭐', 'a single rounded star', false],
  ['phone_off', '📵', 'a phone with a do-not-disturb moon', false],
  ['day_off', '🏖️', 'a beach umbrella with a sun', false],

  // ---------- DUELOS / COUPLE CHALLENGES ----------
  ['candle', '🕯️', 'a lit candle with a soft flame', true],
  ['sparkles', '✨', 'a cluster of soft sparkles', true],
  ['microphone', '🎤', 'a handheld microphone (karaoke)', false],
  ['art_palette', '🎨', 'an artist paint palette with a brush', true],
  ['popcorn_bucket', '🍿', 'a bucket of popcorn', false],
  ['camera', '📸', 'a cute instant camera', true],
  ['letter', '✉️', 'a sealed envelope', false],
  ['hug', '🤗', 'two hearts hugging, warm connection', true],
  ['book', '📖', 'an open book', false],
  ['plane', '✈️', 'a small airplane', false],
  ['puzzle', '🧩', 'a single puzzle piece', false],
  ['cooking', '🍳', 'a frying pan with a fried egg', false],
  ['cheers', '🥂', 'two champagne glasses toasting', false],
  ['music_note', '🎵', 'a music note', false],
  ['vase', '🏺', 'an amphora vase', false],
  ['croissant', '🥐', 'a golden croissant', false],
  ['wave', '🌊', 'an ocean wave', false],
  ['compass', '🧭', 'a compass', false],
  ['theater', '🎭', 'theater drama masks', false],
  ['leafy_green', '🥬', 'a leafy green vegetable', false],
  ['ear_listen', '👂', 'an ear, listening', false],
  ['sunrise', '🌄', 'a sunrise over mountains', false],
  ['pray', '🙏', 'two hands together, gratitude', false],
  ['box', '📦', 'a cardboard box', false],
  ['see_no_evil', '🙈', 'a cute monkey covering its eyes', false],
  ['old_mic', '🎙️', 'a vintage studio microphone', false],
  ['film_reel', '🎞️', 'a film reel strip', false],
  ['check_done', '✅', 'a green check mark in a soft circle', false],
  ['fire_streak', '🔥', 'a warm flame (streak)', true],
  ['bed_rest', '🛌', 'a cozy bed with a pillow', false],
  ['stargazing', '🌌', 'a night sky with stars and a moon', false],
  ['hourglass', '⏳', 'an hourglass', false],
  ['picture_frame', '🖼️', 'a framed picture', false],
  ['ticket', '🎟️', 'an event ticket', false],

  // ---------- LOGROS / ACHIEVEMENTS ----------
  ['trophy', '🏆', 'a golden trophy cup', true],
  ['medal', '🏅', 'a golden medal with a ribbon', true],
  ['crown', '👑', 'a golden crown', false],
  ['seedling', '🌱', 'a small sprout seedling in soil', true],
  ['rocket', '🚀', 'a cute rocket launching', true],
  ['heart', '❤️', 'a soft rounded red heart', false],
  ['sparkle_heart', '💖', 'a pink heart with small sparkles around it', false],
  ['infinity', '♾️', 'an infinity symbol', false],
  ['dancer', '💃', 'a dancing figure, celebratory', false],
  ['gem', '💎', 'a cut gemstone', false],
  ['target', '🎯', 'a dartboard target with a dart in the center', true],
  ['lock', '🔒', 'a closed padlock', false],

  // ---------- METAS DE AHORRO / SAVINGS GOALS ----------
  ['money_bag', '💰', 'a money bag with a coin', true],
  ['house_goal', '🏡', 'a cozy little house', true],
  ['car', '🚗', 'a small cute car', true],
  ['ring', '💍', 'a diamond engagement ring', false],
  ['sofa', '🛋️', 'a comfy sofa', false],
  ['baby_bottle', '🍼', 'a baby bottle', false],
  ['graduation', '🎓', 'a graduation cap', false],
  ['dog_pet', '🐶', 'a cute dog face', false],
  ['laptop', '💻', 'a laptop computer', false],
  ['piggy_bank', '🐷', 'a pink piggy bank with a coin slot', true],
];

module.exports = { concepts };
