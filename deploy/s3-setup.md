# S3 Bucket Setup

## Prerequisites
- AWS CLI installed and configured
- Appropriate AWS permissions for S3

## Steps

1. **Create S3 bucket**:
   ```bash
   aws s3 mb s3://your-gif-slideshow-bucket
   ```

2. **Enable public read access** (for web hosting):
   ```bash
   aws s3api put-bucket-policy --bucket your-gif-slideshow-bucket --policy file://bucket-policy.json
   ```

3. **Enable static website hosting**:
   ```bash
   aws s3 website s3://your-gif-slideshow-bucket --index-document index.html
   ```

4. **Upload GIFs**:
   ```bash
   aws s3 sync ./gifs s3://your-gif-slideshow-bucket/gifs/
   ```

5. **Upload web app**:
   ```bash
   aws s3 sync . s3://your-gif-slideshow-bucket/ --exclude "*.md" --exclude "deploy/*" --exclude ".git/*"
   ```

## Configuration
Update `js/config.js` with your actual S3 bucket URL.