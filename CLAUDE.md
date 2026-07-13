# CLAUDE.md

## Working discipline — theflow

Substantive changes (bug fix / feature / behavior change) follow the **`theflow`**
skill — run `/theflow` at the start. This repo's bindings (module map, reference
routing, boundary rule, proof methods, surfaces, gate matrix) live in
**`docs/agents/theflow.md`**; the per-incident evidence (#42–#45, #47, #48,
#50–#52, #57 …) in **`docs/agents/lessons.md`**. Read both before starting; add
new war-stories to lessons.

## Identity & invariants (the boundary)

`flutter_folderview` renders a **semantic three-tier hierarchy** — **Folder →
Parent → Child** (each a `Node`) — in two interchangeable **View Modes**
(`folder` / `tree`). The tier roles are part of the *contract*, not styling. The
full domain, the tier rules, and the ubiquitous language live in **`CONTEXT.md`**
(source of truth — a `Node` is **not** a "row"; a "row" is a *rendered line*);
decisions in **`docs/adr/`**.

- **Caller owns interaction state (ADR-0002).** The **Expanded Set**, **Selected
  Set**, and **Scale** are caller-controlled — the library *reads* them, never
  mutates. `onNodeTap` / `onScaleChanged` propose; the caller applies.
- **Chrome is excluded from Scale.** Scrollbars (ADR-0001) and tooltips (ADR-0004)
  do not scale — scaling tooltip fields made it visually worse (just_tooltip's
  text default is unscaled).
- **Tier theme fields are intentionally duplicated (ADR-0005)** — do not extract
  a shared base.
- **Tier rules are not enforced at runtime** — violations produce undefined
  visible behavior, by contract.
- **Consumes `just_tooltip`** (the barrel re-exports it). Two surfaces — a
  node-label tooltip and a row-card tooltip; nesting is arbitrated **upstream**
  (innermost wins), so this package holds no priority logic. The row card uses
  `TooltipAnchor.pointer` as a **correctness requirement** (a row goes off screen
  once it scrolls wider than the viewport), not a workaround. On `^0.4.4`. Read
  `../` sibling `flutter_table_plus` and the upstream source, not pub docs.

## Agent skills

### Issue tracker
Issues live in GitHub Issues for `kihyun1998/flutter_folderview`, managed via the
`gh` CLI. Pull requests are not a triage surface. See `docs/agents/issue-tracker.md`.

### Triage labels
Canonical label strings (`needs-triage`, `needs-info`, `ready-for-agent`,
`ready-for-human`, `wontfix`) — no overrides. See `docs/agents/triage-labels.md`.

### Domain docs
Single-context layout: `CONTEXT.md` + `docs/adr/` at the repo root. See
`docs/agents/domain.md`.
