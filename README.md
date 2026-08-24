# AI Resume Maker 🚀

> **Build a resume that gets noticed.**

A production-style, cross-platform **AI Resume Maker** built with **Flutter + Dart** on the frontend and **Node.js + Express + MongoDB** on the backend.

The application combines structured resume building, professional templates, ATS-oriented resume intelligence, AI-assisted writing, job-description analysis, resume-to-job matching, career insights, interview preparation, cover-letter generation, PDF export, cloud persistence, and a protected administrator console.

---

## ✨ Why AI Resume Maker?

Creating a strong resume is more than filling out a template. A good resume needs:

- Clear and professional writing
- ATS-friendly structure
- Relevant skills and keywords
- Role-specific tailoring
- Consistent formatting
- Action-oriented experience descriptions
- Easy export and sharing

**AI Resume Maker** brings these capabilities together in one application so users can create, improve, evaluate, and tailor resumes from a single workspace.

---

## 🌟 Core Features

### 👤 User Experience

- Secure user registration and login
- JWT-based authentication
- Refresh-token based session handling
- Personalized dashboard
- Resume creation, editing, saving, and deletion
- Cloud-backed resume persistence
- Profile management
- Light / Dark theme support
- Responsive layouts for mobile, tablet, and desktop

### 📄 Resume Builder

- Structured resume editor
- Multiple resume sections:
  - Personal information
  - Professional summary
  - Education
  - Experience
  - Projects
  - Skills
  - Certifications
  - Languages
  - Achievements
  - References
- Resume preview
- Professional PDF export
- Auto-save / cloud synchronization
- Reusable resume data model

### 🎨 Resume Templates

The application includes **16 distinct resume templates**, including:

- Modern
- Minimal ATS
- Professional
- Creative
- Executive
- Tech Developer
- Data & Analytics
- Corporate
- Student & Fresher
- Academic CV
- Marketing & Growth
- Finance & Banking
- Elegant Monochrome
- Bold Header
- Clean Two-Column
- Compact ATS Pro

Templates are designed for different career profiles instead of simply changing colors around the same layout.

### 🤖 AI Career Intelligence

AI-assisted capabilities include:

- Professional summary generation
- Experience bullet improvement
- Project description improvement
- Achievement writing
- Cover-letter generation
- Job-description analysis
- Resume-to-job matching
- Resume tailoring
- Resume review
- Career insights
- Interview preparation

The backend also contains a **local Resume Intelligence Engine** for deterministic resume analysis and graceful fallback behavior.

### 📊 Resume Intelligence / ATS

- ATS-oriented resume scoring
- Resume completeness analysis
- Keyword matching
- Skill recommendations
- Missing-skill identification
- Job-description keyword extraction
- Resume-to-job match analysis
- Actionable improvement suggestions

> Deterministic scoring and matching are handled locally rather than relying on an LLM to invent a score.

### 🛡️ Admin Console

A protected administrator area provides functionality for:

- User management
- Resume management
- Platform analytics
- Administrative overview
- Resume/user statistics
- Role-protected access

---

# 🏗️ Architecture

```text
┌──────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                          │
│                                                              │
│        Flutter + Dart                                        │
│        Android • iOS • Web • Windows • macOS • Linux         │
└──────────────────────────────┬───────────────────────────────┘
                               │
                               │ REST API / JSON
                               ▼
┌──────────────────────────────────────────────────────────────┐
│                         API LAYER                            │
│                                                              │
│        Node.js + Express                                     │
│        Authentication • Validation • CORS • Rate Limiting    │
│        Helmet • Error Handling                               │
└───────────────┬──────────────────────────────┬───────────────┘
                │                              │
                │                              │
                ▼                              ▼
┌───────────────────────────┐      ┌───────────────────────────┐
│      DATA LAYER           │      │       AI LAYER            │
│                           │      │                           │
│ MongoDB / Mongoose        │      │ Gemini Provider           │
│ Users                     │      │            │              │
│ Resumes                   │      │            ▼              │
│ Templates                 │      │ Local Resume             │
│ Feedback                  │      │ Intelligence Engine      │
└───────────────────────────┘      └───────────────────────────┘

                               │
                               ▼
                    ┌─────────────────────┐
                    │   PDF Generation    │
                    │   Preview / Export  │
                    └─────────────────────┘
```

