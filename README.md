# Firdaws — a quiet Arabic prayer companion

Firdaws is an Arabic RTL Flutter application served as a static website. `flutter_app/` contains the source, providers, services, content, fonts and pinned dependency lockfile; `public/` contains the actual compiled Flutter Web release. The hosted build validates the committed release rather than fetching a Flutter SDK during deployment.

The November 2026 redesign restructures all eight principal screens: Today, Qibla, Hijri Calendar, Tasbih, Prayer Log, Jannati, Support/Questions, and Settings. A stable mobile bar prioritizes Today, Qibla, Tasbih, Library and More; a right-hand sidebar exposes the full directory on wide screens. Pages are created on demand and retain state after visits, rather than rendering all pages in an animated carousel. Existing `FirdawsNavBridge` indices 0–7 remain valid; 8 and 9 are the new More and Library views. Navigation remains internal to the app’s `/` page.

## Quiet nature visual system

`flutter_app/lib/widgets/calm_ui.dart` supplies the page frame, opaque cards, section headings, action rows, statistics and empty states. Cairo is bundled; user-selected Arabic fonts and specialized Quran-reading typography are retained. Primary text is 16px, support text 14px, section headings 18px and primary page headings 26px.

Legacy theme keys and customization data remain valid. Four curated nature palettes—emerald, forest, water and sunset—pair distinct day/night colors with bundled scenery, selectable in Settings. Static botanical edges and water-line details frame shared pages; local garden photography appears in the prayer dashboard and relevant journeys. Text and Quran surfaces stay opaque and readable. Ambient particle canvases, glowing icons, floating companion chrome and global touch effects remain absent. First-run profile prompts are removed. Fresh users start in day mode; saved preferences are not deleted. The adhan alarm’s audio, keyboard/native handling and swipe-then-stop behavior are preserved in a simplified interface.

Today shows the upcoming time and countdown plus the daily schedule directly, with an optional game shortcut. More organizes personal progress, calendar, Jannati, support, settings and a prominent entry to the existing 30-game hall. The responsive hall, match lobby, active play scenery and results use the existing game engines and callbacks; the Millionaire quiz adds clearer question/rung progress and readable nature-themed surfaces. Six bundled garden scenes are selected deterministically across games and worlds, while event backdrops retain priority. Reduced-motion settings freeze scenic animation without altering gameplay timers or physics. Library provides Quran, azkar, authentic-hadith content, stories and books. Settings groups the four nature looks with location, calculation and notifications.

## Data and platform limits

Existing local-preference providers and religious calculations are preserved. Each browser stores its own data; this is not account-based cloud synchronization. Geolocation requires HTTPS and visitor permission. Native alarms, overlays, background notifications and live compass sensors remain constrained by the visitor’s browser and the existing Flutter plugins. Web Qibla explicitly labels its manual simulation and does not claim a live sensor reading. WebGL is required; the startup/support shell explains unsupported environments and provides a retry action. Game points remain symbolic progress, not a claim to calculate religious merit.

## Rebuilding

Use Flutter 3.47.9 / Dart 3.13.7, then run:

```sh
PATH=/path/to/flutter/bin:$PATH scripts/rebuild-web.sh
```

The script builds the real release and replaces `public/`, retaining the reviewed HTML startup shell and `/manus-routes.json`. Commit source and static output together and push the managed `main` branch. Automatic publication follows the project’s existing Dashboard setting; do not enable it as part of a routine source update.

## Structure and checks

- `flutter_app/lib/theme/`: nature palettes, scenery extension, typography and spacing tokens.
- `flutter_app/lib/widgets/calm_ui.dart` and `nature_ui.dart`: shared quiet primitives and local botanical/scenery treatments.
- `flutter_app/lib/screens/`: principal and secondary application views.
- `flutter_app/lib/providers/`, `models/`, `services/`: existing state, content and business functions.
- `flutter_app/assets/`: bundled fonts, audio and purpose-specific imagery.
- `public/`: complete browser release and local CanvasKit resources.
- `scripts/rebuild-web.sh`: reproducible release refresh.
- `TODO.md` and `plan.md`: delivery scope and implementation decisions.

Run `flutter analyze` from `flutter_app/`. `test/design_system_test.dart` covers font inheritance, palette mapping and controls; `test/calm_redesign_test.dart` covers text contrast, 320px RTL layouts with increased text size, stable responsive navigation and lazy bridge requests. `test/nature_games_test.dart` covers all four day/night nature palettes, persisted theme selection, responsive game hall layouts, all 30 scene mappings, real round launches for all eight engines, reduced motion and zero-canvas safety. Existing model, provider, content and activity tests remain in place, with superseded presentation expectations updated to the current interface. Preview serves `public/` on the configured platform port; production serves committed static output, not sandbox processes.
