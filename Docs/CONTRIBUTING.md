# Contributing to Holdr

Thank you for your interest in contributing to **Holdr**! We welcome contributions from everyone. By participating in this project, you help make it better for the entire community.

## 🛠 Getting Started

1.  **Fork the repository** on GitHub.
2.  **Clone your fork** locally:
    ```bash
    git clone https://github.com/your-username/Holdr.git
    cd Holdr
    ```
3.  **Run the setup script** to ensure you have all dependencies:
    ```bash
    ./scripts/setup_dev.sh
    ```
4.  **Open the project** in Xcode by double-clicking `Package.swift`.

## 💻 Development Workflow

1.  Create a new branch for your feature or bug fix:
    ```bash
    git checkout -b feature/my-new-feature
    ```
2.  Make your changes.
3.  **Test your changes**:
    - Run the app locally to ensure it works as expected.
    - Run the test suite: `Cmd+U` in Xcode or `swift test` in terminal.
4.  **Lint your code** (optional but recommended):
    ```bash
    ./scripts/lint.sh
    ```

## 📝 Pull Request Guidelines

-   Provide a clear and descriptive title for your Pull Request.
-   Explain what changes you made and why.
-   Link to any relevant issues.
-   Ensure all tests pass before submitting.
-   Include screenshots or GIFs for UI changes.

## 🎨 Code Style

-   Follow standard Swift API Design Guidelines.
-   Use clear and descriptive variable names.
-   Keep functions small and focused.
-   Add comments for complex logic.

## 🐛 Reporting Bugs

If you find a bug, please create a new issue on GitHub. Include:
-   Steps to reproduce the bug.
-   Expected behavior vs. actual behavior.
-   Screenshots or logs if applicable.
-   Your macOS version and app version.

Thank you for contributing! 🚀
