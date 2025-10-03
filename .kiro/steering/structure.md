# Project Structure

## Directory Organization
```
├── index.html              # Main application entry point
├── css/
│   └── styles.css         # Full-screen styling and responsive design
├── js/
│   ├── config.js          # Configuration constants and environment settings
│   └── slideshow.js       # Core slideshow class and logic
├── gifs/                  # Local development GIF assets
│   ├── 1.gif through 10.gif # Sample GIFs for testing
├── deploy/                # Manual AWS deployment configuration (legacy)
│   ├── s3-setup.md       # Manual deployment instructions
│   └── bucket-policy.json # S3 bucket policy template
├── terraform/             # Infrastructure-as-Code configuration (primary)
│   ├── main.tf           # Core infrastructure resources
│   ├── variables.tf      # Input variables with validation
│   ├── outputs.tf        # Output values for deployment info
│   ├── versions.tf       # Provider and Terraform version constraints
│   ├── terraform.tfvars.example # Example configuration file
│   └── README.md         # Comprehensive Terraform documentation
├── devbox.json            # Development environment configuration
├── devbox.lock            # Locked development dependencies
└── README.md              # Project documentation with deployment options
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

### Infrastructure Code Patterns
- **Terraform Structure**: Modular configuration with separate files for resources, variables, and outputs
- **Variable Validation**: Comprehensive validation rules for all input parameters
- **Resource Naming**: Consistent naming with project/environment prefixes
- **Tagging Strategy**: Standardized tags for cost tracking and resource management

### File Naming
- Kebab-case for HTML/CSS files and directories
- camelCase for JavaScript variables and functions
- Numbered GIF files (1.gif through 10.gif)
- Descriptive names for configuration files
- snake_case for Terraform variables and resources

## Deployment Patterns

### Development Environment
- Local mode: serves from `./gifs/` directory
- Devbox environment with pre-configured tools
- S3-only infrastructure for cost optimization

### Production Environment
- Production mode: fetches from configured S3 bucket URL
- Optional CloudFront CDN for performance and HTTPS
- Multi-environment support (dev/staging/prod)
- Automated deployment with Terraform

### Infrastructure Management
- **Primary**: Terraform for automated, repeatable deployments
- **Legacy**: Manual AWS CLI deployment for simple use cases
- **Cost-optimized**: Configurable S3-only or S3+CloudFront setups
- **Multi-environment**: Workspace-based environment isolation