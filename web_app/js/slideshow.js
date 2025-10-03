class GifSlideshow {
    constructor() {
        this.gifs = [];
        this.currentIndex = 0;
        this.currentLoops = 0;
        this.gifElement = document.getElementById('gif-display');
        this.loadingElement = document.getElementById('loading');
        this.cursorTimeout = null;
        this.preloadedImages = new Map(); // Cache for preloaded images
        this.isTransitioning = false;

        this.init();
    }

    async init() {
        this.setupCursorHiding();
        await this.loadGifList();
        await this.preloadGifs();
        this.startSlideshow();
    }

    setupCursorHiding() {
        let timeout;
        const hideCursor = () => {
            document.body.classList.add('hide-cursor');
        };

        const showCursor = () => {
            document.body.classList.remove('hide-cursor');
            clearTimeout(timeout);
            timeout = setTimeout(hideCursor, CONFIG.CURSOR_HIDE_DELAY);
        };

        document.addEventListener('mousemove', showCursor);
        timeout = setTimeout(hideCursor, CONFIG.CURSOR_HIDE_DELAY);
    }

    async loadGifList() {
        if (CONFIG.DEVELOPMENT_MODE) {
            // Use local GIFs for development - numbered 1 through 10
            this.gifs = [
                '1.gif',
                '2.gif',
                '3.gif',
                '4.gif',
                '5.gif',
                '6.gif',
                '7.gif',
                '8.gif',
                '9.gif',
                '10.gif'
            ];
        } else {
            // Production mode - use hardcoded list for now
            // In a real deployment, you'd want to list S3 objects or maintain a manifest
            this.gifs = [
                '1.gif',
                '2.gif',
                '3.gif',
                '4.gif',
                '5.gif',
                '6.gif',
                '7.gif',
                '8.gif',
                '9.gif',
                '10.gif'
            ];
        }

        console.log(`Loaded ${this.gifs.length} GIFs from ${CONFIG.DEVELOPMENT_MODE ? 'local folder' : 'S3 bucket'}`);
    }

    async preloadGifs() {
        console.log('Preloading GIFs for better performance...');
        this.loadingElement.textContent = 'Preloading GIFs...';

        const preloadPromises = this.gifs.map((gifName, index) => {
            return new Promise((resolve) => {
                const img = new Image();
                const gifUrl = this.buildGifUrl(gifName);

                img.onload = () => {
                    this.preloadedImages.set(gifName, img);
                    console.log(`Preloaded ${index + 1}/${this.gifs.length}: ${gifName}`);
                    resolve();
                };

                img.onerror = () => {
                    console.warn(`Failed to preload: ${gifName}`);
                    resolve(); // Continue even if one fails
                };

                img.src = gifUrl;
            });
        });

        await Promise.all(preloadPromises);
        console.log('All GIFs preloaded successfully');
    }

    startSlideshow() {
        if (this.gifs.length === 0) {
            this.loadingElement.textContent = 'No GIFs found';
            return;
        }

        this.loadingElement.style.display = 'none';
        this.showCurrentGif();
    }

    showCurrentGif() {
        if (this.isTransitioning) return;
        this.isTransitioning = true;

        const gifName = this.gifs[this.currentIndex];
        const preloadedImg = this.preloadedImages.get(gifName);

        if (preloadedImg && CONFIG.USE_PRELOADED_CACHE) {
            // Use preloaded image for instant display
            this.gifElement.src = preloadedImg.src;
        } else {
            // Always fetch fresh URL with cache-busting for production
            const gifUrl = this.buildGifUrl(gifName);
            this.gifElement.src = gifUrl;
        }

        this.gifElement.style.display = 'block';

        // Reset loop counter for new GIF
        this.currentLoops = 0;

        console.log(`Showing GIF ${this.currentIndex + 1}/${this.gifs.length}: ${gifName}`);

        // Use more accurate timing based on typical GIF frame rates
        const gifDuration = this.estimateGifDuration(gifName);

        setTimeout(() => {
            this.isTransitioning = false;
            this.handleGifLoop();
        }, gifDuration);
    }

    buildGifUrl(gifName) {
        const baseUrl = CONFIG.DEVELOPMENT_MODE
            ? `${CONFIG.LOCAL_GIF_PATH}/${gifName}`
            : `${CONFIG.S3_BUCKET_URL}/${gifName}`;

        // Add cache-busting for production to ensure fresh content
        if (!CONFIG.DEVELOPMENT_MODE && CONFIG.CACHE_BUSTING_ENABLED) {
            const cacheBuster = CONFIG.CACHE_BUSTING_METHOD === 'timestamp' 
                ? Date.now()
                : Math.random().toString(36).substring(7);
            return `${baseUrl}?v=${cacheBuster}`;
        }

        return baseUrl;
    }

    estimateGifDuration(gifName) {
        // Better duration estimation based on file patterns or defaults
        // You could extend this to read actual GIF metadata
        const baseDuration = CONFIG.FALLBACK_DURATION;

        // Some GIFs might have known durations
        const knownDurations = {
            '1.gif': 3000,
            '2.gif': 5000,
            '3.gif': 3500,
            '4.gif': 4500,
            '5.gif': 4000,
            '6.gif': 3000,
            '7.gif': 3500,
            '8.gif': 4000,
            '9.gif': 3500,
            '10.gif': 4000
        };

        return knownDurations[gifName] || baseDuration;
    }

    handleGifLoop() {
        this.currentLoops++;

        if (this.currentLoops >= CONFIG.LOOPS_PER_GIF) {
            this.nextGif();
        } else {
            // Continue with same GIF for another loop
            const gifDuration = this.estimateGifDuration(this.gifs[this.currentIndex]);
            setTimeout(() => {
                this.handleGifLoop();
            }, gifDuration);
        }
    }

    nextGif() {
        // Clean up current image to prevent memory leaks
        this.gifElement.style.display = 'none';

        this.currentIndex = (this.currentIndex + 1) % this.gifs.length;

        // Small delay to ensure cleanup
        setTimeout(() => {
            this.showCurrentGif();
        }, 100);
    }

    // Cleanup method for memory management
    destroy() {
        this.preloadedImages.clear();
        if (this.cursorTimeout) {
            clearTimeout(this.cursorTimeout);
        }
    }
}

// Start the slideshow when page loads
document.addEventListener('DOMContentLoaded', () => {
    new GifSlideshow();
});