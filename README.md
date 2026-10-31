# One Good Thing

One Good Thing brings NASA's Astronomy Picture of the Day (APOD) to iPhone.
Explore the daily image and its explanation, save favorites, and add personal
comments.

## Browser preview

The browser preview mirrors the iOS app's Today, Saved, photo-detail, and
comments screens in an iPhone-style layout. It uses NASA imagery and saves
favorites and comments in the current browser.

### Try the preview on GitHub Pages

Repository maintainers can publish the preview for everyone:

1. Push the repository to GitHub.
2. Open **Settings > Pages** for the repository.
3. Under **Build and deployment**, choose **Deploy from a branch**.
4. Choose the default branch and the `/(root)` folder, then select **Save**.
5. Open the published Pages URL shown in the Pages settings.

### Run the preview locally

Clone or download the repository, then open `index.html`. If your browser
restricts API requests from local files, serve the repository root instead:

```powershell
py -m http.server 8000
```

Visit `http://localhost:8000`.

## Run the iOS app

The native app requires a Mac with Xcode 15 or later:

1. Open `OneGoodThing.xcodeproj` in Xcode.
2. Select the **OneGoodThing** scheme and an iOS 17+ simulator or device.
3. Build and run.

## NASA API and data

Both versions use NASA's public `DEMO_KEY` by default. It is shared and
rate-limited, so APOD requests may be temporarily unavailable. The browser
preview falls back to NASA's public image archive when it cannot load APOD.

For a public deployment with higher request limits, use a backend proxy for a
NASA API key. Do not put a personal key in this repository, the browser code,
or a distributed app; client-side keys can be extracted.

Favorites and comments are stored locally in the user's browser or device.
They are not synced between devices or shared with other users.
