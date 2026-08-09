import '../../../../core/utilities/vietnamese_text_normalizer.dart';
import '../../../../domain/entities/product_entity.dart';

const _vietnameseNumberWords = {
  'mot': 1,
  'hai': 2,
  'ba': 3,
  'bon': 4,
  'tu': 4,
  'nam': 5,
  'sau': 6,
  'bay': 7,
  'tam': 8,
  'chin': 9,
  'muoi': 10,
};

const _freeItemKeyword = 'tự do';

enum VoiceOrderParseType { matchedProduct, explicitFreeItem, noMatch }

class VoiceOrderParseResult {
  final VoiceOrderParseType type;
  final int quantity;
  final String rawQuery;
  final ProductEntity? product;
  final String? freeItemName;

  const VoiceOrderParseResult._({
    required this.type,
    required this.quantity,
    required this.rawQuery,
    this.product,
    this.freeItemName,
  });

  factory VoiceOrderParseResult.matchedProduct({
    required ProductEntity product,
    required int quantity,
    required String rawQuery,
  }) {
    return VoiceOrderParseResult._(
      type: VoiceOrderParseType.matchedProduct,
      quantity: quantity,
      rawQuery: rawQuery,
      product: product,
    );
  }

  factory VoiceOrderParseResult.explicitFreeItem({
    required String freeItemName,
    required int quantity,
    required String rawQuery,
  }) {
    return VoiceOrderParseResult._(
      type: VoiceOrderParseType.explicitFreeItem,
      quantity: quantity,
      rawQuery: rawQuery,
      freeItemName: freeItemName,
    );
  }

  factory VoiceOrderParseResult.noMatch({
    required int quantity,
    required String rawQuery,
  }) {
    return VoiceOrderParseResult._(
      type: VoiceOrderParseType.noMatch,
      quantity: quantity,
      rawQuery: rawQuery,
    );
  }
}

VoiceOrderParseResult parseVoiceOrderText(String text, List<ProductEntity> products) {
  final trimmed = text.trim();
  final isExplicitFreeItem = normalizeVietnamese(trimmed).contains(normalizeVietnamese(_freeItemKeyword));

  final withoutKeyword = isExplicitFreeItem ? _removeSubstring(trimmed, _freeItemKeyword) : trimmed;
  final (quantity, name) = _extractQuantity(withoutKeyword);

  if (isExplicitFreeItem) {
    return VoiceOrderParseResult.explicitFreeItem(
      freeItemName: name.isEmpty ? trimmed : name,
      quantity: quantity,
      rawQuery: trimmed,
    );
  }

  final matchedProduct = _matchProduct(name, products);
  if (matchedProduct != null) {
    return VoiceOrderParseResult.matchedProduct(
      product: matchedProduct,
      quantity: quantity,
      rawQuery: trimmed,
    );
  }

  return VoiceOrderParseResult.noMatch(
    quantity: quantity,
    rawQuery: name.isEmpty ? trimmed : name,
  );
}

String _removeSubstring(String original, String keyword) {
  final normalizedOriginal = normalizeVietnamese(original);
  final normalizedKeyword = normalizeVietnamese(keyword);

  final index = normalizedOriginal.indexOf(normalizedKeyword);
  if (index == -1) return original;

  final removed = original.replaceRange(index, index + normalizedKeyword.length, ' ');

  return removed.replaceAll(RegExp(r'\s+'), ' ').trim();
}

(int, String) _extractQuantity(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return (1, trimmed);

  final digitMatch = RegExp(r'^(\d+)\s*(.*)$').firstMatch(trimmed);
  if (digitMatch != null) {
    final quantity = int.tryParse(digitMatch.group(1)!) ?? 1;
    return (quantity < 1 ? 1 : quantity, digitMatch.group(2)!.trim());
  }

  final words = trimmed.split(RegExp(r'\s+'));
  final quantityFromWord = _vietnameseNumberWords[normalizeVietnamese(words.first)];
  if (quantityFromWord != null) {
    return (quantityFromWord, words.skip(1).join(' ').trim());
  }

  return (1, trimmed);
}

ProductEntity? _matchProduct(String query, List<ProductEntity> products) {
  if (query.isEmpty || products.isEmpty) return null;

  final normalizedQuery = normalizeVietnamese(query);

  for (final product in products) {
    if (normalizeVietnamese(product.name) == normalizedQuery) return product;
  }

  final containsMatches = products.where((product) {
    final normalizedName = normalizeVietnamese(product.name);
    return normalizedName.contains(normalizedQuery) || normalizedQuery.contains(normalizedName);
  }).toList();

  if (containsMatches.length == 1) return containsMatches.first;

  final queryWords = normalizedQuery.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toSet();
  if (queryWords.isEmpty) return null;

  ProductEntity? bestMatch;
  var bestScore = 0;
  var isAmbiguous = false;

  for (final product in products) {
    final nameWords = normalizeVietnamese(
      product.name,
    ).split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toSet();

    final overlap = queryWords.intersection(nameWords).length;
    if (overlap == 0) continue;

    if (overlap > bestScore) {
      bestScore = overlap;
      bestMatch = product;
      isAmbiguous = false;
    } else if (overlap == bestScore) {
      isAmbiguous = true;
    }
  }

  final minOverlapRequired = (queryWords.length / 2).ceil();
  if (bestMatch != null && !isAmbiguous && bestScore >= minOverlapRequired) return bestMatch;

  return null;
}
