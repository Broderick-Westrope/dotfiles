# Cursor Look and Feel Design Spec

**Problem:** Cursor feels heavy and noisy compared to Zed. It uses a different palette (Tokyo Night Dark, not Anvil Night), a blown-up UI (`window.zoomLevel: 1.8`), a cluttered status bar, a minimap, and AI/agent surfaces that are never used. Zed is missing things valued in VS Code/Cursor, so the goal is to bring Zed's calm to Cursor rather than switch editors. Cursor's settings aren't tracked in dotfiles, so none of this would survive a new machine.

**Goal:** Cursor looks and feels like the Zed setup: the Anvil Night palette everywhere (editor, chrome, terminal, diffs), one flat background with minimal borders, Zed-equivalent density and fonts, a stripped status bar, and no Cursor AI surfaces. `chezmoi apply` reproduces all of it on any machine.

**Scope:**
- In:
  - A standalone, hand-maintained VS Code color theme "Anvil Night", stored in this dotfiles repo. It's seeded once from the Zed theme (`~/dev/helse/zed-anvil-theme/themes/anvil-night.json`).
  - A chezmoi `run_onchange_` script that packages and installs the theme into Cursor whenever its files change.
  - Tracking Cursor's `settings.json` in chezmoi, with the density, font, chrome, status bar and AI changes.
  - README updates.
- Out (later workstreams):
  - Keybindings.
  - Agent/anvil-in-editor workflow.
  - New Revu features.
  - Light theme.
  - Marketplace publishing.
  - Tracking the Cursor extension list.
  - Archiving the `zed-anvil-theme` GitHub repo (a manual step, done once the Cursor theme is verified).

**Constraints:**
- The theme source lives at `cursor/anvil-night/` (`package.json`, `themes/anvil-night-color-theme.json`) and is listed in `.chezmoiignore`, so it is never copied into `$HOME`. The theme JSON is the source of truth and is edited by hand.
- The seed conversion script is a one-off. It runs from outside this repo and is never committed here. The approximated and unsupported Zed keys it reports are recorded in the commit that adds the theme.
- The extension manifest has a stable `publisher` (`broderick-westrope`), `name` (`anvil-night`), `version`, an `engines.vscode` compatible with the installed Cursor, and `contributes.themes` with `uiTheme: "vs-dark"`.
- The install script is `run_onchange_after_setup-cursor-theme.sh.tmpl`. The name sorts after `install-packages`, so on a fresh machine Homebrew installs Cursor first.
- Its rerun hash comment includes:
  - the content of every file under `cursor/anvil-night/`, read via `include (joinPath .chezmoi.sourceDir "cursor/anvil-night/...")`;
  - whether `Cursor.app` exists in `/Applications` or `~/Applications` at render time.

  So editing the theme reruns it, and so does installing Cursor after an apply where it was missing.
- Scripts run from the destination tree, not the source checkout. The script uses the templated absolute `{{ .chezmoi.sourceDir }}` path and never relative paths.
- The script:
  - Validates that the theme JSON parses.
  - Builds a `.vsix` in a `mktemp -d` dir with `zip`, containing:
    - `[Content_Types].xml`, declaring the `.json` and `.vsixmanifest` content types;
    - `extension.vsixmanifest`: PackageManifest schema 2.0.0, Identity `Id`/`Publisher`/`Version` matching `package.json`, `Microsoft.VisualStudio.Code` installation target, and a `Microsoft.VisualStudio.Code.Manifest` asset pointing at `extension/package.json`;
    - `extension/package.json` and `extension/themes/…`.

    The script stamps the manifest's identity and version from `package.json` so they can't disagree.
  - Finds the CLI as `cursor` on PATH, else the bundled `Contents/Resources/app/bin/code` inside `/Applications/Cursor.app` or `~/Applications/Cursor.app` (this machine uses the latter), and runs `<cli> --install-extension <vsix> --force`.
  - If no CLI is found, prints a warning and exits 0. The app-exists term in the hash makes it rerun once Cursor is installed.
  - Is macOS-guarded like the existing scripts.
