# Technology Stack

## Core Technologies
- **Frontend**: Vanilla JavaScript (ES6+), HTML5, CSS3
- **Hosting**: AWS S3 static website hosting
- **Storage**: AWS S3 for GIF assets
- **Development**: Local file system with sample GIFs

## Architecture
- Pure client-side static web application
- No build system or bundling required
- No external dependencies or frameworks
- Configuration-driven development/production modes

## File Structure
- `index.html` - Single page application entry point
- `js/config.js` - Environment and behavior configuration
- `js/slideshow.js` - Core slideshow logic as ES6 class
- `css/styles.css` - Full-screen styling and responsive design
- `sample_gifs/` - Local development assets
- `deploy/` - AWS deployment scripts and policies

## Development Commands
```bash
# Local development - serve files with any HTTP server
python3 -m http.server 8000
# or
npx serve .

# Deploy to S3 (requires AWS CLI)
aws s3 sync . s3://your-bucket-name/ --exclude "*.md" --exclude "deploy/*" --exclude ".git/*"
```

## Configuration Management
- Toggle between development/production via `CONFIG.DEVELOPMENT_MODE`
- All timing and behavior controlled through `CONFIG` object
- S3 bucket URL configurable for different environments