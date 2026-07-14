class Surah {
  final int number;
  final String nameArabic;
  final String nameLatin;
  final String nameEnglish;
  final int totalAyat;
  final String revelation; // Meccan / Medinan

  const Surah({
    required this.number,
    required this.nameArabic,
    required this.nameLatin,
    required this.nameEnglish,
    required this.totalAyat,
    required this.revelation,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'] ?? 0,
      nameArabic: json['name'] ?? '',
      nameLatin: json['englishName'] ?? '',
      nameEnglish: json['englishNameTranslation'] ?? '',
      totalAyat: json['numberOfAyahs'] ?? 0,
      revelation: json['revelationType'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name': nameArabic,
      'englishName': nameLatin,
      'englishNameTranslation': nameEnglish,
      'numberOfAyahs': totalAyat,
      'revelationType': revelation,
    };
  }

  String get revelationId {
    switch (revelation) {
      case 'Meccan':
        return 'Makkiyah';
      case 'Medinan':
        return 'Madaniyah';
      default:
        return revelation;
    }
  }

  @override
  String toString() => 'Surah($number: $nameLatin)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Surah && runtimeType == other.runtimeType && number == other.number;

  @override
  int get hashCode => number.hashCode;
}
