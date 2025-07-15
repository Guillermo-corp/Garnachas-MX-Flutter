import 'package:flutter/material.dart';
/* import 'package:flutter_application_1/utils/snackbar_utils.dart';
import 'catalogo_screen.dart';
import '../widgets/BottomNavBar.dart';
import 'profile_screen.dart'; */
import 'package:flutter_svg/flutter_svg.dart';
import '../models/platillo.dart';
import '../models/cart_service.dart';
import '../widgets/product_details.dart';
import '../widgets/stripe_options.dart';
import '../models/notification_service.dart';
import 'package:status_alert/status_alert.dart';
import '../providers/product_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /*  int _selectedIndex = 0; */
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  /* void _onDestinationSelected(int index) {

    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CatalogoScreen()),
      );
    }
  } */

  /* void _onBottomNavSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      // Ya estás en Home, no hagas nada
    } else if (index == 1) {
      showWarningSnackbar(
        context,
        'Ups!',
        'Pronto podrás ver tus platillos favoritos.',
      );
      /* ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Ups!',
            message: 'Pronto podrás ver tus platillos favoritos.',
            contentType: ContentType.warning,
            ),
        ),
      ); */
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CatalogoScreen()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    }
  } */

  /* <-- BOTON DE CARRITO -->*/
  Future<void> _mostrarCarrito(
    BuildContext context,
    VoidCallback onCartUpdated,
  ) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      isScrollControlled: true,
      builder: (context) {
        if (cartItems.isEmpty) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: Text(
                "Tu carrito está vacío 🛒",
                style: TextStyle(fontSize: 18),
              ),
            ),
          );
        }

        // Variable para total, se actualizará después de setState
        double total = cartItems.fold(
          0,
          (sum, item) =>
              sum + (item.priceWithDiscount ?? item.price) * item.quantity,
        );

        return StatefulBuilder(
          builder: (context, setState) {
            void _incrementQuantity(int index) {
              setState(() {
                cartItems[index].quantity += 1;
                cartItemCount.value = cartItems.fold(
                  0,
                  (sum, item) => sum + item.quantity,
                );
              });
            }

            void _decrementQuantity(int index) {
              setState(() {
                if (cartItems[index].quantity > 1) {
                  cartItems[index].quantity -= 1;
                } else {
                  cartItems.removeAt(index);
                }
                cartItemCount.value = cartItems.fold(
                  0,
                  (sum, item) => sum + item.quantity,
                );
              });
            }

            double total = cartItems.fold(
              0,
              (sum, item) =>
                  sum + (item.priceWithDiscount ?? item.price) * item.quantity,
            );

            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.4,
              maxChildSize: 0.95,
              expand: false,
              builder: (_, scrollController) {
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: cartItems.length,
                        itemBuilder: (_, index) {
                          final product = cartItems[index];
                          return ListTile(
                            leading: Image.network(
                              product.images.first,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            title: Text(product.title),
                            subtitle: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _decrementQuantity(index),
                                ),
                                Text(
                                  "${product.quantity}",
                                  style: const TextStyle(fontSize: 16),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    color: Colors.green,
                                  ),
                                  onPressed: () => _incrementQuantity(index),
                                ),
                              ],
                            ),
                            trailing: Text(
                              "\$${((product.priceWithDiscount ?? product.price) * product.quantity).toStringAsFixed(2)}",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: product.priceWithDiscount != null
                                    ? Colors.green
                                    : const Color(0xFFFF7643),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(thickness: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "\$${total.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF7643),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final safeContext = Navigator.of(
                              context,
                            ).overlay!.context;

                            Navigator.pop(safeContext); // Cierra el modal

                            Future.delayed(
                              const Duration(milliseconds: 300),
                              () {
                                if (safeContext.mounted) {
                                  PaymentOptions.show(
                                    safeContext,
                                    onSuccess: onCartUpdated,
                                  );
                                }
                              },
                            );
                          },
                          /* onPressed: () => PaymentOptions.show(context), */
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF7643),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Proceder al pago",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              HomeHeader(
                onCartPressed: () =>
                    _mostrarCarrito(context, () => setState(() {})),
              ),
              const DiscountBanner(),
              PopularProducts(
                onAddToCart: (product, notificationContext) {
                  setState(() {
                    // Si ya está, solo aumenta la cantidad
                    addToCart(product);

                    /* mostrarNotificacion(
                      rootContext,
                      "Agregado al carrito: ${product.title}",
                    ); */
                  });
                },
                scaffoldKey: scaffoldKey,
              ),
              const SizedBox(height: 20),
              const RecentlyAddedProducts(),
            ],
          ),
        ),
      ),
      /* bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavSelected,
      ), */
    );
  }
}

