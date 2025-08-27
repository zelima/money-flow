# Automated Release System

This document describes the automated release system implemented for the Money Flow project using GitHub Actions and semantic versioning.

## Overview

The automated release system automatically creates GitHub releases when pull requests are merged to the `main` or `develop` branches. It analyzes commit messages and PR titles to determine the appropriate version bump according to semantic versioning conventions.

## How It Works

### 1. Trigger Conditions

The workflow is triggered in two scenarios:

- **Automatic**: When a pull request is merged to `main` or `develop` branches
- **Manual**: Via GitHub Actions workflow dispatch with custom version type selection

### 2. Version Detection

The system analyzes PR titles and descriptions for specific keywords:

#### Major Version (Breaking Changes)
- `!feat:` - Breaking feature change
- `!fix:` - Breaking bug fix
- `breaking change` - Any breaking change
- `major` - Explicit major version bump
- `breaking` - Breaking change indicator

#### Minor Version (New Features)
- `feat:` - New feature
- `feature:` - New feature
- `minor` - Explicit minor version bump
- `enhancement` - Feature enhancement

#### Patch Version (Bug Fixes & Improvements)
- `fix:` - Bug fix
- `bugfix:` - Bug fix
- `patch:` - Patch update
- `hotfix:` - Emergency fix
- `docs:` - Documentation update
- `style:` - Code style changes
- `refactor:` - Code refactoring
- `perf:` - Performance improvement
- `test:` - Test updates
- `chore:` - Maintenance tasks

### 3. Version Calculation

The system:
1. Reads the current version from git tags or defaults to `0.1.0`
2. Applies the appropriate version bump based on detected keywords
3. Creates a new semantic version following the pattern `MAJOR.MINOR.PATCH`

### 4. Release Creation

For each release, the system:
1. Creates a GitHub release with the new version tag
2. Generates release notes from PR information
3. Updates version files in the repository
4. Commits and pushes version updates

## Usage Examples

### Automatic Release via PR

#### Feature Addition
```markdown
Title: feat: Add new budget visualization charts
Description: Implements interactive charts for budget analysis
```
**Result**: Minor version bump (e.g., `1.2.0` → `1.3.0`)

#### Bug Fix
```markdown
Title: fix: Resolve data loading issue in dashboard
Description: Fixes the dashboard not loading budget data correctly
```
**Result**: Patch version bump (e.g., `1.2.0` → `1.2.1`)

#### Breaking Change
```markdown
Title: !feat: Redesign API response format
Description: Breaking change: API now returns data in new format
```
**Result**: Major version bump (e.g., `1.2.0` → `2.0.0`)

### Manual Release

1. Navigate to **Actions** → **Automated Release**
2. Click **Run workflow**
3. Select version type:
   - `major` - Breaking changes
   - `minor` - New features
   - `patch` - Bug fixes and improvements
4. Click **Run workflow**

## Workflow Structure

### Jobs

1. **determine-version**: Analyzes PR content and calculates new version
2. **create-release**: Creates GitHub release and updates version files
3. **release-summary**: Provides comprehensive release summary

### Outputs

- `version_type`: Type of version bump (major/minor/patch)
- `new_version`: Calculated new version number
- `should_release`: Whether a release should be created
- `release_notes`: Generated release notes

## Configuration

### Required Dependencies

- `semver==3.0.2` - Python semantic versioning library
- `actions/create-release@v1` - GitHub release creation action

### Environment Variables

- `GITHUB_TOKEN` - Automatically provided by GitHub Actions
- `PYTHON_VERSION` - Set to `3.11.9` for consistency

## Best Practices

### Commit Message Format

Follow the conventional commit format:
```
<type>[!]: <description>

[optional body]

[optional footer]
```

### PR Title Guidelines

- Use descriptive, clear titles
- Include appropriate keywords for version detection
- Prefix breaking changes with `!`
- Use present tense ("Add feature" not "Added feature")

### Version Management

- Let the system handle automatic versioning
- Use manual releases sparingly
- Review release notes before publishing
- Tag releases with meaningful descriptions

## Troubleshooting

### Common Issues

1. **Release not created**: Check if PR was actually merged
2. **Wrong version type**: Verify PR title contains correct keywords
3. **Permission errors**: Ensure `GITHUB_TOKEN` has appropriate permissions

### Debugging

- Check workflow logs in GitHub Actions
- Verify PR title and description format
- Ensure semantic versioning library is available
- Check git tag history for version conflicts

## Integration with CI/CD

The automated release system integrates with existing CI/CD pipelines:

- **Pre-commit**: Code quality checks before commits
- **Integration Tests**: Ensures code quality before release
- **Web App Tests**: Frontend validation
- **API Tests**: Backend validation

All tests must pass before a release can be created.

## Security Considerations

- Uses GitHub-provided `GITHUB_TOKEN` for authentication
- No external API keys or secrets required
- Version updates are committed with `[skip ci]` to prevent loops
- Release creation is limited to merged PRs and manual dispatch

## Future Enhancements

Potential improvements to consider:

- **Changelog Generation**: Automatic changelog from commit history
- **Release Templates**: Customizable release note templates
- **Version Validation**: Integration with package managers
- **Multi-branch Support**: Support for additional branch patterns
- **Release Notifications**: Slack/email notifications for releases
