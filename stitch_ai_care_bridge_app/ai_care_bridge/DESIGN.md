---
name: AI Care Bridge
colors:
  surface: '#f7f9fb'
  surface-dim: '#d8dadc'
  surface-bright: '#f7f9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f6'
  surface-container: '#eceef0'
  surface-container-high: '#e6e8ea'
  surface-container-highest: '#e0e3e5'
  on-surface: '#191c1e'
  on-surface-variant: '#404850'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eff1f3'
  outline: '#707881'
  outline-variant: '#bfc7d1'
  surface-tint: '#006399'
  primary: '#005d90'
  on-primary: '#ffffff'
  primary-container: '#0077b6'
  on-primary-container: '#f3f7ff'
  inverse-primary: '#94ccff'
  secondary: '#00677d'
  on-secondary: '#ffffff'
  secondary-container: '#50d9fe'
  on-secondary-container: '#005c70'
  tertiary: '#00645f'
  on-tertiary: '#ffffff'
  tertiary-container: '#007f78'
  on-tertiary-container: '#d7fffa'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#cde5ff'
  primary-fixed-dim: '#94ccff'
  on-primary-fixed: '#001d32'
  on-primary-fixed-variant: '#004b74'
  secondary-fixed: '#b3ebff'
  secondary-fixed-dim: '#4cd6fb'
  on-secondary-fixed: '#001f27'
  on-secondary-fixed-variant: '#004e5f'
  tertiary-fixed: '#72f7ed'
  tertiary-fixed-dim: '#50dad1'
  on-tertiary-fixed: '#00201e'
  on-tertiary-fixed-variant: '#00504b'
  background: '#f7f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
typography:
  h1:
    fontFamily: Poppins
    fontSize: 32px
    fontWeight: '600'
    lineHeight: '1.2'
    letterSpacing: -0.02em
  h2:
    fontFamily: Poppins
    fontSize: 24px
    fontWeight: '600'
    lineHeight: '1.3'
    letterSpacing: -0.01em
  h3:
    fontFamily: Poppins
    fontSize: 20px
    fontWeight: '500'
    lineHeight: '1.4'
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: '1.6'
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.5'
  label-caps:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: '1.2'
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  container_padding: 24px
  gutter: 16px
  stack_sm: 12px
  stack_md: 24px
  stack_lg: 40px
---

## Brand & Style

The design system is rooted in the **Glassmorphism** movement, tailored specifically for the healthcare sector. It balances technical precision with emotional reassurance, utilizing "frosted" surfaces to evoke a sense of lightness, clarity, and breathability. The brand personality is professional yet empathetic, acting as a "calm bridge" between complex AI data and human well-being.

The interface prioritizes high-trust visuals by avoiding harsh edges or clinical coldness. Instead, it uses soft-focus backgrounds, organic gradients, and high-quality transparency to create a sense of depth and openness. The user experience should feel like a guided journey—fluid, intuitive, and stress-free.

## Colors

The palette is inspired by the calming properties of water and air. **Ocean Blue** (#0077B6) serves as the anchor, providing a foundation of stability and medical professionalism. **Cyan** (#00B4D8) and **Teal** (#00B2A9) are used for interactive elements and data visualizations, injecting a modern, high-tech energy into the interface.

**White** is the primary canvas, but it is rarely used as a flat hex code; it is almost always rendered as a translucent, frosted layer. Backgrounds should utilize a subtle linear gradient from a very soft Ocean Blue to a clean White to provide the necessary "under-glow" for glassmorphism effects to excel.

## Typography

This design system utilizes a dual-font strategy to balance character and clarity. **Poppins** is reserved for headings and structural labels, providing a friendly, geometric warmth that feels approachable. Its larger x-height ensures readability even in high-transparency environments.

**Inter** is the workhorse font for all body copy, UI controls, and data displays. It was chosen for its exceptional legibility and neutral tone, ensuring that vital health information is communicated without distraction. For health metrics and labels, Inter’s tabular numbers and clean glyphs maintain a professional, data-driven aesthetic.

## Layout & Spacing

The layout follows a fluid-width model tailored for mobile viewports, utilizing a **24px side margin** to provide generous white space and prevent the glass elements from feeling cramped. A consistent **8px grid** governs all spacing increments.

To ensure visual harmony, this design system utilizes an "Equal-Height Card" philosophy for dashboard views. Elements within a horizontal scroll or a two-column grid must maintain uniform heights to preserve the clean, structured rhythm of the glass layers. Internal padding within glass cards should be no less than 20px to ensure the frosted edges are visible and distinct.

## Elevation & Depth

Depth is achieved through the stacking of translucent layers rather than traditional dark shadows. The primary elevation technique is the **Backdrop Blur (20px - 30px)** applied to surfaces with a semi-transparent white fill.

1.  **Base Layer:** Soft, vibrant gradient mesh (Ocean Blue to Cyan).
2.  **Mid Layer (Cards):** 70% opacity white with a 24px backdrop blur and a 1.5px semi-transparent white border to simulate light catching the edge of the glass.
3.  **Top Layer (Modals/Overlays):** 85% opacity white with a subtle, ultra-diffused shadow (Color: Ocean Blue, Opacity: 8%, Blur: 40px) to indicate high importance.

Avoid pure black shadows; instead, use tinted "Calm Shadows" that pull color from the primary palette to maintain a soft, integrated appearance.

## Shapes

The shape language is defined by significant curvature, emphasizing comfort and safety. The standard corner radius for all primary containers and cards is **24px**. This high level of roundedness reinforces the organic, human-centric nature of the "Care Bridge" concept.

Buttons and input fields utilize "Pill" shapes or a slightly reduced **16px radius** to differentiate interactive elements from static containers. All stroke weights for glass borders should remain thin (1px to 1.5px) to maintain the illusion of delicate, high-quality material.

## Components

### Buttons
Primary CTAs are large (min-height: 56px) and feature a vibrant gradient (Ocean Blue to Cyan). They should use a subtle inner glow rather than a heavy drop shadow. Text should be bold Inter in white. Secondary buttons utilize the "Ghost Glass" style: transparent center with a solid 2px Teal border.

### Glass Cards
Cards are the primary structural unit. They must feature a 24px corner radius and a 1px white border at 40% opacity. When multiple cards appear in a row (e.g., health metrics), they must be locked to equal height to ensure the grid remains professional and stable.

### Input Fields
Inputs should appear as "recessed glass"—slightly darker than the background with an inner shadow to suggest depth. Focused states are signaled by a 2px Cyan glow and a transition of the background to a clearer, less blurred state.

### Health Trackers
Circular progress indicators and charts should use high-contrast Teal and Cyan against the frosted background. Use soft "blob" shapes for data background accents to maintain the organic feel.

### Navigation
The Bottom Navigation Bar should be a floating glass dock with 32px rounded corners, sitting 16px away from the screen bottom. Active icons should glow subtly in Cyan.