# Project Structure

## Directory Organization
```
├── index.html              # Main application entry point
├── css/
│   └── styles.css         # Full-screen styling and responsive design
├── js/
│   ├── config.js          # Configuration constants and environment settings
│   └── slideshow.js       # Core slideshow class and logic
├── sample_gifs/           # Local development GIF assets
│   ├── 1.gif, 3.gif, etc # Sample GIFs for testing
├── deploy/                # AWS deployment configuration
│   ├── s3-setup.md       # Deployment instructions
│   └── bucket-policy.json # S3 bucket policy template
└── README.md              # Project documentation
```

## Code Organization Patterns

### Configuration Management
- All configurable values centralized in `js/config.js`
- Use `CONFIG` object with UPPER_CASE constants
- Environment switching via `DEVELOPMENT_MODE` boolean
- Clear separation between local and S3 paths

### JavaScript Structure
- Use ES6 classes for main components (`GifSlideshow`)
- Constructor pattern for initialization
- Async/await for file operations
- Console logging for debugging and monitoring

### CSS Conventions
- Mobile-first responsive design with viewport units
- Full-screen layout using `100vw/100vh`
- Object-fit for responsive image scaling
- Utility classes for state management (e.g., `hide-cursor`)

### File Naming
- Kebab-case for HTML/CSS files and directories
- camelCase for JavaScript variables and functions
- Numbered GIF files (1.gif, 3.gif, etc.)
- Descriptive names for configuration files

## Development vs Production
- Local mode: serves from `./sample_gifs/` directory
- Production mode: fetches from configured S3 bucket URL
- Same codebase handles both environments via configuration