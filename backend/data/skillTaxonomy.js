// Curated skill clusters used by the local Resume Intelligence Engine to
// recommend related skills. Each cluster lists skills that commonly appear
// together on resumes in that domain. This is intentionally a fixed,
// human-curated list (not learned/generated) so recommendations are
// explainable and never invent unfamiliar technologies.
const SKILL_CLUSTERS = [
  {
    key: 'frontend',
    skills: [
      'JavaScript', 'TypeScript', 'React', 'Redux', 'Next.js', 'Vue.js', 'Angular',
      'HTML5', 'CSS3', 'Tailwind CSS', 'Sass', 'Webpack', 'Vite', 'Flutter', 'Dart',
      'Responsive Design', 'Accessibility (a11y)', 'Jest', 'Cypress',
    ],
  },
  {
    key: 'backend',
    skills: [
      'Node.js', 'Express.js', 'Python', 'Django', 'Flask', 'Java', 'Spring Boot',
      'C#', '.NET', 'Ruby on Rails', 'Go', 'REST APIs', 'GraphQL', 'Microservices',
      'PostgreSQL', 'MySQL', 'MongoDB', 'Redis', 'RabbitMQ',
    ],
  },
  {
    key: 'data',
    skills: [
      'Python', 'SQL', 'Pandas', 'NumPy', 'Data Analysis', 'Data Visualization',
      'Tableau', 'Power BI', 'Machine Learning', 'TensorFlow', 'PyTorch',
      'Scikit-learn', 'ETL Pipelines', 'Apache Spark', 'R',
    ],
  },
  {
    key: 'mobile',
    skills: [
      'Flutter', 'Dart', 'React Native', 'Swift', 'SwiftUI', 'Kotlin', 'Java',
      'Android SDK', 'iOS Development', 'Firebase', 'Mobile UI Design',
    ],
  },
  {
    key: 'devops',
    skills: [
      'Docker', 'Kubernetes', 'CI/CD', 'GitHub Actions', 'Jenkins', 'AWS', 'Azure',
      'Google Cloud Platform', 'Terraform', 'Linux', 'Nginx', 'Monitoring & Logging',
      'Bash Scripting',
    ],
  },
  {
    key: 'design',
    skills: [
      'Figma', 'Adobe XD', 'UI Design', 'UX Research', 'Wireframing', 'Prototyping',
      'Design Systems', 'User Testing', 'Adobe Photoshop', 'Adobe Illustrator',
    ],
  },
  {
    key: 'product_business',
    skills: [
      'Project Management', 'Agile Methodology', 'Scrum', 'Jira', 'Stakeholder Management',
      'Product Roadmapping', 'Market Research', 'Business Analysis', 'Communication',
      'Presentation Skills', 'Microsoft Excel', 'Data-Driven Decision Making',
    ],
  },
  {
    key: 'general_professional',
    skills: [
      'Team Leadership', 'Problem Solving', 'Time Management', 'Cross-functional Collaboration',
      'Technical Writing', 'Mentoring', 'Customer Communication', 'Critical Thinking',
    ],
  },
];

module.exports = { SKILL_CLUSTERS };
