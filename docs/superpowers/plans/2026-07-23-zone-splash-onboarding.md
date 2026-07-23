# ZONE Splash + Onboarding Figma Build — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the 4 approved screens (Splash, Onboarding Slide 1, Slide 2, Slide 3) as pixel-faithful frames in a new Figma file called "ZONE", using the `claude.ai Figma` MCP tools, verified visually against the design spec at each step.

**Architecture:** One Figma design file with 4 top-level frames (393×852 each), built with the `use_figma` tool (JavaScript against the Figma Plugin API). Shared color/text styles are created once in Task 1 as the source of truth; Tasks 2–5 use raw values that are numerically identical to those styles (applying Figma style-ID references to every node is optional future polish, not required for this slice — visual consistency is what's being verified, via screenshots, not style linkage). Every build task ends with a `get_screenshot` check compared against the spec's written description — this is the "test" for design work, in place of automated tests.

**Tech Stack:** Figma (via `mcp__claude_ai_Figma__*` tools: `whoami`, `create_new_file`, `use_figma`, `get_screenshot`, `get_metadata`). Local git repo at `C:\Users\shakthi\Documents\zone` for spec/plan/build-log tracking only — no app code in this plan.

## Global Constraints

- Design spec of record: `docs/superpowers/specs/2026-07-23-splash-onboarding-design.md`. Every value below is copied from it verbatim — do not invent new colors, fonts, or copy.
- Frame size: 393×852 (iPhone 15 proportions) for all 4 frames.
- Background (onboarding frames): `#FAFAFA`. Text primary: `#111111`. Text secondary: `#6B7280`. Card border: `#E5E7EB`, card fill `#FFFFFF`.
- CTA buttons and the progress indicator's active segment are solid black `#111111` with white content — **no accent color** (green/terracotta was explicitly rejected; stay faithful to the reference).
- Semantic tag colors (only appear inside mockup cards, not as UI chrome): Alert `#DC2626`, Hot `#EA580C`, Info `#D97706`, Chill `#16A34A`.
- Headings: font family "Space Grotesk", style "Bold". Body/subtext: font family "Inter", styles "Regular" and "Semi Bold" (never "SemiBold" — Figma's Inter style name has a space).
- We have no real campus photography. Every place the spec calls for a photo (splash background, slide 1/2 card image, slide 3 project image), use a solid/gradient placeholder rectangle in a neutral dark-grey-blue (`#2B2F36` → `#1A1C20` gradient) instead of a fabricated image URL. Note it in the frame as a placeholder so it's obviously swappable later.
- Out of scope: verification/OTP screens, Main Shell/bottom nav, any other tab, backend, Flutter code. Do not build these.

---

### Task 1: Figma file setup + shared styles

**Figma artifacts:** New file "ZONE" (design type), page-level color styles, page-level text styles.
**Local files:**
- Create: `docs/superpowers/zone-figma-buildlog.md`

**Interfaces:**
- Consumes: nothing (first task)
- Produces: `fileKey` (Figma file key) and the following named styles, recorded in `zone-figma-buildlog.md` for every later task to reference by name:
  - Color styles: `Background/Onboarding` (#FAFAFA), `Text/Primary` (#111111), `Text/Secondary` (#6B7280), `Card/Border` (#E5E7EB), `Card/Fill` (#FFFFFF), `CTA/Black` (#111111), `Semantic/Alert` (#DC2626), `Semantic/Hot` (#EA580C), `Semantic/Info` (#D97706), `Semantic/Chill` (#16A34A)
  - Text styles: `Heading/Display` (Space Grotesk Bold, 28px, line-height 34px), `Body/Regular` (Inter Regular, 15px, line-height 21px), `Body/Small` (Inter Regular, 13px, line-height 18px, color Text/Secondary)

- [ ] **Step 1: Confirm Figma auth and get plan key**

Call `mcp__claude_ai_Figma__whoami` with no arguments. From the response, note the user's handle and the list of plans. If there is exactly one plan, use its `key` field as `planKey` in the next step. If there is more than one, stop and ask the user which team/organization to create the file in.

- [ ] **Step 2: Load the figma-create-new-file skill if it exists**

Try `Skill` with `figma-create-new-file`. If it does not exist in your skill list, try reading the MCP resource `skill://figma/figma-create-new-file/SKILL.md` via `ReadMcpResourceTool`. If neither exists, proceed without it — this is a soft dependency, `create_new_file`'s own tool description is authoritative.

- [ ] **Step 3: Create the Figma file**

Call `mcp__claude_ai_Figma__create_new_file` with:
```json
{
  "fileName": "ZONE",
  "planKey": "<planKey from Step 1>",
  "editorType": "design"
}
```
Record the returned `fileKey` and file URL.

- [ ] **Step 4: Load figma-use guidance**

Try `Skill` with `figma-use`. If unavailable, read the MCP resource `skill://figma/figma-use/SKILL.md` via `ReadMcpResourceTool`. Follow its guidance for the rest of this plan's `use_figma` calls. Note whichever path you used — pass it in `skillNames` on every `use_figma` call (e.g. `"figma-use"` or `"resource:figma-use"`).

- [ ] **Step 5: Create shared color and text styles**

Call `mcp__claude_ai_Figma__use_figma` with `fileKey` from Step 3, `skillNames` from Step 4, `description`: `"Create ZONE shared color and text styles"`, and `code`:

```javascript
async function run() {
  const page = figma.currentPage;

  const colors = [
    ["Background/Onboarding", 0xFA, 0xFA, 0xFA],
    ["Text/Primary", 0x11, 0x11, 0x11],
    ["Text/Secondary", 0x6B, 0x72, 0x80],
    ["Card/Border", 0xE5, 0xE7, 0xEB],
    ["Card/Fill", 0xFF, 0xFF, 0xFF],
    ["CTA/Black", 0x11, 0x11, 0x11],
    ["Semantic/Alert", 0xDC, 0x26, 0x26],
    ["Semantic/Hot", 0xEA, 0x58, 0x0C],
    ["Semantic/Info", 0xD9, 0x77, 0x06],
    ["Semantic/Chill", 0x16, 0xA3, 0x4A],
  ];

  const colorStyleIds = {};
  for (const [name, r, g, b] of colors) {
    const style = figma.createPaintStyle();
    style.name = name;
    style.paints = [{ type: "SOLID", color: { r: r / 255, g: g / 255, b: b / 255 } }];
    colorStyleIds[name] = style.id;
  }

  await figma.loadFontAsync({ family: "Space Grotesk", style: "Bold" });
  await figma.loadFontAsync({ family: "Inter", style: "Regular" });
  await figma.loadFontAsync({ family: "Inter", style: "Semi Bold" });

  const textStyleIds = {};

  const heading = figma.createTextStyle();
  heading.name = "Heading/Display";
  heading.fontName = { family: "Space Grotesk", style: "Bold" };
  heading.fontSize = 28;
  heading.lineHeight = { value: 34, unit: "PIXELS" };
  textStyleIds["Heading/Display"] = heading.id;

  const bodyRegular = figma.createTextStyle();
  bodyRegular.name = "Body/Regular";
  bodyRegular.fontName = { family: "Inter", style: "Regular" };
  bodyRegular.fontSize = 15;
  bodyRegular.lineHeight = { value: 21, unit: "PIXELS" };
  textStyleIds["Body/Regular"] = bodyRegular.id;

  const bodySmall = figma.createTextStyle();
  bodySmall.name = "Body/Small";
  bodySmall.fontName = { family: "Inter", style: "Regular" };
  bodySmall.fontSize = 13;
  bodySmall.lineHeight = { value: 18, unit: "PIXELS" };
  textStyleIds["Body/Small"] = bodySmall.id;

  return { colorStyleIds, textStyleIds };
}
return run();
```

Record the returned `colorStyleIds` and `textStyleIds` maps — later tasks need the exact style IDs to reuse fills/text styles by reference instead of re-declaring raw hex values.

- [ ] **Step 6: Verify styles exist**

Call `mcp__claude_ai_Figma__get_metadata` with the `fileKey` and no `nodeId` to list top-level pages, confirming the file is reachable. Then call `use_figma` again with `description: "List local paint and text styles"` and `code`:
```javascript
async function run() {
  const paints = await figma.getLocalPaintStylesAsync();
  const texts = await figma.getLocalTextStylesAsync();
  return {
    paints: paints.map(p => p.name),
    texts: texts.map(t => t.name),
  };
}
return run();
```
Confirm all 10 color style names and 3 text style names from Step 5 are present in the result.

- [ ] **Step 7: Write build log and commit**

Create `docs/superpowers/zone-figma-buildlog.md`:
```markdown
# ZONE Figma Build Log

File key: `<fileKey from Step 3>`
File URL: `<file URL from Step 3>`

## Shared styles (Task 1)
- Color style IDs: <paste colorStyleIds JSON>
- Text style IDs: <paste textStyleIds JSON>

## Screens
- [ ] Splash (Task 2)
- [ ] Onboarding Slide 1 (Task 3)
- [ ] Onboarding Slide 2 (Task 4)
- [ ] Onboarding Slide 3 (Task 5)
```

Run:
```bash
cd "C:\Users\shakthi\Documents\zone"
git add docs/superpowers/zone-figma-buildlog.md
git commit -m "Set up ZONE Figma file and shared styles"
```

---

### Task 2: Splash screen frame

**Figma artifacts:** Top-level frame `Splash`, 393×852.
**Local files:** Modify: `docs/superpowers/zone-figma-buildlog.md`

**Interfaces:**
- Consumes: `fileKey` and color style IDs (`Text/Primary` not used here — splash text is white per spec; use raw white) from `zone-figma-buildlog.md`
- Produces: `Splash` frame node ID, recorded in the build log for Task 6's final review

- [ ] **Step 1: Build the Splash frame**

Call `use_figma` with the `fileKey`, `skillNames` from Task 1 Step 4, `description`: `"Build ZONE Splash screen frame"`, `code`:

```javascript
async function run() {
  await figma.loadFontAsync({ family: "Space Grotesk", style: "Bold" });
  await figma.loadFontAsync({ family: "Inter", style: "Regular" });

  const frame = figma.createFrame();
  frame.name = "Splash";
  frame.resize(393, 852);
  frame.x = 0;
  frame.y = 0;
  frame.fills = [{
    type: "GRADIENT_LINEAR",
    gradientTransform: [[0, 1, 0], [-1, 0, 1]],
    gradientStops: [
      { position: 0, color: { r: 0.169, g: 0.184, b: 0.212, a: 1 } },
      { position: 1, color: { r: 0.102, g: 0.110, b: 0.125, a: 1 } },
    ],
  }];

  // Dark scrim overlay for text contrast over the placeholder photo
  const scrim = figma.createRectangle();
  scrim.name = "Scrim (placeholder photo overlay)";
  scrim.resize(393, 852);
  scrim.x = 0;
  scrim.y = 0;
  scrim.fills = [{ type: "SOLID", color: { r: 0, g: 0, b: 0 }, opacity: 0.35 }];
  frame.appendChild(scrim);

  // Top-left circular icon mark
  const iconCircle = figma.createEllipse();
  iconCircle.resize(40, 40);
  iconCircle.x = 24;
  iconCircle.y = 64;
  iconCircle.fills = [];
  iconCircle.strokes = [{ type: "SOLID", color: { r: 1, g: 1, b: 1 } }];
  iconCircle.strokeWeight = 1.5;
  frame.appendChild(iconCircle);

  // ZONE wordmark
  const wordmark = figma.createText();
  wordmark.fontName = { family: "Space Grotesk", style: "Bold" };
  wordmark.characters = "ZONE";
  wordmark.fontSize = 56;
  wordmark.fills = [{ type: "SOLID", color: { r: 1, g: 1, b: 1 } }];
  wordmark.x = 24;
  wordmark.y = 520;
  frame.appendChild(wordmark);

  // Tagline
  const tagline = figma.createText();
  tagline.fontName = { family: "Inter", style: "Regular" };
  tagline.characters = "Know your campus, before you step in.";
  tagline.fontSize = 15;
  tagline.fills = [{ type: "SOLID", color: { r: 0.85, g: 0.85, b: 0.87 } }];
  tagline.x = 24;
  tagline.y = 590;
  tagline.resize(300, 40);
  frame.appendChild(tagline);

  // Loading progress bar
  const barTrack = figma.createRectangle();
  barTrack.resize(345, 4);
  barTrack.cornerRadius = 2;
  barTrack.x = 24;
  barTrack.y = 780;
  barTrack.fills = [{ type: "SOLID", color: { r: 1, g: 1, b: 1 }, opacity: 0.2 }];
  frame.appendChild(barTrack);

  const barFill = figma.createRectangle();
  barFill.resize(120, 4);
  barFill.cornerRadius = 2;
  barFill.x = 24;
  barFill.y = 780;
  barFill.fills = [{ type: "SOLID", color: { r: 1, g: 1, b: 1 } }];
  frame.appendChild(barFill);

  // Loading caption
  const loadingText = figma.createText();
  loadingText.fontName = { family: "Inter", style: "Regular" };
  loadingText.characters = "Loading your campus...";
  loadingText.fontSize = 13;
  loadingText.fills = [{ type: "SOLID", color: { r: 0.75, g: 0.75, b: 0.78 } }];
  loadingText.x = 24;
  loadingText.y = 796;
  frame.appendChild(loadingText);

  return { frameId: frame.id };
}
return run();
```

- [ ] **Step 2: Screenshot and verify**

Call `mcp__claude_ai_Figma__get_screenshot` with the `fileKey` and the `frameId` from Step 1 as `nodeId`. Confirm the rendered image has: a dark background, an outlined circle top-left, a large white "ZONE" wordmark, the tagline beneath it, and a progress bar + loading caption near the bottom. If any element is missing or badly positioned, re-run Step 1's `use_figma` call with corrections before continuing.

- [ ] **Step 3: Update build log and commit**

Edit `docs/superpowers/zone-figma-buildlog.md`: check off `Splash`, add the frame's node ID under it. Run:
```bash
cd "C:\Users\shakthi\Documents\zone"
git add docs/superpowers/zone-figma-buildlog.md
git commit -m "Build ZONE Splash screen in Figma"
```

---

### Task 3: Onboarding Slide 1 — "Your campus. Unfiltered."

**Figma artifacts:** Top-level frame `Onboarding-1`, 393×852. Reusable component `Progress Indicator` (3-segment pill, segment 1 filled) and reusable component `Next Button` (circular black, white arrow) — both created here and instanced again in Tasks 4 and 5.
**Local files:** Modify: `docs/superpowers/zone-figma-buildlog.md`

**Interfaces:**
- Consumes: `fileKey`, color style IDs `Background/Onboarding`, `Text/Primary`, `Text/Secondary`, `Card/Border`, `Card/Fill`, `CTA/Black` from build log; text style IDs `Heading/Display`, `Body/Regular`, `Body/Small`
- Produces: `Onboarding-1` frame node ID, `Progress Indicator` component ID, `Next Button` component ID — all recorded in the build log for Tasks 4 and 5 to instance

- [ ] **Step 1: Build the Slide 1 frame with reusable Progress Indicator and Next Button components**

Call `use_figma` with `fileKey`, `skillNames`, `description`: `"Build ZONE Onboarding Slide 1 with reusable progress indicator and next button components"`, `code`:

```javascript
async function run() {
  await figma.loadFontAsync({ family: "Space Grotesk", style: "Bold" });
  await figma.loadFontAsync({ family: "Inter", style: "Regular" });
  await figma.loadFontAsync({ family: "Inter", style: "Semi Bold" });

  const frame = figma.createFrame();
  frame.name = "Onboarding-1";
  frame.resize(393, 852);
  frame.fills = [{ type: "SOLID", color: { r: 250 / 255, g: 250 / 255, b: 250 / 255 } }];

  // --- Progress Indicator component (3 segments, arg: activeIndex) ---
  function buildProgressIndicator(activeIndex) {
    const comp = figma.createComponent();
    comp.name = "Progress Indicator";
    comp.resize(64, 4);
    comp.fills = [];
    const segWidth = 18;
    const gap = 5;
    for (let i = 0; i < 3; i++) {
      const seg = figma.createRectangle();
      seg.resize(segWidth, 4);
      seg.cornerRadius = 2;
      seg.x = i * (segWidth + gap);
      seg.y = 0;
      seg.fills = [{
        type: "SOLID",
        color: i === activeIndex ? { r: 0.067, g: 0.067, b: 0.067 } : { r: 0.85, g: 0.85, b: 0.85 },
      }];
      comp.appendChild(seg);
    }
    return comp;
  }
  const progressComponent = buildProgressIndicator(0);
  progressComponent.x = 165;
  progressComponent.y = 24;
  frame.appendChild(progressComponent);

  // --- Skip label ---
  const skip = figma.createText();
  skip.fontName = { family: "Inter", style: "Regular" };
  skip.characters = "Skip";
  skip.fontSize = 15;
  skip.fills = [{ type: "SOLID", color: { r: 0.067, g: 0.067, b: 0.067 } }];
  skip.x = 337;
  skip.y = 20;
  frame.appendChild(skip);

  // --- Heading ---
  const heading = figma.createText();
  heading.fontName = { family: "Space Grotesk", style: "Bold" };
  heading.characters = "Your campus.\nUnfiltered.";
  heading.fontSize = 28;
  heading.lineHeight = { value: 34, unit: "PIXELS" };
  heading.fills = [{ type: "SOLID", color: { r: 0.067, g: 0.067, b: 0.067 } }];
  heading.x = 24;
  heading.y = 90;
  heading.resize(300, 80);
  frame.appendChild(heading);

  // --- Subtext ---
  const subtext = figma.createText();
  subtext.fontName = { family: "Inter", style: "Regular" };
  subtext.characters = "Anonymous pins on the map to keep everyone informed.";
  subtext.fontSize = 15;
  subtext.lineHeight = { value: 21, unit: "PIXELS" };
  subtext.fills = [{ type: "SOLID", color: { r: 0.42, g: 0.447, b: 0.502 } }];
  subtext.x = 24;
  subtext.y = 185;
  subtext.resize(320, 44);
  frame.appendChild(subtext);

  // --- Mockup card: photo + pin label chip ---
  const card = figma.createFrame();
  card.name = "Mockup Card";
  card.resize(345, 240);
  card.x = 24;
  card.y = 260;
  card.cornerRadius = 20;
  card.strokes = [{ type: "SOLID", color: { r: 0.898, g: 0.906, b: 0.922 } }];
  card.strokeWeight = 1;
  card.fills = [{
    type: "GRADIENT_LINEAR",
    gradientTransform: [[0, 1, 0], [-1, 0, 1]],
    gradientStops: [
      { position: 0, color: { r: 0.169, g: 0.184, b: 0.212, a: 1 } },
      { position: 1, color: { r: 0.102, g: 0.110, b: 0.125, a: 1 } },
    ],
  }];
  card.effects = [{
    type: "DROP_SHADOW",
    color: { r: 0, g: 0, b: 0, a: 0.08 },
    offset: { x: 0, y: 4 }, radius: 12, visible: true, blendMode: "NORMAL",
  }];
  frame.appendChild(card);

  const pinChip = figma.createFrame();
  pinChip.name = "Pin Label Chip";
  pinChip.layoutMode = "HORIZONTAL";
  pinChip.paddingLeft = 12; pinChip.paddingRight = 12;
  pinChip.paddingTop = 8; pinChip.paddingBottom = 8;
  pinChip.primaryAxisSizingMode = "AUTO";
  pinChip.counterAxisSizingMode = "AUTO";
  pinChip.cornerRadius = 12;
  pinChip.fills = [{ type: "SOLID", color: { r: 1, g: 1, b: 1 } }];
  pinChip.x = 16;
  pinChip.y = 16;
  const pinText = figma.createText();
  pinText.fontName = { family: "Inter", style: "Semi Bold" };
  pinText.characters = "📌 Library AC working today";
  pinText.fontSize = 13;
  pinText.fills = [{ type: "SOLID", color: { r: 0.067, g: 0.067, b: 0.067 } }];
  pinChip.appendChild(pinText);
  card.appendChild(pinChip);

  // --- Next Button component (circular black, white arrow) ---
  const nextButton = figma.createComponent();
  nextButton.name = "Next Button";
  nextButton.resize(56, 56);
  nextButton.cornerRadius = 28;
  nextButton.fills = [{ type: "SOLID", color: { r: 0.067, g: 0.067, b: 0.067 } }];
  const arrow = figma.createText();
  arrow.fontName = { family: "Inter", style: "Semi Bold" };
  arrow.characters = "→";
  arrow.fontSize = 22;
  arrow.fills = [{ type: "SOLID", color: { r: 1, g: 1, b: 1 } }];
  arrow.textAlignHorizontal = "CENTER";
  arrow.textAlignVertical = "CENTER";
  arrow.resize(56, 56);
  nextButton.appendChild(arrow);
  nextButton.x = 313;
  nextButton.y = 772;
  frame.appendChild(nextButton);

  return {
    frameId: frame.id,
    progressComponentId: progressComponent.id,
    nextButtonComponentId: nextButton.id,
  };
}
return run();
```

- [ ] **Step 2: Screenshot and verify**

Call `get_screenshot` with `nodeId: frameId`. Confirm: progress pill top-center with segment 1 dark, "Skip" top-right, two-line bold heading, grey subtext, a dark placeholder photo card with a white "📌 Library AC working today" chip in its top-left corner, and a black circular next-arrow button bottom-right. Fix and re-run Step 1 if anything is off.

- [ ] **Step 3: Update build log and commit**

Edit `docs/superpowers/zone-figma-buildlog.md`: check off `Onboarding Slide 1`, record `frameId`, `progressComponentId`, `nextButtonComponentId`. Run:
```bash
cd "C:\Users\shakthi\Documents\zone"
git add docs/superpowers/zone-figma-buildlog.md
git commit -m "Build ZONE Onboarding Slide 1 in Figma with reusable components"
```

---

### Task 4: Onboarding Slide 2 — "Say what you think."

**Figma artifacts:** Top-level frame `Onboarding-2`, 393×852. Instances of `Progress Indicator` (segment 2 active) and `Next Button` from Task 3.
**Local files:** Modify: `docs/superpowers/zone-figma-buildlog.md`

**Interfaces:**
- Consumes: `fileKey`, `progressComponentId`, `nextButtonComponentId` from build log (Task 3)
- Produces: `Onboarding-2` frame node ID, recorded in build log

- [ ] **Step 1: Build the Slide 2 frame, reusing Task 3's components**

Call `use_figma` with `fileKey`, `skillNames`, `description`: `"Build ZONE Onboarding Slide 2 reusing progress indicator and next button components"`, `code`:

```javascript
async function run(progressComponentId, nextButtonComponentId) {
  await figma.loadFontAsync({ family: "Space Grotesk", style: "Bold" });
  await figma.loadFontAsync({ family: "Inter", style: "Regular" });
  await figma.loadFontAsync({ family: "Inter", style: "Semi Bold" });

  const frame = figma.createFrame();
  frame.name = "Onboarding-2";
  frame.resize(393, 852);
  frame.fills = [{ type: "SOLID", color: { r: 250 / 255, g: 250 / 255, b: 250 / 255 } }];

  // Progress indicator instance, segment 2 active: recolor children directly on an instance copy
  const progressComponent = await figma.getNodeByIdAsync(progressComponentId);
  const progressInstance = progressComponent.createInstance();
  progressInstance.x = 165; progressInstance.y = 24;
  frame.appendChild(progressInstance);
  const segs = progressInstance.children;
  for (let i = 0; i < segs.length; i++) {
    segs[i].fills = [{
      type: "SOLID",
      color: i === 1 ? { r: 0.067, g: 0.067, b: 0.067 } : { r: 0.85, g: 0.85, b: 0.85 },
    }];
  }

  const skip = figma.createText();
  skip.fontName = { family: "Inter", style: "Regular" };
  skip.characters = "Skip";
  skip.fontSize = 15;
  skip.fills = [{ type: "SOLID", color: { r: 0.067, g: 0.067, b: 0.067 } }];
  skip.x = 337; skip.y = 20;
  frame.appendChild(skip);

  const heading = figma.createText();
  heading.fontName = { family: "Space Grotesk", style: "Bold" };
  heading.characters = "Say what\nyou think.";
  heading.fontSize = 28;
  heading.lineHeight = { value: 34, unit: "PIXELS" };
  heading.fills = [{ type: "SOLID", color: { r: 0.067, g: 0.067, b: 0.067 } }];
  heading.x = 24; heading.y = 90;
  heading.resize(300, 80);
  frame.appendChild(heading);

  const subtext = figma.createText();
  subtext.fontName = { family: "Inter", style: "Regular" };
  subtext.characters = "Share updates, ask questions and help your peers.";
  subtext.fontSize = 15;
  subtext.lineHeight = { value: 21, unit: "PIXELS" };
  subtext.fills = [{ type: "SOLID", color: { r: 0.42, g: 0.447, b: 0.502 } }];
  subtext.x = 24; subtext.y = 185;
  subtext.resize(320, 44);
  frame.appendChild(subtext);

  // Mockup feed-post card
  const card = figma.createFrame();
  card.name = "Mockup Feed Post Card";
  card.resize(345, 200);
  card.x = 24; card.y = 260;
  card.cornerRadius = 16;
  card.paddingTop = 16; card.paddingLeft = 16; card.paddingRight = 16; card.paddingBottom = 16;
  card.layoutMode = "VERTICAL";
  card.itemSpacing = 10;
  card.primaryAxisSizingMode = "FIXED";
  card.counterAxisSizingMode = "FIXED";
  card.strokes = [{ type: "SOLID", color: { r: 0.898, g: 0.906, b: 0.922 } }];
  card.strokeWeight = 1;
  card.fills = [{ type: "SOLID", color: { r: 1, g: 1, b: 1 } }];
  card.effects = [{
    type: "DROP_SHADOW",
    color: { r: 0, g: 0, b: 0, a: 0.06 },
    offset: { x: 0, y: 2 }, radius: 8, visible: true, blendMode: "NORMAL",
  }];
  frame.appendChild(card);

  const topRow = figma.createFrame();
  topRow.layoutMode = "HORIZONTAL";
  topRow.primaryAxisSizingMode = "AUTO"; topRow.counterAxisSizingMode = "AUTO";
  topRow.itemSpacing = 8; topRow.fills = [];
  const alertChip = figma.createFrame();
  alertChip.layoutMode = "HORIZONTAL";
  alertChip.paddingLeft = 10; alertChip.paddingRight = 10; alertChip.paddingTop = 4; alertChip.paddingBottom = 4;
  alertChip.primaryAxisSizingMode = "AUTO"; alertChip.counterAxisSizingMode = "AUTO";
  alertChip.cornerRadius = 8;
  alertChip.fills = [{ type: "SOLID", color: { r: 0.988, g: 0.910, b: 0.910 } }];
  const alertText = figma.createText();
  alertText.fontName = { family: "Inter", style: "Semi Bold" };
  alertText.characters = "🚨 Alert";
  alertText.fontSize = 12;
  alertText.fills = [{ type: "SOLID", color: { r: 0.863, g: 0.149, b: 0.149 } }];
  alertChip.appendChild(alertText);
  topRow.appendChild(alertChip);
  const timeText = figma.createText();
  timeText.fontName = { family: "Inter", style: "Regular" };
  timeText.characters = "2 min ago";
  timeText.fontSize = 12;
  timeText.fills = [{ type: "SOLID", color: { r: 0.42, g: 0.447, b: 0.502 } }];
  topRow.appendChild(timeText);
  card.appendChild(topRow);

  const title = figma.createText();
  title.fontName = { family: "Inter", style: "Semi Bold" };
  title.characters = "Staff near C Block";
  title.fontSize = 17;
  title.fills = [{ type: "SOLID", color: { r: 0.067, g: 0.067, b: 0.067 } }];
  card.appendChild(title);

  const body = figma.createText();
  body.fontName = { family: "Inter", style: "Regular" };
  body.characters = "Faculty checking IDs.";
  body.fontSize = 14;
  body.fills = [{ type: "SOLID", color: { r: 0.42, g: 0.447, b: 0.502 } }];
  card.appendChild(body);

  const bottomRow = figma.createFrame();
  bottomRow.layoutMode = "HORIZONTAL";
  bottomRow.primaryAxisSizingMode = "AUTO"; bottomRow.counterAxisSizingMode = "AUTO";
  bottomRow.itemSpacing = 16; bottomRow.fills = [];
  const upvotes = figma.createText();
  upvotes.fontName = { family: "Inter", style: "Regular" };
  upvotes.characters = "⬆ 42";
  upvotes.fontSize = 13;
  upvotes.fills = [{ type: "SOLID", color: { r: 0.42, g: 0.447, b: 0.502 } }];
  bottomRow.appendChild(upvotes);
  const comments = figma.createText();
  comments.fontName = { family: "Inter", style: "Regular" };
  comments.characters = "💬 18";
  comments.fontSize = 13;
  comments.fills = [{ type: "SOLID", color: { r: 0.42, g: 0.447, b: 0.502 } }];
  bottomRow.appendChild(comments);
  const overflow = figma.createText();
  overflow.fontName = { family: "Inter", style: "Regular" };
  overflow.characters = "⋯";
  overflow.fontSize = 16;
  overflow.fills = [{ type: "SOLID", color: { r: 0.42, g: 0.447, b: 0.502 } }];
  bottomRow.appendChild(overflow);
  card.appendChild(bottomRow);

  const nextButtonComponent = await figma.getNodeByIdAsync(nextButtonComponentId);
  const nextInstance = nextButtonComponent.createInstance();
  nextInstance.x = 313; nextInstance.y = 772;
  frame.appendChild(nextInstance);

  return { frameId: frame.id };
}
return run("<progressComponentId from build log>", "<nextButtonComponentId from build log>");
```

Before running, replace the two placeholder strings in the final `return run(...)` line with the actual `progressComponentId` and `nextButtonComponentId` values recorded in `zone-figma-buildlog.md` by Task 3.

- [ ] **Step 2: Screenshot and verify**

Call `get_screenshot` with `nodeId: frameId`. Confirm: progress pill with segment 2 dark (not segment 1), "Skip" top-right, heading "Say what you think.", grey subtext, a white feed-post-card mockup with red "🚨 Alert" chip / "2 min ago" / bold title "Staff near C Block" / body "Faculty checking IDs." / "⬆ 42 · 💬 18 · ⋯" row, and the same black circular next button bottom-right. Fix and re-run Step 1 if anything is off.

- [ ] **Step 3: Update build log and commit**

Edit `docs/superpowers/zone-figma-buildlog.md`: check off `Onboarding Slide 2`, record `frameId`. Run:
```bash
cd "C:\Users\shakthi\Documents\zone"
git add docs/superpowers/zone-figma-buildlog.md
git commit -m "Build ZONE Onboarding Slide 2 in Figma"
```

---

### Task 5: Onboarding Slide 3 — "Learn. Build. Show off."

**Figma artifacts:** Top-level frame `Onboarding-3`, 393×852. Instance of `Progress Indicator` (segment 3 active). Full-width `Get Started` button (new, not an instance of `Next Button` — different shape/size).
**Local files:** Modify: `docs/superpowers/zone-figma-buildlog.md`

**Interfaces:**
- Consumes: `fileKey`, `progressComponentId` from build log (Task 3)
- Produces: `Onboarding-3` frame node ID, recorded in build log

- [ ] **Step 1: Build the Slide 3 frame**

Call `use_figma` with `fileKey`, `skillNames`, `description`: `"Build ZONE Onboarding Slide 3 with full-width Get Started button"`, `code`:

```javascript
async function run(progressComponentId) {
  await figma.loadFontAsync({ family: "Space Grotesk", style: "Bold" });
  await figma.loadFontAsync({ family: "Inter", style: "Regular" });
  await figma.loadFontAsync({ family: "Inter", style: "Semi Bold" });

  const frame = figma.createFrame();
  frame.name = "Onboarding-3";
  frame.resize(393, 852);
  frame.fills = [{ type: "SOLID", color: { r: 250 / 255, g: 250 / 255, b: 250 / 255 } }];

  const progressComponent = await figma.getNodeByIdAsync(progressComponentId);
  const progressInstance = progressComponent.createInstance();
  progressInstance.x = 165; progressInstance.y = 24;
  frame.appendChild(progressInstance);
  const segs = progressInstance.children;
  for (let i = 0; i < segs.length; i++) {
    segs[i].fills = [{
      type: "SOLID",
      color: i === 2 ? { r: 0.067, g: 0.067, b: 0.067 } : { r: 0.85, g: 0.85, b: 0.85 },
    }];
  }

  const skip = figma.createText();
  skip.fontName = { family: "Inter", style: "Regular" };
  skip.characters = "Skip";
  skip.fontSize = 15;
  skip.fills = [{ type: "SOLID", color: { r: 0.067, g: 0.067, b: 0.067 } }];
  skip.x = 337; skip.y = 20;
  frame.appendChild(skip);

  const heading = figma.createText();
  heading.fontName = { family: "Space Grotesk", style: "Bold" };
  heading.characters = "Learn. Build.\nShow off.";
  heading.fontSize = 28;
  heading.lineHeight = { value: 34, unit: "PIXELS" };
  heading.fills = [{ type: "SOLID", color: { r: 0.067, g: 0.067, b: 0.067 } }];
  heading.x = 24; heading.y = 90;
  heading.resize(300, 80);
  frame.appendChild(heading);

  const subtext = figma.createText();
  subtext.fontName = { family: "Inter", style: "Regular" };
  subtext.characters = "Discover projects, get help and grow together.";
  subtext.fontSize = 15;
  subtext.lineHeight = { value: 21, unit: "PIXELS" };
  subtext.fills = [{ type: "SOLID", color: { r: 0.42, g: 0.447, b: 0.502 } }];
  subtext.x = 24; subtext.y = 185;
  subtext.resize(320, 44);
  frame.appendChild(subtext);

  // Mockup showcase card
  const card = figma.createFrame();
  card.name = "Mockup Showcase Card";
  card.resize(345, 260);
  card.x = 24; card.y = 260;
  card.cornerRadius = 16;
  card.strokes = [{ type: "SOLID", color: { r: 0.898, g: 0.906, b: 0.922 } }];
  card.strokeWeight = 1;
  card.fills = [{ type: "SOLID", color: { r: 1, g: 1, b: 1 } }];
  card.clipsContent = true;
  frame.appendChild(card);

  const image = figma.createRectangle();
  image.name = "Placeholder project image";
  image.resize(345, 150);
  image.x = 0; image.y = 0;
  image.fills = [{
    type: "GRADIENT_LINEAR",
    gradientTransform: [[0, 1, 0], [-1, 0, 1]],
    gradientStops: [
      { position: 0, color: { r: 0.169, g: 0.184, b: 0.212, a: 1 } },
      { position: 1, color: { r: 0.102, g: 0.110, b: 0.125, a: 1 } },
    ],
  }];
  card.appendChild(image);

  const bookmark = figma.createText();
  bookmark.fontName = { family: "Inter", style: "Regular" };
  bookmark.characters = "\u{1F516}";
  bookmark.fontSize = 18;
  bookmark.fills = [{ type: "SOLID", color: { r: 1, g: 1, b: 1 } }];
  bookmark.x = 309; bookmark.y = 12;
  card.appendChild(bookmark);

  const projTitle = figma.createText();
  projTitle.fontName = { family: "Inter", style: "Semi Bold" };
  projTitle.characters = "Campus Dashboard";
  projTitle.fontSize = 17;
  projTitle.fills = [{ type: "SOLID", color: { r: 0.067, g: 0.067, b: 0.067 } }];
  projTitle.x = 16; projTitle.y = 166;
  card.appendChild(projTitle);

  const stackRow = figma.createFrame();
  stackRow.layoutMode = "HORIZONTAL";
  stackRow.primaryAxisSizingMode = "AUTO"; stackRow.counterAxisSizingMode = "AUTO";
  stackRow.itemSpacing = 6; stackRow.fills = [];
  stackRow.x = 16; stackRow.y = 198;
  for (const tag of ["Flutter", "Firebase", "Groq"]) {
    const chip = figma.createFrame();
    chip.layoutMode = "HORIZONTAL";
    chip.paddingLeft = 8; chip.paddingRight = 8; chip.paddingTop = 4; chip.paddingBottom = 4;
    chip.primaryAxisSizingMode = "AUTO"; chip.counterAxisSizingMode = "AUTO";
    chip.cornerRadius = 6;
    chip.fills = [{ type: "SOLID", color: { r: 0.945, g: 0.945, b: 0.945 } }];
    const chipText = figma.createText();
    chipText.fontName = { family: "Inter", style: "Regular" };
    chipText.characters = tag;
    chipText.fontSize = 11;
    chipText.fills = [{ type: "SOLID", color: { r: 0.067, g: 0.067, b: 0.067 } }];
    chip.appendChild(chipText);
    stackRow.appendChild(chip);
  }
  card.appendChild(stackRow);

  const anon = figma.createText();
  anon.fontName = { family: "Inter", style: "Regular" };
  anon.characters = "👤 Anonymous";
  anon.fontSize = 12;
  anon.fills = [{ type: "SOLID", color: { r: 0.42, g: 0.447, b: 0.502 } }];
  anon.x = 16; anon.y = 228;
  card.appendChild(anon);

  // Full-width Get Started button
  const button = figma.createFrame();
  button.name = "Get Started Button";
  button.layoutMode = "HORIZONTAL";
  button.primaryAxisAlignItems = "CENTER";
  button.counterAxisAlignItems = "CENTER";
  button.primaryAxisSizingMode = "FIXED";
  button.counterAxisSizingMode = "FIXED";
  button.resize(345, 56);
  button.x = 24; button.y = 772;
  button.cornerRadius = 28;
  button.fills = [{ type: "SOLID", color: { r: 0.067, g: 0.067, b: 0.067 } }];
  const buttonLabel = figma.createText();
  buttonLabel.fontName = { family: "Inter", style: "Semi Bold" };
  buttonLabel.characters = "Get Started";
  buttonLabel.fontSize = 16;
  buttonLabel.fills = [{ type: "SOLID", color: { r: 1, g: 1, b: 1 } }];
  button.appendChild(buttonLabel);
  frame.appendChild(button);

  return { frameId: frame.id };
}
return run("<progressComponentId from build log>");
```

Before running, replace `<progressComponentId from build log>` with the actual value from `zone-figma-buildlog.md`.

- [ ] **Step 2: Screenshot and verify**

Call `get_screenshot` with `nodeId: frameId`. Confirm: progress pill segment 3 dark, "Skip" top-right, heading "Learn. Build. Show off.", grey subtext, a showcase-card mockup (placeholder dark image top, bookmark glyph top-right of image, "Campus Dashboard" title, three tech-stack chips, "👤 Anonymous" row), and a full-width black "Get Started" pill button at the bottom (no circular next button on this slide). Fix and re-run Step 1 if anything is off.

- [ ] **Step 3: Update build log and commit**

Edit `docs/superpowers/zone-figma-buildlog.md`: check off `Onboarding Slide 3`, record `frameId`. Run:
```bash
cd "C:\Users\shakthi\Documents\zone"
git add docs/superpowers/zone-figma-buildlog.md
git commit -m "Build ZONE Onboarding Slide 3 in Figma"
```

---

### Task 6: Final cross-screen review

**Figma artifacts:** None new — read-only verification pass.
**Local files:** Modify: `docs/superpowers/zone-figma-buildlog.md`

**Interfaces:**
- Consumes: all 4 frame IDs from the build log
- Produces: a completed, all-checked build log confirming the feature slice is done

- [ ] **Step 1: Screenshot all 4 frames**

Call `get_screenshot` once per frame (`Splash`, `Onboarding-1`, `Onboarding-2`, `Onboarding-3`) using their `frameId`s from the build log.

- [ ] **Step 2: Cross-check consistency**

Compare the 4 screenshots side by side against `docs/superpowers/specs/2026-07-23-splash-onboarding-design.md`. Confirm:
- The onboarding background tone (`#FAFAFA`) and heading/body font choices are identical across slides 1–3
- The progress indicator has exactly one dark segment matching that slide's position (1st/2nd/3rd) and is otherwise identical in size/position across all three slides
- No accent color (green/terracotta or otherwise) appears anywhere — buttons and active progress segments are black
- Slide 3 uses the full-width "Get Started" button instead of the circular next-arrow button used on slides 1–2

If any inconsistency is found, go back to the relevant task and fix it with another `use_figma` call, then re-screenshot.

- [ ] **Step 3: Finalize build log and commit**

Update `docs/superpowers/zone-figma-buildlog.md` — check off all 4 screens, add a closing line: `Splash + Onboarding feature slice complete. Figma file: <file URL>.` Run:
```bash
cd "C:\Users\shakthi\Documents\zone"
git add docs/superpowers/zone-figma-buildlog.md
git commit -m "Complete ZONE Splash + Onboarding Figma build"
```

Report the Figma file URL to the user and note that the next feature slice (per their "one feature at a time" preference) should be brainstormed separately, following the same spec → plan → build cycle.
