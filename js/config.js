// Configuration for the GIF slideshow
const CONFIG = {
    // Development mode - use local files
    DEVELOPMENT_MODE: true,
    
    // Local development path
    LOCAL_GIF_PATH: './sample_gifs',
    
    // S3 bucket configuration (for production)
    S3_BUCKET_URL: 'https://your-bucket-name.s3.amazonaws.com',
    
    // Number of times each GIF should loop before moving to next
    LOOPS_PER_GIF: 3,
    
    // Fallback duration if GIF duration cannot be determined (milliseconds)
    FALLBACK_DURATION: 5000,
    
    // Time to hide cursor after inactivity (milliseconds)
    CURSOR_HIDE_DELAY: 3000
};