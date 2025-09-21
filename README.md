# PhishWise - Phishing Recognition Learning App

A bilingual (Dutch/English) SwiftUI iOS app designed to help users learn to recognize phishing attempts through interactive lessons, quizzes, and stay updated with the latest phishing news.

## Features

- **Bilingual Support**: Full Dutch and English localization
- **Tab-Based Navigation**: Two main sections - News and Course & Certificate
- **Phishing News**: Latest phishing-related news articles with search and filtering
- **Learning Modules**: Expandable lesson system for educational content
- **Interactive Quiz**: JSON-based question system with immediate feedback
- **Progress Tracking**: Score tracking and performance analytics
- **Certificate Generation**: Personalized completion certificates with QR codes
- **Accessibility**: VoiceOver support, Dynamic Type, high contrast design
- **Elderly-Friendly**: Large fonts, clear buttons, simple navigation

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

## Customization Guide

### Adding New Quiz Questions

Edit `/Resources/quiz_questions.json`:

```json
{
  "id": 3,
  "text_en": "Your new question in English",
  "text_nl": "Je nieuwe vraag in het Nederlands",
  "is_phishing": true,
  "explanation_en": "Explanation in English",
  "explanation_nl": "Uitleg in het Nederlands"
}
```

### Adding New News Articles

Edit `/Resources/news_articles.json`:

```json
{
  "id": 4,
  "title_en": "Your article title in English",
  "title_nl": "Je artikel titel in het Nederlands",
  "summary_en": "Brief summary in English",
  "summary_nl": "Korte samenvatting in het Nederlands",
  "content_en": "Full article content in English...",
  "content_nl": "Volledige artikel inhoud in het Nederlands...",
  "date": "2025-01-20",
  "category": "Your Category"
}
```

### Adding New Learning Content

1. **Update LessonView.swift**: Add new `LessonCard` instances in the main VStack
2. **Add Content**: Replace placeholder text with your educational content
3. **Customize Icons**: Change the `icon` parameter to match your content

### Modifying Text and Translations

1. **English**: Edit `/Resources/Localizable.strings`
2. **Dutch**: Edit `/Resources/nl.lproj/Localizable.strings`
3. **Add New Keys**: Use `NSLocalizedString("your_key", comment: "Description")`

### Styling and Design

- **Colors**: Modify color schemes in individual views
- **Fonts**: Adjust `.font()` modifiers throughout the app
- **Layout**: Modify spacing, padding, and alignment in VStack/HStack

## Technical Details

### Architecture
- **MVVM Pattern**: Clear separation of concerns
- **ObservableObject**: Reactive state management
- **SwiftUI**: Modern declarative UI framework

### Accessibility Features
- VoiceOver labels on all interactive elements
- Dynamic Type support (large to accessibility3)
- High contrast color scheme
- Semantic accessibility traits

### Localization
- `Localizable.strings` files for static text
- JSON-based question content for dynamic text
- Runtime language switching

## Getting Started

1. Open `PhishWise.xcodeproj` in Xcode
2. Build and run on iOS Simulator or device
3. Test language switching and quiz functionality
4. Customize content by editing the files mentioned above

## Future Enhancements

- Add more question categories
- Implement lesson progress tracking
- Add multimedia content (images, videos)
- Create user profiles and statistics
- Add push notifications for learning reminders

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## License

This project is created for educational purposes. Feel free to modify and distribute as needed.
