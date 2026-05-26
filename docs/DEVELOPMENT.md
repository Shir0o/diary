# Development Workflow Guidelines

This document outlines the coding standards, testing requirements, and procedures for developers working on this project.

## Test-Driven Development (TDD)

We strictly follow Test-Driven Development (TDD):
1. **Write a Test First:** Before writing any implementation code, write a test that describes the expected behavior and watch it fail.
2. **Implement:** Write the minimum amount of code required to pass the test.
3. **Refactor:** Clean up the implementation while ensuring the tests continue to pass.

### Coverage Requirement
- **95% or higher test coverage** is required for all new or modified code.
- Coverage should be measured using standard coverage tools (`flutter test --coverage` or language-equivalent).

## Documentation and Logs
- Always reference the [Documentation Index](INDEX.md) and [CHANGELOG.md](../CHANGELOG.md) before starting a task to gain context.
- Keep documentation, changelogs, and release notes concise.
- Update all logs and indices upon task completion.
