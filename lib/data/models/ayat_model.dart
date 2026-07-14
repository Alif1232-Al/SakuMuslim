class Ayat {
  final int numberInSurah;
  final int numberInQuran;
  final String textArabic;
  final String textTranslation;
  final int juz;
  final int page;

  const Ayat({
    required this.numberInSurah,
    required this.numberInQuran,
    required this.textArabic,
    required this.textTranslation,
    this.juz = 0,
    this.page = 0,
  });

  factory Ayat.fromJson(Map<String, dynamic> json, {String? translation}) {
    return Ayat(
      numberInSurah: json['numberInSurah'] ?? 0,
      numberInQuran: json['number'] ?? 0,
      textArabic: json['text'] ?? '',
      textTranslation: translation ?? '',
      juz: json['juz'] ?? 0,
      page: json['page'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numberInSurah': numberInSurah,
      'numberInQuran': numberInQuran,
      'text': textArabic,
      'textTranslation': textTranslation,
      'juz': juz,
      'page': page,
    };
  }

  @override
  String toString() => 'Ayat($numberInSurah)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ayat &&
          runtimeType == other.runtimeType &&
          numberInSurah == other.numberInSurah &&
          numberInQuran == other.numberInQuran;

  @override
  int get hashCode => numberInSurah.hashCode ^ numberInQuran.hashCode;
}
