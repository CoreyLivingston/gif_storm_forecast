class GifSlideshow {
    constructor() {
        this.gifs = [];
        this.currentIndex = 0;
        this.currentLoops = 0;
        this.gifElement = document.getElementById('gif-display');
        this.loadingElement = document.getElementById('loading');
        this.cursorTimeout = null;
        
        this.init();
    }
    
    async init() {
        this.setupCursorHiding();
        await this.loadGifList();
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
            // Use local GIFs for development
            this.gifs = [
                '1.gif',
                '12.gif',
                '3.gif',
                '4.gif',
                '5.gif',
                '6.gif'
            ];
        } else {
            // TODO: Implement S3 bucket listing for production
            this.gifs = [];
        }
        
        console.log(`Loaded ${this.gifs.length} GIFs from ${CONFIG.DEVELOPMENT_MODE ? 'local folder' : 'S3 bucket'}`);
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
        const gifUrl = CONFIG.DEVELOPMENT_MODE 
            ? `${CONFIG.LOCAL_GIF_PATH}/${this.gifs[this.currentIndex]}`
            : `${CONFIG.S3_BUCKET_URL}/${this.gifs[this.currentIndex]}`;
        
        this.gifElement.src = gifUrl;
        this.gifElement.style.display = 'block';
        
        // Reset loop counter for new GIF
        this.currentLoops = 0;
        
        console.log(`Showing GIF ${this.currentIndex + 1}/${this.gifs.length}: ${this.gifs[this.currentIndex]}`);
        
        // TODO: Detect actual GIF duration
        const gifDuration = CONFIG.FALLBACK_DURATION;
        
        setTimeout(() => {
            this.handleGifLoop();
        }, gifDuration);
    }
    
    handleGifLoop() {
        this.currentLoops++;
        
        if (this.currentLoops >= CONFIG.LOOPS_PER_GIF) {
            this.nextGif();
        } else {
            // Continue with same GIF for another loop
            const gifDuration = CONFIG.FALLBACK_DURATION;
            setTimeout(() => {
                this.handleGifLoop();
            }, gifDuration);
        }
    }
    
    nextGif() {
        this.currentIndex = (this.currentIndex + 1) % this.gifs.length;
        this.showCurrentGif();
    }
}

// Start the slideshow when page loads
document.addEventListener('DOMContentLoaded', () => {
    new GifSlideshow();
});