# SF Property Data Search (Web)

This project is a static single-page application (SPA) built in Elm for querying San Francisco property data via the SF Data API (Socrata).

## Features
- Search properties by roll year, bedrooms, bathrooms, parcel number, and more.
- Filter by neighborhood districts, codes, and property class codes.
- Compare properties against a "target parcel" to see relative distances and area/value ratios.
- Toggle between Table and JSON views for results.
- Responsive UI built with Bootstrap.

## Getting Started

### Prerequisites
- [Elm 0.19.1](https://guide.elm-lang.org/install/elm.html)
- [Node.js & npm](https://nodejs.org/) (for running tests and local server)

### Installation
```bash
npm install -g elm elm-test
```

### Local Development
To compile the Elm code to JavaScript:
```bash
elm make src/Main.elm --output=main.js
```
Then, open `index.html` in your browser.

### Running Tests
```bash
elm-test
```

## Deployment
The app is automatically built and deployed to GitHub Pages via GitHub Actions on every push to the `master` branch.