- If hand-assembling the VSIX proves unreliable during implementation, the fallback is `npx --yes @vscode/vsce@<pinned> package`. Node is available via mise.
- Cursor settings are managed at `private_Library/private_Application Support/private_Cursor/User/settings.json` on every machine (unlike VS Code, which stays personal-only). The file stays JSONC. Machine-specific keys stay out; anything machine-specific later becomes a `.tmpl`.
- Before the first `chezmoi add`, back up the live Cursor settings. Make targeted edits and keep unrelated settings.
- Known drift: Cursor writes to `settings.json` when settings change through the UI. The README documents `chezmoi re-add` for that case, matching the existing anvil.json note.

**Success Criteria:**
- [ ] On a machine with Cursor installed, `chezmoi apply` installs Anvil Night, and Cursor lists it under the Color Theme picker.
- [ ] Editing the theme JSON and rerunning `chezmoi apply` reinstalls it; Cursor shows the change after a window reload. Applying again without changes doesn't reinstall.
- [ ] `chezmoi apply` with the `cursor` CLI absent prints a warning and completes successfully. After Cursor is installed, the next `chezmoi apply` runs the script again and installs the theme.
- [ ] `.chezmoiignore` lists `cursor/`, `cursor/**`, `plans/` and `plans/**` (chezmoi matches target paths, so both the directory and its contents need patterns). `chezmoi managed` lists nothing under `cursor/` or `plans/`, and `chezmoi diff` is clean after apply.
- [ ] Verification during development uses `chezmoi --source "$WT" …` (`diff`, `managed`, `apply`), where `$WT` is the wtp worktree (`wtp cd feat/cursor-look-and-feel`), since the configured source dir is the main checkout.
- [ ] The hand-built VSIX installs in Cursor and the theme appears in the picker. If it doesn't, switch to the `vsce` fallback.
- [ ] Cursor `settings.json` is never parsed as strict JSON by any script; chezmoi copies it byte-for-byte.
- [ ] The seed conversion accounts for every Zed `style` and `syntax` key: each one is mapped, deliberately approximated, or listed as unsupported, and the commit message records it.
- [ ] In Cursor, `#050014` is the background of:
  - editor, sidebar, panel and terminal
  - active and inactive title bar
  - tab bar, and active and inactive tabs
  - status bar in the normal, no-folder and debugging states

  Borders use the explicitly mapped Zed `border.variant`/`border` colours. Verified against a visual checklist.
- [ ] Syntax: on a Go and a TS fixture file, the categories keyword, function, method, type, string, number, comment, variable, property, parameter, constant, enumMember, namespace and operator render in the Zed theme's colours, checked with `Developer: Inspect Editor Tokens and Scopes`. TextMate fallbacks cover them when semantic tokens are absent. `readonly` and `defaultLibrary` modifiers and the italic/bold font styles from the Zed syntax map are preserved.
- [ ] `gopls.ui.semanticTokens: true` is set, so Go highlighting uses LSP tokens.
- [ ] Terminal ANSI normal and bright colours equal the Zed values. Zed's dim colours have no VS Code equivalent and are recorded as unsupported. `terminal.integrated.minimumContrastRatio: 1` stops Cursor shifting colours.
- [ ] Git decorations, gutter change markers, and diff editor line/word backgrounds use the Zed version_control/diff_hunk colours. Hollow hunk variants are recorded as approximated or unsupported.
- [ ] Fonts and density:
  - `window.zoomLevel` is set to 0.
  - Editor and terminal font size 15, FiraCode Nerd Font Mono, ligatures on.
  - `editor.lineHeight` and `terminal.integrated.lineHeight` are numeric values approximating Zed's "comfortable" (1.6 for the editor).
  - VS Code has no general UI font-size setting. Chrome density is checked by opening the same file in Zed and Cursor side by side:
    - editor text the same size;
    - sidebar row text no larger than Zed's;
    - tab and status bar heights no larger than Zed's.

    Changing zoom away from 0 is a later iteration, not part of this spec.
- [ ] Minimap off, sticky scroll off, `editor.renderLineHighlight: "gutter"`, command center and layout controls off. The activity bar stays hidden: check the current effective/profile state and codify it in settings if it isn't already.
- [ ] Status bar:
  - `git.blame.statusBarItem.enabled: false`, and the other setting-backed AI and extension items are disabled.
  - The remaining items are pruned manually through the status bar context menu.
  - After a reload, only editor selection, source control checkout and source control sync remain.
  - The manual pruning steps are documented in the README, since they aren't settings-backed. `chezmoi apply` restores only the settings-backed part; the per-item pruning is a manual step on each new machine.
