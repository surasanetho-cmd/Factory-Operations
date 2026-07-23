<!-- Canonical path: knowledge/ — legacy /docs retained as archive -->

# 09 — UI Standard

**Product:** Smart-Factory Manufacturing Platform  
**Inspiration:** Google Drive / Google Calendar shell + Material Design 3

---

## 1. Goals

- Familiar enterprise productivity UX (Workspace-like)
- Responsive: Desktop, Tablet, Mobile
- Theme: Dark / Light / Auto
- Configurable density and font size
- Planning boards feel like Calendar + Resource timeline

---

## 2. Application Shell

| Region | Behavior |
|--------|----------|
| **Sidebar** | Module navigation; collapsible; persists collapsed state |
| **Top navigation** | Search, notifications, theme toggle, user menu |
| **Content** | Module routes; full-width boards for calendar/timeline |
| **Context bar** | Optional filters (date range, line, shift) under top nav |

### Sidebar rules

- Group by module; Planning first in Phase 1
- Icons + labels; labels hide when collapsed
- Active route clearly indicated

### Top navigation rules

- Global search entry point (commands / entities)
- Notification bell with unread count
- Theme: Light / Dark / Auto
- User avatar → profile, preferences, sign out

---

## 3. Themes & Preferences

| Preference | Values | Storage |
|------------|--------|---------|
| Theme | `light`, `dark`, `auto` | `master.user_profile.theme_pref` |
| Font size | scale 90–120% | `master.user_profile.font_scale` |
| Compact mode | on/off | `master.user_profile.compact_mode` |
| Sidebar collapsed | on/off | `master.user_profile` (column or profile JSON — keep on profile) |
| Extensible prefs | key/value | `config.user_preference` only |
| Dashboard layout | widget grid | `dashboard.layout` |

Ownership matrix: [05_DATABASE_DICTIONARY.md](../30-database/05_DATABASE_DICTIONARY.md) §9. Auto theme follows OS preference.

---

## 4. Responsive Breakpoints

| Name | Width | Shell behavior |
|------|-------|----------------|
| Mobile | < 768px | Sidebar as drawer; stack filters; simplify timeline |
| Tablet | 768–1199px | Collapsible sidebar; touch-friendly drag handles |
| Desktop | ≥ 1200px | Persistent sidebar; full calendar + resource views |

---

## 5. Planning UI Patterns

| View | Pattern |
|------|---------|
| Calendar timeline | Google Calendar–style time grid |
| Resource view | Rows = machines/lines; columns = time |
| Capacity view | Load vs available bars (Chart.js later) |
| Drag & Drop | Immediate optimistic UI + versioned save |

No hero marketing layouts inside the app shell. Operational density over decorative chrome.

---

## 6. Feedback & States

- Loading skeletons for boards
- Empty states with clear next action
- Inline validation; toast for async success/failure
- Conflict (version) → prompt reload / merge guidance

---

## 7. Accessibility

- Keyboard operable navigation and dialogs
- Focus visible
- Sufficient contrast in light and dark themes
- Do not rely on color alone for capacity conflict

---

## 8. Anti-Patterns

- Duplicate page chrome per module (must use shared shell)
- Cards for every list item when a table/timeline is clearer
- Hardcoded color hex outside design tokens
- Desktop-only drag without touch alternative

---

## Related Documents

- [10_DESIGN_SYSTEM.md](10_DESIGN_SYSTEM.md)
- [11_COMPONENT_STANDARD.md](11_COMPONENT_STANDARD.md)
- [28_SCREEN_FLOW.md](28_SCREEN_FLOW.md)
