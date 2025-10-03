# Requirements Document

## Introduction

This feature enhancement adds the ability to display the name of the currently playing GIF on the GIF Storm Forecast slideshow application. The GIF name will be shown as an overlay on the full-screen display, providing users with identification of the current content while maintaining the kiosk-style aesthetic and minimal UI principles of the application.

## Requirements

### Requirement 1

**User Story:** As a viewer of the GIF slideshow, I want to see the name of the currently displayed GIF, so that I can identify and reference specific content.

#### Acceptance Criteria

1. WHEN a GIF is displayed THEN the system SHALL show the GIF filename as an overlay on the screen
2. WHEN the slideshow transitions to a new GIF THEN the system SHALL update the displayed name to match the new GIF
3. WHEN the GIF name is displayed THEN the system SHALL use a readable font size and color that contrasts with the background
4. WHEN the GIF name is shown THEN the system SHALL position it in a way that doesn't obstruct the main GIF content

### Requirement 2

**User Story:** As a kiosk operator, I want the GIF name display to be configurable, so that I can enable or disable it based on the deployment context.

#### Acceptance Criteria

1. WHEN the application starts THEN the system SHALL check a configuration setting to determine if GIF names should be displayed
2. IF GIF name display is disabled THEN the system SHALL not show any filename overlay
3. WHEN the configuration is changed THEN the system SHALL apply the new setting without requiring a page reload
4. WHEN in development mode THEN the system SHALL default to showing GIF names for debugging purposes

### Requirement 3

**User Story:** As a developer, I want the GIF name display to follow the existing code patterns, so that it integrates seamlessly with the current architecture.

#### Acceptance Criteria

1. WHEN implementing the feature THEN the system SHALL use the existing CONFIG object for configuration management
2. WHEN displaying GIF names THEN the system SHALL follow the current CSS naming conventions and responsive design patterns
3. WHEN updating the display THEN the system SHALL use the existing GifSlideshow class methods and event handling
4. WHEN showing the name THEN the system SHALL respect the cursor hiding behavior and kiosk mode optimizations

### Requirement 4

**User Story:** As a user viewing the slideshow, I want the GIF name to be visually appealing and non-intrusive, so that it enhances rather than detracts from the viewing experience.

#### Acceptance Criteria

1. WHEN the GIF name is displayed THEN the system SHALL use a semi-transparent background to ensure readability
2. WHEN positioning the name THEN the system SHALL place it in a corner or edge location that minimizes interference with GIF content
3. WHEN styling the text THEN the system SHALL use appropriate typography that matches the application's aesthetic
4. WHEN the name appears THEN the system SHALL use smooth transitions consistent with the existing slideshow animations

### Requirement 5

**User Story:** As a content manager, I want the displayed name to be clean and user-friendly, so that viewers see meaningful information rather than technical filenames.

#### Acceptance Criteria

1. WHEN displaying a GIF filename THEN the system SHALL remove the file extension (.gif) from the displayed name
2. WHEN showing numbered GIFs THEN the system SHALL display the number in a user-friendly format
3. IF a GIF has a descriptive filename THEN the system SHALL format it for better readability (e.g., replace underscores with spaces)
4. WHEN the filename is very long THEN the system SHALL truncate it appropriately to prevent layout issues