---

# 🧱 Frontend Architecture

The Flutter application follows a layered architecture with reactive state management:

```text
Screens / Widgets
       │
       ▼
Riverpod Providers / Notifiers
       │
       ▼
Repositories
       │
       ▼
Services
       │
       ├── Dio HTTP Client
       ├── Secure Storage
       ├── Shared Preferences
       └── PDF Generator
```

### Major frontend layers

| Layer | Responsibility |
|---|---|
| `lib/core/` | Design system, theme, reusable widgets, utilities |
| `lib/models/` | Typed application and resume data models |
| `lib/providers/` | Reactive state management with Riverpod |
| `lib/repositories/` | Data/API access abstraction |
| `lib/routes/` | GoRouter navigation and route guards |
| `lib/screens/` | Authentication, dashboard, resume, AI, profile, settings and admin UI |
| `lib/services/` | API client, secure storage, preferences and PDF services |

---

# 🔧 Technology Stack

## Frontend

- **Flutter**
- **Dart**
- **Material 3**
- **Riverpod**
- **GoRouter**
- **Dio**
- **Flutter Secure Storage**
- **Shared Preferences**
- **Google Fonts**
- **PDF**
- **Printing**

## Backend

- **Node.js**
- **Express.js**
- **MongoDB**
- **Mongoose**
- **JWT**
- **bcryptjs**
- **Express Validator**
- **Helmet**
- **CORS**
- **Express Rate Limit**
- **dotenv**

## AI

- **Google Gemini** for configured natural-language AI tasks
- **Local Resume Intelligence Engine** as a zero-cost deterministic/fallback layer

The backend is designed so that AI-assisted functionality can gracefully fall back to local intelligence when the external AI provider is unavailable or unconfigured.

---

# 📁 Project Structure

