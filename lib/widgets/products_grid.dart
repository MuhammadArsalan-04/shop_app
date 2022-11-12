import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import './product_item.dart';

class ProductsGrid extends StatefulWidget {
  final bool showFavs;

  ProductsGrid(this.showFavs);

  @override
  State<ProductsGrid> createState() => _ProductsGridState();
}

class _ProductsGridState extends State<ProductsGrid> {
  bool isInit = true;
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (isInit) {
      Provider.of<Products>(context, listen: false).fetchProducts().then((_) {
        setState(() {
          isLoading = false;
        });
      });
      isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final products =
        widget.showFavs ? productsData.favoriteItems : productsData.items;
    return isLoading
        ? Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          )
        : productsData.items.isEmpty
            ? const Center(
                child: Text(
                  'Currently Shop Has No items',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(10.0),
                itemCount: products.length,
                itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
                  // builder: (c) => products[i],
                  value: products[i],
                  child: ProductItem(
                      // products[i].id,
                      // products[i].title,
                      // products[i].imageUrl,
                      ),
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
              );
  }
}
