# CountiQ — Number Target Puzzle Game

Game teka-teki matematika ala "Countdown" TV show. Pemain diberikan angka target (misal: 120) dan serangkaian angka input (misal: 75, 5, 8, 7, 6, 2). Pemain harus kombinasikan angka-angka tersebut dengan operasi +, -, ×, ÷ untuk mencapai target.

Layout dan struktur arsitektur akan mengikuti pola **CryptiQ** (dark glassmorphism, particle background, gold accent, Poppins font).

## Pendekatan: Bertahap (Inti Dulu)

Karena projectnya cukup besar, kita akan bangun **menu inti** terlebih dahulu:

### Fase 1 (Sekarang) — Foundation + Core Screens
1. **Project Setup** — Flutter project, dependencies, fonts, theme
2. **Core Engine** — Puzzle Generator + Solver algorithm
3. **Home Screen** — Layout seperti CryptiQ
4. **Game Screen** — Board interaksi (tap angka → tap operator → tap angka → hasil)
5. **Result Screen** — Tampilan setelah berhasil solve

### Fase 2 (Nanti) — Extended Features
- Level Select Screen
- Daily Challenge
- Settings Screen
- Statistics Screen
- Hint System (watch ad for hint)
- Sound effects

### Fase 3 (Nanti) — Monetization & Polish
- Ads integration
- IAP (Pro mode)
- Achievements
- Onboarding

---

## Proposed Changes — Fase 1

### Project Setup

#### [NEW] Flutter project initialization
- `flutter create countiq` di folder `/Users/sbr-02/Belajar/countiq`
- Dependencies: `flutter_riverpod`, `go_router`, `equatable`, `hive`, `hive_flutter`, `confetti`
- Font: Poppins (copy dari CryptiQ)

---

### Core Theme (Mengikuti pattern CryptiQ)

#### [NEW] [app_theme.dart](file:///Users/sbr-02/Belajar/countiq/lib/core/theme/app_theme.dart)
- Warna tema: Dark navy + **Cyan/Teal accent** (beda dari CryptiQ yang gold) → memberi identitas unik
- Glassmorphism decoration, glow decoration
- Background gradient, surface colors
- Difficulty colors untuk level

#### [NEW] [theme_presets.dart](file:///Users/sbr-02/Belajar/countiq/lib/core/theme/theme_presets.dart)
- Default: Deep Ocean (cyan/teal accent)
- Preset lain bisa ditambah nanti

---

### Core Engine (Bagian Tersulit)

#### [NEW] [puzzle_model.dart](file:///Users/sbr-02/Belajar/countiq/lib/domain/models/puzzle_model.dart)
- `CountiqPuzzle` class: `target` (int), `numbers` (List<int>), `solutions` (List<Solution>)
- `Solution` class: list of `Step` (num1, operator, num2, result)

#### [NEW] [puzzle_solver.dart](file:///Users/sbr-02/Belajar/countiq/lib/core/engine/puzzle_solver.dart)
- Brute-force solver: coba semua kombinasi angka & operasi
- Rules: single use, hanya bilangan bulat positif, no fractions
- Return semua solusi yang valid

#### [NEW] [puzzle_generator.dart](file:///Users/sbr-02/Belajar/countiq/lib/core/engine/puzzle_generator.dart)
- Generate random numbers + target
- Verify solvability menggunakan solver
- Difficulty tiers: Easy (target 10-100), Medium (100-300), Hard (300-999)
- Angka pool: "big numbers" [25, 50, 75, 100] + "small numbers" [1-10]

#### [NEW] [game_validator.dart](file:///Users/sbr-02/Belajar/countiq/lib/core/engine/game_validator.dart)
- Validasi langkah pemain (no fractions, no negatives)
- Check apakah target tercapai

---

### Presentation Layer

#### [NEW] [particle_background.dart](file:///Users/sbr-02/Belajar/countiq/lib/presentation/widgets/particle_background.dart)
- Floating math symbols (÷, ×, +, −) sebagai partikel background (bukan titik biasa)

#### [NEW] [home_screen.dart](file:///Users/sbr-02/Belajar/countiq/lib/presentation/screens/home_screen.dart)
Layout mengikuti CryptiQ:
- Logo circle dengan "C" → tapi icon kalkulator/angka
- Title "CountiQ" dengan ShaderMask gradient
- Subtitle "Reach the Number"
- Daily Challenge card (placeholder dulu)
- **▶ PLAY** button (gold/cyan glow)
- Select Level button
- Icon row: Stats, Achievements, Settings
- Particle background

#### [NEW] [game_screen.dart](file:///Users/sbr-02/Belajar/countiq/lib/presentation/screens/game_screen.dart)
**Layout Game Board:**
```
┌──────────────────────────┐
│  ← Back    Level 1   ⏱  │  Header
├──────────────────────────┤
│                          │
│      TARGET: 120         │  Target display (besar, prominent)
│                          │
├──────────────────────────┤
│  Steps:                  │
│  ① 75 ÷ 5 = 15          │  Steps history (scrollable)
│  ② 15 × 8 = 120 ✓       │
│                          │
├──────────────────────────┤
│  ┌───┐ ┌───┐ ┌───┐      │
│  │75 │ │ 7 │ │ 6 │      │  Number tiles (tap to select)
│  └───┘ └───┘ └───┘      │  Angka yang sudah dipakai → dim/strikethrough
│  ┌───┐ ┌───┐ ┌───┐      │
│  │ 2 │ │ 8 │ │ 5 │      │
│  └───┘ └───┘ └───┘      │
├──────────────────────────┤
│  ┌─┐  ┌─┐  ┌─┐  ┌─┐    │
│  │+│  │-│  │×│  │÷│    │  Operator buttons
│  └─┘  └─┘  └─┘  └─┘    │
├──────────────────────────┤
│  💡 Hint    ↩ Undo   ✓  │  Action buttons
└──────────────────────────┘
```

