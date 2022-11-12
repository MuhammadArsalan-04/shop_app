import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/helper/custom_page_transiotion_route.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/screens/auth_screen.dart';

import './screens/cart_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './providers/products.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: AuthProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, Products>(
          create: (context) => Products(itemsList: []),
          update: (context, auth, previousProduct) => Products(
            authToken: auth.token,
            itemsList: previousProduct == null ? [] : previousProduct.items,
            userid: auth.userID,
          ),
        ),
        ChangeNotifierProxyProvider<AuthProvider, Cart>(
          create: (context) => Cart(cartList: {}),
          update: (context, auth, previousCart) => Cart(
              authToken: auth.token,
              userId: auth.userID,
              cartList: previousCart!.items),
        ),
        ChangeNotifierProxyProvider<AuthProvider, Orders>(
          create: (context) => Orders(ordersList: []),
          update: (context, auth, previousOrder) => Orders(
            authToken: auth.token,
            userid: auth.userID,
            ordersList: previousOrder == null ? [] : previousOrder.orders,
          ),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MyShop',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            // ignore: deprecated_member_use
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
            pageTransitionsTheme: PageTransitionsTheme(builders: {
              TargetPlatform.android : CustomPageTranstionRoute(),
              TargetPlatform.iOS : CustomPageTranstionRoute(),
            })
          ),
          home: auth.isAuthenticated
              ? ProductsOverviewScreen()
              : FutureBuilder(
                  future: auth.getDetails(),
                  builder: (context, authSnapshot) =>
                      authSnapshot.connectionState == ConnectionState.waiting
                          ? Scaffold(
                              body: Center(
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            )
                          : AuthScreen()),
          routes: {
            ProductsOverviewScreen.routeName: (ctx) => ProductsOverviewScreen(),
            AuthScreen.routeName: (ctx) => AuthScreen(),
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
