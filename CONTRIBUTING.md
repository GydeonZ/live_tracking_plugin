# Contributing to Live Tracking Plugin

First off, thanks for taking the time to contribute! 🎉

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the issue list as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible:

* **Use a clear and descriptive title**
* **Describe the exact steps which reproduce the problem**
* **Provide specific examples to demonstrate the steps**
* **Describe the behavior you observed after following the steps**
* **Explain which behavior you expected to see instead and why**
* **Include screenshots and animated GIFs if possible**
* **Include your environment details** (Flutter version, device/emulator, OS version)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

* **Use a clear and descriptive title**
* **Provide a step-by-step description of the suggested enhancement**
* **Provide specific examples to demonstrate the steps**
* **Describe the current behavior** and **the expected behavior**
* **Explain why this enhancement would be useful**

### Pull Requests

* Fill in the required template
* Follow the styleguides
* Include appropriate test cases
* Document new code
* End all files with a newline

## Styleguides

### Git Commit Messages

* Use the present tense ("Add feature" not "Added feature")
* Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
* Limit the first line to 72 characters or less
* Reference issues and pull requests liberally after the first line

### Dart/Flutter Code Style

* Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
* Use meaningful variable and function names
* Add comments for complex logic
* Run `flutter format` before committing
* Run `flutter analyze` and fix any issues

### Kotlin Code Style

* Follow the [Kotlin Coding Conventions](https://kotlinlang.org/docs/coding-conventions.html)
* Use camelCase for variables and methods
* Use PascalCase for class names

### Swift Code Style

* Follow the [Swift Style Guide](https://google.github.io/swift/)
* Use meaningful names
* Add comments for complex logic

### Documentation

* Use clear and concise language
* Include code examples where appropriate
* Update README.md if you change functionality
* Add comments to explain the "why" not just the "what"

## Development Setup

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/live_tracking_plugin.git
   ```
3. Add upstream remote:
   ```bash
   git remote add upstream https://github.com/yourusername/live_tracking_plugin.git
   ```
4. Create a new branch:
   ```bash
   git checkout -b feature/amazing-feature
   ```
5. Make your changes
6. Run tests:
   ```bash
   flutter test
   ```
7. Format code:
   ```bash
   flutter format .
   ```
8. Analyze code:
   ```bash
   flutter analyze
   ```
9. Commit your changes:
   ```bash
   git commit -m 'Add amazing feature'
   ```
10. Push to your branch:
    ```bash
    git push origin feature/amazing-feature
    ```
11. Open a Pull Request

## Testing

* Add tests for any new functionality
* Ensure all tests pass before submitting a PR
* Test on both iOS and Android if possible
* Test with different accuracy levels and update intervals

## Release Process

1. Update version in `pubspec.yaml`
2. Update `CHANGELOG.md` with changes
3. Create a git tag: `git tag -a v0.1.0 -m "Release v0.1.0"`
4. Push the tag: `git push upstream v0.1.0`
5. Publish to pub.dev: `flutter pub publish`

## Questions?

Feel free to open an issue or contact the maintainers. We're here to help!

## Recognition

Contributors will be recognized in the project README and CHANGELOG. Thank you for your contributions!
