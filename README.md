# Flippy Radio Clock

For my old iPad 3 which got very slow over time and is today nearly unusable today (thanks apple) i was thinking about another usecase. My goal was to develop a minimal radio/tv app that should fullfill two points:

 - run smootly on the oldest iOS-Hardware as possible (XCode allows builds back to iOS 8).
 - provide a very minimalisitic user interface


Any form of complex user interface or animation should be avoided due to the lacking cpu/gpu power.

In the settings the user can save 3 different stream-urls (audio or video) and change the background image.


Due to the small energy impact of the iPad there is an option in the settings to keep the iPad awake for ever, like a digital image frame. After a specific time the display gets dimmed to reduce power. 

##  technology/topics

* Swift 5
* Date/Time Localization
* AVPlayer for audio & video
* Layout without Autolayout to support legacy devices with iOS 8


##  platform destinations

* iOS
* iPadOS
