import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:dentex_clean/data/data_sources/remote/support_remote_data_source.dart';
import 'package:dentex_clean/data/models/support_ticket_model.dart';

@Injectable(as: SupportRemoteDataSource)
class SupportRemoteDataSourceImpl implements SupportRemoteDataSource {
  final FirebaseFirestore _firestore;

  SupportRemoteDataSourceImpl(this._firestore);

  @override
  Future<void> sendTicket(SupportTicketModel ticket) async {
    await _firestore.collection('support_tickets').add(ticket.toFirestore());
  }

  @override
  Stream<List<SupportTicketModel>> getTickets(String? role) {
    Query query = _firestore.collection('support_tickets').orderBy('createdAt', descending: true);
    if (role != null) {
      query = query.where('senderRole', isEqualTo: role);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return SupportTicketModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  @override
  Future<void> replyToTicket(String ticketId, String reply) async {
    await _firestore.collection('support_tickets').doc(ticketId).update({
      'reply': reply,
      'status': 'In Progress',
    });
  }

  @override
  Future<void> markAsResolved(String ticketId) async {
    await _firestore.collection('support_tickets').doc(ticketId).update({
      'status': 'Resolved',
    });
  }
}
