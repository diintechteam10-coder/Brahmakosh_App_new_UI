import 'package:brahmakosh/features/astrology/views/astrology_experts_view.dart';
import '../../../core/common_imports.dart';
import '../model.dart';

class ServiceDetailView extends StatelessWidget {
  final ServiceModel service;

  const ServiceDetailView({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    if (service.isStore && service.storeItems != null) {
      return _buildStoreView(context);
    }

    return _buildServiceDetailView(context);
  }

  Widget _buildStoreView(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: service.color,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          service.title,
          style: GoogleFonts.lora(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [service.color, service.color.withOpacity(0.8)],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.25),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Lottie.asset(
                      service.lottie,
                      fit: BoxFit.contain,
                      repeat: true,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    'Winter Sale!',
                    style: GoogleFonts.lora(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: service.color,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Store Items List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: service.storeItems!.length,
              itemBuilder: (context, index) {
                return _buildStoreItemCard(
                  context,
                  service.storeItems![index],
                  index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreItemCard(BuildContext context, String itemName, int index) {
    return _TiltCard(
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.lightGold, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGold.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          leading: Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryGold.withOpacity(0.3),
                  AppTheme.lightGold.withOpacity(0.4),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGold.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              _getIconForItem(itemName),
              color: AppTheme.primaryGold,
              size: 22,
            ),
          ),
          title: Text(
            itemName,
            style: GoogleFonts.lora(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.primaryGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.primaryGold,
              size: 14,
            ),
          ),
          onTap: () {
            if (service.title.toLowerCase().contains('astrology') ||
                itemName.toLowerCase().contains('consultation')) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AstrologyExpertsView(),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  IconData _getIconForItem(String itemName) {
    if (itemName.toLowerCase().contains('rudraksha')) {
      return Icons.circle;
    } else if (itemName.toLowerCase().contains('bracelet')) {
      return Icons.watch;
    } else if (itemName.toLowerCase().contains('murti')) {
      return Icons.temple_hindu;
    } else if (itemName.toLowerCase().contains('yantra')) {
      return Icons.auto_awesome;
    } else if (itemName.toLowerCase().contains('gemstone')) {
      return Icons.diamond;
    } else if (itemName.toLowerCase().contains('necklace')) {
      return Icons.circle_outlined;
    } else if (itemName.toLowerCase().contains('pyramid')) {
      return Icons.change_circle;
    } else if (itemName.toLowerCase().contains('gift')) {
      return Icons.card_giftcard;
    } else if (itemName.toLowerCase().contains('consultation')) {
      return Icons.chat;
    } else {
      return Icons.shopping_bag;
    }
  }

  Widget _buildServiceDetailView(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: service.color,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          service.title,
          style: GoogleFonts.lora(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [service.color, service.color.withOpacity(0.8)],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Center(
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Lottie.asset(
                      service.lottie,
                      fit: BoxFit.contain,
                      repeat: true,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About ${service.title}',
                    style: GoogleFonts.lora(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    service.description,
                    style: GoogleFonts.lora(
                      fontSize: 16,
                      height: 1.6,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ...service.features.map(
                    (feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: GestureDetector(
                        onTap: () {
                          if (feature.title.toLowerCase().contains('chat') ||
                              feature.title.toLowerCase().contains(
                                'astrologer',
                              )) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AstrologyExpertsView(),
                              ),
                            );
                          }
                        },
                        child: _buildFeatureCard(
                          context,
                          feature.title,
                          feature.description,
                          feature.icon,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    return _TiltCard(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.lightGold, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGold.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryGold.withOpacity(0.3),
                    AppTheme.lightGold.withOpacity(0.4),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGold.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: AppTheme.primaryGold, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lora(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.lora(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
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

// 3D Tilt Card Widget
class _TiltCard extends StatefulWidget {
  final Widget child;

  const _TiltCard({required this.child});

  @override
  State<_TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<_TiltCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _xRotation = 0.0;
  double _yRotation = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final size = box.size;
    final localPosition = box.globalToLocal(details.globalPosition);

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final deltaX = localPosition.dx - centerX;
    final deltaY = localPosition.dy - centerY;

    setState(() {
      _xRotation = (deltaY / centerY) * 0.1;
      _yRotation = -(deltaX / centerX) * 0.1;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _controller.forward(from: 0.0).then((_) {
      _controller.reverse();
    });

    setState(() {
      _xRotation = 0.0;
      _yRotation = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(_xRotation)
          ..rotateY(_yRotation),
        alignment: FractionalOffset.center,
        child: widget.child,
      ),
    );
  }
}

