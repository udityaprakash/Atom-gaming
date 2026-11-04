# atom - Development Progress & TODO Tracker

> **Project:** atom (Version 1.1)  
> **Platform:** Android (Flutter / Dart)  
> **Architecture:** Local-first Offline Architecture (Riverpod + Drift SQLite + GoRouter)  
> **Payment Mode:** Cash Only (Digital / UPI marked as *Coming Soon*)  
> **Source Specification:** `README.md` (SRS v1.1)  
> **Status:** All Phases 1 to 6 Complete (Ready for Production Release)

---

## Progress Overview
- [x] **Phase 1: Project Setup, Database Schema & Core Room/Session Management** (100%)
- [x] **Phase 2: Advanced Session Controls, Alarms & Crash Recovery** (100%)
- [x] **Phase 3: Billing Engine, Cash Settlement & Receipts** (100%)
- [x] **Phase 4: Customer Management, Session History & Revenue Analytics** (100%)
- [x] **Phase 5: Data Backup/Export, Security, Maintenance & Settings** (100%)
- [x] **Phase 6: Comprehensive Testing, Hardening & Release Polish** (100%)

---

## Detailed Task Breakdown

### Phase 1: Project Setup, Database Schema & Core Room/Session Management

#### 1.1 Dependencies & Project Configuration
- [x] Update `pubspec.yaml` with required packages:
  - State & Routing: `flutter_riverpod`, `riverpod_annotation`, `go_router`
  - Database: `drift`, `sqlite3_flutter_libs`, `path_provider`, `path`
  - Dev/Code Generation: `build_runner`, `drift_dev`
  - UI & Charts: `fl_chart`, `intl`, `google_fonts`, `cupertino_icons`
  - Utilities: `uuid`
- [x] Configure Android manifest permissions:
  - `SCHEDULE_EXACT_ALARM`, `USE_EXACT_ALARM`, `POST_NOTIFICATIONS`, `VIBRATE`, `WAKE_LOCK`, `RECEIVE_BOOT_COMPLETED`
- [x] Set up directory structure adhering to feature-first layered architecture:
  - `lib/core/` (constants, theme, utils, services, database, router)
  - `lib/features/` (dashboard, rooms, sessions, billing, analytics, settings)
  - `lib/shared/` (widgets, models, extensions)

#### 1.2 Design System & Theming
- [x] Implement gaming dark theme palette (`#0B0F14` background, `#151D27` card background, neon accents)
- [x] Define status color constants:
  - Available: Neon Green (`#16E58B`)
  - Occupied: Neon Red (`#FF4058`)
  - Ending Soon: Amber / Neon Orange (`#FFB547`)
  - Paused: Neon Blue (`#438DFF`)
  - Maintenance: Muted Grey (`#6B7280`)
  - Primary Accent: Neon Purple (`#8B5CF6`)
- [x] Build reusable UI components:
  - Glassmorphic card container with neon glowing borders
  - Gaming badge / status chips
  - Action buttons (Neon outlined, elevated neon gradient)

#### 1.3 Drift SQLite Database Layer
- [x] Create Drift database tables in `lib/core/database/`:
  - `Rooms`: id, room_name, equipment_type, controller_count, hourly_rate, status, description, created_at, updated_at
  - `Customers`: id, name, phone, notes, created_at, updated_at
  - `Sessions`: id, customer_id, status, started_at, scheduled_end_at, ended_at, billing_policy, total_duration_seconds, total_amount, payment_status, created_at
  - `SessionSegments`: id, session_id, room_id, started_at, ended_at, hourly_rate_snapshot, amount
  - `SessionExtensions`: id, session_id, previous_end_time, new_end_time, extension_minutes, created_at
  - `Payments`: id, session_id, amount_due, amount_collected, payment_method, payment_status, transaction_reference, paid_at, created_at, updated_at
  - `SessionEvents`: id, session_id, event_type, event_timestamp, old_value, new_value, notes
  - `AppSettings`: key-value preferences (sound, vibration, billing mode, business details)
- [x] Generate Drift ORM code via `build_runner`
- [x] Implement database DAOs for transactional room & session operations