**Mekanik Interaksi:**
1. Tap angka pertama → highlight
2. Tap operator → operator terpilih
3. Tap angka kedua → kalkulasi otomatis
4. Hasil muncul sebagai "angka baru" menggantikan kedua angka
5. Ulangi sampai target tercapai

#### [NEW] [result_screen.dart](file:///Users/sbr-02/Belajar/countiq/lib/presentation/screens/result_screen.dart)
- Star rating (1-3 bintang)
- Waktu penyelesaian
- Steps yang diambil
- Tombol: Next Level, Replay, Home

---

### State Management

#### [NEW] [game_state_provider.dart](file:///Users/sbr-02/Belajar/countiq/lib/presentation/providers/game_state_provider.dart)
- GameState: puzzle, availableNumbers, steps, selectedNumber, selectedOperator, timer, isComplete
- Actions: selectNumber, selectOperator, undo, reset, useHint

---

### Navigation

#### [NEW] [app_router.dart](file:///Users/sbr-02/Belajar/countiq/lib/presentation/router/app_router.dart)
- Routes: `/` (home), `/game` (game), `/result` (result)
- Smooth slide-fade transitions (copy pattern dari CryptiQ)

---

### Main Entry

#### [NEW] [main.dart](file:///Users/sbr-02/Belajar/countiq/lib/main.dart)
- Initialize Hive, set orientations, run app with ProviderScope

---

## Warna Tema CountiQ (Identitas Sendiri)

Untuk membedakan dari CryptiQ (Navy Gold), CountiQ akan menggunakan:
- **Primary**: Cyan/Teal `#00E5FF` → `#00BCD4`
- **Background**: Deep dark blue `#0A0E1A` → `#111827`
- **Surface**: `#1A2332` → `#243447`
- **Accent gradient**: Cyan to electric blue

> [!IMPORTANT]
> **Identitas Visual**: CountiQ punya nuansa "math/number" yang kuat — warna cyan/electric blue, particle background dengan simbol matematika floating, dan angka-angka sebagai elemen dekoratif.

---

## Verification Plan

### Automated Tests
- Unit test solver: verifikasi bahwa solver bisa menemukan solusi untuk soal yang sudah diketahui jawabannya
- Unit test generator: generate 100 soal, pastikan semuanya solvable
- Unit test validator: cek rules (no fractions, no negatives, single use)

### Manual Verification
- Run di Chrome / emulator
- Test mekanik tap angka → operator → angka → hasil
- Verifikasi layout responsif di berbagai ukuran layar

---

> [!NOTE]
> Fase 1 ini fokus pada **fondasi yang solid**: engine yang benar + 3 screen inti (Home, Game, Result). Fitur tambahan (Daily Challenge, Level Select, Settings, dll) akan ditambahkan bertahap di fase berikutnya.

---

## Fase 5 (Selesai) — Onboarding

### Keputusan Desain

**Pilihan yang diajukan:**
1. ~~Phase 5: Full Localization — Terapkan localization ke semua screen~~
2. ~~Phase 5: Ads Integration (AdMob)~~
3. ~~Phase 5: UI/UX Improvement~~
4. **✅ Phase 5: Onboarding — First-time user tutorial overlay** ← Dipilih
5. ~~Phase 5: Complete Localization + Production Ready~~

**Alasan**: Onboarding penting untuk user retention. User baru perlu dipandu cara bermain agar tidak bingung dan langsung engage.

### Pendekatan yang Dipilih

**Full-screen overlay** (bukan redirect ke `/how-to-play`):
- Lebih premium dan immersive
- Muncul otomatis HANYA pertama kali (state disimpan di Hive)
- Background semi-transparent glassmorphism di atas home screen
- 4 halaman swipeable dengan animasi smooth
- Tombol "Skip" di setiap halaman (kecuali terakhir)

### Proposed Changes — Fase 5

#### [MODIFY] [local_database.dart](file:///Users/sbr-02/Belajar/countiq/lib/data/datasources/local_database.dart)
- `isFirstLaunch` getter → cek `_settingsBox.get('onboarding_done')`
- `markOnboardingDone()` → set flag ke `true`

#### [NEW] [onboarding_overlay.dart](file:///Users/sbr-02/Belajar/countiq/lib/presentation/widgets/onboarding_overlay.dart)
4-slide overlay widget:
- Slide 1: Welcome — Logo bounce, gradient title, math symbols
- Slide 2: How It Works — TARGET mockup (120), 4 step rows
- Slide 3: Rules — 3 color-coded rule cards
- Slide 4: Ready — Feature icons + "LET'S GO!" CTA

#### [MODIFY] [home_screen.dart](file:///Users/sbr-02/Belajar/countiq/lib/presentation/screens/home_screen.dart)
- Stack wrapper, cek `isFirstLaunch` di `initState()`
- Tampilkan `OnboardingOverlay` sebagai full-screen overlay

#### [MODIFY] [app_strings.dart](file:///Users/sbr-02/Belajar/countiq/lib/core/l10n/app_strings.dart)
- 14 key baru untuk onboarding (EN/ID)

### Verification — Fase 5
- ✅ `flutter analyze` → 0 issues
- ✅ Overlay muncul saat pertama kali buka app
- ✅ Setelah complete, tidak muncul lagi
- ✅ Reset di Settings → onboarding muncul lagi
