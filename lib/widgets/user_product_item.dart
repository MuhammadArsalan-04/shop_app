import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/HandlingException.dart';

import '../screens/edit_product_screen.dart';
import '../providers/products.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;
  bool isLoading = false;

  UserProductItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final snackBar = ScaffoldMessenger.of(context);
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : ListTile(
            title: Text(title),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(imageUrl),
            ),
            trailing: Container(
              width: 100,
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        EditProductScreen.routeName,
                        arguments: id,
                      );
                    },
                    color: Theme.of(context).primaryColor,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      try {
                        await Provider.of<Products>(context, listen: false)
                            .deleteProduct(id);
                      } on HandlingException catch (error) {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text(
                                'Something Went Wrong! Please Try Again Later'),
                            content: Text(error.message),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('okay'))
                            ],
                          ),
                        );
                      } catch (error) {
                        snackBar.showSnackBar(SnackBar(
                          content: Text(
                            error.toString(),
                          ),
                          duration: const Duration(seconds: 1),
                        ));
                      }
                    },
                    color: Theme.of(context).errorColor,
                  ),
                ],
              ),
            ),
          );
  }
}
