# CountiQ — Walkthrough (Phase 1 → Phase 3)

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
│   │   └── services/
│   │       ├── daily_challenge_service.dart           # Date-seeded daily puzzle + streak
│   │       ├── sound_service.dart                     # Haptic feedback service
│   │       └── achievement_service.dart               # 20 achievements, 5 categories
│   ├── data/
│   │   └── datasources/
│   │       └── local_database.dart                   # Hive persistence layer
│   ├── domain/
│   │   └── models/
│   │       └── puzzle_model.dart                     # CalcStep, Solution, CountiqPuzzle
│   └── presentation/
│       ├── router/
│       │   └── app_router.dart                       # GoRouter (10 routes)
│       ├── providers/
│       │   └── game_state_provider.dart              # Riverpod game state
│       ├── screens/
│       │   ├── home_screen.dart                      # Home menu
│       │   ├── game_screen.dart                      # Quick play game
│       │   ├── campaign_game_screen.dart             # Campaign level game
│       │   ├── daily_challenge_screen.dart            # Daily challenge
│       │   ├── result_screen.dart                    # Result + confetti + achievement check
│       │   ├── level_select_screen.dart              # Level grid (5x5, paginated)
│       │   ├── achievements_screen.dart               # Achievement gallery
│       │   ├── how_to_play_screen.dart                # 5-page swipeable tutorial
│       │   ├── settings_screen.dart                  # Sound/haptic/reset
│       │   └── statistics_screen.dart                # Stats dashboard
│       └── widgets/
│           ├── particle_background.dart              # Math symbol particles
│           └── achievement_toast.dart                 # Unlock notification overlay
├── fonts/                                            # Poppins font family
├── IMPLEMENTATION_PLAN.md                            # Full plan (Fase 1-3)
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

---

## Routes
| Path | Screen |
|------|--------|
| `/` | Home Screen |
| `/game/:difficulty` | Quick Play Game |
| `/campaign/:level` | Campaign Game |
| `/daily` | Daily Challenge |
| `/result` | Result Screen |
| `/levels` | Level Select |
| `/achievements` | Achievements |
| `/how-to-play` | How To Play |
| `/settings` | Settings |
| `/statistics` | Statistics |

---

## Verification
- ✅ `flutter analyze` — **0 issues**
- ✅ `flutter run -d chrome` — running on localhost:8080

---

## What's Next
- Sound effects with audioplayers (tap, solve, error sounds)
- Share puzzle results to social media
- Ad integration (AdMob)
- IAP (Pro mode — remove ads)
- Localization (EN/ID)
- App store listing assets
