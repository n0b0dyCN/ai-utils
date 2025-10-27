# Review Rust Code Commands: cargo clippy & cargo fmt

Here are the essential terminal commands to review and improve Rust code using the built-in Cargo tools.

These tools are standard in the Rust ecosystem:

  * `cargo fmt`: A code formatter that automatically reformats your code to follow community style guidelines.
  * `cargo clippy`: A powerful linter that catches common mistakes, identifies anti-patterns, and suggests more idiomatic ways to write your Rust code.

-----

### 1\. `cargo fmt` (Code Formatting)

Always start by ensuring the code is formatted correctly.

#### Check for Formatting Issues

This command will check if your code is formatted correctly without making any changes. It's perfect for Continuous Integration (CI) pipelines.

```bash
cargo fmt -- --check
```

  * If the code is formatted correctly, it will exit silently.
  * If formatting issues are found, it will print the files that need to be reformatted and exit with an error.

#### Automatically Format the Code

This command will find all formatting issues and fix them in place.

```bash
cargo fmt
```

  * Run this before committing your code to ensure everything conforms to the standard Rust style.

-----

### 2\. `cargo clippy` (Code Linting)

After formatting, use Clippy to find potential bugs and style improvements.

#### Run Clippy and Show Warnings

This is the most common command. It analyzes your code and prints a list of warnings and suggestions.

```bash
cargo clippy
```

  * Review each warning carefully. Clippy often provides excellent explanations and links to documentation.

#### Automatically Fix Simple Clippy Issues

Clippy can automatically fix many of the issues it finds.

```bash
cargo clippy --fix
```

  * This will apply simple, "safe" fixes directly to your code.
  * **Important:** Always re-run `cargo clippy` (and `cargo test`) after running this command to review the changes and ensure no new warnings were introduced.

#### Run Clippy for CI (Strict Mode)

In a CI environment, you want to fail the build if *any* Clippy warnings are found. This command treats all warnings as errors.

```bash
cargo clippy -- -D warnings
```

  * The `-D warnings` flag tells the Rust compiler (which Clippy uses) to "Deny" (treat as errors) all "warnings".

-----

### Suggested Review Workflow

Here is a simple, effective workflow to follow:

1.  **Check Status:** Before starting, make sure your git workspace is clean. `git status` should show no uncommitted changes. This ensures your formatting/linting changes are in a separate, clean commit.
    ```bash
    git status
    ```
2.  **Format:** Run `cargo fmt` to apply standard formatting.
    ```bash
    cargo fmt
    ```
3.  **Lint:** Run `cargo clippy` to see all suggestions.
    ```bash
    cargo clippy
    ```
4.  **Auto-fix:** Run `cargo clippy --fix` to fix the easy issues.
    ```bash
    cargo clippy --fix
    ```
5.  **Fix the warnings that are not fixed by the auto-fix.**
6.  **Review:** Run `cargo clippy` again to review any remaining warnings that require manual changes. Manually fix any lingering issues.
7.  **Test:** Run `cargo test` to make sure your changes didn't break anything.
    ```bash
    cargo test
    ```
8.  **Commit:** Once all checks pass and your workspace is clean other than these changes, commit the automated fixes.
    ```bash
    git add .
    git commit -m "style: Apply cargo fmt and clippy fixes"
    ```