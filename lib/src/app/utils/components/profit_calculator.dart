import 'package:business_manager_web_ui/src/models/product_model.dart';

class ProfitCalculator {
  static double calculateProfit(OrderProducts product) {
    // Assuming you have costPrice and sellingPrice in OrderProducts
    final cost = product.cost ?? 0;
    final selling = product.price ?? 0;
    final quantity = product.quantity ?? 1;

    return (selling - cost) * quantity;
  }

  static double calculateMarginPercentage(OrderProducts product) {
    final cost = product.cost ?? 0;
    final selling = product.price ?? 0;

    if (selling == 0) return 0;
    return ((selling - cost) / selling) * 100;
  }
}