class HomeHeader extends StatelessWidget {
  final VoidCallback onCartPressed;

  const HomeHeader({Key? key, required this.onCartPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(child: SearchField()),
          const SizedBox(width: 16),
          ValueListenableBuilder<int>(
            valueListenable: cartItemCount,
            builder: (context, totalItems, _) {
              return IconBtnWithCounter(
                svgSrc: cartIcon,
                numOfitem: totalItems,
                press: onCartPressed,
              );
            },
          ),
          const SizedBox(width: 8),

          ValueListenableBuilder<int>(
            valueListenable: NotificationService.notificationCount,
            builder: (context, count, _) {
              return IconBtnWithCounter(
                svgSrc: bellIcon,
                numOfitem: count,
                press: () => showNotificationsDialog(context),
              );
            },
          ),
        ],
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      child: TextFormField(
        onChanged: (value) {},
        decoration: InputDecoration(
          filled: true,
          hintStyle: const TextStyle(color: Color(0xFF757575)),
          fillColor: const Color(0xFF979797).withOpacity(0.1),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          hintText: "Search product",
          prefixIcon: const Icon(Icons.search),
        ),
      ),
    );
  }
}

class IconBtnWithCounter extends StatelessWidget {
  const IconBtnWithCounter({
    Key? key,
    required this.svgSrc,
    this.numOfitem = 0,
    required this.press,
  }) : super(key: key);

