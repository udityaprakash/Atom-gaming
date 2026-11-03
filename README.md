# PLAYZONE CONTROL
## Gaming Zone Management Application
### Software Requirements Specification (SRS) – Version 1.1

---

# 1. PROJECT OVERVIEW

**Application Name:** PLAYZONE CONTROL  
**Application Type:** Android Mobile Application  
**Frontend:** Flutter (Dart)  
**Architecture:** Local-first  
**Database:** SQLite with Drift ORM  
**State Management:** Riverpod  
**Primary Currency:** INR (₹)  
**Target User:** Gaming Zone Owner / Administrator

## 1.1 Project Objective

Develop a mobile application that allows a gaming zone owner to manage multiple gaming rooms, monitor live occupancy, track customer playing time, calculate charges, manage cash collection, and analyze business revenue.

Each room represents one gaming machine or device, such as PS5, PS4, Xbox, or Gaming PC. Each machine can have multiple controllers for multiplayer gaming.

The application must provide real-time room monitoring, reliable session timers, automatic completion alerts, session extensions, room transfers, billing, historical records, and revenue analytics.

The application must operate completely offline without requiring a backend server or internet connection.

# 2. CORE APPLICATION REQUIREMENTS

The application must support:

1. Multiple gaming rooms.
2. Individual room configurations.
3. Room-specific hourly pricing.
4. Live occupancy monitoring.
5. Customer session management.
6. Custom session durations.
7. Session extensions.
8. Room-to-room transfers.
9. Automatic session completion alerts.
10. Sound and vibration customization.
11. Automatic billing calculations.
12. Cash-only payment collection.
13. Paid and unpaid session status.
14. Customer history.
15. Session history.
16. Revenue analytics.
17. JSON and CSV exports.
18. Database backup and restoration.
19. Application security.
20. Gaming-themed user interface.

# 3. ROOM MANAGEMENT MODULE

## 3.1 Room Definition

One room represents one gaming machine/device.

Example:

| Room | Equipment | Controllers | Hourly Price |
|---|---|---|---|
| Room 01 | PS5 | 2 | ₹150 |
| Room 02 | PS5 | 4 | ₹200 |
| Room 03 | PS4 | 2 | ₹100 |
| Room 04 | Gaming PC | 1 | ₹120 |

## 3.2 Room Operations

The application must allow the administrator to:

- Add a new room.
- Edit an existing room.
- Rename a room.
- Change equipment type.
- Configure controller count.
- Set hourly pricing.
- Add equipment notes.
- Deactivate a room.
- Delete a room if it has no historical dependencies.
- Mark a room as under maintenance.
- Restore a room to available status.
- View room-specific session history.

## 3.3 Room Properties

Each room should contain:

- Unique room ID.
- Room name.
- Equipment type.
- Controller count.
- Hourly rate.
- Current status.
- Description.
- Created timestamp.
- Updated timestamp.

Room IDs must remain unchanged when room names are edited.

Room pricing changes must not affect historical sessions.

# 4. HOME SCREEN – LIVE DASHBOARD

The home screen is the primary interface of the application.

## 4.1 Layout

- Dark gaming-themed interface.
- Vertically scrollable room cards.
- Two-column room grid.
- Glassmorphism design.
- Responsive card layouts.
- Summary statistics at the top.
- Bottom navigation bar.

## 4.2 Room Status Colors

| Status | Color | Meaning |
|---|---|---|
| Available | Neon Green | Room is free |
| Occupied | Neon Red | Customer is playing |
| Ending Soon | Yellow/Orange | Session is nearing completion |
| Maintenance | Grey | Room unavailable |
| Paused | Blue | Session temporarily paused |

## 4.3 Dashboard Statistics

Display:

- Total rooms.
- Available rooms.
- Occupied rooms.
- Maintenance rooms.
- Active sessions.
- Today's completed sessions.
- Today's revenue.
- Today's unpaid amount.

