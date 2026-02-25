import '../models/notification_model.dart';

class DummyNotifications {
  static List<NotificationModel> getAll() {
    final now = DateTime.now();
    return [
      // ===== TODAY =====

      // 1. Daily Astrology
      NotificationModel(
        id: '1',
        title: 'Daily Numerology Insight',
        body:
            'Your life path number 7 brings deep reflection today. Trust your inner wisdom.',
        description:
            'Today your numerology number 7 aligns with the energy of deep introspection and spiritual awareness. The universe is guiding you to trust your inner voice.\n\nKey Insights:\n• Lucky Number: 7\n• Lucky Color: Indigo\n• Best Time: 3:00 PM – 5:00 PM\n\nEmbrace solitude today for clarity. Meditation will bring powerful breakthroughs.',
        createdAt: now.subtract(const Duration(minutes: 30)),
        isRead: false,
        category: NotificationCategory.dailyAstrology,
      ),

      // 6. Spiritual Check-In
      NotificationModel(
        id: '2',
        title: 'Daily Check-In Reminder',
        body:
            'Start your morning with a moment of gratitude. Your spiritual journey awaits.',
        description:
            'Good morning! A quick check-in with yourself can set the tone for a beautiful day.\n\nToday\'s Check-In Prompt:\n"What am I grateful for right now?"\n\nTaking just 2 minutes to reflect can align your energy and set positive intentions. Your daily streak is active — keep the momentum going!',
        createdAt: now.subtract(const Duration(hours: 1)),
        isRead: false,
        category: NotificationCategory.spiritualCheckIn,
      ),

      // 8. Remedies
      NotificationModel(
        id: '3',
        title: "Today's Suggested Remedy",
        body: 'Light a ghee diya during sunset for inner peace and clarity.',
        description:
            'Remedy of the Day: Ghee Diya at Sunset\n\nLighting a pure ghee lamp during sunset is a powerful Vedic remedy that brings:\n• Mental clarity and peace\n• Removal of negative energies\n• Alignment with evening cosmic vibrations\n\nHow to perform:\n1. Use a brass or clay lamp\n2. Add pure cow ghee\n3. Light it facing East\n4. Sit in silence for 5 minutes\n\nThis simple remedy can transform your evening energy.',
        createdAt: now.subtract(const Duration(hours: 2)),
        isRead: true,
        category: NotificationCategory.remedies,
      ),

      // 9. AI Intuition
      NotificationModel(
        id: '4',
        title: 'New Insight Based on Your Pattern',
        body:
            'We noticed increased spiritual activity this week. Your energy alignment is improving!',
        description:
            'Brahmakosh Intelligence has analyzed your recent patterns:\n\n📊 Your Spiritual Score This Week: 78/100 (↑12 from last week)\n\nKey Observations:\n• You\'ve been consistent with morning check-ins\n• Your meditation time has increased by 15 minutes\n• Remedy completion rate is at 85%\n\nPersonalized Suggestion:\nConsider adding a 5-minute breathwork session before sleep. Based on your pattern, this could boost your clarity score significantly.\n\nKeep up the beautiful work! 🌟',
        createdAt: now.subtract(const Duration(hours: 3)),
        isRead: false,
        category: NotificationCategory.aiIntuition,
      ),

      // 1. Daily Astrology - Panchang
      NotificationModel(
        id: '5',
        title: 'Panchang Summary',
        body:
            'Tithi: Shukla Dashami | Nakshatra: Rohini | Yoga: Siddha — An auspicious day ahead.',
        description:
            'Today\'s Panchang Details:\n\n📅 Date: ${now.day}/${now.month}/${now.year}\n🌙 Tithi: Shukla Dashami\n⭐ Nakshatra: Rohini\n🧘 Yoga: Siddha\n📿 Karana: Bava\n\nShubh Muhurat: 9:15 AM – 10:45 AM\nRahu Kaal: 1:30 PM – 3:00 PM (avoid starting new tasks)\n\nThis is a day of growth and prosperity. Rohini Nakshatra brings stability and creative energy. Ideal for starting spiritual practices.',
        createdAt: now.subtract(const Duration(hours: 4)),
        isRead: true,
        category: NotificationCategory.dailyAstrology,
      ),

      // ===== THIS WEEK =====

      // 12. Emotional / Companion
      NotificationModel(
        id: '6',
        title: 'You are not alone.',
        body:
            'Remember, every step you take on this path matters. We believe in your journey.',
        description:
            'Dear seeker,\n\nIn moments of doubt, remember that the universe has placed you exactly where you need to be. Your spiritual journey is unique and beautiful.\n\n"The soul that is practicing patience is very close to enlightenment."\n\nWe\'re here with you — every step, every breath, every moment. Take a deep breath and know that you are supported.\n\nWith love,\nTeam Brahmakosh 🙏',
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: false,
        category: NotificationCategory.emotionalCompanion,
      ),

      // 5. Missed Activity
      NotificationModel(
        id: '7',
        title: 'Your streak is waiting',
        body:
            'You haven\'t checked-in today. A moment of reflection can make all the difference.',
        description:
            'Hey there! 🌸\n\nWe noticed you haven\'t done your daily check-in yet. No pressure — but your 14-day streak is still active and waiting for you!\n\nA 2-minute check-in can:\n• Reset your mental compass\n• Build consistency in your practice\n• Strengthen your energy alignment\n\nTap below to continue your streak. Even a small step counts! 💫',
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
        isRead: true,
        category: NotificationCategory.missedActivity,
      ),

      // 2. Offer
      NotificationModel(
        id: '8',
        title: 'Festival Special — 30% Off Rudraksha',
        body:
            'Authentic 5 Mukhi Rudraksha now available at a special festival price. Limited stock!',
        description:
            '🪔 Festival Special Offer!\n\nAuthentic 5 Mukhi Rudraksha Mala\n\n✅ Energized & Lab-Certified\n✅ Original Nepal Origin\n✅ Comes with Puja Guide\n\nOriginal Price: ₹2,499\nFestival Price: ₹1,749 (30% OFF)\n\nValid till: ${now.add(const Duration(days: 3)).day}/${now.add(const Duration(days: 3)).month}/${now.add(const Duration(days: 3)).year}\n\nLimited stock available. Don\'t miss this divine opportunity!\n\nVisit BrahmaBazaar to order now.',
        createdAt: now.subtract(const Duration(days: 2)),
        isRead: false,
        category: NotificationCategory.offer,
      ),

      // 6. Spiritual Check-In - Streak
      NotificationModel(
        id: '9',
        title: 'Streak Milestone — 21 Days! 🎉',
        body:
            'You\'ve completed 21 consecutive days of spiritual check-ins. Keep the divine energy flowing!',
        description:
            'Congratulations! 🌟\n\nYou\'ve achieved the 21-Day Streak Milestone!\n\nThis is a significant spiritual achievement:\n• 21 days is known to build a habit\n• Your consistency shows deep commitment\n• Your energy pattern has improved by 34%\n\nReward Earned: 50 Brahma Points 🎁\n\nNext milestone: 108 Days\n"What we repeatedly do, defines who we become."\n\nNamaste 🙏',
        createdAt: now.subtract(const Duration(days: 2, hours: 5)),
        isRead: true,
        category: NotificationCategory.spiritualCheckIn,
      ),

      // 4. New Launch / Feature
      NotificationModel(
        id: '10',
        title: 'New Feature: Swapna Decoder',
        body:
            'Decode your dreams with AI-powered Vedic interpretation. Try it now!',
        description:
            '🆕 Introducing Swapna Decoder!\n\nNow you can decode the spiritual significance of your dreams using advanced Vedic wisdom combined with AI.\n\nWhat you can do:\n• Record your dream narratives\n• Get Vedic interpretations\n• Discover spiritual messages hidden in your dreams\n• Track recurring patterns\n\nThis is a groundbreaking feature that blends ancient wisdom with modern intelligence.\n\nTap to explore Swapna Decoder now!',
        createdAt: now.subtract(const Duration(days: 3)),
        isRead: false,
        category: NotificationCategory.newLaunchFeature,
      ),

      // 7. Critical Alert
      NotificationModel(
        id: '11',
        title: 'Major Planetary Transit: Jupiter enters Taurus',
        body:
            'Jupiter is moving into Taurus. This brings growth, stability, and new opportunities.',
        description:
            '🪐 Important Planetary Transit Alert\n\nJupiter (Guru) is transitioning into Taurus (Vrishabha) — a significant cosmic event that happens once every 12 years.\n\nWhat this means for you:\n• Period of financial stability and growth\n• Time for grounding spiritual practices\n• Creative energy will be enhanced\n• Relationships deepen with trust\n\nRecommended actions:\n1. Offer yellow flowers at your altar\n2. Wear yellow or gold on Thursdays\n3. Begin a 40-day Jupiter mantra practice\n\nMantra: "Om Gurave Namaha"\n\nThis is a positive transit — embrace the energy of abundance!',
        createdAt: now.subtract(const Duration(days: 3, hours: 8)),
        isRead: true,
        category: NotificationCategory.criticalAlert,
      ),

      // 11. Rewards
      NotificationModel(
        id: '12',
        title: 'Brahma Rewards Earned',
        body:
            'You\'ve earned 25 Brahma Points for completing your weekly remedies.',
        description:
            '🎁 Reward Update!\n\n+25 Brahma Points earned!\n\nReason: Weekly Remedy Completion\n\nYour Total Points: 350\n\nRedeemable Rewards:\n• 100 pts → Free Panchang Report\n• 250 pts → Personalized Numerology Report\n• 500 pts → 1-on-1 Astrologer Session\n\nKeep completing your spiritual activities to earn more points. Every action counts!',
        createdAt: now.subtract(const Duration(days: 4)),
        isRead: true,
        category: NotificationCategory.rewards,
      ),

      // 3. Survey / Feedback
      NotificationModel(
        id: '13',
        title: 'How was your Astrologer session?',
        body:
            'Your feedback helps us serve you better. Rate your recent session.',
        description:
            'We\'d love to hear about your experience!\n\nYour recent session with Pt. Ravi Sharma:\n📅 Date: ${now.subtract(const Duration(days: 5)).day}/${now.subtract(const Duration(days: 5)).month}/${now.subtract(const Duration(days: 5)).year}\n⏱ Duration: 25 minutes\n\nPlease rate:\n⭐ Knowledge & Accuracy\n⭐ Communication\n⭐ Overall Satisfaction\n\nYour honest feedback helps:\n• Improve astrologer quality\n• Enhance your future sessions\n• Support our spiritual community\n\nTap to share your rating.',
        createdAt: now.subtract(const Duration(days: 4, hours: 6)),
        isRead: false,
        category: NotificationCategory.surveyFeedback,
      ),

      // ===== EARLIER =====

      // 10. Special Occasion
      NotificationModel(
        id: '14',
        title: 'Happy Birthday! 🎂 A Special Blessing for You',
        body:
            'May this new year of your life bring divine blessings and spiritual growth.',
        description:
            '🌸 Happy Birthday, Dear Soul! 🌸\n\nOn this special day, the universe celebrates your existence.\n\nBirthday Blessing:\n"May the divine light guide your path, may every breath bring you closer to truth, and may this new year of your life be filled with peace, prosperity, and spiritual awakening."\n\nYour Birthday Remedy:\n• Light a lamp at sunrise\n• Donate food to those in need\n• Begin a new mantra practice\n\nSpecial Gift: 100 Bonus Brahma Points 🎁\n\nWith love and light,\nTeam Brahmakosh 🙏',
        createdAt: now.subtract(const Duration(days: 8)),
        isRead: true,
        category: NotificationCategory.specialOccasion,
      ),

      // 13. Payment
      NotificationModel(
        id: '15',
        title: 'Subscription Renewal Reminder',
        body:
            'Your Brahmakosh Premium subscription renews in 3 days. Manage your plan.',
        description:
            '💳 Subscription Renewal Notice\n\nYour Brahmakosh Premium plan is up for renewal.\n\nPlan: Premium Monthly\nAmount: ₹299/month\nRenewal Date: ${now.add(const Duration(days: 3)).day}/${now.add(const Duration(days: 3)).month}/${now.add(const Duration(days: 3)).year}\nPayment Method: UPI (xxx@oksbi)\n\nPremium Benefits:\n• Unlimited AI Intuition insights\n• Priority astrologer sessions\n• Ad-free experience\n• Exclusive remedies & reports\n\nTo manage or cancel, visit your profile settings.',
        createdAt: now.subtract(const Duration(days: 10)),
        isRead: true,
        category: NotificationCategory.paymentRequest,
      ),

      // 14. App Update
      NotificationModel(
        id: '16',
        title: 'New Version Available — v2.5.0',
        body:
            'Updated with Swapna Decoder, improved check-in flow, and bug fixes.',
        description:
            '📱 Brahmakosh v2.5.0 is here!\n\nWhat\'s New:\n• 🆕 Swapna Decoder — AI Dream Interpretation\n• ✨ Improved Check-In Experience\n• 🔧 Performance improvements\n• 🐛 Bug fixes\n\nWhy update?\n• Faster app loading\n• Smoother animations\n• New spiritual features\n• Enhanced security\n\nUpdate now to get the best experience!',
        createdAt: now.subtract(const Duration(days: 12)),
        isRead: true,
        category: NotificationCategory.appUpdate,
      ),

      // 8. Remedies - Completion
      NotificationModel(
        id: '17',
        title: 'Remedy Cycle Complete ✅',
        body:
            'You\'ve completed the 7-day Surya Namaskar remedy cycle. Well done!',
        description:
            '🎉 Remedy Cycle Completed!\n\nRemedy: 7-Day Surya Namaskar at Sunrise\nStatus: ✅ Complete\nDuration: 7 of 7 days\n\nBenefits gained:\n• Enhanced solar energy absorption\n• Improved physical vitality\n• Strengthened spiritual discipline\n• +15 Brahma Points earned\n\nNext Suggested Remedy:\n"11-Day Hanuman Chalisa Recitation"\n\nYour dedication to spiritual practice is truly inspiring! 🙏',
        createdAt: now.subtract(const Duration(days: 14)),
        isRead: true,
        category: NotificationCategory.remedies,
      ),

      // 12. Emotional
      NotificationModel(
        id: '18',
        title: 'Gentle Support Message',
        body:
            'Life is a journey, not a destination. Take a moment to breathe and be present.',
        description:
            '🌿 A Moment of Peace\n\n"In the middle of everything, there is space. In the space, there is peace. In the peace, there is you."\n\nToday\'s gentle reminder:\n• You don\'t have to have it all figured out\n• Every small step is progress\n• Your presence on this path matters\n\nTry this: Close your eyes, take 3 deep breaths, and smile. Feel the warmth of being alive.\n\nWe\'re always here if you need us. 💛\n\nWith care,\nBrahmakosh Companion',
        createdAt: now.subtract(const Duration(days: 15)),
        isRead: true,
        category: NotificationCategory.emotionalCompanion,
      ),

      // 5. Missed Activity
      NotificationModel(
        id: '19',
        title: 'We miss you 🌸',
        body:
            'It\'s been a while since your last visit. Your spiritual journey is waiting.',
        description:
            'Hello dear soul,\n\nWe noticed it\'s been 5 days since your last visit. We hope everything is well!\n\nHere\'s what you\'ve missed:\n• 3 Daily Insights\n• 2 New Remedies\n• 1 AI Intuition Alert\n• Your streak was paused\n\nComing back takes just a moment, and it can make a world of difference.\n\n"The best time to plant a tree was 20 years ago. The second best time is now."\n\nWe\'re here whenever you\'re ready. No judgment, only love. 🌷',
        createdAt: now.subtract(const Duration(days: 18)),
        isRead: true,
        category: NotificationCategory.missedActivity,
      ),

      // 2. Offer - Course
      NotificationModel(
        id: '20',
        title: 'Course Discount — Learn Vedic Astrology',
        body:
            'Enroll in our Vedic Astrology Foundation course at 40% off. Limited seats!',
        description:
            '📚 Learning Opportunity!\n\nVedic Astrology Foundation Course\n\nInstructor: Acharya Pradeep Ji\nDuration: 8 Weeks (Online)\nLanguage: Hindi & English\n\nWhat you\'ll learn:\n• Birth Chart Reading Basics\n• Planetary Significance\n• Nakshatra & Dasha Analysis\n• Practical Prediction Methods\n\nOriginal Price: ₹4,999\nOffer Price: ₹2,999 (40% OFF)\n\nLimited to 50 seats only.\n\nVisit BrahmaBazaar → Courses to enroll.',
        createdAt: now.subtract(const Duration(days: 20)),
        isRead: true,
        category: NotificationCategory.offer,
      ),

      // 9. AI Intuition
      NotificationModel(
        id: '21',
        title: 'Reflection Prompt',
        body:
            'What intention are you setting for this lunar cycle? Journal your thoughts.',
        description:
            '🤖 AI Reflection Prompt\n\nBased on the current lunar cycle and your recent activity patterns, here\'s a deep reflection question for you:\n\n"What is one belief that no longer serves your growth?"\n\nWhy this matters:\n• The waning moon is ideal for release\n• Your pattern shows readiness for transformation\n• Journaling activates subconscious clarity\n\nTake 10 minutes today to write freely about this prompt. You might discover something profound.\n\n📝 Open your Brahmakosh Journal to begin.',
        createdAt: now.subtract(const Duration(days: 22)),
        isRead: true,
        category: NotificationCategory.aiIntuition,
      ),

      // 11. Rewards - Seva
      NotificationModel(
        id: '22',
        title: 'Seva Contribution Update',
        body:
            'Your contributions have helped 12 people access free astrology sessions this month.',
        description:
            '🙏 Seva Impact Report\n\nYour kindness is making a difference!\n\nThis Month\'s Impact:\n• 12 people received free astrology guidance\n• 5 spiritual courses were sponsored\n• 3 families received Puja materials\n\nYour Total Seva Score: 245 points\nImpact Level: 🌟 Golden Contributor\n\n"Service to others is the rent you pay for your room here on Earth." — Muhammad Ali\n\nThank you for being a light in someone\'s life. 💫',
        createdAt: now.subtract(const Duration(days: 25)),
        isRead: true,
        category: NotificationCategory.rewards,
      ),

      // 4. New Launch
      NotificationModel(
        id: '23',
        title: 'Major App Announcement',
        body:
            'Brahmakosh 3.0 roadmap revealed! Exciting spiritual features coming soon.',
        description:
            '📢 Big Announcement!\n\nBrahmakosh 3.0 Roadmap:\n\nComing Soon:\n• 🧘 Live Group Meditation Sessions\n• 📿 AR Temple Visit Experience\n• 🤖 Enhanced AI Guru — voice-based spiritual guidance\n• 🌐 Multi-language support (10+ languages)\n• 🎵 Vedic Sound Healing Library\n\nTimeline: Next 3 months\n\nWe\'re building the future of spiritual technology, and you\'re part of this journey!\n\nStay tuned for updates. 🚀',
        createdAt: now.subtract(const Duration(days: 28)),
        isRead: true,
        category: NotificationCategory.newLaunchFeature,
      ),
    ];
  }

  static int getUnreadCount() {
    return getAll().where((n) => !n.isRead).length;
  }
}
