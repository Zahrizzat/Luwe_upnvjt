enum UserRole { buyer, seller }

enum StoreVerificationStatus {
  none, // Belum mengajukan
  pending, // Menunggu verifikasi
  approved, // Disetujui
  rejected, // Ditolak
}

class UserModel {
  final String id;
  final int? dbUserId;
  final int? dbStoreId;
  final String name;
  final String email;
  final String npm;
  final String faculty;
  final String studyProgram;
  final String phoneNumber;
  final UserRole role;
  final String avatarUrl;
  final String storeName;
  final String storeLocation;
  final String? storeDescription;
  final String? storeContactPhone;
  final bool isStoreOpen;
  final StoreVerificationStatus verificationStatus;
  final String? rejectionReason;
  final String userType; // 'mahasiswa', 'karyawan', 'dosen'
  final String bankName;
  final String bankAccountNumber;
  final String bankAccountHolder;
  final bool isBankAccountVerified;

  const UserModel({
    required this.id,
    this.dbUserId,
    this.dbStoreId,
    required this.name,
    required this.email,
    required this.npm,
    required this.faculty,
    required this.studyProgram,
    required this.phoneNumber,
    required this.role,
    required this.avatarUrl,
    this.storeName = '',
    this.storeLocation = '',
    this.storeDescription,
    this.storeContactPhone,
    this.isStoreOpen = true,
    this.verificationStatus = StoreVerificationStatus.none,
    this.rejectionReason,
    this.userType = 'mahasiswa',
    this.bankName = 'Bank BCA',
    this.bankAccountNumber = '8291039482',
    this.bankAccountHolder = '',
    this.isBankAccountVerified = true,
  });

  bool get isGuest => id == 'guest';
  bool get isSellerApproved => verificationStatus == StoreVerificationStatus.approved;

  String get maskedBankAccountNumber {
    final clean = bankAccountNumber.trim();
    if (clean.isEmpty) return '-';
    if (clean.length <= 4) return clean;
    final last4 = clean.substring(clean.length - 4);
    return '•••• •••• $last4';
  }

  static const guest = UserModel(
    id: 'guest',
    name: 'Tamu LuWe',
    email: '',
    npm: '',
    faculty: 'UPN "Veteran" Jawa Timur',
    studyProgram: 'Tamu Kampus',
    phoneNumber: '',
    role: UserRole.buyer,
    avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=400&q=80',
    verificationStatus: StoreVerificationStatus.none,
    userType: 'mahasiswa',
    bankName: '',
    bankAccountNumber: '',
    bankAccountHolder: '',
    isBankAccountVerified: false,
  );

  UserModel copyWith({
    String? id,
    int? dbUserId,
    int? dbStoreId,
    String? name,
    String? email,
    String? npm,
    String? faculty,
    String? studyProgram,
    String? phoneNumber,
    UserRole? role,
    String? avatarUrl,
    String? storeName,
    String? storeLocation,
    String? storeDescription,
    String? storeContactPhone,
    bool? isStoreOpen,
    StoreVerificationStatus? verificationStatus,
    String? rejectionReason,
    String? userType,
    String? bankName,
    String? bankAccountNumber,
    String? bankAccountHolder,
    bool? isBankAccountVerified,
  }) {
    return UserModel(
      id: id ?? this.id,
      dbUserId: dbUserId ?? this.dbUserId,
      dbStoreId: dbStoreId ?? this.dbStoreId,
      name: name ?? this.name,
      email: email ?? this.email,
      npm: npm ?? this.npm,
      faculty: faculty ?? this.faculty,
      studyProgram: studyProgram ?? this.studyProgram,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      storeName: storeName ?? this.storeName,
      storeLocation: storeLocation ?? this.storeLocation,
      storeDescription: storeDescription ?? this.storeDescription,
      storeContactPhone: storeContactPhone ?? this.storeContactPhone,
      isStoreOpen: isStoreOpen ?? this.isStoreOpen,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      userType: userType ?? this.userType,
      bankName: bankName ?? this.bankName,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankAccountHolder: bankAccountHolder ?? this.bankAccountHolder,
      isBankAccountVerified: isBankAccountVerified ?? this.isBankAccountVerified,
    );
  }
}