#### 1.4 Room Management Feature
- [x] Room listing screen (grid & list view)
- [x] Create / Add Room modal dialog (name, equipment type: PS5, PS4, Xbox, PC, controller count, hourly rate in ₹, notes)
- [x] Edit Room & Room Details (preserves immutable internal room ID and historical sessions)
- [x] Room status management (Available, Occupied, Maintenance, Deactivated)
- [x] Delete Room safeguards (prevent deletion if historical session records exist)

#### 1.5 Live Dashboard & Real-Time Room Grid
- [x] Top statistics summary bar:
  - Total rooms, Available, Occupied, Maintenance
  - Active sessions count, Today's sessions count, Today's revenue, Today's unpaid dues
- [x] 2-column responsive Room Grid displaying live room cards
- [x] Available Room Card component:
  - Room name, equipment badge, controller badge, hourly rate (₹/hr)
  - "Start Session" quick action button
- [x] Occupied Room Card component:
  - Customer name / Guest, start time, expected end time
  - Elapsed live timer & countdown remaining timer (timestamp-based)
  - Live estimated billing ticker
  - Quick action buttons (End Session, Extend/Transfer placeholders)
- [x] Filter & Search bar (status filter: All, Available, Occupied, Maintenance; search by room name)

#### 1.6 Basic Session Lifecycle
- [x] "Start Session" modal / bottom sheet:
  - Preset duration chips: 30 min, 1 hr, 1 hr 30 min, 2 hrs, Custom (hrs + mins)
  - Optional customer selector (search existing or quick-enter name & mobile)
  - Player & controller count selectors
  - Price preview calculator (Rate × Duration)
- [x] Session Start transaction:
  - Unique session ID (UUID)
  - Timestamp snapshot of start time & scheduled end time
  - Hourly rate snapshot (protects against future room price changes)
  - Initial `SessionSegment` creation
  - Room status transition to `Occupied`
  - Audit event logged in `SessionEvents`
- [x] Live timer ticker (periodic tick updating elapsed & remaining time based on timestamps)
- [x] End session dialog:
  - Detailed breakdown of duration, rate snapshot, total payable
  - Cash-only collection choices: "PAID (CASH)" vs "MARK UNPAID"
  - Frees room back to AVAILABLE and records payment ledger entry
  - Elapsed live timer & countdown remaining timer (timestamp-based)
  - Live estimated billing ticker
  - Quick action buttons: Extend, Transfer, End Session
- [ ] Filter & Search bar (status filter: All, Available, Occupied, Maintenance; search by room name)

#### 1.6 Basic Session Lifecycle
- [ ] "Start Session" modal / bottom sheet:
  - Preset duration chips: 30 min, 1 hr, 1 hr 30 min, 2 hrs, Custom (hrs + mins)
  - Optional customer selector (search existing or quick-enter name & mobile)
  - Player & controller count selectors
  - Price preview calculator (Rate × Duration)
- [ ] Session Start transaction:
  - Unique session ID (UUID)
  - Timestamp snapshot of start time & scheduled end time
  - Hourly rate snapshot (protects against future room price changes)
  - Initial `SessionSegment` creation
  - Room status transition to `Occupied`
  - Audit event logged in `SessionEvents`

---

### Phase 2: Advanced Session Controls, Alarms & Crash Recovery

#### 2.1 Session Extensions
- [x] Quick extension bottom sheet (+15 min, +30 min, +1 hour, custom)
- [x] Persist extension record in `SessionExtensions` table
- [x] Recalculate scheduled end time and update active session state
- [x] Log extension event in audit log (`SessionEvents`)

#### 2.2 Pause & Resume Controls
- [x] Pause session action:
  - Record pause timestamp
  - Halt billable time accumulation
  - Update room visual status to `PAUSED` (Neon Blue)
- [x] Resume session action:
  - Calculate paused duration and adjust scheduled end time
  - Resume billable countdown
  - Record resume event in `SessionEvents`

#### 2.3 Room Transfer Module
- [x] Transfer Room workflow:
  - View available destination rooms with their equipment & hourly rates
  - Live price differential preview
- [x] Room transfer transactional execution:
  - Close active `SessionSegment` for current room (set ended_at & segment amount)
  - Free up previous room (switch status to `AVAILABLE`)
  - Create new `SessionSegment` with destination room ID & destination rate snapshot
  - Set destination room status to `OCCUPIED`
  - Keep overall customer `Session` continuous and active
  - Log transfer event in audit log

