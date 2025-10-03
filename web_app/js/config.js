// Configuration for the GIF slideshow
const CONFIG = {
    // Development mode - set to false for production deployment
    DEVELOPMENT_MODE: false,
    
    // Local development path
    LOCAL_GIF_PATH: './gifs',
    
    // CloudFront HTTPS URL (for production)
    // Replace with your actual CloudFront distribution URL from terraform output
    // Must be HTTPS - HTTP S3 website endpoints are not supported
    S3_BUCKET_URL: 'https://your-cloudfront-domain.cloudfront.net',
    
    // Number of times each GIF should loop before moving to next
    LOOPS_PER_GIF: 3,
    
    // Fallback duration if GIF duration cannot be determined (milliseconds)
    FALLBACK_DURATION: 4000,
    
    // Time to hide cursor after inactivity (milliseconds)
    CURSOR_HIDE_DELAY: 2000,
    
    // Performance optimizations
    PRELOAD_ENABLED: true,
    TRANSITION_DELAY: 100,
    
    // Cache control settings
    CACHE_BUSTING_ENABLED: true, // Enable cache-busting in production
    CACHE_BUSTING_METHOD: 'timestamp', // 'timestamp' or 'random'
    USE_PRELOADED_CACHE: false // Set to false to always fetch fresh URLs
};