- [ ] Cursor AI: Cursor Tab is disabled, and the inline prompt, agent/composer/chat entry points are hidden. Each control is verified against the installed Cursor version, and any surface that can't be removed is recorded in the README's known gaps.
- [ ] The old `workbench.colorCustomizations` diff overrides and `workbench.colorTheme: "Tokyo Night Dark"` are removed. `workbench.colorTheme` is `"Anvil Night"`.
- [ ] The README covers: the Cursor theme and how to edit it, the install script, `chezmoi re-add` for UI-made Cursor setting changes, manual status bar pruning, and known gaps.

**Design Decisions:**
- **Standalone VS Code theme extension** rather than `colorCustomizations` overrides on Tokyo Night Dark (messy scope overrides, and theme updates change what shows through) or shipping it inside Revu (mixes concerns).
- **Lives in dotfiles, not its own repo.** The theme is personal config, like the Ghostty theme and Zed settings already tracked here. Keeping it next to the Cursor settings means one `chezmoi apply` restores the whole look. `zed-anvil-theme` is retired.
- **Seed once, then hand-maintain.** Zed is being retired, so an ongoing generator would add a build step and a second format for no benefit.
- **Install via `run_onchange_` script, not by dropping files into `~/.cursor/extensions/`.** Cursor tracks installed extensions in `~/.cursor/extensions/extensions.json`, and a copied-in folder isn't reliably registered. The CLI install is the supported path, and `run_onchange_` with a content hash gives "reinstall only when changed" for free.
- **Cursor settings on all machines.** Cursor is used at work, unlike the personal-only VS Code config.
- **Mapping strategy (seed script):**
  - Zed UI keys map to VS Code `colors`, e.g.:
    - `editor.background` → `editor.background`
    - `panel.background` → `sideBar.background`/`panel.background`
    - `status_bar.background` → `statusBar.background`
    - `title_bar.background` → `titleBar.activeBackground`
    - `border.variant` → most `*.border` keys
    - `terminal.ansi.*` → `terminal.ansi*`
    - `version_control.*` → `gitDecoration.*` and `editorGutter.*`
    - `editor.diff_hunk.*` → `diffEditor.*`
  - Zed `syntax.*` maps to both TextMate `tokenColors` and `semanticTokenColors`, with `semanticHighlighting: true`. Semantic tokens carry most of the fidelity for Go and TS. The theme flag only lets the theme style the tokens; the language provider must emit them too, hence the gopls setting.
  - The mapping tables are explicit data in the seed script, which fails on any unaccounted Zed key.
  - Alpha colours pass through as `#rrggbbaa`. Compositing is only used where a VS Code key rejects alpha, and each case is listed.
- **Density via fonts, not zoom.** Zooming the whole window inflates all of Cursor's chrome.
- **Status bar stripped and blended** rather than hidden. Per-item visibility isn't settings-backed, so it's documented, not codified. Iterate if it's still noisy.
- **Breadcrumbs kept.** Clicking a symbol breadcrumb (or `cmd+shift+o`) gives the Zed-style searchable symbol jump; it's built from LSP document symbols rather than tree-sitter, but behaves the same.
- **Activity bar left as-is** (already hidden, keyboard-only).
- **Cursor AI off.** Exact Cursor keys are verified against the installed version during implementation, since they change between releases.

**Context Files:**
- `~/dev/helse/zed-anvil-theme/themes/anvil-night.json`: seed palette (156 style keys, ~45 syntax categories).
- `~/Library/Application Support/Cursor/User/settings.json`: current live Cursor settings (zoom 1.8, Tokyo Night Dark, diff colour overrides, JSONC).
- `~/.config/zed/settings.json` (tracked as `dot_config/zed/settings.json`): reference for the target feel.
- `run_onchange_after_install-packages.sh.tmpl`: pattern for a hash-triggered, macOS-guarded script.
- `.chezmoiignore`: add `cursor/`, `cursor/**`, `plans/`, `plans/**`.
- `private_Library/private_Application Support/private_Code/User/settings.json`: existing VS Code settings, the naming pattern for the Cursor path.
- `README.md`: "Known gaps" section and the `chezmoi re-add` note.