```text
ai_resume_maker/
│
├── android/                 # Android platform
├── ios/                     # iOS platform
├── linux/                   # Linux platform
├── macos/                   # macOS platform
├── windows/                 # Windows platform
├── web/                     # Flutter Web configuration
│
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   ├── theme/
│   │   ├── utils/
│   │   └── widgets/
│   │
│   ├── models/
│   ├── providers/
│   ├── repositories/
│   ├── routes/
│   ├── screens/
│   │   ├── auth/
│   │   ├── dashboard/
│   │   ├── resume/
│   │   ├── admin/
│   │   ├── profile/
│   │   └── settings/
│   │
│   └── services/
│       ├── pdf/
│       └── ...
│
├── backend/
│   ├── config/
│   ├── controllers/
│   ├── data/
│   ├── middleware/
│   ├── models/
│   ├── routes/
│   ├── services/
│   │   ├── providers/
│   │   └── resumeIntelligenceEngine.js
│   ├── test/
│   ├── package.json
│   └── server.js
│
├── test/
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

---

# 🚀 Getting Started

## Prerequisites

Install:

- Flutter SDK
- Dart SDK (included with Flutter)
- Node.js
- npm
- MongoDB / MongoDB Atlas
- Git

Verify:

```bash
flutter --version
dart --version
node --version
npm --version
git --version
```

---

# ⚙️ 1. Clone the Repository

```bash
git clone https://github.com/Heerrr166/flutter-ai-resume-maker.git
cd flutter-ai-resume-maker
```

---

# 📦 2. Install Flutter Dependencies

```bash
flutter pub get
```

---

# 🖥️ 3. Configure the Backend

```bash
cd backend
npm install
```

Create:

```text
backend/.env
```

Use `backend/.env.example` as the template.

### Important

Never commit:

```text
backend/.env
```

The `.env` file may contain:

- MongoDB credentials
- JWT secrets
- AI API keys
- Admin credentials
- Other private configuration

Only commit the example configuration with placeholders.

---

# 🗄️ 4. Configure MongoDB

Set your MongoDB connection string in:

```env
MONGO_URI=your_mongodb_connection_string
```

For production, use a secure MongoDB deployment such as MongoDB Atlas.

---

# 🔐 5. Configure Authentication Secrets

Example:

```env
JWT_SECRET=replace-with-a-strong-secret
JWT_EXPIRES_IN=1d
REFRESH_TOKEN_SECRET=replace-with-another-strong-secret
REFRESH_TOKEN_EXPIRES_IN=7d
```

Do not use example secrets in a real deployment.

---

# 🤖 6. Configure Gemini

If AI-powered natural-language generation is required, configure:

```env
GEMINI_API_KEY=your_gemini_api_key
GEMINI_MODEL=gemini-2.0-flash
```

The project also contains a local Resume Intelligence Engine for deterministic analysis and fallback behavior.

---

# ▶️ 7. Run the Backend

From:

```text
ai_resume_maker/backend
```

Run:

```bash
npm start
```

Development mode:

```bash
npm run dev
```

The backend uses:

```text
http://localhost:5000
```

by default.

---

# ▶️ 8. Run Flutter

Open another terminal in the project root:

```bash
flutter pub get
flutter run -d chrome
```

For a release web build:

```bash
flutter build web --release
```

The production files are generated in:

```text
build/web/
```

---

# 🌐 Flutter Web Production API

The frontend can be built with a production API URL using:

```bash
flutter build web --release --dart-define=API_URL=https://YOUR-BACKEND-URL/api
```

This keeps the local development fallback while allowing the deployed frontend to communicate with a deployed backend.

---

# 📱 Mobile / LAN Development

For testing Flutter Web on a phone connected to the same network:

1. Start the backend on the development machine.
2. Bind the backend to `0.0.0.0`.
3. Allow the backend port through Windows Firewall if required.
4. Serve the Flutter Web build/server on the machine's LAN IP.
5. Open the machine's LAN address from the phone.

Example:

```text
http://YOUR-PC-IP:8081
```

Both devices must be able to reach the same network.

---

# 🧪 Testing & Quality Checks

### Flutter analysis

```bash
dart analyze lib
```

or:

```bash
flutter analyze
```

### Flutter tests

```bash
flutter test
```

### Production Web build

```bash
flutter build web --release
```

### Backend tests

```bash
cd backend
npm test
```

---

# 🔒 Security Principles

This project follows several security practices:

- JWT authentication
- Refresh-token flow
- Password hashing with bcrypt
- Input validation
- CORS configuration
- Helmet security headers
- API rate limiting
- Environment-based secrets
- No credentials hardcoded into application source
- Role-protected admin routes
- No candidate resume data intentionally written into AI failure logs

### Never commit

```text
.env
.env.*
backend/.env
API keys
JWT secrets
database passwords
admin passwords
private tokens
```

---

# 🎯 Design Goals

The application was designed to feel like a polished commercial resume SaaS product rather than a basic academic demo.

Key UI/UX priorities:

- Clean visual hierarchy
- Professional typography
- Consistent spacing
- Reusable components
- Light and dark themes
- Responsive layouts
- Mobile-first considerations
- Desktop productivity
- Accessible interactions
- Minimal visual clutter

---

# 📊 Resume Intelligence Pipeline

```text
Resume Data
     │
     ▼
Structured Resume Model
     │
     ├───────────────┐
     ▼               ▼
ATS / Keyword     AI Writing
Analysis          Assistance
     │               │
     ▼               ▼
Score + Gaps      Improved Content
     │               │
     └───────┬───────┘
             ▼
      Better Resume
             │
             ▼
       PDF Export
```

---

# 🧠 Hybrid AI Strategy

The application intentionally does not depend entirely on an external LLM.

### Natural-language tasks

Gemini can assist with:

- Summary writing
- Experience rewriting
- Project rewriting
- Achievement writing
- Cover letters
- Job-description analysis
- Resume tailoring
- Career insights
- Interview preparation

### Deterministic tasks

The local engine handles important calculations and structured analysis such as:

- ATS scoring
- Resume completeness
- Literal keyword matching
- Skill recommendations
- Skill-gap analysis

This separation makes the application more predictable and allows core resume intelligence to remain useful even when the external AI provider is unavailable.

---

# 🛡️ Admin Architecture

```text
User
 │
 ▼
