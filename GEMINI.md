# Project Instructions

## Development Standards

### 1. Test-Driven Design (TDD)
- Adhere strictly to Test-Driven Design principles.
- Do not cut corners with tests or modify them solely to pass.
- Implement a comprehensive testing strategy including:
    - **Unit Tests:** For business logic and data models.
    - **Widget Tests:** For individual UI components.
    - **Golden Tests:** To ensure visual consistency and prevent regressions.
    - **Integration Tests:** For end-to-end user flows.
    - **Component/Scenario Tests:** For complex interactions.

### 2. Documentation
- Maintain a thorough and up-to-date record of project documentation.
- Update documentation immediately whenever changes are made to features, architecture, or configurations.

### 3. Visual Validation
- Upon completion of a feature, capture a screenshot or screen recording of it running on an iOS or Android emulator.
- Use tools like integration tests or manual runs to facilitate this process.
- This ensures the final product meets the required standards and provides visual proof of functionality.

### 4. Design System & Theming
- **NO HARD-CODED STYLES:** All colors, spacing, and typography must be sourced from a centralized design system (e.g., `AppTheme` or `DesignSystem` class).
- **Theme Support:** Maintain full support for Light, Dark, and System Default themes.
- **Visual Consistency:** Use defined theme tokens to ensure a cohesive look and feel across all screens.

## Progress Tracker

- [x] Initial Project Setup
- [x] Implement Timeline Screen (TDD)
- [x] Implement New Entry Screen (TDD)
    - [x] Screen Logic/Model
    - [x] Screen Widget Implementation
    - [x] Golden Tests
    - [x] Integration (Navigation from Home)
- [x] Implement Settings & Backup Screen (TDD)
    - [x] Screen Widget Implementation
    - [x] Golden Tests
    - [x] Navigation from Bottom Bar
    - [x] Biometric Lock Implementation
    - [x] Dropdown-based Theme Selection
    - [x] Standardized Design System Integration
- [x] Implement Calendar Navigation Screen (TDD)
    - [x] Screen Widget Implementation
    - [x] Golden Tests
    - [x] Integration (Navigation from Bottom Bar)
- [x] Implement Side Navigation Drawer (TDD)
    - [x] Widget Implementation
    - [x] Golden Tests
    - [x] Integration (Global access from screens)
- [x] Implement Analytics/Stats Screen (TDD)
    - [x] Logic/Helper Implementation
    - [x] Screen Widget Implementation
    - [x] Golden Tests
    - [x] Integration (Navigation from Bottom Bar & Drawer)
- [ ] Final Polishing & Deployment Preparation
