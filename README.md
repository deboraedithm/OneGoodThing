# One Good Thing

**A little wonder, every day.**

One Good Thing brings NASA's Astronomy Picture of the Day (APOD) to an
iPhone-inspired experience. Explore the latest image and its story, revisit
past discoveries, and keep a personal collection of favorites and comments.

> Every day, the universe has something worth stopping for.

## What you can do

- **Explore today's APOD** with its image, title, and explanation.
- **Travel back in time** to browse the APOD archive, from June 16, 1995 onward.
- **Save favorites** and add personal comments.
- **Use the native iOS app** or try the browser preview—no Mac required for the
  preview.
- **Keep your library private:** favorites and comments stay on your device or
  in your browser; they are not synced to an account.

## Try the browser preview

Open [`index.html`](./index.html) in a browser. If your browser blocks API
requests from local files, serve the repository root:

```powershell
py -m http.server 8000
```

Then visit [http://localhost:8000](http://localhost:8000).

### Publish the preview with GitHub Pages

1. Push the repository to GitHub.
2. Open **Settings → Pages**.
3. Under **Build and deployment**, choose **Deploy from a branch**.
4. Choose your default branch and the `/(root)` folder, then select **Save**.
5. Open the published URL shown in Pages settings.

The public preview uses NASA's shared `DEMO_KEY` unless you deliberately
configure a different key. **Do not publish your personal key**; browser code
and browser requests are visible to visitors.

## Run the iOS app

You need a Mac with Xcode 15 or later:

1. Open [`OneGoodThing.xcodeproj`](./OneGoodThing.xcodeproj) in Xcode.
2. Select the **OneGoodThing** scheme and an iOS 17 or later simulator/device.
3. Build and run.

## NASA API configuration

The app and preview use NASA's APOD service. The default `DEMO_KEY` is shared
and rate-limited. For local development, create a personal key at
[api.nasa.gov](https://api.nasa.gov/#signUp) and store it only in the
Git-ignored local configuration files:

- **Browser:** Copy [`config.example.js`](./config.example.js) to `config.js`,
  then set `nasaApiKey` in `config.js`.
- **iOS:** Copy
  [`OneGoodThing.xcodeproj/Secrets.xcconfig.example`](./OneGoodThing.xcodeproj/Secrets.xcconfig.example)
  to `OneGoodThing.xcodeproj/Secrets.xcconfig`, then set `NASA_API_KEY`.

Never commit `config.js` or `Secrets.xcconfig`. These files are ignored by Git,
but a key used by a browser or distributed iOS app is **not truly secret**:
browser requests expose it, and app builds can be inspected. For a public
production app, put the key behind a server-side proxy instead. A personal key
has its own quota, but cannot prevent NASA API outages.

## How date browsing works

APOD entries begin on June 16, 1995. The app uses NASA's current WordPress
endpoint, `https://science.nasa.gov/wp-json/wp/v2/apod-basic/`. The endpoint
returns pages of 25 entries and currently ignores its `date` query parameter,
so One Good Thing finds the requested date in the appropriate page and checks
the result before displaying it.

The legacy `api.nasa.gov/planetary/apod` endpoint is scheduled for retirement
on December 1, 2026. Requests use UTC dates. The app refreshes today's APOD
when the UTC day changes or the app/browser returns to the foreground.

## Built with

- **SwiftUI** for the native iOS app
- **HTML, CSS, and JavaScript** for the browser preview
- **NASA APOD API** for astronomy imagery and explanations
- **Local persistence** for favorites and comments

## License

See [`LICENSE`](./LICENSE).
