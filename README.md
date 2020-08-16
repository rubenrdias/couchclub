# couchclub

An app for tracking movies and shows with a list-based system. Users can also create chatrooms to discuss with friends what they watched.

**Current functionality available:**
* Create watchlists, to track a group of movies or shows to watch later
* Collaborative watchlists, to enable a group viewing experience
* Search for movies or shows
* Create chatrooms to discuss a certain watchlist, movie or show
* iPad support for a seamless experience in all devices
* Dark theme support for devices running iOS 13 or up

**Relevant Technologies**
* Built entirely with Swift
* Core Data - store all application data
* Firebase: Auth - user accounts, login and account creation
* Firebase: Firestore - business logic (chatrooms and messages, watchlists)
* Firebase: Messaging + Cloud Functions - push notifications, database cleanup


**Implementation Details**
* REST Interface - API for Movies/Shows
* Uses design patterns: coordinator, builder, singleton