# CountiQ — Walkthrough (Phase 1 + Phase 2 + Phase 2.5)

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
│   │       └── daily_challenge_service.dart           # Date-seeded daily puzzle + streak
│   ├── data/
│   │   └── datasources/
│   │       └── local_database.dart                   # Hive persistence layer
│   ├── domain/
│   │   └── models/
│   │       └── puzzle_model.dart                     # CalcStep, Solution, CountiqPuzzle
│   └── presentation/
│       ├── router/
│       │   └── app_router.dart                       # GoRouter (8 routes)
│       ├── providers/
│       │   └── game_state_provider.dart              # Riverpod game state
│       ├── screens/
│       │   ├── home_screen.dart                      # Home menu
│       │   ├── game_screen.dart                      # Quick play game
│       │   ├── campaign_game_screen.dart             # Campaign level game
│       │   ├── daily_challenge_screen.dart            # Daily challenge
│       │   ├── result_screen.dart                    # Result + confetti
│       │   ├── level_select_screen.dart              # Level grid (5x5, paginated)
│       │   ├── settings_screen.dart                  # Sound/haptic/reset
│       │   └── statistics_screen.dart                # Stats dashboard
│       └── widgets/
│           └── particle_background.dart              # Math symbol particles
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

### Home Screen Updates
- "PLAY" button (was "START CAMPAIGN")
- Daily Challenge card with completion indicator + streak badge
- Green check when today is completed

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
| `/settings` | Settings |
| `/statistics` | Statistics |

---

## Verification
- ✅ `flutter analyze` — **0 issues**
- ✅ `flutter run -d chrome` — running on localhost:8080

---

## What's Next (Phase 3)
- Achievements system
- Sound effects (audioplayers)
- Onboarding tutorial
- Ad integration
- IAP (Pro mode)
- Localization (EN/ID)
