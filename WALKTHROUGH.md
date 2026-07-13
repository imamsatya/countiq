# CountiQ — Walkthrough (Phase 1 → Phase 4)

## Summary
Game CountiQ — number target puzzle ala "Countdown" TV show. Pemain diberikan angka target dan harus mengkombinasikan angka-angka yang tersedia dengan operasi +, −, ×, ÷ untuk mencapai target.

## File Structure
```
countiq/
├── lib/
│   ├── main.dart                                    # Entry point + Hive init
│   ├── core/
│   │   ├── theme/
│   │   │   └── app_theme.dart                       # Cyan/Teal theme system
│   │   ├── engine/
│   │   │   ├── puzzle_solver.dart                    # Brute-force recursive solver
│   │   │   ├── puzzle_generator.dart                 # Random solvable puzzle gen
│   │   │   └── campaign_generator.dart               # Seeded deterministic levels
│   │   ├── l10n/
│   │   │   └── app_strings.dart                      # EN/ID localization strings
│   │   └── services/
│   │       ├── daily_challenge_service.dart           # Date-seeded daily puzzle + streak
│   │       ├── sound_service.dart                     # Audio + haptic feedback
│   │       └── achievement_service.dart               # 20 achievements, 5 categories
│   ├── data/
│   │   └── datasources/
│   │       └── local_database.dart                   # Hive persistence + resetAll()
│   ├── domain/
│   │   └── models/
│   │       └── puzzle_model.dart                     # CalcStep, Solution, CountiqPuzzle
│   └── presentation/
│       ├── router/
│       │   └── app_router.dart                       # GoRouter (11 routes)
│       ├── providers/
│       │   └── game_state_provider.dart              # Riverpod game state
│       ├── screens/
│       │   ├── home_screen.dart                      # Home menu + entry animations
│       │   ├── game_screen.dart                      # Quick play + solve flash
│       │   ├── campaign_game_screen.dart             # Campaign level game
│       │   ├── daily_challenge_screen.dart            # Daily challenge
│       │   ├── time_attack_screen.dart                # 60s time attack mode
│       │   ├── result_screen.dart                    # Result + confetti + share + star anim
│       │   ├── level_select_screen.dart              # Level grid (5x5, paginated)
│       │   ├── achievements_screen.dart               # Achievement gallery
│       │   ├── how_to_play_screen.dart                # 5-page swipeable tutorial
│       │   ├── settings_screen.dart                  # Sound/haptic/language/reset
│       │   └── statistics_screen.dart                # Stats + Time Attack stats
│       └── widgets/
│           ├── particle_background.dart              # Math symbol particles + rotation
│           ├── onboarding_overlay.dart                # First-time 4-slide tutorial overlay
│           └── achievement_toast.dart                 # Unlock notification overlay
├── fonts/                                            # Poppins font family
├── assets/audio/                                     # pop.mp3, success.mp3, error.mp3
├── IMPLEMENTATION_PLAN.md                            # Full plan (Fase 1-4)
└── WALKTHROUGH.md                                    # This file
```

---

## Phase 1 — Foundation ✅

### Core Engine
- **Puzzle Solver** — Recursive brute-force, tries all number pair + operator combos
- **Puzzle Generator** — Random generation with solvability verification
- **Rules**: single use, positive integers only, no fractions, no negatives

### Core Screens
- **Home Screen** — CryptiQ-style layout, particle background, gradient title
- **Game Screen** — Target display, number tiles, operator buttons, step history
- **Result Screen** — Confetti, star rating, stats cards

---

## Phase 2 — Progression & Persistence ✅

### Local Database (Hive)
- **Settings**: sound, haptic, difficulty preferences
- **Level progress**: stars, time, steps per campaign level
- **Statistics**: total solved, total time, best time, per-difficulty counts

### New Screens
- **Level Select** — 5x5 grid, 4 pages, lock/unlock, star indicators
- **Campaign Game** — Seeded puzzles (1-30 Easy, 31-70 Medium, 71-100 Hard)
- **Settings** — Sound/haptic toggles, reset progress with confirmation
- **Statistics** — Overview cards, progress bar, quick play breakdown

---

## Phase 2.5 — Daily Challenge ✅

### Daily Challenge Service
- Date-seeded puzzle generation (same puzzle for all players on same day)
- Medium-hard difficulty (2 big numbers, 4 small, target 100-999)
- Streak tracking with persistence
- Completion state (can only solve once per day)

### Daily Challenge Screen
- Date display + streak fire emoji
- Shows "completed" state with stars & time if already done today
- "Come back tomorrow" message
- Full game mechanics (hint, undo, reset)

---

## Phase 3 — Polish & Engagement ✅

### Achievement System (20 achievements, 5 categories)

| Category | Achievements |
|----------|-------------|
| 🌱 Beginner | First Steps, Pure Mind, Speed Demon, Perfect Score |
| 📖 Campaign | Getting Started (10), Quarter Way (25), Halfway Hero (50), Campaign Master (100) |
| 🎮 Quick Play | Puzzle Lover (10), Puzzle Addict (50), Versatile, Hard Mode Hero |
| 📅 Daily | Daily Player, On a Roll (3), Weekly Warrior (7), Monthly Master (30) |
| 👑 Mastery | Lightning Fast (15s), Centurion (100), Star Collector (100★), Efficient (2 steps) |

