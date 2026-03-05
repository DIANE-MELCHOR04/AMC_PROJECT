// This file defines the core data models for the app.
// They represent how data is structured in a (future) backend or local database.

/// Enum describing the allowed reaction types on posts and reviews.
/// You can extend this later with more reactions if needed.
enum ReactionType {
  like,
  love,
  insightful,
  funny,
}

/// Enum describing the supported visual themes.
/// The value is stored in the user profile so the theme can be restored.
enum AppThemeType {
  light,
  dark,
  ocean,
  forest,
  sunset,
  lavender,
  midnight,
  rose,
  lemon,
  plum,
}

/// Enum for categorizing community posts.
enum PostCategory {
  all,
  recs,
  ask,
  other,
}

/// Simple identifier wrapper type for clarity.
/// In a real backend this would likely be a string UUID.
typedef Id = String;

/// Core user model for authentication and personalization.
class AppUser {
  /// Unique identifier for the user.
  final Id id;

  /// Public username displayed across the app.
  final String username;

  /// Optional biography shown on the profile page.
  final String bio;

  /// Optional URL or asset path for the profile picture.
  final String? profileImageUrl;

  /// Plain e-mail used for login in this demo.
  /// In a real app you would never expose or store passwords directly here.
  final String email;

  /// Hashed password in a real app; here just a placeholder string for demo.
  final String password;

  /// Preferred visual theme for the user.
  final AppThemeType preferredTheme;

  const AppUser({
    required this.id,
    required this.username,
    required this.bio,
    required this.email,
    required this.password,
    this.profileImageUrl,
    this.preferredTheme = AppThemeType.light,
  });

  /// Creates a copy of the user with optional overrides.
  AppUser copyWith({
    String? username,
    String? bio,
    String? profileImageUrl,
    String? email,
    String? password,
    AppThemeType? preferredTheme,
  }) {
    return AppUser(
      id: id,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      email: email ?? this.email,
      password: password ?? this.password,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      preferredTheme: preferredTheme ?? this.preferredTheme,
    );
  }
}

/// Book model representing an item in the catalog.
class Book {
  /// Unique identifier of the book.
  final Id id;

  /// Title of the book.
  final String title;

  /// Author name or names.
  final String author;

  /// Primary genre label.
  final String genre;

  /// URL or asset path for the cover image.
  final String? coverImageUrl;

  /// Short description or synopsis of the book.
  final String description;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.description,
    this.coverImageUrl,
  });
}

/// Review model representing a user's opinion about a book.
class Review {
  /// Unique identifier of the review.
  final Id id;

  /// ID of the book the review is about.
  final Id bookId;

  /// ID of the user who wrote the review.
  final Id userId;

  /// Rating from 1 to 5 stars.
  final int rating;

  /// Free-text review body.
  final String content;

  /// Creation timestamp for sorting in feeds and book pages.
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.rating,
    required this.content,
    required this.createdAt,
  });
}

/// Post model used in the social feed.
class Post {
  /// Unique identifier of the post.
  final Id id;

  /// ID of the user who created the post.
  final Id userId;

  /// Optional ID of a recommended book.
  final Id? recommendedBookId;

  /// Category of the post (Recs, Ask, Other).
  final PostCategory category;

  /// Text content of the post.
  final String content;

  /// Creation timestamp for ordering the feed.
  final DateTime createdAt;

  const Post({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.category = PostCategory.other,
    this.recommendedBookId,
  });
}

/// Comment model for both posts and reviews.
class Comment {
  /// Unique identifier of the comment.
  final Id id;

  /// ID of the user who wrote the comment.
  final Id userId;

  /// Optional ID of the post being commented on.
  final Id? postId;

  /// Optional ID of the review being commented on.
  final Id? reviewId;

  /// Comment text.
  final String content;

  /// Creation timestamp for ordering comment threads.
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.postId,
    this.reviewId,
  });
}

/// Reaction model for likes and other reactions on posts and reviews.
class Reaction {
  /// Unique identifier of the reaction.
  final Id id;

  /// ID of the user who reacted.
  final Id userId;

  /// Optional ID of the post being reacted to.
  final Id? postId;

  /// Optional ID of the review being reacted to.
  final Id? reviewId;

  /// Type of reaction (like, love, etc.).
  final ReactionType type;

  const Reaction({
    required this.id,
    required this.userId,
    required this.type,
    this.postId,
    this.reviewId,
  });
}
