# PhishWise / PhishWijzer

A Dutch/English Swift-based iOS app designed to help users (specifically elders) learn to recognize phishing attempts through quizzes, and stay updated with the latest phishing news.

<p align="center">
  <img src="images/logo.png" alt="PhishWijzer Logo" width="200"/>
</p>

## App Structure

```
PhishWise/
├── Models/
│   ├── Question.swift              # Question model with bilingual support
│   ├── NewsArticle.swift           # News article model with bilingual support
│   └── Certificate.swift           # Certificate model with QR code generation
├── ViewModels/
│   ├── AppViewModel.swift          # Main app state management
│   ├── QuizViewModel.swift         # Quiz-specific logic
│   └── NewsViewModel.swift         # News-specific logic
├── Views/
│   ├── MainTabView.swift           # Main TabView container
│   ├── WelcomeView.swift           # Welcome screen with language selection
│   ├── LessonView.swift            # Learning modules display
│   ├── QuizView.swift              # Quiz interface
│   ├── FeedbackView.swift          # Answer explanations
│   ├── ProgressView.swift          # Progress tracking
│   ├── CertificateView.swift       # Certificate generation and display
│   └── News/
│       ├── NewsListView.swift      # News articles list with search/filter
│       └── NewsDetailView.swift    # Individual article detail view
├── Resources/
│   ├── Localizable.strings         # English translations
│   ├── nl.lproj/
│   │   └── Localizable.strings     # Dutch translations
│   ├── quiz_questions.json         # Sample quiz questions
│   └── news_articles.json          # Sample news articles
└── ContentView.swift               # Root view controller
```

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## License

This project is created for educational purposes. All rights reserved to Sidd Sehgal.
