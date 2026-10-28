# Gargaarsa Yeroo Rakkoo

Flutter Android starter project for an emergency-help app.

## Included
- Afaan Oromoo, Amharic, and English interface
- SOS screen with user-confirmed emergency dialing (991 is prefilled as the police dial option; confirm local coverage before relying on it)
- Police, hospital, and fire service dial fields (editable; no unverified numbers are prefilled)
- GPS location display and sharing
- Voice recording and Android share sheet

## Build
Install Flutter, then run:
```bash
flutter pub get
flutter run
```
To create an APK:
```bash
flutter build apk --release
```

The GitHub Actions workflow in `.github/workflows/android-apk.yml` can build an APK when this project is uploaded to a GitHub repository. The app cannot silently place calls or send recordings; Android asks the user to approve permissions and confirm sharing/calling.
