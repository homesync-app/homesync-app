import 'package:flutter/material.dart';
import 'package:homesync_client/features/couple_space/presentation/widgets/couple_art.dart';

enum HouseholdArtKind {
  cleaning,
  laundry,
  plant,
  tools,
  pets,
  calendar,
  sun,
  clock,
  recycling,
  home,
  cooking,
  shopping,
  wallet,
  movies,
  medal,
}

/// Category and section illustrations extend the original couple icon family.
class HouseholdArt extends StatelessWidget {
  final HouseholdArtKind kind;
  final double size;

  const HouseholdArt({super.key, required this.kind, this.size = 44});

  static HouseholdArtKind forCategory(String? category) {
    switch (category?.trim().toLowerCase()) {
      case 'limpieza':
      case 'limpieza general':
      case 'cleaning':
      case 'baño':
      case 'bano':
      case 'bathroom':
        return HouseholdArtKind.cleaning;
      case 'ropa':
      case 'clothing':
      case 'lavanderia':
      case 'lavandería':
      case 'laundry':
      case 'dormitorio':
      case 'bedroom':
        return HouseholdArtKind.laundry;
      case 'jardin':
      case 'jardín':
      case 'jardineria':
      case 'jardinería':
      case 'exterior':
      case 'outdoor':
        return HouseholdArtKind.plant;
      case 'mantenimiento':
      case 'mantenimiento del hogar':
      case 'bricolaje':
      case 'maintenance':
        return HouseholdArtKind.tools;
      case 'mascotas':
      case 'pets':
        return HouseholdArtKind.pets;
      case 'residuos':
      case 'recycling':
        return HouseholdArtKind.recycling;
      case 'comida':
      case 'kitchen':
      case 'cocina':
      case 'cooking':
        return HouseholdArtKind.cooking;
      case 'compras':
      case 'shopping':
      case 'supermarket':
        return HouseholdArtKind.shopping;
      case 'finanzas':
      case 'savings':
        return HouseholdArtKind.wallet;
      case 'administracion':
      case 'administración':
      case 'administración del hogar':
        return HouseholdArtKind.calendar;
      case 'entretenimiento':
      case 'entertainment':
      case 'ocio':
        return HouseholdArtKind.movies;
      default:
        return HouseholdArtKind.home;
    }
  }

  static HouseholdArtKind forExpenseCategory(String? category) {
    final normalized = (category ?? '')
        .trim()
        .toLowerCase()
        .replaceAll('\u00e1', 'a')
        .replaceAll('\u00e9', 'e')
        .replaceAll('\u00ed', 'i')
        .replaceAll('\u00f3', 'o')
        .replaceAll('\u00fa', 'u')
        .replaceAll('\u00f1', 'n');
    switch (normalized) {
      case 'supermarket':
      case 'supermercado':
      case 'groceries':
      case 'compras':
      case 'shopping':
      case 'market':
      case 'almacen':
        return HouseholdArtKind.shopping;
      case 'food':
      case 'comida':
      case 'cooking':
      case 'cocina':
      case 'kitchen':
      case 'restaurant':
      case 'restaurante':
      case 'restaurantes':
      case 'delivery':
      case 'cafe':
        return HouseholdArtKind.cooking;
      case 'cleaning':
      case 'limpieza':
      case 'bano':
      case 'bathroom':
        return HouseholdArtKind.cleaning;
      case 'pets':
      case 'mascotas':
      case 'veterinaria':
        return HouseholdArtKind.pets;
      case 'entertainment':
      case 'entretenimiento':
      case 'ocio':
      case 'salidas':
      case 'movies':
      case 'cine':
        return HouseholdArtKind.movies;
      case 'clothing':
      case 'ropa':
      case 'indumentaria':
      case 'laundry':
      case 'lavanderia':
        return HouseholdArtKind.laundry;
      case 'maintenance':
      case 'mantenimiento':
      case 'reparaciones':
      case 'tools':
      case 'ferreteria':
        return HouseholdArtKind.tools;
      case 'home':
      case 'hogar':
      case 'alquiler':
      case 'rent':
      case 'housing':
      case 'expensas':
        return HouseholdArtKind.home;
      case 'utilities':
      case 'servicios':
      case 'bills':
      case 'impuestos':
      case 'subscriptions':
      case 'suscripciones':
        return HouseholdArtKind.calendar;
      case 'gift':
      case 'regalo':
      case 'regalos':
        return HouseholdArtKind.medal;
      case 'garden':
      case 'jardin':
      case 'plantas':
        return HouseholdArtKind.plant;
      default:
        return HouseholdArtKind.wallet;
    }
  }

  @override
  Widget build(BuildContext context) {
    final existing = switch (kind) {
      HouseholdArtKind.home => CoupleArtKind.home,
      HouseholdArtKind.cooking => CoupleArtKind.cooking,
      HouseholdArtKind.shopping => CoupleArtKind.picnic,
      HouseholdArtKind.wallet => CoupleArtKind.wallet,
      HouseholdArtKind.movies => CoupleArtKind.movies,
      HouseholdArtKind.medal => CoupleArtKind.medal,
      _ => null,
    };
    if (existing != null) return CoupleArt(kind: existing, size: size);
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: ClipRect(
          clipper: const _AtlasGutterClipper(),
          child: OverflowBox(
            minWidth: size * 3,
            maxWidth: size * 3,
            minHeight: size * 3,
            maxHeight: size * 3,
            alignment:
                Alignment((kind.index % 3) - 1.0, (kind.index ~/ 3) - 1.0),
            child: Image.asset(
              'assets/images/household_icons.webp',
              width: size * 3,
              height: size * 3,
              filterQuality: FilterQuality.medium,
            ),
          ),
        ),
      ),
    );
  }
}

class _AtlasGutterClipper extends CustomClipper<Rect> {
  const _AtlasGutterClipper();
  @override
  Rect getClip(Size size) => Rect.fromLTRB(
        size.width * 0.025,
        size.height * 0.025,
        size.width * 0.975,
        size.height * 0.975,
      );
  @override
  bool shouldReclip(covariant _AtlasGutterClipper oldClipper) => false;
}