## 4.4 Available Room Card

Display:

- Room name.
- Equipment type.
- Controller count.
- Hourly price.
- Available status.
- Start Session button.

## 4.5 Occupied Room Card

Display:

- Room name.
- Equipment type.
- Customer name, if available.
- Session start time.
- Expected end time.
- Elapsed time.
- Remaining time.
- Current estimated bill.
- Extend button.
- Transfer button.
- End Session button.

## 4.6 Dashboard Interactions

- Tap available room to start a session.
- Tap occupied room to view session details.
- Quick extension from room card.
- Transfer session from room card.
- Filter rooms by status.
- Search rooms by name.
- Sort by room name, price or ending time.
- Long-press room for additional options.

# 5. SESSION MANAGEMENT MODULE

## 5.1 Starting a Session

When the administrator selects Start Session, open a session configuration screen or bottom sheet.

### Duration Selection

Provide predefined duration options:

- 30 minutes.
- 1 hour.
- 1 hour 30 minutes.
- 2 hours.
- Custom duration.

Custom duration must allow selecting hours and minutes.

### Customer Information

Customer information should be optional.

Fields:

- Customer name.
- Mobile number.
- Number of players.
- Number of controllers used.
- Additional notes.

The application must allow starting a session without registering a customer.

### Session Price Preview

Before starting the session, display:

- Room name.
- Equipment.
- Hourly price.
- Selected duration.
- Estimated charge.
- Start time.
- Expected end time.

### Start Confirmation

On confirmation:

1. Generate a unique session ID.
2. Record the exact start timestamp.
3. Associate the session with the selected room.
4. Store the room's current hourly rate as a price snapshot.
5. Calculate the scheduled end timestamp.
6. Change room status to Occupied.
7. Schedule the completion alarm.
8. Update the home dashboard.

## 5.2 Active Session

Each active session must maintain:

- Session ID.
- Customer ID, if available.
- Room ID.
- Start timestamp.
- Scheduled end timestamp.
- Actual end timestamp.
- Elapsed duration.
- Remaining duration.
- Current billing amount.
- Session status.

## 5.3 Session Controls

Available actions:

- Extend Session.
- Pause Session.
- Resume Session.
- Transfer Room.
- End Session.
- View Session Details.

## 5.4 Session Extensions

The administrator must be able to extend a session at any point.

Quick extension options:

- +15 minutes.
- +30 minutes.
- +1 hour.
- Custom duration.

Every extension must be recorded in the database.

Record:

- Previous scheduled end time.
- New scheduled end time.
- Extension duration.
- Extension timestamp.

Extensions must update the session countdown and reschedule the completion alarm.

## 5.5 Pause and Resume

Allow the administrator to temporarily pause a session.

When paused:

- Stop billable-time accumulation.
- Stop the active countdown.
- Record pause timestamp.

When resumed:

- Record resume timestamp.
- Continue remaining billable duration.
- Reschedule the alarm.

Maintain a complete pause/resume history.

# 6. SESSION COMPLETION AND ALERT SYSTEM

This is a critical feature.

When a session reaches its scheduled end time, the application must alert the administrator.

## 6.1 Alert Behaviour

- Play an alarm sound.
- Trigger device vibration.
- Show a prominent notification.
- Display room name.
- Display customer information if available.
- Display session details.
- Provide Extend and End Session actions.

The session must NOT automatically close when the selected duration expires.

Instead:

- Mark it as Time Expired / Overtime.
- Keep the room occupied.
- Continue calculating additional playing time.
- Continue calculating overtime charges according to billing rules.
- Wait for administrator action.

## 6.2 Background Alarm Requirements

The application must support:

- Alarms when the app is in the background.
- Alarms when another application is open.
- Lock-screen notifications.
- Alarm recovery after application restart.
- Alarm recovery after device restart.
- Multiple simultaneous active room alarms.

Use Android-compatible notification and exact alarm mechanisms where permitted.

