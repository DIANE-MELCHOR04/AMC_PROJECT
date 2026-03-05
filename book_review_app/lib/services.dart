// This file groups lightweight in-memory services used by the demo app.
// In a real production app, these services would talk to a backend or database.

import 'dart:math';

import 'models.dart';

/// Simple utility to generate fake IDs for demo purposes.
String _randomId() => Random().nextInt(1 << 31).toString();

/// Authentication and user profile service.
/// This demo keeps users in memory and does not persist passwords securely.
class AuthService {
  /// Internal list of demo users.
  final List<AppUser> _users = [];

  /// Currently authenticated user, or null if no user is logged in.
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  /// Registers a new user with minimal validation.
  /// Returns the created [AppUser] or throws if the e-mail already exists.
  AppUser signUp({
    required String username,
    required String email,
    required String password,
  }) {
    final existing =
        _users.where((u) => u.email.toLowerCase() == email.toLowerCase());
    if (existing.isNotEmpty) {
      throw Exception('An account with this email already exists.');
    }

    final user = AppUser(
      id: _randomId(),
      username: username,
      bio: '',
      email: email,
      password: password,
    );
    _users.add(user);
    _currentUser = user;
    return user;
  }

  /// Logs a user in using the stored demo credentials.
  /// In a real app this would be handled on a secure backend.
  AppUser logIn({
    required String email,
    required String password,
  }) {
    final match = _users.firstWhere(
      (u) =>
          u.email.toLowerCase() == email.toLowerCase() && u.password == password,
      orElse: () => throw Exception('Invalid credentials'),
    );
    _currentUser = match;
    return match;
  }

  /// Logs out the current user.
  void logOut() {
    _currentUser = null;
  }

  /// Updates the current user's profile and returns the updated instance.
  AppUser updateProfile(AppUser updated) {
    final index = _users.indexWhere((u) => u.id == updated.id);
    if (index == -1) {
      throw Exception('User not found');
    }
    _users[index] = updated;
    _currentUser = updated;
    return updated;
  }

  /// Returns a user by their unique ID.
  AppUser? getUserById(Id id) {
    try {
      return _users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Service responsible for book data and search.
class BookService {
  /// In-memory list of all known books.
  final List<Book> _books = [
    Book(
      id: '1',
      title: 'The Flutter Journey',
      author: 'Jane Developer',
      genre: 'Technology',
      description:
          'A practical guide to building beautiful mobile apps with Flutter.',
    ),
    Book(
      id: '2',
      title: 'Mystery in the Forest',
      author: 'A. Storyteller',
      genre: 'Mystery',
      description: 'A gripping mystery set in a quiet forest town.',
    ),
    Book(
      id: '3',
      title: 'Ocean of Dreams',
      author: 'W. Explorer',
      genre: 'Fantasy',
      description:
          'An epic fantasy adventure across oceans and mystical islands.',
    ),
  ];

  List<Book> get allBooks => List.unmodifiable(_books);

  /// Finds a single book by ID or returns null.
  Book? getById(String id) {
    try {
      return _books.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Performs a simple case-insensitive search across title, author, and genre.
  List<Book> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return allBooks;
    return _books
        .where(
          (b) =>
              b.title.toLowerCase().contains(q) ||
              b.author.toLowerCase().contains(q) ||
              b.genre.toLowerCase().contains(q),
        )
        .toList();
  }

  /// Returns books that appear to be "trending".
  /// Here we simply return the first few books as a placeholder.
  List<Book> trending({int limit = 5}) {
    return _books.take(limit).toList();
  }
}

/// Service that manages reviews, comments, reactions, and posts.
class SocialService {
  final List<Review> _reviews = [];
  final List<Comment> _comments = [];
  final List<Post> _posts = [];
  final List<Reaction> _reactions = [];

  List<Post> get posts =>
      _posts.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  /// Creates and stores a new post.
  Post createPost({
    required Id userId,
    required String content,
    PostCategory category = PostCategory.other,
    Id? recommendedBookId,
  }) {
    final post = Post(
      id: _randomId(),
      userId: userId,
      content: content,
      category: category,
      createdAt: DateTime.now(),
      recommendedBookId: recommendedBookId,
    );
    _posts.add(post);
    return post;
  }

  /// Adds a comment to a post.
  Comment commentOnPost({
    required Id userId,
    required Id postId,
    required String content,
  }) {
    final comment = Comment(
      id: _randomId(),
      userId: userId,
      content: content,
      createdAt: DateTime.now(),
      postId: postId,
    );
    _comments.add(comment);
    return comment;
  }

  /// Returns all comments associated with a specific post.
  List<Comment> commentsForPost(Id postId) {
    return _comments
        .where((c) => c.postId == postId)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// Adds a review for a book.
  Review createReview({
    required Id userId,
    required Id bookId,
    required int rating,
    required String content,
  }) {
    final review = Review(
      id: _randomId(),
      userId: userId,
      bookId: bookId,
      rating: rating,
      content: content,
      createdAt: DateTime.now(),
    );
    _reviews.add(review);
    return review;
  }

  /// Returns all reviews for a given book.
  List<Review> reviewsForBook(Id bookId) {
    return _reviews
        .where((r) => r.bookId == bookId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Returns all reviews written by a specific user.
  List<Review> reviewsForUser(Id userId) {
    return _reviews
        .where((r) => r.userId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Adds a comment to a review.
  Comment commentOnReview({
    required Id userId,
    required Id reviewId,
    required String content,
  }) {
    final comment = Comment(
      id: _randomId(),
      userId: userId,
      content: content,
      createdAt: DateTime.now(),
      reviewId: reviewId,
    );
    _comments.add(comment);
    return comment;
  }

  /// Returns all comments associated with a specific review.
  List<Comment> commentsForReview(Id reviewId) {
    return _comments
        .where((c) => c.reviewId == reviewId)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// Toggles a reaction for a post for a given user.
  /// If the same reaction already exists, it is removed; otherwise it is created.
  void toggleReactionOnPost({
    required Id userId,
    required Id postId,
    required ReactionType type,
  }) {
    final existingIndex = _reactions.indexWhere(
      (r) => r.userId == userId && r.postId == postId && r.type == type,
    );
    if (existingIndex != -1) {
      _reactions.removeAt(existingIndex);
    } else {
      _reactions.add(
        Reaction(
          id: _randomId(),
          userId: userId,
          postId: postId,
          type: type,
        ),
      );
    }
  }

  /// Counts how many reactions of any type a post has.
  int reactionCountForPost(Id postId) {
    return _reactions.where((r) => r.postId == postId).length;
  }

  /// Returns whether a user has reacted with a specific type to a post.
  bool hasUserReactedToPost({
    required Id userId,
    required Id postId,
    required ReactionType type,
  }) {
    return _reactions
        .any((r) => r.postId == postId && r.userId == userId && r.type == type);
  }
}
