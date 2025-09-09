# 🚗 GitHub Workflows & Templates

This directory contains GitHub Actions workflows and templates for the Car Dealership project.

## 🔄 Workflows

### `ci-cd.yml` - Complete CI/CD Pipeline
- **Tests**: Django, Node.js API, and React frontend
- **Integration**: Full application testing with endpoint validation  
- **Deployment**: Automated staging and production deployment
- **Caching**: Optimized dependency caching for faster builds

### `test.yml` - Quick Testing
- **Purpose**: Fast feedback on basic functionality
- **Runs on**: Every push and pull request
- **Tests**: Dependency installation and React build

## 🛠️ Configuration Files

### `dependabot.yml`
- **Python**: Weekly updates for Django dependencies
- **Node.js**: Weekly updates for both API and frontend
- **GitHub Actions**: Keep workflow actions up to date

### `pull_request_template.md`
- Comprehensive checklist for code reviews
- UI/UX validation requirements
- Testing and technical verification

## 📋 Issue Templates

### Bug Reports (`ISSUE_TEMPLATE/bug_report.md`)
- Structured bug reporting with environment details
- Screenshots and console log sections
- Device-specific information for mobile issues

### Feature Requests (`ISSUE_TEMPLATE/feature_request.md`)
- Detailed feature descriptions with motivation
- UI/UX and technical considerations
- Acceptance criteria and mockup sections

## 🚀 How Workflows Trigger

| Event | Quick Test | Full CI/CD |
|-------|------------|------------|
| Push to `main` | ✅ | ✅ |
| Push to `develop` | ❌ | ✅ |
| Pull Request | ✅ | ✅ |
| Manual | ❌ | ✅ |

## 🎯 Workflow Features

- **🔒 Security**: Vulnerability scanning with Trivy
- **📦 Artifacts**: React builds stored between jobs
- **🌍 Environments**: Staging and production with protection rules
- **⚡ Performance**: Dependency caching and parallel jobs
- **📊 Reporting**: Test coverage and deployment status

## 💡 Usage Tips

1. **Before Creating PR**: Ensure local tests pass with `./start.sh`
2. **Bug Reports**: Use the template for consistent issue quality
3. **Feature Requests**: Include mockups and technical considerations
4. **Dependencies**: Let Dependabot handle routine updates

---
**Note**: Workflows will automatically run when you push changes to GitHub!
