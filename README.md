# GIF Storm Forecast

A full-screen kiosk-style GIF slideshow application that displays animated GIFs in a continuous loop.

## Overview

This project creates a static web application that displays GIFs from an S3 bucket in full-screen mode. Each GIF plays through 3 complete cycles before automatically advancing to the next one, creating an engaging slideshow experience perfect for digital displays, kiosks, or ambient screens.

## Features

- **Full-screen display**: GIFs are displayed in full-screen mode for maximum visual impact
- **Automatic progression**: Each GIF plays 3 complete loops before moving to the next
- **S3 integration**: GIFs are stored and served from an AWS S3 bucket
- **Static web app**: Lightweight, client-side application with no server requirements
- **Continuous loop**: Slideshow runs indefinitely, cycling through all available GIFs

## How it works

1. GIFs are uploaded to a configured S3 bucket
2. The web application fetches the list of available GIFs
3. Each GIF is displayed in full-screen mode
4. After 3 complete animation cycles, the app automatically advances to the next GIF
5. The slideshow continues indefinitely, looping back to the first GIF after the last one
