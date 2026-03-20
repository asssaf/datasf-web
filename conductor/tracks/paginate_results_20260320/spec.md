# Specification: Support Pagination of Results

## Overview
This track introduces support for paginated results when calling the REST API. The CLI will now expose `--limit` and `--offset` arguments to allow users to control data retrieval.

## Functional Requirements
- **CLI Arguments**: Update the `query_builder.py` and `main.py` (and relevant Click configuration) to accept `--limit` and `--offset`.
- **API Requests**: Ensure the `api_client.py` passes these arguments as query parameters to the API.
- **Defaults**: Default `--limit` to 100 if not provided. `--offset` should default to 0.

## Non-Functional Requirements
- Ensure consistent error handling if API returns errors related to pagination parameters.

## Acceptance Criteria
- Executing command with `--limit 50 --offset 0` correctly sends parameters to the API.
- Executing without arguments uses default limit of 100.
- Documentation updated to include new CLI options.

## Out of Scope
- Auto-pagination (fetching all pages automatically).
- UI/UX components for page navigation.
