// This file defines the main pages/screens of the app.
// For a larger project you might split these into separate files per screen.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'services.dart';
import 'theme_notifier.dart';

/// Login and sign-up page. Keeps UX simple while demonstrating authentication.
class AuthPage extends StatefulWidget {
  final AuthService authService;
  final void Function(AppUser user) onAuthenticated;

  const AuthPage({
    super.key,
    required this.authService,
    required this.onAuthenticated,
  });

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();

  bool _isLogin = true;
  String _username = '';
  String _email = '';
  String _password = '';
  String? _error;

  /// Handles both log in and sign up using the auth service.
  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _formKey.currentState!.save();

    setState(() {
      _error = null;
    });

    try {
      AppUser user;
      if (_isLogin) {
        user = widget.authService.logIn(email: _email, password: _password);
      } else {
        user = widget.authService
            .signUp(username: _username, email: _email, password: _password);
      }
      widget.onAuthenticated(user);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Log in' : 'Sign up'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Book Review & Recommendations',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                if (!_isLogin)
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Username'),
                    onSaved: (v) => _username = v?.trim() ?? '',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (v) => _email = v?.trim() ?? '',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  onSaved: (v) => _password = v ?? '',
                  validator: (v) =>
                      (v == null || v.length < 4) ? 'Min 4 characters' : null,
                ),
                const SizedBox(height: 16),
                if (_error != null)
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(_isLogin ? 'Log in' : 'Sign up'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                  },
                  child: Text(_isLogin
                      ? 'Need an account? Sign up'
                      : 'Already have an account? Log in'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Home page hosting a bottom navigation bar for feed, search, and profile.
class HomePage extends StatefulWidget {
  final AppUser user;
  final AuthService authService;
  final BookService bookService;
  final SocialService socialService;
  final VoidCallback onLoggedOut;

  const HomePage({
    super.key,
    required this.user,
    required this.authService,
    required this.bookService,
    required this.socialService,
    required this.onLoggedOut,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      BookSearchPage(
        bookService: widget.bookService,
        socialService: widget.socialService,
        currentUser: widget.user,
      ),
      FeedPage(
        user: widget.user,
        bookService: widget.bookService,
        socialService: widget.socialService,
        authService: widget.authService,
      ),
      const Scaffold(body: Center(child: Text('Activity Coming Soon'))),
      ProfilePage(
        user: widget.user,
        authService: widget.authService,
        bookService: widget.bookService,
        socialService: widget.socialService,
        onLoggedOut: widget.onLoggedOut,
      ),
    ];

    final labels = ['Discover', 'Community', 'Activity', 'Profile'];

    return Scaffold(
      appBar: AppBar(
        title: Text(labels[_index]),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Open search functionality or Navigate to search page
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).colorScheme.onPrimary,
                      child: Text(
                        widget.user.username.isNotEmpty
                            ? widget.user.username[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 24,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.user.username,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.settings, color: Theme.of(context).colorScheme.primary),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SettingsPage(user: widget.user),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.primary),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  widget.authService.logOut();
                  widget.onLoggedOut();
                },
              ),
            ],
          ),
        ),
      ),
      body: pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: 'Discover'),
          const BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'Community'),
          const BottomNavigationBarItem(icon: Icon(Icons.notifications_none), activeIcon: Icon(Icons.notifications), label: 'Activity'),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

/// Feed page showing recent posts and allowing creation of new ones.
class FeedPage extends StatefulWidget {
  final AppUser user;
  final BookService bookService;
  final SocialService socialService;
  final AuthService authService;

  const FeedPage({
    super.key,
    required this.user,
    required this.bookService,
    required this.socialService,
    required this.authService,
  });

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  PostCategory _selectedCategory = PostCategory.all;