Authentication
 │
 ▼
JWT / Role Check
 │
 ├── User → User Dashboard
 │
 └── Admin → Admin Console
                 │
                 ├── Users
                 ├── Resumes
                 └── Analytics
```

---

# 🗺️ Roadmap

Potential future improvements:

- [ ] Resume version history
- [ ] More advanced ATS scoring
- [ ] Job recommendation engine
- [ ] LinkedIn profile optimization
- [ ] Portfolio website generator
- [ ] Multi-language resumes
- [ ] Resume sharing links
- [ ] QR-based resume sharing
- [ ] More premium templates
- [ ] Advanced analytics
- [ ] Improved deployment automation
- [ ] Automated CI/CD

---

# 👥 Contributors

This project was developed collaboratively by:

### 👩‍💻 Heer — `Heerrr166`

**Primary responsibilities:**

- Flutter application development
- UI/UX implementation
- Responsive mobile, tablet and desktop layouts
- Dashboard experience
- Resume Hub and template selection
- Authentication screens
- Admin Console interface
- Visual design system and reusable UI components
- Frontend integration and usability improvements
- Cross-platform interface testing

GitHub: https://github.com/Heerrr166

---

### 👨‍💻 Kathan — `Kathan-x`

**Primary responsibilities:**

- Backend/API architecture and integration
- Node.js / Express development
- Authentication and API flows
- MongoDB data integration
- AI service integration and fallback architecture
- Resume intelligence logic
- PDF generation/integration
- Frontend-backend API integration
- Deployment preparation and environment configuration
- Git/GitHub collaboration and project infrastructure

GitHub: https://github.com/Kathan-x

---

## 🤝 Collaboration Model

The project follows a shared development workflow:

```text
Heer
 │
 ├── Frontend / UI
 ├── Responsive UX
 └── Admin Experience
        │
        ▼
   Shared GitHub
        ▲
        │
 ├── Backend / API
 ├── AI / Intelligence
 ├── PDF / Integration
 └── Deployment
 │
Kathan
```

Both contributors collaborated on integration, testing, debugging, and final product polishing.

> The contribution section describes the team's primary areas of responsibility; individual commits may span multiple areas.

---

# 📜 Academic Project

**Course:** Cross Platform Mobile Application Development  
**Project:** AI Resume Maker  
**Technology:** Flutter + Dart + Node.js + Express + MongoDB + AI  
**University:** GLS University  
**Programme:** iMCA / BCA Dual  
**Semester:** V

The project proposal defines the application around AI-assisted resume creation, professional summaries, skill recommendations, cover letters, PDF export, cloud storage, and an administrative module. fileciteturn22file0

---

# 📄 Project Scope

The documented project scope includes:

- User registration and login
- Resume creation and editing
- Multiple resume templates
- AI professional summaries
- AI skill recommendations
- AI cover letters
- Resume preview
- PDF export
- Cloud backup
- Admin user/template management
- User activity monitoring
- AI usage monitoring
- Reports

The proposal also identifies Flutter, Dart, Node.js, Express.js, MongoDB Atlas, JWT authentication, cloud services, AI APIs, Git, and GitHub as part of the technology ecosystem. fileciteturn22file1

---

# ⭐ Project Highlights

```text
16 Resume Templates
        +
AI-Assisted Writing
        +
ATS / Resume Intelligence
        +
Job Matching
        +
Career Tools
        +
PDF Export
        +
Cloud Persistence
        +
Admin Console
        +
Responsive Flutter UI
        =
Complete Resume & Career Workspace
```

---

# 📌 Disclaimer

This project is an academic / portfolio software project. AI-generated content should be reviewed by the user before being included in a final job application.

The application is designed to assist users with resume preparation; it does not guarantee employment, interview selection, ATS acceptance, or recruiter response.

---

# ❤️ Built With

**Flutter • Dart • Node.js • Express • MongoDB • Riverpod • GoRouter • Dio • JWT • Gemini • PDF • GitHub**

If this project helps you, consider giving the repository a ⭐.
