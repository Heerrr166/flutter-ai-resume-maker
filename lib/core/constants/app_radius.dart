// Centralized corner-radius scale so every card, button, input, chip, sheet,
// and dialog in the app shares the same rounding language instead of each
// screen picking its own nearby number (16 vs 18 vs 20 vs 24...).
class AppRadius {
  AppRadius._();

  static const double sm = 12; // chips, small badges
  static const double md = 16; // buttons, text fields
  static const double lg = 20; // cards
  static const double xl = 28; // sheets, dialogs, hero surfaces
}
