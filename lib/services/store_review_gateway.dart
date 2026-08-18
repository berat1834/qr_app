import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class StoreReviewGateway {
  Future<void> rateApp({required String androidPackageName});
}

class DefaultStoreReviewGateway implements StoreReviewGateway {
  const DefaultStoreReviewGateway();

  @override
  Future<void> rateApp({required String androidPackageName}) async {
    final inAppReview = InAppReview.instance;
    final webUri = Uri.parse(
      'https://play.google.com/store/apps/details?id=$androidPackageName',
    );
    final marketUri = Uri.parse('market://details?id=$androidPackageName');

    if (await inAppReview.isAvailable()) {
      try {
        await inAppReview.requestReview();
        return;
      } catch (_) {
        // Fall back to store listing if in-app review fails.
      }
    }

    try {
      await inAppReview.openStoreListing();
      return;
    } catch (_) {
      // Continue with URL fallback if plugin-based listing fails.
    }

    if (await launchUrl(webUri, mode: LaunchMode.externalApplication)) {
      return;
    }

    if (await launchUrl(marketUri, mode: LaunchMode.externalApplication)) {
      return;
    }

    throw StateError('store_listing_not_opened');
  }
}
