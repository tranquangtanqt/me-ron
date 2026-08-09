import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/app_providers.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/services/speech/speech_recognition_service.dart';
import '../../../../domain/entities/product_entity.dart';
import '../../../providers/order/order_form_notifier.dart';
import '../../../widgets/app_dialog.dart';
import '../../../widgets/app_snack_bar.dart';
import 'voice_order_item_parser.dart';

class OrderVoiceAddButton extends ConsumerWidget {
  final List<ProductEntity> products;

  const OrderVoiceAddButton({
    super.key,
    required this.products,
  });

  Future<void> _startVoiceAddItem(WidgetRef ref) async {
    final service = ref.read(speechRecognitionServiceProvider);

    final permissionResult = await service.checkPermission();
    if (permissionResult.isFailure) {
      AppSnackBar.showError(permissionResult.error.toString());
      return;
    }

    final isInitialized = await service.initialize(
      onError: (message) => AppSnackBar.showError('Lỗi nhận diện giọng nói: $message'),
    );

    if (!isInitialized) {
      AppSnackBar.showError('Không thể khởi tạo nhận diện giọng nói trên thiết bị này');
      return;
    }

    final recognizedText = await _listenAndGetText(service);
    await service.stopListening();

    final text = recognizedText.trim();
    if (text.isEmpty) {
      AppSnackBar.show('Không nhận được câu nói nào');
      return;
    }

    final result = parseVoiceOrderText(text, products);

    switch (result.type) {
      case VoiceOrderParseType.matchedProduct:
        _addMatchedProduct(ref, result);
      case VoiceOrderParseType.explicitFreeItem:
        _addFreeItem(ref, name: result.freeItemName!, quantity: result.quantity);
      case VoiceOrderParseType.noMatch:
        await _confirmAddAsFreeItem(ref, result);
    }
  }

  Future<String> _listenAndGetText(SpeechRecognitionService service) async {
    final transcript = ValueNotifier<String>('');
    String? finalText;

    await service.startListening(
      onPartialResult: (text) => transcript.value = text,
      onResult: (text) {
        finalText = text;
        transcript.value = text;

        if (AppRoutes.rootNavigatorKey.currentState?.canPop() ?? false) {
          AppRoutes.rootNavigatorKey.currentState?.pop();
        }
      },
    );

    await AppDialog.show(
      title: 'Đang nghe...',
      leftButtonText: 'Dừng',
      onTapLeftButton: (context) => Navigator.of(context).pop(),
      child: ValueListenableBuilder<String>(
        valueListenable: transcript,
        builder: (context, value, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.mic, size: 40),

              const SizedBox(height: 12),

              Text(
                value.isEmpty ? 'Hãy nói tên món, ví dụ: "2 bánh bao xả xíu"' : value,
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
    );

    return finalText ?? transcript.value;
  }

  void _addMatchedProduct(WidgetRef ref, VoiceOrderParseResult result) {
    final notifier = ref.read(orderFormNotifierProvider.notifier);

    notifier.addItem(result.product);

    final index = ref.read(orderFormNotifierProvider).items!.length - 1;
    notifier.updateQuantity(index, result.quantity);
  }

  void _addFreeItem(WidgetRef ref, {required String name, required int quantity}) {
    final notifier = ref.read(orderFormNotifierProvider.notifier);

    notifier.addFreeItem();

    final index = ref.read(orderFormNotifierProvider).items!.length - 1;
    notifier.updateFreeItemName(index, name);
    notifier.updateQuantity(index, quantity);
  }

  Future<void> _confirmAddAsFreeItem(WidgetRef ref, VoiceOrderParseResult result) async {
    await AppDialog.show(
      title: 'Không tìm thấy món',
      text: 'Không tìm thấy món khớp với "${result.rawQuery}". Bạn có muốn thêm làm món tự do không?',
      leftButtonText: 'Hủy',
      rightButtonText: 'Thêm món tự do',
      onTapRightButton: (context) {
        Navigator.of(context).pop();
        _addFreeItem(ref, name: result.rawQuery, quantity: result.quantity);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () => _startVoiceAddItem(ref),
      icon: const Icon(Icons.mic),
      tooltip: 'Thêm món bằng giọng nói',
    );
  }
}
