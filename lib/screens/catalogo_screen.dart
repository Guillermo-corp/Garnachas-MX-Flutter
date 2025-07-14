import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/platillo.dart';
import 'package:flutter_application_1/widgets/product_details.dart';
import 'package:flutter_application_1/models/cart_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/providers/product_provider.dart';

final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

class CatalogoScreen extends StatelessWidget {
  const CatalogoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Catálogo")),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  itemCount: demoProducts.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 1.02,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 16,
                  ),
                  itemBuilder: (context, index) => ProductCard(
                    product: productProvider.productos[index],
                    onPress: () {
                      showProductDetailsModal(
                        context: context,
                        product: productProvider.productos[index],
                        onAddToCart: (product) {
                          addToCart(product);
                        },
                        scaffoldKey: scaffoldKey,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 1.52,
              child: Container(
                padding: const EdgeInsets.all(1),
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
            Text(
              "\$${(product.priceWithDiscount ?? product.price).toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: product.priceWithDiscount != null
                    ? Colors.green
                    : const Color(0xFFFF7643),
              ),
            ),
            /* InkWell(
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
            ), */
          ],
        ),
      ),
    );
  }
}