### Achievement Toast
- Slide-in overlay notification when new achievement unlocked
- Auto-triggers on result screen after puzzle completion
- Shows for 3 seconds with smooth animation

### How To Play Tutorial
- 5-page swipeable walkthrough
- Pages: Goal, How to Play, Rules, Star Rating, Tips & Hints
- Dot indicators + Next/Got It navigation
- Example boxes with formatted math

### Sound/Haptic Service
- Centralized haptic feedback through `SoundService`
- Respects user settings (sound/haptic toggles)
- Prepared for future audioplayers integration

### Home Screen Updates
- "PLAY" button (simplified from "START CAMPAIGN")
- Daily Challenge card with streak + completion
- 4 bottom icons: Statistics, Achievements, How to Play, Settings

## Phase 4 — Social, Polish & Pre-Release ✅

### Share Results
- Share button on result screen with emoji-formatted text
- Includes target, star rating, solution steps, time, hashtags
- `share_plus` integration for native OS share sheet

### Localization (EN/ID)
- `AppStrings` class with 100+ key-value pairs for EN and ID
- Language toggle in Settings (🇬🇧 EN ↔ 🇮🇩 ID)
- Persisted in Hive via `getLocale()` / `setLocale()`
- Applied to home screen and settings screen

### UX Polish
- **Home Screen**: Staggered entry animations (logo bounce, fade+slide for title, buttons, icons)
- **Daily Card**: Pulse glow animation when not completed today
- **Game Screen**: Green celebration flash overlay on puzzle solve
- **Result Screen**: Stars bounce in one-by-one (staggered elasticOut)
- **Result Screen**: Stats counter animation (numbers count up from 0)
- **Particles**: 25 particles with rotation, added π, √, ∑ symbols

### Time Attack Stats
- New section in Statistics screen: Best Score, Games Played, Total Solved, Avg per Game
- Empty state prompt if no games played yet

### Reset Progress Fix
- **Bug**: Reset only cleared `settingsBox` → stats and levels were preserved
- **Fix**: New `resetAll()` method clears all 3 Hive boxes

---

## Phase 5 — Onboarding & Localization ✅

### Full Localization (11 Languages)
- **11 Bahasa**: English, Español, Português, Deutsch, Français, 日本語, 한국어, Bahasa Indonesia, 简体中文, हिन्दी, العربية.
- **System Default**: Opsi deteksi bahasa sesuai pengaturan sistem device.
- **Language Selector**: Tampilan list picker premium dengan bendera (seperti di CryptiQ).
- **Semua Teks Diterjemahkan**: Mulai dari menu, tutorial, game screen, result, time attack, hingga statistik (total 70+ string).

### First-Time User Tutorial Overlay
- **Trigger**: Otomatis muncul saat pertama kali buka app (`isFirstLaunch` flag di Hive)
- **Persistence**: Flag `onboarding_done` disimpan di Hive, overlay hanya muncul sekali
- **Reset**: Jika user reset progress di Settings, onboarding muncul lagi

### 4-Slide Premium Overlay

| Slide | Isi | Visual |
|-------|-----|--------|
| 1. Welcome | Logo CountiQ + "Welcome to CountiQ!" | Logo bounce anim, gradient title, math symbols row |
| 2. How It Works | TARGET mockup (120) + 4 step rows | Mini game board, numbered steps with badges |
| 3. Rules | 3 aturan permainan | Color-coded rule cards with icons & examples |
| 4. Ready | Feature preview + CTA | Celebration emoji, feature icons, "LET'S GO!" glow button |

### Fitur Overlay
- Entry fade + scale animation (800ms)
- Exit fade animation (500ms)
- Per-page content fade + slide animation
- Animated dot indicators with gradient
- Skip button di setiap halaman (kecuali halaman terakhir)
- PageView dengan smooth navigation
- Full EN/ID localization (14 key baru)

### Files Changed
| File | Aksi |
|------|------|
| `onboarding_overlay.dart` | **NEW** — 4-slide full-screen overlay widget |
| `local_database.dart` | MODIFY — `isFirstLaunch` + `markOnboardingDone()` |
| `app_strings.dart` | MODIFY — 14 onboarding strings EN/ID |
| `home_screen.dart` | MODIFY — Stack wrapper + overlay trigger |

---

## Routes
| Path | Screen |
|------|--------|
| `/` | Home Screen |
| `/game/:difficulty` | Quick Play Game |
| `/campaign/:level` | Campaign Game |
| `/daily` | Daily Challenge |
| `/time-attack` | Time Attack |
| `/result` | Result Screen |
| `/levels` | Level Select |
| `/achievements` | Achievements |
| `/how-to-play` | How To Play |
| `/settings` | Settings |
| `/statistics` | Statistics |

---

## Verification
- ✅ `flutter analyze` — **0 issues**
- ✅ All phases (1-5) complete

---

## What's Next
- Ad integration (AdMob)
- IAP (Pro mode — remove ads)
- App store listing assets (screenshots, descriptions)
- More localization coverage (remaining screens)
- Leaderboard / online competitive mode
