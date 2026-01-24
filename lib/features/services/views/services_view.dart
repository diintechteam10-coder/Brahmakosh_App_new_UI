import '../../../core/common_imports.dart';
import '../controllers/services_controller.dart';
import '../model.dart';

class ServicesView extends StatelessWidget {
  const ServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    final ServicesController controller = Get.find<ServicesController>();
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGold,
        elevation: 0,
        title: Text(
          'Shadana',
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.backgroundLight,
              Colors.white,
              AppTheme.primaryGold.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Obx(() {
            if (controller.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            if (controller.services.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      controller.errorMessage.isNotEmpty
                          ? controller.errorMessage
                          : 'No services available',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }
            
            return GridView.builder(
              padding: const EdgeInsets.only(top: 24, bottom: 100),
              itemCount: controller.services.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 20,
                childAspectRatio: 0.82, // Adjusted for more vertical space
              ),
              itemBuilder: (context, index) {
                return ServiceCard(
                  service: controller.services[index],
                  onTap: () => controller.navigateToServiceDetail(
                    context,
                    controller.services[index],
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}

class ServiceCard extends StatefulWidget {
  final ServiceModel service;
  final VoidCallback onTap;

  const ServiceCard({super.key, required this.service, required this.onTap});

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard>
    with SingleTickerProviderStateMixin {
  bool isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => isHovered = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => isHovered = false);
        _controller.reverse();
        Future.delayed(const Duration(milliseconds: 150), () {
          widget.onTap();
        });
      },
      onTapCancel: () {
        setState(() => isHovered = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.service.color.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.service.color.withOpacity(isHovered ? 0.3 : 0.1),
                blurRadius: isHovered ? 25 : 15,
                offset: const Offset(0, 10),
                spreadRadius: isHovered ? 2 : 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Subtle Background Glow
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.service.color.withOpacity(0.08),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Lottie Icon or API Image with dynamic background
                      Flexible(
                        child: Container(
                          constraints: const BoxConstraints(
                            maxHeight: 90,
                            maxWidth: 90,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                widget.service.color.withOpacity(0.15),
                                widget.service.color.withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: widget.service.imageUrl != null && widget.service.imageUrl!.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    widget.service.imageUrl!,
                                    fit: BoxFit.cover,
                                    width: 90,
                                    height: 90,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Lottie.asset(
                                          widget.service.lottie,
                                          fit: BoxFit.contain,
                                        ),
                                      );
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Lottie.asset(
                                          widget.service.lottie,
                                          fit: BoxFit.contain,
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Lottie.asset(
                                    widget.service.lottie,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.service.title,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Explore",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: widget.service.color.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 9,
                            color: widget.service.color.withOpacity(0.8),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
