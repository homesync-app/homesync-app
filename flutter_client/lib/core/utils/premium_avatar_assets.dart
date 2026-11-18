/// Purpose-drawn portraits and shared scenes, independent of member order.
abstract final class PremiumAvatarArt {
  static const ids = [
    'key_bird',
    'keys_girl',
    'market_dog',
    'mate_boy',
    'orange_cat',
    'paper_plane_kid',
    'star_girl',
    'tool_adult_man',
  ];

  static String? idFor(String? value) {
    final normalized = value?.trim();
    if (normalized == null) return null;
    for (final id in ids) {
      if (normalized == 'premium://premium_$id' ||
          normalized == 'premium_$id' ||
          normalized == 'assets/images/premium_3d_avatars/premium_$id.webp') {
        return id;
      }
    }
    return null;
  }

  static String? portraitFor(String? value) {
    final id = idFor(value);
    return id == null ? null : 'assets/images/avatar_art/portrait_$id.webp';
  }

  static String? duoFor(String? first, String? second) {
    final a = idFor(first);
    final b = idFor(second);
    if (a == null || b == null) return null;
    final pair = [a, b]..sort();
    return 'assets/images/avatar_art/duo_${pair.join('__')}.webp';
  }
}
