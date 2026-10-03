# HER-STEPS.md — Things only Cori can do

The app code is complete and tested. These steps need **you** (identity, payment,
your phone, your accounts). Nothing goes to any store until you say so.

## 1. Build the APK/AAB — RECOMMENDED: Codemagic (free, no computer needed)
Muse prepared everything so a cloud service builds the app for you — **you don't
need a computer at all**:

1. Muse pushes this project to a GitHub repo (it will ask for your go-ahead first).
2. You sign up at **https://codemagic.io** with your GitHub account (free tier =
   500 build minutes/month, plenty for this app) and add the repo.
3. Codemagic builds automatically using `codemagic.yaml` (already in the project):
   - **Android debug APK** → install on your phone to test
   - **Android release AAB** → upload to Google Play
   - **iOS debug IPA** → for iPhone testing (built on their Macs — no Mac needed)
4. Download the finished files from the Codemagic dashboard.

Why not build on Muse's machine? The Linux server only has ~1GB free RAM and
no swap — the Android build tool (Gradle) needs more and fails there. The code
itself is complete and verified; it just needs a bigger machine, which Codemagic
provides for free.

**Option B — Build on your own computer** (if you install Flutter):
```bash
cd ~/workspace/baby-tracker
flutter build apk --debug       # for testing on your phone
flutter build appbundle --release  # for Play Store upload
```
APK output: `build/app/outputs/flutter-apk/app-debug.apk`
AAB output: `build/app/outputs/bundle/release/app-release.aab`

## 2. Test it on your phone (Android) — ~10 minutes
1. Copy the `app-debug.apk` to your Android phone.
2. Open the file on your phone → allow "Install unknown apps" when asked → Install.
3. Try it: log a bottle, switch mL/oz in Settings, log a diaper, add a doctor visit, export a PDF.
4. Tell Muse what to fix — nothing ships until you approve.

## 3. Google Play (Android publishing)
- [ ] Create a **Google Play developer account** ($25 one-time) at play.google.com/console — needs your Google account + ID verification.
- [ ] In the Play Console, create the app listing (name, description — drafts are in `docs/store-listing-en.md` and `docs/store-listing-es.md`).
- [ ] Generate an **upload keystore** (Muse will walk you through it; the keystore file stays with you, never shared). Command:
  ```bash
  keytool -genkey -v -keystore ~/nurture-upload.keystore -alias nurture -keyalg RSA -keysize 2048 -validity 10000
  ```
  Save the passwords somewhere safe — you'll need them for every release build.
- [ ] Muse builds the signed release AAB (using your keystore) → you upload it in the Play Console → answer Google's review questions (privacy policy URL — draft in `docs/privacy-policy.md`; data-safety form: "no data collected").
- [ ] Pick the final app name (currently codenamed **Nurture**).

## 4. Apple App Store (iOS publishing)
- [ ] Enroll in the **Apple Developer Program** ($99/year) at developer.apple.com — needs your Apple ID + identity verification.
- [ ] A Mac is required to sign the iOS build, **or** use **Codemagic** (cloud Mac CI, free tier available) — Muse will configure it when you're ready.
- [ ] In App Store Connect, create the app (Bundle ID: `com.nurturebaby.nurture`), paste the listing text + privacy policy, upload the build, answer Apple's review questions.
- [ ] Same: final app name decision before submission.

## 5. After launch (whenever)
- Tell Muse the final app name → it updates the code, icon text (none — icon has no text), and listings.
- Privacy policy contact email: replace `[INSERT CONTACT EMAIL]` in `docs/privacy-policy.md` with a real address before publishing.

## What Muse already handled
App code (Flutter, iOS + Android), local SQLite database (no accounts, no tracking),
appointment reminders, PDF export, English + Spanish, dark mode, mL/oz unit toggle,
app icon, store listing drafts (EN+ES), privacy policy draft, and code QC (analyzer:
0 errors, database tests pass).

## What still needs a build machine
- Debug APK (`app-debug.apk`) — for your phone testing
- Release AAB (`app-release.aab`) — for Play Store upload
- iOS IPA — for iPhone testing (unsigned) / App Store (signed, needs your certs)
- All three are produced automatically by Codemagic once you connect the repo —
  see step 1 above. Not blocked on code.
