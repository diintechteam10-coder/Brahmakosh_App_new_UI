Brahmakosh Chat Application - User API Documentation

Base URL: https://stage.brahmakosh.com
WebSocket URL: wss://stage.brahmakosh.com/socket.io/
Generated: February 10, 2026

Table of Contents
· Overview & Authentication
· REST API Endpoints
· Get Available Partners
· Conversation Management
· Message Management
· Credits Management
· WebSocket Events
· Connection & Authentication
· Join & Leave Conversation Rooms
· Real-time Messaging
· Message Delivery & Read Status
· Typing Indicators
· Notifications
· Partner Status Changes
· Error Handling
· Example Integration Flow

Overview & Authentication
This document provides technical documentation for user-side integration with the Brahmakosh Chat Application. The application enables real-time communication between users and astrology partners through a hybrid approach combining REST APIs for data operations and WebSocket for real-time features.
Key Features
· Real-time messaging with astrology partners
· Conversation request and management
· Credit-based billing (4 credits per minute)
· Typing indicators and read receipts
· Partner availability tracking
· Message history and pagination
Authentication
All API requests and WebSocket connections require JWT authentication.
REST API Authentication
Include the JWT token in the Authorization header:
Authorization: Bearer YOUR_JWT_TOKEN
WebSocket Authentication
Pass the token during Socket.IO connection initialization:
const socket = io('wss://stage.brahmakosh.com', {
path: '/socket.io/',
auth: { token: 'YOUR_JWT_TOKEN' },
transports: ['websocket']
});
Token Requirements
· Token must be valid JWT signed with server's JWT_SECRET
· Token must contain: userId and role ('user')
· Token should not be expired

REST API Endpoints
All endpoints use the base URL: https://stage.brahmakosh.com/api/chat
Get Available Partners
GET /partners
Description: Get all available partners for consultation
Authorization: Required
Response (200 OK)
{
"success": true,
"data": [
{
"_id": "partner123",
"name": "Astrologer Ram",
"email": "ram@example.com",
"phone": "+919876543210",
"profilePicture": "https://...",
"bio": "Expert in Vedic Astrology...",
"specialization": ["Vedic Astrology", "Numerology"],
"rating": 4.5,
"totalSessions": 150,
"experience": 10,
"onlineStatus": "online",
"activeConversationsCount": 2,
"maxConversations": 5,
"canAcceptConversation": true,
"availableSlots": 3
}
]
}

Conversation Management
Create Conversation
POST /conversations
Description: Initiate a chat with a partner
Authorization: Required (User only)
Request Body:
{
"partnerId": "partner123",
"userAstrologyData": {
"name": "John Doe",
"dateOfBirth": "1990-01-15",
"timeOfBirth": "14:30",
"placeOfBirth": "Mumbai",
"zodiacSign": "Capricorn",
"additionalInfo": {
"concerns": "Career and marriage",
"questions": ["When will I get married?"],
"specificTopics": ["Career", "Marriage"]
}
}
}
Response (201 Created):
{
"success": true,
"message": "Conversation request sent to partner",
"data": {
"_id": "conv123",
"conversationId": "conv_1707307200000_user456_partner123",
"partnerId": "partner123",
"userId": "user456",
"status": "pending",
"isAcceptedByPartner": false,
"createdAt": "2026-02-07T10:00:00.000Z"
}
}

End Conversation
PATCH /conversations/:conversationId/end
Description: End an active conversation and calculate billing
Authorization: Required
Response (200 OK):
{
"success": true,
"message": "Conversation ended successfully",
"data": {
"conversationId": "conv_1707307200000_user456_partner123",
"status": "ended",
"endedAt": "2026-02-07T11:00:00.000Z",
"sessionDetails": {
"duration": 55,
"messagesCount": 42,
"creditsUsed": 220,
"userRatePerMinute": 4
},
"billing": {
"userDebited": 220,
"userRemainingCredits": 780
}
}
}
Get All Conversations
GET /conversations
Description: Get all conversations for current user
Authorization: Required
Query Parameters:
· status (optional): 'pending', 'accepted', 'active', 'ended'
Response (200 OK):
{
"success": true,
"data": [
{
"_id": "conv123",
"conversationId": "conv_1707307200000_user456_partner123",
"partnerId": { ... },
"userId": { ... },
"status": "active",
"lastMessage": {
"content": "Thank you for the consultation",
"createdAt": "2026-02-07T10:55:00.000Z"
},
"unreadCount": {
"user": 0
},
"createdAt": "2026-02-07T10:00:00.000Z"
}
]
}

