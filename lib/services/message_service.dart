import 'package:dio/dio.dart';
import 'api_service.dart';

class MessageService {
  final ApiService _apiService = ApiService();

  // Obtenir toutes les conversations
  Future<Map<String, dynamic>> getConversations() async {
    try {
      final response = await _apiService.get('/api/conversations');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la récupération des conversations',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Obtenir une conversation spécifique
  Future<Map<String, dynamic>> getConversation(int id) async {
    try {
      final response = await _apiService.get('/api/conversations/$id');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la récupération de la conversation',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Obtenir les messages d'une conversation
  Future<Map<String, dynamic>> getMessages(int conversationId) async {
    try {
      final response = await _apiService.get('/api/conversations/$conversationId/messages');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la récupération des messages',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Envoyer un message
  Future<Map<String, dynamic>> sendMessage(Map<String, dynamic> messageData) async {
    try {
      final response = await _apiService.post('/api/messages', data: messageData);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
          'message': 'Message envoyé avec succès',
        };
      } else if (response.statusCode == 422) {
        // Erreur de validation
        String errorMessage = 'Erreur de validation:';
        final errors = response.data['errors'] ?? {};
        errors.forEach((field, messages) {
          errorMessage += '\n• ${messages.join(', ')}';
        });
        return {
          'success': false,
          'message': errorMessage,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur HTTP ${response.statusCode}: ${response.data['message'] ?? 'Erreur inconnue'}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Créer une nouvelle conversation
  Future<Map<String, dynamic>> createConversation(Map<String, dynamic> conversationData) async {
    try {
      final response = await _apiService.post('/api/conversations', data: conversationData);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
          'message': 'Conversation créée avec succès',
        };
      } else if (response.statusCode == 422) {
        // Erreur de validation
        String errorMessage = 'Erreur de validation:';
        final errors = response.data['errors'] ?? {};
        errors.forEach((field, messages) {
          errorMessage += '\n• ${messages.join(', ')}';
        });
        return {
          'success': false,
          'message': errorMessage,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur HTTP ${response.statusCode}: ${response.data['message'] ?? 'Erreur inconnue'}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Marquer un message comme lu
  Future<Map<String, dynamic>> markAsRead(int messageId) async {
    try {
      final response = await _apiService.put('/api/messages/$messageId/mark-as-read');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Message marqué comme lu',
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors du marquage comme lu',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Marquer tous les messages d'une conversation comme lus
  Future<Map<String, dynamic>> markConversationAsRead(int conversationId) async {
    try {
      final response = await _apiService.put('/api/conversations/$conversationId/mark-as-read');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Conversation marquée comme lue',
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors du marquage comme lu',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Supprimer un message
  Future<Map<String, dynamic>> deleteMessage(int messageId) async {
    try {
      final response = await _apiService.delete('/api/messages/$messageId');
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'success': true,
          'message': 'Message supprimé avec succès',
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur HTTP ${response.statusCode}: ${response.data['message'] ?? 'Erreur inconnue'}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Supprimer une conversation
  Future<Map<String, dynamic>> deleteConversation(int conversationId) async {
    try {
      final response = await _apiService.delete('/api/conversations/$conversationId');
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'success': true,
          'message': 'Conversation supprimée avec succès',
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur HTTP ${response.statusCode}: ${response.data['message'] ?? 'Erreur inconnue'}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Obtenir les utilisateurs disponibles pour créer une conversation
  Future<Map<String, dynamic>> getAvailableUsers() async {
    try {
      final response = await _apiService.get('/api/users/available-for-chat');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la récupération des utilisateurs',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Obtenir les statistiques de messagerie
  Future<Map<String, dynamic>> getMessagingStats() async {
    try {
      final response = await _apiService.get('/api/messaging/stats');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la récupération des statistiques',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
