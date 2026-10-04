import '../models/sweet_craft_application.dart';
import '../models/sweet_craft_request.dart';

class SweetCraftService {
  SweetCraftService._();

  static final SweetCraftService instance = SweetCraftService._();

  final List<SweetCraftRequest> requests = [
    SweetCraftRequest(
      id: 'SC001',
      title: 'Elegant Birthday Cake',
      foodType: 'Custom Cake',
      occasion: 'Birthday',
      description:
          'I want an elegant birthday cake for a 20th birthday celebration.',
      theme: 'Pink & Gold',
      flavor: 'Chocolate',
      servings: 20,
      minBudget: 8000,
      maxBudget: 12000,
      requiredDate: 'October 20, 2026',
      location: 'Colombo',
      referenceImages: [],
      status: SweetCraftRequestStatus.reviewing,
    ),
    SweetCraftRequest(
      id: 'SC002',
      title: 'Custom Wedding Cupcakes',
      foodType: 'Cupcakes',
      occasion: 'Wedding',
      description:
          'Looking for elegant cupcakes for a small wedding celebration.',
      theme: 'White & Floral',
      flavor: 'Vanilla',
      servings: 50,
      minBudget: 10000,
      maxBudget: 15000,
      requiredDate: 'November 8, 2026',
      location: 'Kaduwela',
      referenceImages: [],
      status: SweetCraftRequestStatus.open,
    ),
  ];

  final List<SweetCraftApplication> applications = [
    SweetCraftApplication(
      id: 'APP001',
      requestId: 'SC001',
      shopName: 'Cocos Elegance',
      sellerName: 'Cocos Bakery',
      offeredPrice: 9500,
      estimatedCompletionDate: 'October 19, 2026',
      message: 'We can create this cake with a beautiful pink and gold design. We can also customize the topper.',
      rating: 4.9,
      completedOrders: 126,
      instagramUrl: 'https://instagram.com',
      facebookUrl: 'https://facebook.com',
      websiteUrl: 'https://example.com',
      portfolioImages: [],
    ),
    SweetCraftApplication(
      id: 'APP002',
      requestId: 'SC001',
      shopName: 'Sweet Moments',
      sellerName: 'Sweet Moments Bakery',
      offeredPrice: 11000,
      estimatedCompletionDate: 'October 20, 2026',
      message: 'We specialize in custom birthday cakes and can create the requested theme.',
      rating: 4.8,
      completedOrders: 94,
      instagramUrl: 'https://instagram.com',
      facebookUrl: 'https://facebook.com',
      websiteUrl: 'https://example.com',
      portfolioImages: [],
    ),
    SweetCraftApplication(
      id: 'APP003',
      requestId: 'SC002',
      shopName: 'Urban Bakes',
      sellerName: 'Urban Bakes',
      offeredPrice: 12500,
      estimatedCompletionDate: 'November 7, 2026',
      message: 'We can prepare elegant floral wedding cupcakes with custom decoration.',
      rating: 4.7,
      completedOrders: 81,
      instagramUrl: 'https://instagram.com',
      facebookUrl: 'https://facebook.com',
      websiteUrl: 'https://example.com',
      portfolioImages: [],
    ),
  ];

  SweetCraftRequest? getRequestById(String id) {
    try {
      return requests.firstWhere((request) => request.id == id);
    } catch (_) {
      return null;
    }
  }

  List<SweetCraftApplication> getApplicationsForRequest(String requestId) {
    return applications
        .where((application) => application.requestId == requestId)
        .toList();
  }

  void addRequest(SweetCraftRequest request) {
    requests.insert(0, request);
  }

  void updateRequestStatus(String requestId, SweetCraftRequestStatus status) {
    final request = getRequestById(requestId);

    if (request != null) {
      request.status = status;
    }
  }

  void updateApplicationStatus(
    String applicationId,
    SweetCraftApplicationStatus status,
  ) {
    final application = applications.firstWhere(
      (application) => application.id == applicationId,
    );

    application.status = status;
  }

  SweetCraftApplication? getAcceptedApplication(String requestId) {
    try {
      return applications.firstWhere(
        (application) =>
            application.requestId == requestId &&
            application.status == SweetCraftApplicationStatus.accepted,
      );
    } catch (_) {
      return null;
    }
  }
}
