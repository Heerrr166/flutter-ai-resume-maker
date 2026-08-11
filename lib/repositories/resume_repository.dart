import '../models/resume_model.dart';
import '../services/api_service.dart';

// AI calls can take noticeably longer than a normal CRUD request, so they get
// a longer receive timeout than ApiService's 15s default.
const _aiTimeout = Duration(seconds: 35);

class ResumeRepository {
  final ApiService apiService;

  ResumeRepository({required this.apiService});

  Future<List<ResumeModel>> fetchResumes() async {
    final resp = await apiService.get('/resumes');
    final data = resp.data['data'] as List<dynamic>? ?? [];
    return data.map((e) => ResumeModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ResumeModel> createResume({required String title, String? template}) async {
    final resp = await apiService.post('/resumes', data: {'title': title, 'template': ?template});
    return ResumeModel.fromJson(resp.data['data'] as Map<String, dynamic>);
  }

  Future<ResumeModel> fetchResumeById(String id) async {
    final resp = await apiService.get('/resumes/$id');
    return ResumeModel.fromJson(resp.data['data'] as Map<String, dynamic>);
  }

  Future<ResumeModel> updateResume({required String id, required Map<String, dynamic> payload}) async {
    final resp = await apiService.put('/resumes/$id', data: payload);
    return ResumeModel.fromJson(resp.data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteResume({required String id}) async {
    await apiService.delete('/resumes/$id');
  }

  // --- Resume Intelligence features. All calls go through the backend's
  // /ai/* routes. These currently run entirely on a local, zero-cost,
  // deterministic engine (no external API/key involved) - see
  // backend/services/resumeIntelligenceEngine.js.

  Future<String> generateSummary({
    String? currentSummary,
    List<Map<String, String>>? experience,
    List<String>? skills,
    List<Map<String, String>>? education,
  }) async {
    final resp = await apiService.post(
      '/ai/summary',
      data: {
        if (currentSummary != null && currentSummary.isNotEmpty) 'currentSummary': currentSummary,
        'experience': ?experience,
        'skills': ?skills,
        'education': ?education,
      },
      receiveTimeout: _aiTimeout,
    );
    return resp.data['data']['summary'] as String;
  }

  Future<String> improveExperience({required String text, String? position, String? company}) async {
    final resp = await apiService.post(
      '/ai/experience/improve',
      data: {
        'text': text,
        if (position != null && position.isNotEmpty) 'position': position,
        if (company != null && company.isNotEmpty) 'company': company,
      },
      receiveTimeout: _aiTimeout,
    );
    return resp.data['data']['text'] as String;
  }

  Future<String> improveProject({required String text, String? name, List<String>? technologies}) async {
    final resp = await apiService.post(
      '/ai/project/improve',
      data: {
        'text': text,
        if (name != null && name.isNotEmpty) 'name': name,
        if (technologies != null && technologies.isNotEmpty) 'technologies': technologies,
      },
      receiveTimeout: _aiTimeout,
    );
    return resp.data['data']['text'] as String;
  }

  Future<List<String>> recommendSkills({String? summary, List<String>? experience, List<String>? existingSkills}) async {
    final resp = await apiService.post(
      '/ai/skills/recommend',
      data: {
        if (summary != null && summary.isNotEmpty) 'summary': summary,
        'experience': ?experience,
        'existingSkills': ?existingSkills,
      },
      receiveTimeout: _aiTimeout,
    );
    final skills = resp.data['data']['skills'] as List<dynamic>? ?? [];
    return skills.map((s) => s.toString()).toList();
  }

  Future<Map<String, dynamic>> scoreResume({
    String? summary,
    List<Map<String, dynamic>>? experience,
    List<Map<String, dynamic>>? education,
    List<String>? skills,
    List<Map<String, dynamic>>? projects,
    String? jobDescription,
  }) async {
    final resp = await apiService.post(
      '/ai/resume/score',
      data: {
        if (summary != null && summary.isNotEmpty) 'summary': summary,
        'experience': ?experience,
        'education': ?education,
        'skills': ?skills,
        'projects': ?projects,
        if (jobDescription != null && jobDescription.isNotEmpty) 'jobDescription': jobDescription,
      },
      receiveTimeout: _aiTimeout,
    );
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<String> generateCoverLetter({
    required String jobTitle,
    required String company,
    String? summary,
    List<String>? experience,
    String? jobDescription,
  }) async {
    final resp = await apiService.post(
      '/ai/cover-letter',
      data: {
        'jobTitle': jobTitle,
        'company': company,
        if (summary != null && summary.isNotEmpty) 'summary': summary,
        'experience': ?experience,
        if (jobDescription != null && jobDescription.isNotEmpty) 'jobDescription': jobDescription,
      },
      receiveTimeout: _aiTimeout,
    );
    return resp.data['data']['coverLetter'] as String;
  }

  Future<String> writeAchievement({required String text}) async {
    final resp = await apiService.post(
      '/ai/achievement/improve',
      data: {'text': text},
      receiveTimeout: _aiTimeout,
    );
    return resp.data['data']['text'] as String;
  }

  Future<Map<String, dynamic>> analyzeJobDescription({required String jobDescription}) async {
    final resp = await apiService.post(
      '/ai/job/analyze',
      data: {'jobDescription': jobDescription},
      receiveTimeout: _aiTimeout,
    );
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> matchResumeToJob({
    required String jobDescription,
    String? summary,
    List<Map<String, dynamic>>? experience,
    List<Map<String, dynamic>>? education,
    List<String>? skills,
    List<Map<String, dynamic>>? projects,
  }) async {
    final resp = await apiService.post(
      '/ai/resume/match',
      data: {
        'jobDescription': jobDescription,
        if (summary != null && summary.isNotEmpty) 'summary': summary,
        'experience': ?experience,
        'education': ?education,
        'skills': ?skills,
        'projects': ?projects,
      },
      receiveTimeout: _aiTimeout,
    );
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> tailorResume({
    required String jobDescription,
    String? summary,
    List<Map<String, dynamic>>? experience,
    List<String>? skills,
    List<Map<String, dynamic>>? projects,
  }) async {
    final resp = await apiService.post(
      '/ai/resume/tailor',
      data: {
        'jobDescription': jobDescription,
        if (summary != null && summary.isNotEmpty) 'summary': summary,
        'experience': ?experience,
        'skills': ?skills,
        'projects': ?projects,
      },
      receiveTimeout: _aiTimeout,
    );
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> reviewResume({
    String? summary,
    List<Map<String, dynamic>>? experience,
    List<Map<String, dynamic>>? education,
    List<String>? skills,
    List<Map<String, dynamic>>? projects,
  }) async {
    final resp = await apiService.post(
      '/ai/resume/review',
      data: {
        if (summary != null && summary.isNotEmpty) 'summary': summary,
        'experience': ?experience,
        'education': ?education,
        'skills': ?skills,
        'projects': ?projects,
      },
      receiveTimeout: _aiTimeout,
    );
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> careerInsights({
    String? summary,
    List<Map<String, dynamic>>? experience,
    List<String>? skills,
    List<Map<String, dynamic>>? projects,
    String? targetRole,
  }) async {
    final resp = await apiService.post(
      '/ai/career/insights',
      data: {
        if (summary != null && summary.isNotEmpty) 'summary': summary,
        'experience': ?experience,
        'skills': ?skills,
        'projects': ?projects,
        if (targetRole != null && targetRole.isNotEmpty) 'targetRole': targetRole,
      },
      receiveTimeout: _aiTimeout,
    );
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> interviewPrep({
    List<Map<String, dynamic>>? experience,
    List<Map<String, dynamic>>? projects,
    List<String>? skills,
    String? jobDescription,
  }) async {
    final resp = await apiService.post(
      '/ai/interview/prep',
      data: {
        'experience': ?experience,
        'projects': ?projects,
        'skills': ?skills,
        if (jobDescription != null && jobDescription.isNotEmpty) 'jobDescription': jobDescription,
      },
      receiveTimeout: _aiTimeout,
    );
    return resp.data['data'] as Map<String, dynamic>;
  }
}