Implement appropriate notification permission handling, full-screen notification support where eligible, and battery optimization guidance.

Do not assume Android allows unrestricted foreground activity launches.

## 6.3 Notification Settings

Provide the following configurable settings:

| Setting | Options |
|---|---|
| Sound | Enable / Disable |
| Vibration | Enable / Disable |
| Sound selection | Multiple built-in sounds |
| Vibration pattern | Short / Long / Pulse / Custom |
| Vibration intensity | Adjustable where hardware permits |
| Alert volume | Adjustable where supported |
| Repeat alert | Once / Every 30 seconds / Every minute |
| Snooze | 1 / 2 / 5 minutes |
| Alert duration | Configurable |

Provide:

- Test Sound button.
- Test Vibration button.
- Reset Settings button.

# 7. ROOM TRANSFER MODULE

The application must support transferring a customer from one room to another without ending their overall session.

## 7.1 Transfer Workflow

1. Open an active room.
2. Select Transfer Room.
3. Display all available rooms.
4. Select destination room.
5. Display destination equipment.
6. Display destination hourly price.
7. Calculate the billing estimate.
8. Confirm transfer.

## 7.2 Transfer Rules

- The original room becomes available.
- The destination room becomes occupied.
- The original room segment is closed.
- A new room segment is created.
- The main customer session remains active.
- All historical records must be preserved.

## 7.3 Transfer Billing

Example:

| Room | Duration | Rate | Charge |
|---|---|---|---|
| PS4 Room 02 | 30 min | ₹100/hr | ₹50 |
| PS5 Room 01 | 60 min | ₹150/hr | ₹150 |
| Total | 90 min | | ₹200 |

Each room segment must maintain its own price snapshot and duration.

# 8. BILLING AND CASH COLLECTION MODULE

## 8.1 Billing Policies

Support configurable billing methods:

- Per-minute billing.
- 15-minute billing blocks.
- 30-minute billing blocks.
- Full-hour billing.
- Minimum session charge.
- Grace period.
- Overtime billing.

Default recommendation: Actual-time billing with per-minute calculation.

The selected session duration determines the expected end time, not the final billable duration.

## 8.2 Session Completion

When End Session is selected, display:

- Session ID.
- Customer details.
- Room details.
- Session start time.
- Session end time.
- Total playing duration.
- Extension history.
- Room transfer history.
- Hourly rates.
- Total payable amount.
- Cash collection status.

## 8.3 Payment Collection – Current Version

The current version must support CASH ONLY.

There must be no functional UPI, card, wallet or online payment integration.

### Payment Status

Provide two main statuses:

**1. PAID**

- Customer has paid the complete amount in cash.
- Record the cash collection timestamp.
- Include the amount in collected cash revenue.

**2. UNPAID**

- Customer has not paid the amount.
- Keep the amount outstanding.
- Include it in the unpaid balance report.
- Allow the administrator to collect cash later and update the status to Paid.

### Session Completion Workflow

When a session ends, display:

- Total playing duration.
- Total payable amount.
- Payment status.
- Mark as Paid button.
- Mark as Unpaid button.

The administrator should be able to select the appropriate status before closing the session.

### Payment Record Fields

- Payment ID.
- Session ID.
- Amount due.
- Amount collected.
- Payment method.
- Payment status.
- Collection timestamp.
- Created timestamp.
- Updated timestamp.

Payment method in the current version must be CASH only.

If a session is marked Unpaid:

- Amount collected = ₹0.
- Outstanding amount = Total payable amount.
- Payment status = UNPAID.

If the administrator later collects the amount:

- Allow updating the payment status to PAID.
- Record the actual cash collection timestamp.
- Update outstanding balance.
- Preserve the original session completion timestamp.

For the current version, full payment or unpaid status is sufficient. Partial payments are not required.

## 8.4 Future Payment Methods – Coming Soon

The application should display a section called:

**Other Payment Methods – Coming Soon**

Display the following as disabled or informational options:

- UPI – Coming Soon.
- Card – Coming Soon.
- Online Payments – Coming Soon.
- Digital Wallet – Coming Soon.

These options must not be clickable or perform any payment operation in Version 1.1.

Do not implement payment gateways or external payment integrations.

Keep the architecture extensible so additional payment methods can be added in future versions without changing historical cash records.

## 8.5 Billing Receipt

Display a final receipt with:

- Gaming zone name.
- Session ID.
- Room information.
- Playing duration.
- Billing breakdown.
- Total amount.
- Payment status.
- Collection method, if paid.

Provide sharing and export options.

# 9. SESSION HISTORY MODULE

Maintain a permanent history of all customer sessions.

## 9.1 Session History Fields

- Unique session ID.
- Customer ID.
- Room information.
- Start timestamp.
- End timestamp.
- Total duration.
- Hourly rate snapshot.
- Extension history.
- Transfer history.
- Total amount.
- Payment status.
- Payment method.
- Cash collection timestamp.

## 9.2 Search and Filters

Provide:

- Today.
- Yesterday.
- This week.
- This month.
- Custom date range.
- Room-wise filtering.
- Customer-wise filtering.
- Paid sessions.
- Unpaid sessions.

## 9.3 Session Details

Opening a historical session must display a complete timeline:

- Session started.
- Extension performed.
- Session paused.
- Session resumed.
- Room transferred.
- Session ended.
- Cash collected, if applicable.
- Payment status updated.

Historical records must not be silently overwritten.

# 10. CUSTOMER MANAGEMENT

Customer management should be optional during session creation.

Features:

- Add customer.
- Edit customer.
- Search by name or phone number.
- View previous sessions.
- Total playing hours.
- Total amount spent.
- Outstanding unpaid amount.
- Last visit.
- Customer notes.

Future enhancements:

- Membership packages.
- Loyalty points.
- Prepaid gaming credits.
- Customer discounts.

# 11. ANALYTICS AND REVENUE REPORTS

Create a dedicated analytics dashboard.

## 11.1 Revenue Analytics

Provide:

- Daily revenue.
- Weekly revenue.
- Monthly revenue.
- Yearly revenue.
- Custom date range.
- Total sessions.
- Average session duration.
- Average revenue per session.
- Cash actually collected.
- Outstanding unpaid amount.

IMPORTANT: Distinguish between revenue generated and cash collected.

For example:

| Metric | Amount |
|---|---:|
| Total billed | ₹5,000 |
| Cash collected | ₹4,000 |
| Outstanding unpaid | ₹1,000 |

Unpaid sessions must not be counted as cash collected.

## 11.2 Room-wise Analytics

For each room, display:

- Number of sessions.
- Total billed amount.
- Total occupied hours.
- Average session duration.
- Occupancy percentage.
- Revenue per operating hour.

## 11.3 Business Insights

Display:

- Most frequently used room.
- Highest revenue-generating room.
- Peak business hours.
- Weekday versus weekend revenue.
- Equipment-wise revenue.
- Room utilization comparison.

Use charts and graphs for visual reporting.

# 12. ADDITIONAL FEATURES

## 12.1 Maintenance Management

- Mark room under maintenance.
- Record maintenance reason.
- Track maintenance start date.
- Restore availability.

## 12.2 Daily Cash Closing

Display:

- Total cash collected today.
- Cash received from previously unpaid sessions.
- Cash collected from today's sessions.
- Outstanding unpaid amount.
- Total billed amount.
- Discounts.
- Adjustments.

Allow recording the actual cash in hand.

Avoid counting historical unpaid balances as current-day revenue when they are subsequently collected. Show collection-date reports separately from session-date reports.

## 12.3 Activity Log

Record important application actions:

