# Elysian Horizon — Design System

Platform perjalanan dengan estetika _Soft Minimalism_ dan _Atmospheric Layering_ — memadukan langit terbuka yang lapang dengan modernisme geometris yang bersih.

---

## Brand & Style

Desain ini mengusung etika perjalanan yang ekspansif, mengangkat, dan tenang — dirancang untuk menginspirasi wanderlust dan menghilangkan hambatan dalam penemuan destinasi. Dibangun dengan filosofi mobile-first.

**Dua pilar estetika utama:**

- **Atmospheric Gradient Canvas** — Tampilan mengalir dari kabut putih bercahaya ke nada biru horizon yang tenang.
- **Enclosed Visual Portals** — Foto dan highlight berada dalam portal lingkaran dan kapsul pill yang dibatasi border putih opak nan generous.
- **Geometric Harmony** — Heading dan body copy berbagi struktur geometris kontemporer yang kohesif.
- **Pill-Form Tactility** — Tombol, search bar, chip, dan navigasi mengadopsi geometri pill penuh untuk maksimalkan affordance sentuhan.

---

## Colors

### Palet Utama

| Token     | Hex       | Peran                                                                   |
| --------- | --------- | ----------------------------------------------------------------------- |
| Primary   | `#9DBED8` | Soft luminous horizon blue — gradient bg, aksen seleksi, container fill |
| Secondary | `#111827` | Deep charcoal slate — tipografi, tombol, ikon aktif                     |
| Tertiary  | `#EBF2F7` | Whispering sky mist — card backdrop, container sekunder, tint langit    |
| Neutral   | `#FFFFFF` | Pure cloud white — tombol interaktif, frosted glass, form input         |

### Surface

| Token                       | Hex       |
| --------------------------- | --------- |
| `surface`                   | `#F9F9F9` |
| `surface-dim`               | `#DADADA` |
| `surface-bright`            | `#F9F9F9` |
| `surface-container-lowest`  | `#FFFFFF` |
| `surface-container-low`     | `#F3F3F4` |
| `surface-container`         | `#EEEEEE` |
| `surface-container-high`    | `#E8E8E8` |
| `surface-container-highest` | `#E2E2E2` |

### Warna Sistem

| Token                | Hex       |
| -------------------- | --------- |
| `on-surface`         | `#1A1C1C` |
| `on-surface-variant` | `#42474C` |
| `inverse-surface`    | `#2F3131` |
| `inverse-on-surface` | `#F0F1F1` |
| `outline`            | `#72787D` |
| `outline-variant`    | `#C2C7CD` |
| `surface-tint`       | `#426279` |

### Primary

| Token                      | Hex       |
| -------------------------- | --------- |
| `primary`                  | `#426279` |
| `on-primary`               | `#FFFFFF` |
| `primary-container`        | `#9DBED8` |
| `on-primary-container`     | `#2D4D63` |
| `inverse-primary`          | `#A9CBE5` |
| `primary-fixed`            | `#C8E6FF` |
| `primary-fixed-dim`        | `#A9CBE5` |
| `on-primary-fixed`         | `#001E2F` |
| `on-primary-fixed-variant` | `#294A60` |

### Secondary

| Token                        | Hex       |
| ---------------------------- | --------- |
| `secondary`                  | `#575E70` |
| `on-secondary`               | `#FFFFFF` |
| `secondary-container`        | `#D9DFF5` |
| `on-secondary-container`     | `#5C6274` |
| `secondary-fixed`            | `#DCE2F7` |
| `secondary-fixed-dim`        | `#C0C6DB` |
| `on-secondary-fixed`         | `#141B2B` |
| `on-secondary-fixed-variant` | `#404758` |

### Tertiary

| Token                       | Hex       |
| --------------------------- | --------- |
| `tertiary`                  | `#585F64` |
| `on-tertiary`               | `#FFFFFF` |
| `tertiary-container`        | `#B4BBC0` |
| `on-tertiary-container`     | `#444B4F` |
| `tertiary-fixed`            | `#DCE3E8` |
| `tertiary-fixed-dim`        | `#C0C7CC` |
| `on-tertiary-fixed`         | `#151D20` |
| `on-tertiary-fixed-variant` | `#41484C` |

### Error & Lainnya

| Token                | Hex       |
| -------------------- | --------- |
| `error`              | `#BA1A1A` |
| `on-error`           | `#FFFFFF` |
| `error-container`    | `#FFDAD6` |
| `on-error-container` | `#93000A` |
| `background`         | `#F9F9F9` |
| `on-background`      | `#1A1C1C` |
| `sky-gradient-start` | `#F4F8FB` |
| `text-muted`         | `#4B5563` |
| `surface-border`     | `#C2C7CD` |
| `accent-dark-blue`   | `#426279` |

### Aturan Penggunaan Palet

- **Canvas Gradation** — Viewport penuh bertransisi linear dari `#F4F8FB` (atas) ke `#9DBED8` (bawah).
- **Inverted Core Actions** — Tombol primer menggunakan fill `#FFFFFF` dengan tipografi `#111827` agar kontras di atas wash horizon berwarna.
- **Secondary Copy** — Detail tambahan, segmen penerbangan, dan metadata menggunakan `text-muted` (`#4B5563`) di permukaan terang untuk legibilitas AA.

---

## Typography

Seluruh tipografi menggunakan satu keluarga: **Poppins**.

