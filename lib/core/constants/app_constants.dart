abstract final class AppConstants {
  static const appName = 'Domo';

  // Firestore collections
  static const usersCollection = 'users';
  static const casasCollection = 'casas';
  static const membersCollection = 'members';
  static const joinRequestsCollection = 'join_requests';
  static const pantryItemsCollection = 'pantry_items';

  // Item status
  static const statusHave = 'have';
  static const statusNeed = 'need';
  static const statusInCart = 'in_cart';

  // Join request status
  static const requestPending = 'pending';
  static const requestApproved = 'approved';
  static const requestRejected = 'rejected';

  // Storage paths
  static const profilePhotosPath = 'profile_photos';

  // Image compression
  static const maxPhotoQuality = 70;
  static const maxPhotoWidthHeight = 512;
}