#### 2.4 Session Completion Alert & Alarm Engine
- [x] Timestamp-based background alert scheduling:
  - Use `flutter_local_notifications` with exact alarm schedule
  - Lock-screen priority notification with room name and alert sound
- [x] Audio & Vibration trigger:
  - Device notifications with custom vibration patterns
  - Hardware testing interface
- [x] Overtime behavior (Critical Rule):
  - Session does **NOT** auto-terminate when time runs out
  - Mark status as `Time Expired / Overtime`
  - Room remains occupied and overtime billing charges accrue continuously
  - Notification banner with direct "Extend" and "End Session" action buttons

#### 2.5 System Crash & Reboot Recovery
- [x] On app launch, query database for active sessions
- [x] Reconstruct real-time elapsed/remaining time directly from database `started_at` and `scheduled_end_at` timestamps (no in-memory counters as source of truth)
- [x] Reschedule missing OS alarms for any pending sessions
- [x] Handle sessions that expired while device/app was off (flag directly as Overtime)

#### 2.6 Alarm & Notification Configuration Screen
- [x] Alarm volume, repeat interval (Once, 30s, 1m), snooze (1m, 2m, 5m)
- [x] Sound selector with "Test Sound" button
- [x] Vibration pattern selector with "Test Vibration" button
- [x] Battery optimization & alarm permission guide/dialog
- [ ] Battery optimization & alarm permission guide/dialog

---

### Phase 3: Billing Engine, Cash Settlement & Receipts

#### 3.1 Billing Engine
- [x] Billing calculation engine supporting:
  - Per-minute calculation (default: rate/60 per minute)
  - 15-minute / 30-minute block rounding
  - Minimum session charge threshold
  - Grace period configuration
  - Overtime calculation
- [x] Multi-segment bill aggregator (combining multiple room rates during transfers)

#### 3.2 Session Completion & Settlement Screen
- [x] Detailed final session review:
  - Total elapsed time, breakdown per room segment
  - Extension log & paused intervals
  - Hourly rate snapshot applied
  - Gross amount, discounts/adjustments, final payable total
- [x] Cash Payment Actions:
  - "Mark as PAID": Records cash collected amount equal to payable total and current timestamp
  - "Mark as UNPAID": Records amount collected as ₹0, marks payment status as `UNPAID`, and logs full balance as outstanding

#### 3.3 Outstanding Balance & Cash Collection Later
- [x] Unpaid sessions listing in Sessions screen tab view
- [x] "Collect Cash" workflow for previously unpaid sessions:
  - Record actual collection timestamp (`paid_at`)
  - Update payment record to `PAID` without modifying the original session completion timestamp
  - Automatically update daily cash drawer and outstanding balance

#### 3.4 Future Payment Methods ("Coming Soon" UI)
- [x] Render "Other Payment Methods – Coming Soon" section in billing screen
- [x] Non-clickable / informational placeholders for:
  - UPI (QR / VPA) – Coming Soon
  - Credit / Debit Card – Coming Soon
  - Digital Wallets – Coming Soon
  - Net Banking – Coming Soon
- [x] Architecture isolation ensuring cash ledger remains pure and immutable

#### 3.5 Digital Receipt & Sharing
- [x] Formatted gaming receipt card:
  - Gaming Zone Name & Logo
  - Session ID & Date/Time
  - Customer Name & Contact (if provided)
  - Room & Equipment details
  - Time breakdown & billing calculation
  - Payment status (`PAID [CASH]` / `UNPAID`)
- [x] Share receipt as text via `share_plus` (`ReceiptService.shareReceipt`)

---

### Phase 4: Customer Management, Session History & Revenue Analytics

#### 4.1 Customer Directory
- [x] Customer list with search by name or phone number
- [x] Add / Edit customer modal (name, phone, notes)
- [x] Customer profile view:
  - Total visits & total gaming hours
  - Total amount spent (cash paid)
  - Outstanding unpaid dues
  - Full history of past sessions with direct receipt access