  /// Helper for showing a dialog to create a new post.
  Future<void> _showCreatePostDialog() async {
    String content = '';
    Book? selectedBook;
    PostCategory category = PostCategory.other;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('New post'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'What would you like to share?',
                      ),
                      onChanged: (v) => content = v,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<PostCategory>(
                      decoration: const InputDecoration(labelText: 'Category'),
                      value: category,
                      items: [
                        PostCategory.recs,
                        PostCategory.ask,
                        PostCategory.other,
                      ].map((c) => DropdownMenuItem(value: c, child: Text(c.name.toUpperCase()))).toList(),
                      onChanged: (c) => setDialogState(() => category = c ?? PostCategory.other),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<Book>(
                      decoration: const InputDecoration(
                        labelText: 'Recommend a book (optional)',
                      ),
                      initialValue: selectedBook,
                      items: [
                        const DropdownMenuItem<Book>(
                          value: null,
                          child: Text('No specific book'),
                        ),
                        ...widget.bookService.allBooks.map(
                          (b) => DropdownMenuItem<Book>(
                            value: b,
                            child: Text(b.title),
                          ),
                        ),
                      ],
                      onChanged: (b) => selectedBook = b,
                    ),
                  ],
                ),
              );
            }
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (content.trim().isEmpty) return;
                widget.socialService.createPost(
                  userId: widget.user.id,
                  content: content.trim(),
                  category: category,
                  recommendedBookId: selectedBook?.id,
                );
                setState(() {});
                Navigator.of(ctx).pop();
              },
              child: const Text('Post'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final allPosts = widget.socialService.posts;
    final posts = _selectedCategory == PostCategory.all 
        ? allPosts 
        : allPosts.where((p) => p.category == _selectedCategory).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildFilterChip(PostCategory.all),
                  _buildFilterChip(PostCategory.recs),
                  _buildFilterChip(PostCategory.ask),
                  _buildFilterChip(PostCategory.other),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Readers Like You', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: 5,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: CircleAvatar(radius: 30, backgroundColor: Colors.grey[300], child: const Icon(Icons.person)),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return _buildCommunityPost(post);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(PostCategory category) {
    final isSelected = _selectedCategory == category;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(category.name.toUpperCase()),
        selected: isSelected,
        onSelected: (v) => setState(() => _selectedCategory = category),
        backgroundColor: Colors.transparent,
        selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        checkmarkColor: Theme.of(context).colorScheme.primary,
        shape: StadiumBorder(side: BorderSide(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[300]!)),
      ),
    );
  }

  Widget _buildCommunityPost(Post post) {
    final author = widget.authService.getUserById(post.userId);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            child: Text(
              author?.username.isNotEmpty == true ? author!.username[0].toUpperCase() : '?',
              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(author?.username ?? 'Unknown User', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('12m', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(post.category.name.toUpperCase(), style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 4),
                Text(post.content),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.reply_outlined, size: 18),
                      color: Colors.grey[600],
                      onPressed: () async {
                         await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PostCommentsPage(
                              post: post,
                              user: widget.user,
                              socialService: widget.socialService,
                              authService: widget.authService,
                            ),
                          ),
                        );
                        setState(() {});
                      },
                    ),
                    IconButton(
                      icon: Icon(
                         widget.socialService.hasUserReactedToPost(userId: widget.user.id, postId: post.id, type: ReactionType.like)
                            ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                      ),
                      color: widget.socialService.hasUserReactedToPost(userId: widget.user.id, postId: post.id, type: ReactionType.like)
                          ? Colors.red : Colors.grey[600],
                      onPressed: () {
                        widget.socialService.toggleReactionOnPost(
                            userId: widget.user.id,
                            postId: post.id,
                            type: ReactionType.like,
                          );
                          setState(() {});
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_outlined, size: 18),
                      color: Colors.grey[600],
                      onPressed: () {},
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Page for searching books and opening book details.
class BookSearchPage extends StatefulWidget {
  final BookService bookService;
  final SocialService socialService;
  final AppUser currentUser;

  const BookSearchPage({
    super.key,
    required this.bookService,
    required this.socialService,
    required this.currentUser,
  });

  @override
  State<BookSearchPage> createState() => _BookSearchPageState();
}

class _BookSearchPageState extends State<BookSearchPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final books = widget.bookService.search(_query);
    final trending = widget.bookService.trending(limit: 5);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Search books',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            _buildSectionHeader('Recommended for You'),
            _buildBookHeroList(trending),
            _buildSectionHeader('Community Reads'),
            _buildBookGrid(books.take(4).toList()),
            _buildSectionHeader('Upcoming Books'),
            _buildBookGrid(books.skip(4).toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Icon(Icons.chevron_right, color: Colors.grey[600]),
        ],
      ),
    );
  }

  Widget _buildBookHeroList(List<Book> books) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: books.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
               Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BookDetailPage(
                    book: books[index],
                    socialService: widget.socialService,
                    currentUser: widget.currentUser,
                  ),
                ),
              );
            },
            child: Container(
              width: 150,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[300],
                image: books[index].coverImageUrl != null ? DecorationImage(image: NetworkImage(books[index].coverImageUrl!), fit: BoxFit.cover) : null,
              ),
              child: books[index].coverImageUrl == null ? Center(child: Text(books[index].title, textAlign: TextAlign.center)) : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookGrid(List<Book> books) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        return GestureDetector(
           onTap: () {
               Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BookDetailPage(
                    book: books[index],
                    socialService: widget.socialService,
                    currentUser: widget.currentUser,
                  ),
                ),
              );
            },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: Center(child: Text(books[index].title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10))),
          ),
        );
      },
    );
  }
}

