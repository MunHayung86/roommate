class SurveyQuestion {
  const SurveyQuestion({
    required this.id,
    required this.title,
    this.options = const <String>[],
    this.requiresTimeInput = false,
  });

  final String id;
  final String title;
  final List<String> options;
  final bool requiresTimeInput;
}