Message Management
Get Messages
GET /conversations/:conversationId/messages
Description: Get paginated messages for a conversation
Authorization: Required
Query Parameters:
· page (default: 1)
· limit (default: 50)
Response (200 OK):
{
"success": true,
"data": {
"messages": [
{
"_id": "msg123",
"conversationId": "conv_1707307200000_user456_partner123",
"senderId": "user456",
"receiverId": "partner123",
"senderModel": "User",
"receiverModel": "Partner",
"messageType": "text",
"content": "Hello, I need help with my horoscope",
"isDelivered": true,
"deliveredAt": "2026-02-07T10:10:00.000Z",
"isRead": true,
"readAt": "2026-02-07T10:11:00.000Z",
"createdAt": "2026-02-07T10:10:00.000Z"
}
],
"pagination": {
"currentPage": 1,
"totalPages": 3,
"totalMessages": 125,
"limit": 50
}
}
}

Credits Management
Get Credit Balance
GET /credits/balance/user
Description: Get current user's credit balance
Authorization: Required
Response (200 OK):
{
"success": true,
"data": {
"userId": "user456",
"credits": 1000,
"lastUpdated": "2026-02-07T10:00:00.000Z"
}
}
Get Credit History
GET /credits/history/user
Description: Get user's credit usage history
Authorization: Required
Query Parameters:
· page (optional)
· limit (optional)
Response (200 OK):
{
"success": true,
"data": [
{
"conversationId": "conv_1707307200000_user456_partner123",
"billableMinutes": 55,
"creditsUsed": 220,
"createdAt": "2026-02-07T11:00:00.000Z",
"partner": { ... }
}
],
"meta": {
"page": 1,
"limit": 20,
"total": 45,
"totalPages": 3
}
}

WebSocket Events
WebSocket URL: wss://stage.brahmakosh.com/socket.io/
Protocol: Socket.IO v4.x
Connection & Authentication
Connecting to WebSocket:
import { io } from 'socket.io-client';

const socket = io('wss://stage.brahmakosh.com', {
path: '/socket.io/',
auth: { token: 'YOUR_JWT_TOKEN' },
transports: ['websocket'],
reconnection: true,
reconnectionAttempts: 5,
reconnectionDelay: 1000
});

// Connection successful
socket.on('connect', () => {
console.log('Connected:', socket.id);
});

// Connection error
socket.on('connect_error', (error) => {
console.error('Connection error:', error.message);
});
Connection Success Event
Event: connection:success
Emitted when connection is established successfully
{
"message": "Connected successfully",
"userId": "user456",
"userType": "user",
"socketId": "abc123xyz",
"timestamp": "2026-02-07T10:00:00.000Z"
}

Join & Leave Conversation Rooms
Join Conversation
Client Emit: conversation:join
Join a conversation room to receive real-time updates
socket.emit('conversation:join', {
conversationId: 'conv_1707307200000_user456_partner123'
}, (response) => {
console.log(response);
});
Server Response:
{
"success": true,
"message": "Joined conversation room",
"conversationId": "conv_1707307200000_user456_partner123"
}
Leave Conversation
Client Emit: conversation:leave
socket.emit('conversation:leave', {
conversationId: 'conv_1707307200000_user456_partner123'
}, (response) => {
console.log(response);
});

Real-time Messaging
Send Message
Client Emit: message:send
socket.emit('message:send', {
conversationId: 'conv_1707307200000_user456_partner123',
messageType: 'text',
content: 'Hello, I need help with my horoscope',
mediaUrl: null
}, (response) => {
if (response.success) {
console.log('Message sent:', response.message);
}
});
Server Response:
{
"success": true,
"message": {
"_id": "msg123",
"conversationId": "conv_1707307200000_user456_partner123",
"senderId": {
"_id": "user456",
"name": "John Doe",
"email": "john@example.com"
},
"messageType": "text",
"content": "Hello, I need help with my horoscope",
"isDelivered": false,
"isRead": false,
"createdAt": "2026-02-07T10:10:00.000Z"
}
}
Receive New Message
Server Emit: message:new
Broadcast to all users in the conversation room when a new message is sent
socket.on('message:new', (data) => {
console.log('New message:', data.message);
// Update UI with new message
});
Event Data:
{
"conversationId": "conv_1707307200000_user456_partner123",
"message": {
"_id": "msg123",
"senderId": { ... },
"content": "Hello, I need help...",
"createdAt": "2026-02-07T10:10:00.000Z"
}
}