/// Book details page showing description and reviews.
class BookDetailPage extends StatelessWidget {
  final Book book;
  final SocialService socialService;
  final AppUser currentUser;

  const BookDetailPage({
    super.key,
    required this.book,
    required this.socialService,
    required this.currentUser,
  });

  /// Helper to open the review creation page.
  Future<void> _writeReview(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReviewPage(
          book: book,
          socialService: socialService,
          currentUser: currentUser,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reviews = socialService.reviewsForBook(book.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _writeReview(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.rate_review, color: Colors.white),
        label: const Text('Write review', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              book.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              'by ${book.author}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(book.genre),
              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Text(book.description),
            const SizedBox(height: 24),
            Text(
              'Reviews',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (reviews.isEmpty)
              const Text('No reviews yet. Be the first to write one!')
            else
              ...reviews.map(
                (r) => Card(
                  child: ListTile(
                    title: Row(
                      children: [
                        ...List.generate(
                          r.rating,
                          (index) => const Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(r.content),
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ReviewCommentsPage(
                            review: r,
                            user: currentUser,
                            socialService: socialService,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Page for writing a new review for a specific book.
class ReviewPage extends StatefulWidget {
  final Book book;
  final SocialService socialService;
  final AppUser currentUser;

  const ReviewPage({
    super.key,
    required this.book,
    required this.socialService,
    required this.currentUser,
  });

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  int _rating = 3;
  String _content = '';

  /// Persists the new review in the social service.
  void _submit() {
    if (_content.trim().isEmpty) return;
    widget.socialService.createReview(
      userId: widget.currentUser.id,
      bookId: widget.book.id,
      rating: _rating,
      content: _content.trim(),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write review'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rating: $_rating stars'),
            Slider(
              value: _rating.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: '$_rating',
              activeColor: Theme.of(context).colorScheme.primary,
              onChanged: (v) {
                setState(() {
                  _rating = v.round();
                });
              },
            ),
            TextField(
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Your review',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => _content = v,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dedicated page showing comments for a specific post.
class PostCommentsPage extends StatefulWidget {
  final Post post;
  final AppUser user;
  final SocialService socialService;
  final AuthService authService;

  const PostCommentsPage({
    super.key,
    required this.post,
    required this.user,
    required this.socialService,
    required this.authService,
  });

  @override
  State<PostCommentsPage> createState() => _PostCommentsPageState();
}

class _PostCommentsPageState extends State<PostCommentsPage> {
  final TextEditingController _controller = TextEditingController();

  /// Adds a new comment using the social service.
  void _addComment() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.socialService.commentOnPost(
      userId: widget.user.id,
      postId: widget.post.id,
      content: text,
    );
    _controller.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final comments = widget.socialService.commentsForPost(widget.post.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post comments'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(widget.post.content),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final c = comments[index];
                final author = widget.authService.getUserById(c.userId);
                return ListTile(
                  leading: CircleAvatar(
                    radius: 15,
                    child: Text(author?.username[0].toUpperCase() ?? '?'),
                  ),
                  title: Text(author?.username ?? 'Unknown'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.content),
                      Text(c.createdAt.toLocal().toString().substring(0, 16), style: const TextStyle(fontSize: 10)),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: _addComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Page for comments on a review.
class ReviewCommentsPage extends StatefulWidget {
  final Review review;
  final AppUser user;
  final SocialService socialService;

  const ReviewCommentsPage({
    super.key,
    required this.review,
    required this.user,
    required this.socialService,
  });

  @override
  State<ReviewCommentsPage> createState() => _ReviewCommentsPageState();
}

class _ReviewCommentsPageState extends State<ReviewCommentsPage> {
  final TextEditingController _controller = TextEditingController();

  /// Adds a new comment for the review.
  void _addComment() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.socialService.commentOnReview(
      userId: widget.user.id,
      reviewId: widget.review.id,
      content: text,
    );
    _controller.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final comments =
        widget.socialService.commentsForReview(widget.review.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review comments'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ...List.generate(
                      widget.review.rating,
                      (index) => const Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(widget.review.content),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final c = comments[index];
                return ListTile(
                  title: Text(c.content),
                  subtitle: Text(c.createdAt.toLocal().toString()),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: _addComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// User profile page with a simple settings shortcut.
class ProfilePage extends StatefulWidget {
  final AppUser user;
  final AuthService authService;
  final BookService bookService;
  final SocialService socialService;
  final VoidCallback onLoggedOut;

  const ProfilePage({
    super.key,
    required this.user,
    required this.authService,
    required this.bookService,
    required this.socialService,
    required this.onLoggedOut,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    // Dynamically fetch books the user has actually reviewed (read)
    final reviews = widget.socialService.reviewsForUser(widget.user.id);
    final readBooks = reviews.map((r) => widget.bookService.getById(r.bookId)).whereType<Book>().toList();

    // Dynamically fetch books the user has recommended (via posts)
    final posts = widget.socialService.posts.where((p) => p.userId == widget.user.id && p.recommendedBookId != null);
    final recommendedBooks = posts.map((p) => widget.bookService.getById(p.recommendedBookId!)).whereType<Book>().toList();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),
            // Profile Picture - Moved to be more centered/prominent
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                child: Icon(Icons.person, size: 50, color: Theme.of(context).colorScheme.primary),
              ),
            ),
            const SizedBox(height: 16),
            // Name and Bio centered
            Center(child: Text(widget.user.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24))),
            const Center(child: Text('Reader', style: TextStyle(color: Colors.grey, fontSize: 16))),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(widget.user.bio.isEmpty ? 'Passionate about reading and sharing thoughts on books.' : widget.user.bio, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 16),
            // Follow Button - Added as requested
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: const Text('Follow'),
            ),
            const SizedBox(height: 24),
            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn(readBooks.length.toString(), 'Books'),
                _buildStatColumn('0', 'Followers'), 
                _buildStatColumn('0', 'Following'), 
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: const Icon(Icons.link), color: Theme.of(context).colorScheme.primary, onPressed: () {}),
                IconButton(icon: const Icon(Icons.camera_alt_outlined), color: Theme.of(context).colorScheme.primary, onPressed: () {}),
                IconButton(icon: const Icon(Icons.alternate_email), color: Theme.of(context).colorScheme.primary, onPressed: () {}),
              ],
            ),
            const Divider(),
            _buildSectionHeader('Books recommended by ${widget.user.username}'),
            _buildBookHeroList(recommendedBooks, context),
            _buildSectionHeader('Read'),
            _buildBookHeroList(readBooks, context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String count, String label) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }

  Widget _buildBookHeroList(List<Book> books, BuildContext context) {
    if (books.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text('No books yet.', style: TextStyle(color: Colors.grey))),
      );
    }

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: books.length,
        itemBuilder: (context, index) => GestureDetector(
           onTap: () {
               Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BookDetailPage(
                    book: books[index],
                    socialService: widget.socialService,
                    currentUser: widget.user,
                  ),
                ),
              );
            },
          child: Container(
            width: 110,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
              image: books[index].coverImageUrl != null ? DecorationImage(image: NetworkImage(books[index].coverImageUrl!), fit: BoxFit.cover) : null,
            ),
            child: books[index].coverImageUrl == null ? Center(child: Text(books[index].title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10))) : null,
          ),
        ),
      ),
    );
  }
}

/// Settings page hosting a theme selector.
class SettingsPage extends StatelessWidget {
  final AppUser user;

  const SettingsPage({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
    final authService = context.read<AuthService>();
    final prefs = context.read<SharedPreferences>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Theme Selection'),
            subtitle: Text(
              'Pick a color scheme that suits your style. '
              'The selected theme will be saved and applied across the entire app.',
            ),
          ),
          const Divider(),
          ...AppThemeType.values.map((type) {
            return RadioListTile<AppThemeType>(
              title: Text(type.name[0].toUpperCase() + type.name.substring(1)),
              value: type,
              groupValue: themeNotifier.currentType,
              activeColor: Theme.of(context).colorScheme.primary,
              onChanged: (newType) async {
                if (newType == null) return;
                
                // 1. Update the UI immediately via ThemeNotifier
                themeNotifier.setTheme(newType);
                
                // 2. Persist the choice to disk for the next app launch
                await prefs.setString('selected_theme', themeTypeToKey(newType));
                
                // 3. Update the user profile in the (in-memory) auth service
                final updatedUser = user.copyWith(preferredTheme: newType);
                authService.updateProfile(updatedUser);
              },
            );
          }),
        ],
      ),
    );
  }
}
