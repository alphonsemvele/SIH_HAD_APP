import 'package:flutter/material.dart';
import '../services/message_service.dart';

class MessagerieScreen extends StatefulWidget {
  const MessagerieScreen({super.key});

  @override
  State<MessagerieScreen> createState() => _MessagerieScreenState();
}

class _MessagerieScreenState extends State<MessagerieScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MessageService _messageService = MessageService();
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadConversations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    setState(() => _isLoading = true);
    try {
      final result = await _messageService.getConversations();
      if (!mounted) return;
      if (result['success'] == true) {
        final raw = result['data'];
        final List<dynamic> list = raw is List ? raw : (raw['data'] ?? []);
        setState(() {
          _conversations = list.map((c) => Map<String, dynamic>.from(c)).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refresh() async => _loadConversations();

  String _formatHeure(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final d = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      if (d.year == now.year && d.month == now.month && d.day == now.day) {
        return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
      }
      final daysDiff = now.difference(d).inDays;
      if (daysDiff == 1) return 'Hier';
      if (daysDiff < 7) return '${d.day}/${d.month}';
      return '${d.day}/${d.month}/${d.year.toString().substring(2)}';
    } catch (_) {
      return '';
    }
  }

  String _conversationTitle(Map<String, dynamic> c) {
    if (c['title'] != null && c['title'].toString().isNotEmpty) {
      return c['title'].toString();
    }
    // Sinon prendre le nom du 1er participant qui n'est pas moi
    final participants = (c['participants'] as List?) ?? [];
    if (participants.isNotEmpty) {
      return participants.first['name']?.toString() ?? 'Conversation';
    }
    return 'Conversation';
  }

  String _lastMessagePreview(Map<String, dynamic> c) {
    final last = c['last_message'];
    if (last is Map && last['content'] != null) {
      return last['content'].toString();
    }
    return 'Aucun message';
  }

  String _lastMessageTime(Map<String, dynamic> c) {
    final last = c['last_message'];
    if (last is Map && last['created_at'] != null) {
      return _formatHeure(last['created_at'].toString());
    }
    return _formatHeure(c['updated_at']?.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF12121A),
        elevation: 0,
        title: const Text(
          'Messagerie',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadConversations,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFFFF4433),
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              tabs: [
                Tab(text: 'Tous (${_conversations.length})'),
                Tab(text: 'Non lus (${_conversations.where((c) => (c['unread_count'] ?? 0) > 0).length})'),
                const Tab(text: 'Récents'),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF4433)))
          : RefreshIndicator(
              color: const Color(0xFFFF4433),
              onRefresh: _refresh,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildList(_conversations),
                  _buildList(_conversations.where((c) => (c['unread_count'] ?? 0) > 0).toList()),
                  _buildList(_conversations.take(5).toList()),
                ],
              ),
            ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> convs) {
    if (convs.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 100),
          Icon(Icons.chat_bubble_outline, size: 60, color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Aucune conversation',
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 15),
            ),
          ),
        ],
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: convs.length,
      itemBuilder: (_, i) => _buildItem(convs[i]),
    );
  }

  Widget _buildItem(Map<String, dynamic> c) {
    final unread = (c['unread_count'] ?? 0) as int;
    final hasUnread = unread > 0;
    final title = _conversationTitle(c);
    final preview = _lastMessagePreview(c);
    final time = _lastMessageTime(c);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => _ChatScreen(conversation: c)),
      ).then((_) => _loadConversations()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF12121A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasUnread
                ? const Color(0xFFFF4433).withOpacity(0.5)
                : const Color(0xFF1E1E2A),
            width: hasUnread ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFFF4433).withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  title.split(' ').where((p) => p.isNotEmpty).map((e) => e[0]).take(2).join().toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFFF4433),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          color: hasUnread ? const Color(0xFFFF4433) : Colors.white60,
                          fontSize: 11,
                          fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          preview,
                          style: TextStyle(
                            color: hasUnread ? Colors.white70 : Colors.white60,
                            fontSize: 12,
                            fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF4433),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$unread',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
//  ÉCRAN DE CHAT BRANCHÉ BACKEND
// ============================================================

class _ChatScreen extends StatefulWidget {
  final Map<String, dynamic> conversation;
  const _ChatScreen({required this.conversation});

  @override
  State<_ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<_ChatScreen> {
  final MessageService _messageService = MessageService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final id = widget.conversation['id'];
    if (id == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final res = await _messageService.getMessages(id is int ? id : int.parse(id.toString()));
      if (!mounted) return;
      if (res['success'] == true) {
        final raw = res['data'];
        final List<dynamic> list = raw is Map && raw['messages'] is List
            ? raw['messages']
            : (raw is List ? raw : []);
        setState(() {
          _messages = list.map((m) => Map<String, dynamic>.from(m)).toList();
          _isLoading = false;
        });
        // Scroll to bottom après render
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;
    final convId = widget.conversation['id'];
    if (convId == null) return;

    setState(() => _isSending = true);

    final res = await _messageService.sendMessage({
      'conversation_id': convId is int ? convId : int.parse(convId.toString()),
      'content': text,
      'type': 'text',
    });

    if (!mounted) return;
    if (res['success'] == true) {
      _messageController.clear();
      // Recharger les messages
      await _loadMessages();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message']?.toString() ?? 'Erreur envoi'),
          backgroundColor: const Color(0xFFFF4433),
          duration: const Duration(seconds: 2),
        ),
      );
    }
    if (mounted) setState(() => _isSending = false);
  }

  String _formatTime(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final d = DateTime.parse(iso).toLocal();
      return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  bool _isMe(Map<String, dynamic> msg) {
    if (msg['is_me'] == true) return true;
    if (_currentUserId != null) return msg['sender_id'] == _currentUserId;
    return msg['sender']?['email'] == 'infirmier@sih.local'; // fallback démo
  }

  @override
  Widget build(BuildContext context) {
    final title = (widget.conversation['title']?.toString().isNotEmpty == true)
        ? widget.conversation['title'].toString()
        : 'Conversation';

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF12121A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFF4433).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  title.split(' ').where((p) => p.isNotEmpty).map((e) => e[0]).take(2).join().toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFFF4433),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadMessages,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF4433)))
                : _messages.isEmpty
                    ? Center(
                        child: Text(
                          'Aucun message dans cette conversation',
                          style: TextStyle(color: Colors.white.withOpacity(0.5)),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (_, i) => _buildBubble(_messages[i]),
                      ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF12121A),
              border: Border(top: BorderSide(color: Color(0xFF1E1E2A))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Écrire un message...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                        filled: true,
                        fillColor: const Color(0xFF1E1E2A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF4433),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: _isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: _isSending ? null : _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(Map<String, dynamic> msg) {
    final isMe = _isMe(msg);
    final content = msg['content']?.toString() ?? '';
    final time = _formatTime(msg['created_at']?.toString());
    final senderName = msg['sender']?['name']?.toString() ?? msg['sender_name']?.toString() ?? '';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFFF4433) : const Color(0xFF12121A),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isMe ? 14 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 14),
          ),
          border: isMe ? null : Border.all(color: const Color(0xFF1E1E2A)),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe && senderName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  senderName,
                  style: const TextStyle(
                    color: Color(0xFFFF4433),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Text(
              content,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                color: isMe ? Colors.white.withOpacity(0.7) : Colors.white.withOpacity(0.4),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
