# One Good Thing

A native SwiftUI iOS app that brings NASA's Astronomy Picture of the Day (APOD)
to your home screen, with a description, favorites, and personal comments.

## See the browser preview

Open `index.html` in a browser, or serve this folder locally:

```powershell
py -m http.server 8000
```

Then visit `http://localhost:8000`. The browser preview is arranged like an
iPhone screen and follows the SwiftUI app's Today, Saved, photo-detail, and
comments screens. It fetches NASA imagery and stores favorites and comments in
your browser. If APOD is unavailable, it shows a photo from NASA's image
archive. The NASA demo API key is rate-limited; configure your own key in
`index.html` for regular use.

## Run the app

1. Open `OneGoodThing.xcodeproj` in Xcode 15 or later.
2. Select the **OneGoodThing** scheme and an iOS 17+ simulator or device.
3. Build and run. The app uses NASA's `DEMO_KEY` by default, so no setup is
   needed to try it.

For regular use, request a key at [api.nasa.gov](https://api.nasa.gov/) and
change the `NASA_API_KEY` build setting for the app target. API keys embedded
in a distributed client app can be extracted; use a backend proxy if the key
must remain private.

Favorites and comments are stored locally on the device. They are not shared
with NASA or other users.