  final String svgSrc;
  final int numOfitem;
  final GestureTapCallback press;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: press,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF979797).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.string(svgSrc),
          ),
          if (numOfitem != 0)
            Positioned(
              top: -3,
              right: 0,
              child: Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4848),
                  shape: BoxShape.circle,
                  border: Border.all(width: 1.5, color: Colors.white),
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        ),
                        child: child,
                      );
                    },
                    child: Text(
                      '$numOfitem',
                      key: ValueKey<int>(numOfitem),
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

BuildContext? getOverlayContext(BuildContext context) {
  return Navigator.of(context, rootNavigator: true).overlay?.context;
}

// Esta función muestra una notificación en la pantalla y la agrega al servicio de notificaciones
void mostrarNotificacion(BuildContext context, String mensaje) {
  print("Notificación: $mensaje");
  StatusAlert.show(
    context,
    duration: const Duration(seconds: 2),
    title: 'Notificación',
    subtitle: mensaje,
    configuration: const IconConfiguration(icon: Icons.info),
  );
  NotificationService.add(mensaje);
}

/* class DiscountBanner extends StatelessWidget {
  const DiscountBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 139, 30),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text.rich(
        TextSpan(
          style: TextStyle(color: Colors.white),
          children: [
            TextSpan(text: "Tienes cupones por canjear\n"),
            TextSpan(
              text: "20% de descuento",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
 */
class DiscountBanner extends StatefulWidget {
  const DiscountBanner({Key? key}) : super(key: key);

  @override
  State<DiscountBanner> createState() => _DiscountBannerState();
}

class _DiscountBannerState extends State<DiscountBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  bool _visible = true; // Controla si se debe mostrar el banner

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant DiscountBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si el cupón desaparece desde el provider, aseguramos que el banner no esté visible
    final provider = Provider.of<ProductProvider>(context, listen: false);
    if (provider.cuponCodigo == null && _visible) {
      // Si no hay cupón pero banner está visible, ocultarlo
      _hideBannerWithoutAnimation();
    }
  }

  void _hideBannerWithoutAnimation() {
    setState(() {
      _visible = false;
    });
  }

  Future<void> _removeCoupon(ProductProvider provider) async {
    // Animación hacia arriba
    await _controller.reverse();

    // Quitar cupón del provider
    provider.removeVoucher();

    // Ocultar el banner de la UI
    setState(() {
      _visible = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Cupón eliminado"),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    final codigo = provider.cuponCodigo;
    final descuento = provider.cuponDescuento;

    if (!_visible || codigo == null || descuento == null) {
      return const SizedBox.shrink();
    }

    final porcentaje = (descuento * 100).toInt();

    final totalAhorro = provider.productos.fold(0.0, (sum, p) {
      if (p.priceWithDiscount != null) {
        final ahorroPorProducto = (p.price - p.priceWithDiscount!) * p.quantity;
        return sum + ahorroPorProducto;
      }
      return sum;
    });

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 139, 30),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: const TextStyle(color: Colors.white),
                  children: [
                    const TextSpan(text: "Cupón aplicado: "),
                    TextSpan(
                      text: codigo,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: "\nDescuento: $porcentaje%",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                          "\nEstás ahorrando: \$${totalAhorro.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.white),
              onPressed: () {
                _removeCoupon(provider);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({Key? key, required this.title, required this.press})
    : super(key: key);

  final String title;
  final GestureTapCallback press;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        TextButton(
          onPressed: press,
          style: TextButton.styleFrom(foregroundColor: Colors.grey),
          child: const Text("Ver más"),
        ),
      ],
    );
  }
}

class PopularProducts extends StatelessWidget {
  final Function(Product, BuildContext) onAddToCart;
  final GlobalKey<ScaffoldState> scaffoldKey;
  const PopularProducts({
    super.key,
    required this.onAddToCart,
    required this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    final productos = provider.productos;

    final popularProducts = productos
        .where((product) => product.isPopular)
        .toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionTitle(title: "Antojitos Populares", press: () {}),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: popularProducts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 5,
              childAspectRatio: 0.7,
            ),
            itemBuilder: (context, index) {
              final popularProduct = popularProducts[index];
              return ProductCard(
                product: popularProduct,
                onPress: () {
                  showProductDetailsModal(
                    context: context,
                    product: popularProduct,
                    onAddToCart: (product) => onAddToCart(product, context),
                    scaffoldKey: scaffoldKey,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class RecentlyAddedProducts extends StatelessWidget {
  const RecentlyAddedProducts({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    final productos = provider.productos;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionTitle(title: "Recien agregados", press: () {}),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: productos.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 5,
              childAspectRatio: 0.7,
            ),
            itemBuilder: (context, index) {
              return ProductCard(product: demoProducts[index], onPress: () {});
            },
          ),
        ),
      ],
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({
    Key? key,
    this.width = 140,
    this.aspectRetio = 1.02,
    required this.product,
    required this.onPress,
  }) : super(key: key);

  final double width, aspectRetio;
  final Product product;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: onPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.02,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF979797).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.network(product.images[0]),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.title,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "\$${product.price.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF7643),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    height: 24,
                    width: 24,
                    decoration: BoxDecoration(
                      color: product.isFavourite
                          ? const Color(0xFFFF7643).withOpacity(0.15)
                          : const Color(0xFF979797).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.string(
                      heartIcon,
                      colorFilter: ColorFilter.mode(
                        product.isFavourite
                            ? const Color(0xFFFF4848)
                            : const Color(0xFFDBDEE4),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
