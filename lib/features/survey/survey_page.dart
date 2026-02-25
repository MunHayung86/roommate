import 'package:flutter/material.dart';

import 'data/lifestyle_questions.dart';
import 'pages/lifestyle_survey_page.dart';

class SurveyPage extends StatelessWidget {
  const SurveyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LifestyleSurveyPage(
      questions: kLifestyleQuestions,
    );
  }
}