- Session started.
- Session extended.
- Session paused.
- Session resumed.
- Room transferred.
- Session ended.
- Payment marked Paid.
- Payment marked Unpaid.
- Unpaid amount collected.
- Room configuration changed.

Include timestamp and relevant details.

## 12.4 Application Security

- PIN protection.
- Biometric authentication.
- Secure settings access.
- Protection against accidental deletion.
- Confirmation before destructive operations.

## 12.5 Future Reservations

Allow customers to reserve rooms in advance.

Support:

- Reservation date.
- Reservation time.
- Room selection.
- Customer information.
- Reservation status.
- Conflict detection.

## 12.6 Opening and Closing Hours

Allow configuring business operating hours.

Display warnings for active sessions when closing time approaches.

Never automatically terminate an active customer session.

# 13. DATA EXPORT AND BACKUP

The application must support complete local data ownership.

## 13.1 Export Formats

- JSON.
- CSV.

## 13.2 Exportable Information

- Rooms.
- Sessions.
- Customers.
- Cash collection records.
- Session extensions.
- Room transfers.
- Activity logs.
- Application settings.

## 13.3 Backup and Restoration

Provide:

- Full database backup.
- Automatic local backup.
- Manual backup.
- Restore database.
- Backup history.
- Last backup timestamp.
- Backup integrity validation.

Exported JSON must contain sufficient information to reconstruct session history, room transfers, billing records and cash collection history.

# 14. APPLICATION NAVIGATION

Use five primary navigation sections.

### 1. Home
- Live dashboard.
- Room cards.
- Occupancy statistics.
- Quick session start.

### 2. Rooms
- Room list.
- Add room.
- Edit room.
- Room details.
- Maintenance management.

### 3. Sessions
- Active sessions.
- Session history.
- Session details.
- Billing information.
- Paid and unpaid filters.

### 4. Analytics
- Daily reports.
- Weekly reports.
- Monthly reports.
- Room-wise reports.
- Revenue charts.
- Cash collection reports.
- Outstanding balances.

### 5. More / Settings
- Customer management.
- Cash collection records.
- Notifications.
- Billing settings.
- Backup and restore.
- Export.
- Application security.
- About.

# 15. UI/UX DESIGN REQUIREMENTS

The application must have a gaming-inspired visual identity.

## 15.1 Design Direction

- Dark mode as default.
- Glassmorphism cards.
- Neon green accents.
- Neon red accents.
- Subtle purple and blue highlights.
- Smooth animations.
- Rounded cards.
- Modern typography.
- Gaming-inspired icons.

## 15.2 Suggested Color Palette

| Element | Color |
|---|---|
| Background | #0B0F14 |
| Card Background | #151D27 |
| Available | #16E58B |
| Occupied | #FF4058 |
| Ending Soon | #FFB547 |
| Paused | #438DFF |
| Primary Accent | #8B5CF6 |
| Main Text | #F5F7FA |
| Secondary Text | #929CAA |

## 15.3 Interaction Requirements

- Smooth transitions.
- Responsive layouts.
- Loading indicators.
- Confirmation dialogs.
- Empty states.
- Error messages.
- Success feedback.
- Haptic feedback for important actions.

Avoid unnecessary visual complexity. Room status, remaining time and current charges must always be easy to identify.

# 16. ABOUT SECTION

Display:

- Application name.
- Logo.
- Version.
- Build number.
- Developer details.
- Copyright.
- Technology credits.
- Open-source licenses.
- Privacy policy.
- Contact/support information.

# 17. TECHNICAL ARCHITECTURE

## 17.1 Technology Stack

| Component | Technology |
|---|---|
| Mobile UI | Flutter |
| Language | Dart |
| Database | SQLite |
| ORM | Drift |
| State Management | Riverpod |
| Navigation | GoRouter |
| Charts | FL Chart |
| Notifications | Flutter Local Notifications |
| Sound | AudioPlayers |
| Vibration | Vibration |
| Export | Dart JSON / CSV |
| File Access | Path Provider |
| Sharing | Share Plus |
| Authentication | Local Auth |

