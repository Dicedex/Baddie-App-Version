import 'package:flutter/material.dart';
import '../widgets/shimmer_loader.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _loading = true;
  List<_Conversation> _conversations = [];
  List<_Conversation> _filteredConversations = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadConversations();
    _searchController.addListener(_filterConversations);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    
    setState(() {
      _conversations = [
        _Conversation(
          id: '1',
          name: 'Ava',
          lastMessage: 'That sounds amazing! When are you free? 😊',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          imageUrl: 'https://picsum.photos/400/700?1',
          isOnline: true,
          unreadCount: 2,
        ),
        _Conversation(
          id: '2',
          name: 'Mia',
          lastMessage: 'Haha that\'s so funny 😂',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          imageUrl: 'https://picsum.photos/400/700?2',
          isOnline: false,
          unreadCount: 0,
        ),
        _Conversation(
          id: '3',
          name: 'Zoe',
          lastMessage: 'Just finished my workout! How\'s your day?',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          imageUrl: 'https://picsum.photos/400/700?3',
          isOnline: true,
          unreadCount: 1,
        ),
        _Conversation(
          id: '4',
          name: 'Emma',
          lastMessage: 'You: Let\'s grab coffee sometime ☕',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          imageUrl: 'https://picsum.photos/400/700?4',
          isOnline: false,
          unreadCount: 0,
        ),
        _Conversation(
          id: '5',
          name: 'Sophie',
          lastMessage: 'That museum exhibit looks cool! 🎨',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          imageUrl: 'https://picsum.photos/400/700?5',
          isOnline: true,
          unreadCount: 0,
        ),
      ];
      _filteredConversations = List.from(_conversations);
      _loading = false;
    });
  }

  void _filterConversations() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredConversations = List.from(_conversations);
      } else {
        _filteredConversations = _conversations
            .where((conv) => conv.name.toLowerCase().contains(_searchQuery))
            .toList();
      }
    });
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${timestamp.month}/${timestamp.day}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search conversations...',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[500],
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            _filterConversations();
                          },
                          child: Icon(
                            Icons.close,
                            color: Colors.grey[500],
                            size: 20,
                          ),
                        )
                      : null,
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          // Conversations list
          Expanded(
            child: _loading
                ? _buildShimmerLoading()
                : _filteredConversations.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _filteredConversations.length,
                        itemBuilder: (context, index) {
                          return _buildConversationTile(
                            _filteredConversations[index],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  ShimmerLoader(
                    height: 56,
                    width: 56,
                    borderRadius: 28,
                    margin: EdgeInsets.zero,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerLoader(
                          height: 14,
                          width: 150,
                          borderRadius: 6,
                          margin: EdgeInsets.only(bottom: 8),
                        ),
                        ShimmerLoader(
                          height: 12,
                          width: double.infinity,
                          borderRadius: 6,
                          margin: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  ShimmerLoader(
                    height: 12,
                    width: 40,
                    borderRadius: 4,
                    margin: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mail_outline,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          Text(
            _searchQuery.isNotEmpty
                ? 'No conversations found'
                : 'No messages yet',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try a different search'
                : 'When you match someone, you can message them here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(_Conversation conversation) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              recipientId: conversation.id,
              recipientName: conversation.name,
              recipientImageUrl: conversation.imageUrl,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: conversation.unreadCount > 0
              ? [
                  BoxShadow(
                    color: const Color(0xFFF06595).withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Profile picture with online indicator
              Stack(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey[200]!,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        conversation.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.person,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (conversation.isOnline)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green[400],
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              // Name and message preview
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      conversation.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: conversation.unreadCount > 0
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      conversation.lastMessage,
                      style: TextStyle(
                        fontSize: 13,
                        color: conversation.unreadCount > 0
                            ? Colors.black87
                            : Colors.grey[600],
                        fontWeight: conversation.unreadCount > 0
                            ? FontWeight.w500
                            : FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Time and unread badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatTimestamp(conversation.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (conversation.unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF06595),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        conversation.unreadCount > 9
                            ? '9+'
                            : conversation.unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Conversation {
  final String id;
  final String name;
  final String lastMessage;
  final DateTime timestamp;
  final String imageUrl;
  final bool isOnline;
  final int unreadCount;

  _Conversation({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.timestamp,
    required this.imageUrl,
    required this.isOnline,
    required this.unreadCount,
  });
}