Message Delivery & Read Status
Message Delivered
Server Emit: message:delivered
Sent to message sender when receiver is online and message is delivered
socket.on('message:delivered', (data) => {
console.log('Message delivered:', data);
// Update message UI to show delivered status
});
Event Data:
{
"messageId": "msg123",
"conversationId": "conv_1707307200000_user456_partner123",
"deliveredAt": "2026-02-07T10:10:05.000Z"
}
Mark Messages as Read
Client Emit: message:read
Mark messages as read when user views them
// Mark specific messages as read
socket.emit('message:read', {
conversationId: 'conv_1707307200000_user456_partner123',
messageIds: ['msg123', 'msg124', 'msg125']
}, (response) => {
console.log(response);
});

// OR mark all messages in conversation as read
socket.emit('message:read', {
conversationId: 'conv_1707307200000_user456_partner123'
}, (response) => {
console.log(response);
});
Read Receipt
Server Emit: message:read:receipt
Sent to message sender when receiver reads messages
socket.on('message:read:receipt', (data) => {
console.log('Messages read:', data);
// Update UI to show read status
});
Event Data:
{
"conversationId": "conv_1707307200000_user456_partner123",
"messageIds": ["msg123", "msg124"],
"readBy": "partner123",
"readAt": "2026-02-07T10:15:00.000Z"
}

Typing Indicators
Start Typing
Client Emit: typing:start
socket.emit('typing:start', {
conversationId: 'conv_1707307200000_user456_partner123'
});
Stop Typing
Client Emit: typing:stop
socket.emit('typing:stop', {
conversationId: 'conv_1707307200000_user456_partner123'
});
Typing Status
Server Emit: typing:status
Broadcast to other users in conversation when someone is typing
socket.on('typing:status', (data) => {
if (data.isTyping) {
console.log('Partner is typing...');
} else {
console.log('Partner stopped typing');
}
});
Event Data:
{
"conversationId": "conv_1707307200000_user456_partner123",
"userId": "partner123",
"userType": "partner",
"isTyping": true,
"timestamp": "2026-02-07T10:12:00.000Z"
}

Notifications
New Message Notification
Server Emit: notification:new:message
Sent to user when they receive a new message while online but not in the conversation room
socket.on('notification:new:message', (data) => {
console.log('New message notification:', data);
// Show notification banner
});
Event Data:
{
"conversationId": "conv_1707307200000_user456_partner123",
"message": {
"id": "msg123",
"content": "Hello, I need help with...",
"senderName": "Astrologer Ram",
"timestamp": "2026-02-07T10:10:00.000Z"
}
}
Partner Status Changes
Server Emit: partner:status:changed
Broadcast to all users when a partner's online status changes
socket.on('partner:status:changed', (data) => {
console.log('Partner status changed:', data);
// Update partner's status in UI
});
Event Data:
{
"partnerId": "partner123",
"status": "online" | "offline" | "busy",
"timestamp": "2026-02-07T10:30:00.000Z"
}

Error Handling
All API responses follow a consistent error format:
{
"success": false,
"message": "Error description",
"error": "ERROR_CODE"
}
Common Error Codes
· UNAUTHORIZED: Invalid or missing authentication token
· FORBIDDEN: User doesn't have permission for this action
· NOT_FOUND: Resource not found
· INVALID_INPUT: Request validation failed
· INSUFFICIENT_CREDITS: Not enough credits for operation
· PARTNER_UNAVAILABLE: Partner is offline or busy

Example Integration Flow
1. Initialize Connection
   const socket = io('wss://stage.brahmakosh.com', {
   path: '/socket.io/',
   auth: { token: userJwtToken },
   transports: ['websocket']
   });
2. Get Available Partners
   const response = await fetch('https://stage.brahmakosh.com/api/chat/partners', {
   headers: { 'Authorization': `Bearer ${userJwtToken}` }
   });
   const partners = await response.json();
3. Create Conversation
   const conversation = await fetch('https://stage.brahmakosh.com/api/chat/conversations', {
   method: 'POST',
   headers: {
   'Authorization': `Bearer ${userJwtToken}`,
   'Content-Type': 'application/json'
   },
   body: JSON.stringify({
   partnerId: selectedPartnerId,
   userAstrologyData: { ... }
   })
   });
4. Join Conversation Room
   socket.emit('conversation:join', {
   conversationId: conversation.data.conversationId
   });
5. Listen for Messages
   socket.on('message:new', (data) => {
   displayMessage(data.message);
   });
6. Send Messages
   socket.emit('message:send', {
   conversationId: currentConversationId,
   messageType: 'text',
   content: messageText
   });
7. End Conversation
   await fetch(`https://stage.brahmakosh.com/api/chat/conversations/${conversationId}/end`, {
   method: 'PATCH',
   headers: { 'Authorization': `Bearer ${userJwtToken}` }
   });

© 2026 Brahmakosh. All rights reserved.
