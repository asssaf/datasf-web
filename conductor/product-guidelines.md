# Product Guidelines

## Prose Style
The application will use an **Informative & Friendly** tone for all documentation and user messages. This ensures that users feel supported while maintaining clarity and technical accuracy.

## UX Principles
- **CLI-First Design**: The interface is optimized for standard terminal usage patterns, ensuring it feels native to command-line environments.
- **Minimalist Feedback**: The application will prioritize essential information, following the principle of "silent success" where appropriate, unless detailed feedback is required.

## Interaction Guidelines
- **Standard CLI Flags**: Strict adherence to POSIX command-line argument standards (e.g., `-f`, `--flag`) to provide a familiar experience for CLI users.
- **Comprehensive Built-in Help**: Every command should include detailed help messages to guide the user without needing external documentation.

## Output and Feedback
- **Strictly Structured (JSON)**: All primary output will be presented in JSON format, making it easy to parse and integrate with other tools while maintaining readability.
