import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.dateTime,
    @required this.id,
    @required this.products,
    @required this.amount,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  List<OrderItem> get orders {
    return [..._orders];
  }

  final String authToken;
  Orders(this.authToken,this._orders);

  Future<void> fetchAndSetOrder() async {
    final url =
        'https://flutter-http-request-d1ee4-default-rtdb.firebaseio.com/orders.json?auth=$authToken';
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if(extractedData == null){
      return;
    }
    extractedData.forEach((orderId, orderItem) {
      loadedOrders.add(
        OrderItem(
            dateTime: DateTime.parse(orderItem['dateTime']),
            id: orderId,
            products: (orderItem['products'] as List<dynamic>)
                .map(
                  (item) => CartItem(
                      id: item['id'],
                      title: item['title'],
                      price: item['price'],
                      quantity: item['quantity']),
                )
                .toList(),
            amount: orderItem['amount']),
      );
    });
    _orders= loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> placeOrder(List<CartItem> cart, double total) async {
    final timeStamp = DateTime.now();
    final url =
        'https://flutter-http-request-d1ee4-default-rtdb.firebaseio.com/orders.json?auth=$authToken';
    final response = await http.post(url,
        body: json.encode({
          'dateTime': timeStamp.toIso8601String(),
          'amount': total,
          'products': cart
              .map((cartProduct) => {
                    'id': cartProduct.id,
                    'title': cartProduct.title,
                    'price': cartProduct.price,
                    'quantity': cartProduct.quantity,
                  })
              .toList(),
        }));
    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        dateTime: timeStamp,
        products: cart,
        amount: total,
      ),
    );
    notifyListeners();
  }
}