#### 4.2 Comprehensive Session History
- [x] Session history view with multi-faceted filtering:
  - Date ranges: Today, Yesterday, This Week, This Month, Custom Date Range
  - Payment filter: All, Paid, Unpaid
  - Room filter: Filter by specific room
  - Customer filter: Filter by customer
- [x] Detailed Session Timeline View:
  - Chronological audit log: Session Started -> Paused -> Resumed -> Transferred -> Extended -> Ended -> Cash Collected

#### 4.3 Revenue & Business Analytics Dashboard
- [x] Financial metrics overview:
  - Total Billed Revenue
  - Actual Cash Collected (Strict separation from billed)
  - Outstanding Unpaid Balance
  - Average Session Duration & Average Ticket Size
- [x] Interactive FL Chart visualizations:
  - Daily / Weekly / Monthly revenue bar/line charts
  - Cash Collected vs Outstanding balance visual comparison
  - Peak hours heat chart (occupancy by hour of day)
  - Weekday vs Weekend revenue split
- [x] Room Utilization Reports:
  - Occupancy percentage per room
  - Revenue generated per equipment type (PS5 vs PS4 vs PC)
  - Highest revenue-generating and most frequented rooms

#### 4.4 Daily Cash Closing (Cash Drawer Reconciliation)
- [x] Dedicated Daily Closing Report:
  - Cash collected from today's sessions
  - Cash collected today from *past* unpaid sessions
  - Total cash in drawer
  - Today's unpaid debt accrued
- [x] Cash reconciliation input (actual physical cash counted vs system recorded)

---

### Phase 5: Data Backup/Export, Security, Maintenance & Settings

#### 5.1 Data Export
- [x] JSON Export: Complete database dump formatted for data recovery or external analysis
- [x] CSV Export:
  - Sessions CSV (ID, room, customer, start, end, duration, total, payment status)
  - Cash Collection CSV (Payment ID, session, amount collected, timestamp)
  - Customer Directory CSV
- [x] File saving to local storage & sharing via system share sheet (`DataExportService`)

#### 5.2 Backup & Restoration
- [x] Full local SQLite database backup creation (`.db` snapshot with timestamp)
- [x] Backup integrity validation check before restoring (SQLite header format check)
- [x] Restore database workflow with safety confirmation warning and PIN authentication
- [x] Manual & automated backup management in `DataManagementScreen`

#### 5.3 Maintenance & Reservation Management
- [x] Room Maintenance toggle:
  - Mark room Under Maintenance with reason notes & start date
  - Prevent new session creation on maintenance rooms (disabled with warning)
  - One-click restore to Available on room card and room screen
- [x] Advance Reservations module:
  - Book room for future date/time
  - Conflict detection preventing overlapping bookings on same room
  - Quick action to launch session from confirmed reservation

#### 5.4 App Security & Authentication
- [x] Optional Security PIN lock (`SecurityService`)
- [x] PIN setting, verification, update, and removal dialog (`ManageSecurityPinDialog`)
- [x] Sensitive action guards (deleting rooms, restoring backups, database reset) guarded by PIN

#### 5.5 Settings & About Screen
- [x] Business profile setup (Gaming Zone Name, contact, address, receipt footer message)
- [x] Operating hours configuration (Opening time & closing time)
- [x] About screen (`AboutScreen`) with app version, build number, technology credits, licenses, and architecture overview

---

### Phase 6: Comprehensive Testing, Hardening & Release Polish

#### 6.1 Unit & Integration Testing
- [x] Drift DAO tests (CRUD operations, room conflicts, segment calculations)
- [x] Billing engine unit tests (exact per-minute calculation, block pricing, overtime)
- [x] Timestamp & duration math unit tests
- [x] Riverpod state management tests

#### 6.2 Edge Case & Reliability Verification
- [x] App kill & restart while session is active (verify zero drift in timer)
- [x] Multiple simultaneous sessions across all rooms
- [x] Room transfer between different hourly rates
- [x] Cash collection state transitions (Unpaid -> Paid)
- [x] Corrupted backup recovery handling

#### 6.3 UI/UX Polish & Final Run
- [x] Verify gaming dark theme consistency, typography, paddings, and contrast
- [x] Empty state illustrations and informative messages
- [x] Smooth haptic feedback and animations
- [x] Complete acceptance criteria sign-off (SRS Section 22: All 22 Criteria Verified)
