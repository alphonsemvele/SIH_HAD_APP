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

  Future<void> _loadConversations() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await _messageService.getConversations();
      
      if (result['success']) {
        setState(() {
          _conversations = List<Map<String, dynamic>>.from(result['data']);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        _showErrorSnackBar(result['message'] ?? 'Erreur lors du chargement');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Erreur: ${e.toString()}');
    }
  }

  Future<void> _refreshConversations() async {
    await _loadConversations();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF4433),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Mapper les données API pour l'UI
  Map<String, dynamic> _mapConversationFromApi(Map<String, dynamic> conversation) {
    return {
      'id': conversation['id'],
      'nom': conversation['display_title'] ?? 'Conversation',
      'role': conversation['is_group'] ? 'Groupe' : 'Utilisateur',
      'dernier': conversation['last_message_content'] ?? 'Aucun message',
      'heure': conversation['last_message_time'] ?? '',
      'nonLu': conversation['unread_count'] ?? 0,
      'online': false, // À implémenter avec un système de présence
      'isGroup': conversation['is_group'] ?? false,
    };
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Messagerie',
          style: TextStyle(color: Color(0xFF1A1A2E), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.search, color: Color(0xFF1A1A2E), size: 20),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
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
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Tous'),
                      if (_conversations.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_conversations.length}',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Tab(
                  child: Builder(
                    builder: (context) {
                      final unreadCount = _conversations
                          .where((c) => (c['unread_count'] ?? 0) > 0)
                          .length;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Médecins'),
                          if (unreadCount > 0) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$unreadCount',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
                const Tab(text: 'Équipe'),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshConversations,
        color: const Color(0xFF1A1A2E),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildConversationsList(_conversations.map((conv) => _mapConversationFromApi(conv)).toList()),
            _buildConversationsList(_conversations.where((c) => (c['unread_count'] ?? 0) > 0).map((conv) => _mapConversationFromApi(conv)).toList()),
            _buildConversationsList(_conversations.where((c) => c['is_group'] == true).map((conv) => _mapConversationFromApi(conv)).toList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewMessageSheet(context),
        backgroundColor: const Color(0xFFFF4433),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  Widget _buildConversationsList(List<Map<String, dynamic>> conversations) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conv = conversations[index];
        return _buildConversationItem(conv);
      },
    );
  }

  Widget _buildConversationItem(Map<String, dynamic> conv) {
    final hasUnread = (conv['nonLu'] as int) > 0;
    final isGroup = conv['isGroup'] == true;

    return GestureDetector(
      onTap: () => _openChat(context, conv),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: hasUnread
              ? Border.all(color: const Color(0xFFFF4433).withOpacity(0.3))
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isGroup
                        ? const Color(0xFF2196F3).withOpacity(0.15)
                        : const Color(0xFFFF4433).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: isGroup
                        ? const Icon(Icons.groups, color: Color(0xFF2196F3), size: 24)
                        : Text(
                            (conv['nom'] as String).split(' ').map((e) => e[0]).take(2).join(),
                            style: const TextStyle(
                              color: Color(0xFFFF4433),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                if (conv['online'] == true)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),

            // Contenu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        conv['nom'],
                        style: TextStyle(
                          color: const Color(0xFF1A1A2E),
                          fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        conv['heure'],
                        style: TextStyle(
                          color: hasUnread ? const Color(0xFFFF4433) : Colors.grey.shade500,
                          fontSize: 12,
                          fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    conv['role'],
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conv['dernier'],
                          style: TextStyle(
                            color: hasUnread ? const Color(0xFF1A1A2E) : Colors.grey.shade600,
                            fontSize: 13,
                            fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF4433),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${conv['nonLu']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
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

  void _openChat(BuildContext context, Map<String, dynamic> conv) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ChatScreen(conversation: conv),
      ),
    );
  }

  void _showNewMessageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Nouveau message',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher un contact...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildContactItem('Dr. Michel Onana', 'Cardiologue', true),
                  _buildContactItem('Dr. Christiane Bella', 'Diabétologue', false),
                  _buildContactItem('Dr. Robert Tagne', 'Pneumologue', false),
                  _buildContactItem('Claire Mbede', 'Infirmière HAD', true),
                  _buildContactItem('Pharmacie Centrale', 'Pharmacie', true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(String nom, String role, bool online) {
    return ListTile(
      leading: Stack(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFFF4433).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                nom.split(' ').map((e) => e[0]).take(2).join(),
                style: const TextStyle(
                  color: Color(0xFFFF4433),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (online)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Text(nom, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(role, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
      onTap: () => Navigator.pop(context),
    );
  }
}

// Écran de chat
class _ChatScreen extends StatefulWidget {
  final Map<String, dynamic> conversation;

  const _ChatScreen({required this.conversation});

  @override
  State<_ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<_ChatScreen> {
  final _messageController = TextEditingController();
  
  final List<Map<String, dynamic>> _messages = [
    {'text': 'Bonjour, comment va M. Nguemo aujourd\'hui ?', 'isMe': false, 'heure': '10:15'},
    {'text': 'Bonjour Docteur ! Sa tension est à 145/92 ce matin, légèrement élevée.', 'isMe': true, 'heure': '10:18'},
    {'text': 'Je vois. Il faudrait peut-être ajuster le traitement. Vous pouvez augmenter le Furosémide à 60mg ?', 'isMe': false, 'heure': '10:22'},
    {'text': 'D\'accord, je note. Je lui fais le changement dès demain matin.', 'isMe': true, 'heure': '10:25'},
    {'text': 'Parfait. Surveillez aussi les œdèmes des membres inférieurs.', 'isMe': false, 'heure': '10:28'},
    {'text': 'Compris. Je vous tiendrai informé de l\'évolution.', 'isMe': true, 'heure': '10:30'},
    {'text': 'D\'accord pour la modification du traitement de M. Nguemo', 'isMe': false, 'heure': '10:32'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
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
                  (widget.conversation['nom'] as String).split(' ').map((e) => e[0]).take(2).join(),
                  style: const TextStyle(
                    color: Color(0xFFFF4433),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.conversation['nom'],
                  style: const TextStyle(
                    color: Color(0xFF1A1A2E),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  widget.conversation['online'] == true ? 'En ligne' : widget.conversation['role'],
                  style: TextStyle(
                    color: widget.conversation['online'] == true
                        ? const Color(0xFF4CAF50)
                        : Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone, color: Color(0xFF1A1A2E)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF1A1A2E)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.attach_file, color: Colors.grey.shade500),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Écrire un message...',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
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
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: () {},
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

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final isMe = msg['isMe'] as bool;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFFF4433) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              msg['text'],
              style: TextStyle(
                color: isMe ? Colors.white : const Color(0xFF1A1A2E),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              msg['heure'],
              style: TextStyle(
                color: isMe ? Colors.white.withOpacity(0.7) : Colors.grey.shade500,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}