## 17.2 Architecture Principles

Use a feature-first, layered architecture.

Separate:

- Presentation layer.
- Business logic layer.
- Data layer.
- Database layer.
- Notification/alarm services.

The application must not depend on a remote backend.

All core business operations must work offline.

## 17.3 Suggested Project Structure

lib/

    main.dart

    core/
        constants/
        theme/
        utils/
        services/
        database/
        notifications/

    features/
        dashboard/
        rooms/
        sessions/
        billing/
        customers/
        cash_collection/
        analytics/
        history/
        backup/
        settings/
        about/

    shared/
        widgets/
        models/

Each feature should have its own presentation, application/business logic and data components where appropriate.

# 18. DATABASE SCHEMA

Use SQLite through Drift.

## 18.1 Rooms Table

Fields:

- id: Primary key.
- room_name.
- equipment_type.
- controller_count.
- hourly_rate.
- status.
- description.
- created_at.
- updated_at.

## 18.2 Customers Table

Fields:

- id.
- name.
- phone.
- notes.
- created_at.
- updated_at.

## 18.3 Sessions Table

Fields:

- id.
- customer_id.
- status.
- started_at.
- scheduled_end_at.
- ended_at.
- billing_policy.
- total_duration_seconds.
- total_amount.
- payment_status.
- created_at.

## 18.4 Session Segments Table

Fields:

- id.
- session_id.
- room_id.
- started_at.
- ended_at.
- hourly_rate_snapshot.
- amount.

## 18.5 Session Extensions Table

Fields:

- id.
- session_id.
- previous_end_time.
- new_end_time.
- extension_minutes.
- created_at.

## 18.6 Payments / Cash Collection Table

Fields:

- id.
- session_id.
- amount_due.
- amount_collected.
- payment_method.
- payment_status.
- transaction_reference.
- paid_at.
- created_at.
- updated_at.

For Version 1.1:

- payment_method must be CASH for successful collections.
- payment_status must support PAID and UNPAID.
- No online payment processing.
- No payment gateway integration.
- No partial payment functionality.

The schema should remain extensible for future payment methods.

## 18.7 Session Events Table

Fields:

- id.
- session_id.
- event_type.
- event_timestamp.
- old_value.
- new_value.
- notes.

## 18.8 App Settings Table

Store:

- Sound preferences.
- Vibration preferences.
- Billing configuration.
- Currency.
- Business information.
- Theme preferences.
- Notification configuration.

# 19. CRITICAL BUSINESS LOGIC

The following rules are mandatory.

1. A room cannot have two simultaneous active sessions.
2. Each session must have a unique identifier.
3. Each room must have a unique internal identifier.
4. Historical hourly rates must never change.
5. Room transfers must preserve the overall session.
6. Each transfer must create a new session segment.
7. Extensions must be recorded separately.
8. Session expiration must not automatically terminate the session.
9. Overtime must be calculated correctly.
10. Payment status must be stored separately from session status.
11. Only cash collection is supported in Version 1.1.
12. Unpaid amounts must remain outstanding until cash is received.
13. Changing an unpaid session to Paid must record the actual collection timestamp.
14. Cash collected must never be counted twice in analytics.
15. All important changes must be auditable.
16. Database transactions must protect session and room status updates.
17. Active sessions must recover after application crashes.
18. Active sessions must recover after device restart.
19. Timers must be calculated using timestamps rather than relying on an in-memory counter.
20. Revenue analytics must distinguish billed revenue from cash collected.
21. Database backup must not corrupt active sessions.

# 20. ERROR HANDLING AND RECOVERY

The application must handle:

- Application force-stop.
- Phone restart.
- Database errors.
- Notification permission denial.
- Exact alarm permission restrictions.
- Battery optimization restrictions.
- Missing sound files.
- Failed exports.
- Invalid backup files.
- Duplicate session start requests.
- Room transfer conflicts.
- Interrupted cash collection status updates.
- Device time changes.

