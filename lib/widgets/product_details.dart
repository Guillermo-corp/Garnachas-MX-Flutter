import 'package:flutter/material.dart';
import '../models/platillo.dart';
import '../screens/home_screen.dart';

class ProductDetails extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;

  const ProductDetails({
    Key? key,
    required this.product,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) => SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  product.images.first,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              product.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            product.priceWithDiscount != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "\$${product.price.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "\$${product.priceWithDiscount!.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  )
                : Text(
                    "\$${product.price.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFFFF7643),
                    ),
                  ),
            const SizedBox(height: 20),
            /* const SizedBox(height: 10),
            Text(
              "\$${product.price.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 18, color: Color(0xFFFF7643)),
            ),
            const SizedBox(height: 20), */
            Text(
              product.description ?? "Descripción no disponible.",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  /* addToCart(product); */
                  onAddToCart();
                  /* Navigator.pop(context); */
                  /* ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${product.title} agregado al carrito')),
                  ); */
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7643),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Agregar al carrito",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showProductDetailsModal({
  required BuildContext context,
  required Product product,
  required void Function(Product) onAddToCart,
  required GlobalKey<ScaffoldState> scaffoldKey,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    isScrollControlled: true,
    builder: (context) {
      return ProductDetails(
        product: product,
        onAddToCart: () {
          onAddToCart(product);

          final notificationContext = scaffoldKey.currentContext ?? context;
          mostrarNotificacion(
            notificationContext,
            "Agregado al carrito: ${product.title}",
          );

          Future.delayed(const Duration(milliseconds: 300), () {
            if (context.mounted) {
              Navigator.pop(context);
            }
          });
        },
      );
    },
  );
}