### Skala Tipografi

| Token                | Font    | Size | Weight | Line Height | Letter Spacing |
| -------------------- | ------- | ---- | ------ | ----------- | -------------- |
| `headline-xl`        | Poppins | 40px | 700    | 48px        | 0.02em         |
| `headline-xl-mobile` | Poppins | 30px | 700    | 38px        | 0.02em         |
| `headline-lg`        | Poppins | 26px | 600    | 34px        | 0.01em         |
| `headline-md`        | Poppins | 20px | 600    | 28px        | 0em            |
| `headline-sm`        | Poppins | 18px | 600    | 24px        | 0em            |
| `body-lg`            | Poppins | 16px | 400    | 26px        | 0em            |
| `body-md`            | Poppins | 14px | 400    | 22px        | 0em            |
| `body-sm`            | Poppins | 12px | 400    | 18px        | 0em            |
| `label-lg`           | Poppins | 15px | 600    | 20px        | 0.04em         |
| `label-md`           | Poppins | 13px | 600    | 18px        | 0.02em         |
| `label-sm`           | Poppins | 11px | 600    | 16px        | 0.04em         |

### Peran Tipografi

- **Headlines (SemiBold/Bold)** — Otoritas kritis dan optimis. Sering uppercase atau title-case dengan tracking halus.
- **Body (Regular)** — X-height generous dan counter terbuka menjaga keterbacaan pada itinerari padat.
- **Action Labels (SemiBold)** — Diterapkan pada tombol, pill pencarian, dan tab dengan tracking halus untuk hierarki visual saat scanning cepat.

---

## Layout & Spacing

### Spacing Tokens

| Token           | Value     |
| --------------- | --------- |
| `gutter`        | `1rem`    |
| `gutter-sm`     | `0.75rem` |
| `margin`        | `1.5rem`  |
| `margin-mobile` | `1.25rem` |
| `space-xs`      | `0.25rem` |
| `space-sm`      | `0.5rem`  |
| `space-md`      | `1rem`    |
| `space-lg`      | `1.5rem`  |
| `space-xl`      | `2.5rem`  |

### Rounded Tokens

| Token               | Value    |
| ------------------- | -------- |
| `rounded-sm`        | `0.5rem` |
| `rounded` (default) | `1rem`   |
| `rounded-md`        | `1.5rem` |
| `rounded-lg`        | `2rem`   |
| `rounded-xl`        | `3rem`   |
| `rounded-full`      | `9999px` |

### Grid

| Breakpoint | Layout                                        |
| ---------- | --------------------------------------------- |
| Mobile     | Fluid single column, edge margin `1.25rem`    |
| Tablet     | 4–8 kolom, gutter `1rem`                      |
| Desktop    | 12 kolom, max-width `1200px`, gutter `1.5rem` |

---

## Elevation & Depth

| Elemen                   | Shadow                                                               |
| ------------------------ | -------------------------------------------------------------------- |
| Tombol & floating action | `0 8px 24px -4px rgba(17, 24, 39, 0.08)`                             |
| Card destinasi           | `0 10px 30px rgba(0, 0, 0, 0.05)`                                    |
| Frosted nav/filter       | `background: rgba(255,255,255,0.85)` + `backdrop-filter: blur(16px)` |
| Portal border (halo)     | `4px–6px solid #FFFFFF`                                              |

---

## Components

### Buttons

**Primary Pill Action**

```css
background: #ffffff;
color: #111827;
font:
  label-lg,
  weight 600,
  uppercase,
  letter-spacing 0.04em;
border-radius: 9999px;
height: 54px;
box-shadow: 0 8px 20px rgba(17, 24, 39, 0.06);
```

**Secondary Pill Button**

```css
background: rgba(255, 255, 255, 0.25);
border: 1px solid #ffffff;
color: #111827;
font: label-md;
border-radius: 9999px;
```

---

### Input Fields & Search Bars

```css
border-radius: 9999px;
height: 52px;
background: #ffffff; /* atau rgba(255,255,255,0.95) */
border: 1px solid rgba(157, 190, 216, 0.45);
color: #111827; /* teks isi */
/* placeholder */
color: #4b5563;

/* Focus state */
border: 2px solid #111827;
```

---

### Category Chips & Filters

```css
/* Inactive */
border-radius: 9999px;
padding: 0.5rem 1.25rem;
background: rgba(255, 255, 255, 0.7);
color: #4b5563;
font: label-md;

/* Active */
background: #111827;
color: #ffffff;
```

---

### Image Portals (Circular Frames)

```css
border-radius: 50%;
aspect-ratio: 1 / 1;
border: 4px solid #ffffff; /* hingga 6px */
/* Stacking: overlap offset -1.5rem hingga -2rem */
```

---

### Booking & Destination Cards

```css
background: #ffffff;
border-radius: 1.5rem; /* hingga 2rem */
box-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
/* Gambar di atas dengan border-radius sama */
/* Nama destinasi: headline-md */
/* Tag negara: body-sm */
/* Harga: accent badge pill */
```

---

### Checkboxes & Radio Selectors

- **Radio** — Cincin luar dengan fill aktif `#9DBED8` dan disc putih di tengah.
- **Checkbox** — Sudut membulat `rounded-sm`, berubah ke `#111827` saat dipilih dengan ikon centang putih.

---

_Elysian Horizon Design System — dokumentasi internal_
