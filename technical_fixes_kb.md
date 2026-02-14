# Chat System Technical Documentation - Deep Dive

This document provides an exhaustive technical breakdown of the fixes implemented to stabilize the Brahmakosh Astrology Chat system.

---

## 1. Duplicate Message Prevention (Multi-Layer Strategy)

### The Problem
Messages were appearing multiple times due to the "Race Condition" between the **Optimistic UI** (local addition) and the **Socket Broadcast** (server reply). When a user sends a message, it is added immediately to the list for a "snappy" feel. Milliseconds later, the socket sends the same message back, causing a duplicate if the IDs don't match or the logic is too slow.

### The Technical Solution
1.  **Fuzzy Deduplication (Live)**:
    - Located in `AstrologyChatController._onNewMessage`.
    - Instead of just checking IDs, we use a **Content + Time Hash**.
    - If a message arrives with the identical `content` as a message sent by the user in the last **2 seconds**, it is discarded as a socket echo of an optimistic message.
2.  **HyperScrub (Fetch Logic)**:
    - Located in `_fetchMessages`.
    - When loading history from the API, we pass the data through a `Map<String, ChatMessage> idMap`.
    - Since map keys are unique, this automatically collapses duplicates at the data level before they ever hit the reactive `messages` list.
3.  **Socket Listener Idempotency**:
    - In `SocketService.dart`, every `.on()` call is preceded by an `.off()` to ensure that even if the connection fluctuates, we don't end up with two active listeners for the same event name.

---

## 2. In-App Notification Restoration

### The Problem
Global listeners for message notifications were losing their "binding" when the socket disconnected and reconnected, leading to missed banners when the user wasn't on the chat screen.

### The Technical Solution
- **GetXService Lifecycle**: The `ChatNotificationService` is a singleton `GetXService` that initializes on app start.
- **Unified Binding**: We moved the registration of `notification:new:message` into a protected method called during `initSocket`. This ensures that every time the socket establishes a new physical connection, the notification handlers are re-injected.
- **Context Awareness**: The service tracks the `_activeConversationId`. If the user is currently on the chat screen for *Expert A*, the banner for *Expert A* is suppressed to avoid redundancy, while banners for *Expert B* are still permitted.

---

## 3. Dynamic Credit Check (402 Error)

### The Problem
A hardcoded constraint of ₹100 prevented users with ₹80 from chatting with experts who only charged ₹10/min. This led to a 402 "Insufficient Credits" error from the backend.

### The Technical Solution
- **Dynamic Gatekeeping**: In `astrology_experts_view.dart`, we implemented a business rule: **"User must have enough balance for 5 minutes of consultation."**
- **Calculation**: `minRequired = (expert.chatCharge) * 5`.
- **User Experience**: This approach is "Expert-Aware." It lowers the barrier for entry while still protecting the expert's time by ensuring a meaningful baseline session duration.

---

## 4. Hybrid Read Receipt Sync (Blue Ticks)

### The Problem
Read receipts (blue ticks) are traditionally handled via real-time socket events. However, mobile devices often "sleep" or deprioritize socket connections, leading to "stuck" grey ticks even when the expert has read the message.

### The Technical Solution
- **Implicit Marking**: In the controller, we added a logic block: *If the expert replies, verify that all previous user messages are marked as read.* This is biologically/logically sound—an expert cannot reply without having read the message.
- **Periodic Sync (The Fail-Safe)**:
    - Added `_msgSyncTimer` (8-second interval).
    - Even if all socket events fail, this timer performs a silent background `GET` request to the messages API.
    - Since the API is the source of truth, the UI "rectifies" itself automatically within seconds.
- **Event Aliasing**: `SocketService` was updated to listen for both `message:read` and `message:read:receipt` to ensure compatibility with different backend microservices.

---

## 5. Unread Message Counter Architecture

### The Problem
The unread count needs to be consistent across the Home Screen (Badge), History Screen (List), and the Top Bar.

### The Technical Solution
- **Reactive Stream**: `ChatHistoryController` holds a reactive `unreadCount` observable.
- **Cross-Service Communication**:
    - Whenever `ChatNotificationService` receives a message, it calls `historyController.fetchUnreadCount()`.
    - Whenever a user opens a chat, the `AstrologyChatController` calls the same refresh after the "Mark as Read" API call.
- **Centralized Logic**: By keeping the unread count in a dedicated history controller, we avoid duplicate API calls and ensure that one "fetch" updates every badge in the app simultaneously.

---
**Maintained by**: Antigravity Technical Docs
**Last Updated**: 2026-02-14
