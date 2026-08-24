import 'user_model.dart';

class AdminStats {
  final int totalUsers;
  final int totalAdmins;
  final int verifiedUsers;
  final int regularUsers;
  final int totalResumes;
  final int publishedResumes;
  final int draftResumes;

  const AdminStats({
    this.totalUsers = 0,
    this.totalAdmins = 0,
    this.verifiedUsers = 0,
    this.regularUsers = 0,
    this.totalResumes = 0,
    this.publishedResumes = 0,
    this.draftResumes = 0,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalUsers: json['totalUsers'] as int? ?? 0,
      totalAdmins: json['totalAdmins'] as int? ?? 0,
      verifiedUsers: json['verifiedUsers'] as int? ?? 0,
      regularUsers: json['regularUsers'] as int? ?? 0,
      totalResumes: json['totalResumes'] as int? ?? 0,
      publishedResumes: json['publishedResumes'] as int? ?? 0,
      draftResumes: json['draftResumes'] as int? ?? 0,
    );
  }
}

class AdminResumeItem {
  final String id;
  final String title;
  final String status;
  final String template;
  final String ownerName;
  final String ownerEmail;
  final String updatedAt;
  final int sectionsCount;

  const AdminResumeItem({
    required this.id,
    required this.title,
    required this.status,
    required this.template,
    required this.ownerName,
    required this.ownerEmail,
    required this.updatedAt,
    this.sectionsCount = 0,
  });

  factory AdminResumeItem.fromJson(Map<String, dynamic> json) {
    final sections = json['sections'] as List<dynamic>? ?? [];
    return AdminResumeItem(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      title: (json['title'] as String? ?? '').trim().isEmpty ? 'Untitled Resume' : json['title'] as String,
      status: json['status'] as String? ?? 'draft',
      template: json['template'] as String? ?? 'modern',
      ownerName: json['ownerName'] as String? ?? 'Unknown User',
      ownerEmail: json['ownerEmail'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      sectionsCount: sections.length,
    );
  }
}

class AdminOverviewData {
  final AdminStats stats;
  final List<UserModel> recentUsers;
  final List<AdminResumeItem> recentResumes;

  const AdminOverviewData({
    this.stats = const AdminStats(),
    this.recentUsers = const [],
    this.recentResumes = const [],
  });

  factory AdminOverviewData.fromJson(Map<String, dynamic> json) {
    final statsJson = json['stats'] as Map<String, dynamic>? ?? {};
    final recentUsersJson = json['recentUsers'] as List<dynamic>? ?? [];
    final recentResumesJson = json['recentResumes'] as List<dynamic>? ?? [];

    return AdminOverviewData(
      stats: AdminStats.fromJson(statsJson),
      recentUsers: recentUsersJson.map((u) => UserModel.fromJson(u as Map<String, dynamic>)).toList(),
      recentResumes: recentResumesJson.map((r) => AdminResumeItem.fromJson(r as Map<String, dynamic>)).toList(),
    );
  }
}
