import 'package:flutter/material.dart';

import '../models/sweet_craft_request.dart';
import '../services/sweet_craft_service.dart';
import 'sweet_craft_final_offer_screen.dart';

class SweetCraftChatScreen extends StatefulWidget {
  final String requestId;
  final String applicationId;

  const SweetCraftChatScreen({
    super.key,
    required this.requestId,
    required this.applicationId,
  });

  @override
  State<SweetCraftChatScreen> createState() => _SweetCraftChatScreenState();
}

class _SweetCraftChatScreenState extends State<SweetCraftChatScreen> {
  final messageController = TextEditingController();

  final List<Map<String, dynamic>> messages = [
    {
      'sender': 'seller',
      'message': 'Hi! Thank you for selecting our shop. We would love to create this for you.',
    },
    {
      'sender': 'customer',
      'message':
          'Thank you! Can we make the gold details slightly more subtle?',
    },
    {
      'sender': 'seller',
      'message': 'Absolutely. We can adjust the design and keep the main theme elegant.',
    },
  ];

  @override
  void initState() {
    super.initState();

    SweetCraftService.instance.updateRequestStatus(
      widget.requestId,
      SweetCraftRequestStatus.negotiating,
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = SweetCraftService.instance;

    final application = service.applications.firstWhere(
      (application) => application.id == widget.applicationId,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              application.shopName,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Private negotiation',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SweetCraftFinalOfferScreen(
                    requestId: widget.requestId,
                    applicationId: widget.applicationId,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: 'Final Offer',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(18, 14, 18, 4),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE6EE),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_outline, color: Color(0xFFE91E63), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'This is a private chat between you and the selected seller.',
                    style: TextStyle(fontSize: 12, height: 1.4),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(18),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isCustomer = message['sender'] == 'customer';

                return Align(
                  alignment: isCustomer
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 300),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isCustomer
                          ? const Color(0xFFE91E63)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      message['message'],
                      style: TextStyle(
                        color: isCustomer ? Colors.white : Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            color: Colors.white,
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Write a message...',
                        filled: true,
                        fillColor: const Color(0xFFFFF3F7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: const Color(0xFFE91E63),
                    child: IconButton(
                      onPressed: _sendMessage,
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 19,
                      ),
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

  void _sendMessage() {
    final text = messageController.text.trim();

    if (text.isEmpty) {
      return;
    }

    setState(() {
      messages.add({'sender': 'customer', 'message': text});
    });

    messageController.clear();
  }
}