Provide meaningful error messages and recovery instructions.

Never silently discard an active session or its historical data.

# 21. DEVELOPMENT PHASES

## Phase 1 – Core Application

- Flutter project setup.
- Database setup.
- Room management.
- Dashboard.
- Start and end sessions.
- Live timers.

## Phase 2 – Advanced Session Management

- Extensions.
- Pause/resume.
- Room transfers.
- Alarm system.
- Sound and vibration settings.
- Crash recovery.

## Phase 3 – Billing and Cash Collection

- Billing engine.
- Cash-only collection.
- Paid/unpaid status.
- Outstanding balance tracking.
- Receipt generation.
- Overtime.
- Discounts.

## Phase 4 – Business Management

- Customer management.
- Session history.
- Revenue analytics.
- Room utilization.
- Cash collection reports.

## Phase 5 – Data and Advanced Features

- JSON export.
- CSV export.
- Backup and restoration.
- Security.
- Maintenance.
- Reservations.
- Future payment method interface marked Coming Soon.

# 22. ACCEPTANCE CRITERIA

The application will be considered ready for its initial production release when:

1. Administrator can create and configure multiple rooms.
2. Room cards correctly display available and occupied states.
3. Administrator can start a session with predefined or custom durations.
4. Session timers display accurate remaining time.
5. Session completion triggers the configured alarm.
6. Alarms work under tested background and lock-screen conditions.
7. Administrator can extend sessions without losing history.
8. Administrator can transfer a session between available rooms.
9. Charges are calculated correctly across different room rates.
10. Session history remains intact after application restart.
11. Sessions recover after device reboot.
12. Administrator can close a session and calculate the final bill.
13. Administrator can mark a session Paid or Unpaid.
14. Administrator can collect cash later against an unpaid session.
15. Cash collection records include accurate timestamps.
16. Analytics correctly distinguish total billed amounts, cash collected and unpaid amounts.
17. UPI, card and online payments are displayed as Coming Soon and are non-functional.
18. JSON and CSV exports contain complete records.
19. Backup and restore work correctly.
20. Application operates without internet connectivity.
21. No two active sessions can occupy the same room.
22. No historical billing record is changed by later room price updates.

# 23. INSTRUCTIONS TO THE DEVELOPMENT AGENT

Build PLAYZONE CONTROL as a complete, production-quality Flutter Android application.

Follow these instructions:

- Understand the complete requirements before implementation.
- Use modular and maintainable Flutter architecture.
- Use SQLite and Drift for persistent local storage.
- Use Riverpod for application state management.
- Implement business logic separately from UI.
- Prioritize session accuracy and database integrity.
- Implement reliable Android alarm handling.
- Never use an in-memory timer as the source of truth.
- Never introduce unnecessary backend dependencies.
- Do not use mock data in production screens.
- Ensure all buttons and interactions work.
- Provide proper loading, error and empty states.
- Maintain a consistent gaming-themed design.
- Test all session lifecycle scenarios.
- Test application restart and device reboot recovery.
- Test simultaneous sessions across multiple rooms.
- Test room transfers with different hourly rates.
- Test cash collection and unpaid status.
- Test billing calculations with different rounding policies.
- Do not implement functional online payment integration in this version.
- Display future payment options as Coming Soon.

Implement the application incrementally, starting with the database, room management and session lifecycle.

Do not compromise session reliability for visual effects.

The final application must be usable by a gaming zone owner during actual daily business operations.

---

**END OF SOFTWARE REQUIREMENTS SPECIFICATION**

Project: PLAYZONE CONTROL  
Version: 1.1  
Platform: Android  
Architecture: Flutter + SQLite  
Deployment: Local-first, offline-capable application  
Current Payment Mode: Cash Only  
Digital Payments: Reserved for Future Updates