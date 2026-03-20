# SF Property Data CLI

This project provides a CLI interface for querying San Francisco property data via the SF Data API (Socrata).

## Project Structure
- `main.py`: Entry point for the CLI application.
- `api_client.py`: Module for handling API requests.
- `formatter.py`: Module for formatting API responses (JSON and Table).
- `query_builder.py`: Module for constructing SoQL queries.
- `tests/`: Directory containing project tests.
- `conductor/`: Project management and workflow documentation.

## Getting Started
To install dependencies and set up the environment, run:
```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

## Running the Application
```bash
python3 main.py query --help
```

### Example Usage
```bash
# Query properties with 2 bedrooms in district 9, formatted as a table
python3 main.py query --bedrooms 2 --district 9 --format table
```

## Running Tests
```bash
venv/bin/pytest
```

## Running Tests with Coverage
```bash
venv/bin/pytest --cov=.
```

## Generating Standalone Binary
To generate a standalone executable using PyInstaller:
```bash
pyinstaller main.spec
```
The binary will be located in the `dist/` directory.
