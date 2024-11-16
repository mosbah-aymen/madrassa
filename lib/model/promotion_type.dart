
import 'package:madrassa/constants/enums.dart';

class PromotionType {
  PromotionTypeEnum type;
  double? discountPercentage; // Only used if type is customDiscount

  PromotionType({
    required this.type,
    this.discountPercentage,
  });

  factory PromotionType.fromMap(Map<String, dynamic> data) {
    return PromotionType(
      type: PromotionTypeEnum.values.firstWhere(
              (e) => e.toString() == 'PromotionTypeEnum.${data['type']}'),
      discountPercentage: data['discountPercentage']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.toString().split('.').last,
      'discountPercentage': discountPercentage,
    };
  }
}
