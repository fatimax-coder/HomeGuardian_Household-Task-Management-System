# HomeGuardian — Household Maintenance & Management System

**HomeGuardian** is a centralized, cross-platform household management application built with **Flutter** and **Supabase**. It provides families and roommates with a single platform to organize daily chores, track appliance warranties and service histories, and stay ahead of upcoming bills and maintenance reminders.

---

## Project Objectives

- Provide a unified platform for managing household activities and maintenance information.
- Allow users to create, assign, update, and track household tasks.
- Help family members clearly understand their responsibilities and current task statuses.
- Maintain detailed appliance records, warranty coverage, and service histories.
- Deliver timely reminders for bills, scheduled maintenance, services, and important tasks.
- Display a centralized dashboard summarizing the overall status of the household.
- Improve everyday organization, coordination, and convenience in household management.

---

## Features & Scope

### Included Features (In-Scope)
- **Authentication & Profiles:** User registration, secure login, household profile creation, and member management.
- **Task Management:** Create, assign, edit, complete, and track household tasks and responsibilities.
- **Appliance & Warranty Tracking:** Store appliance names, models, purchase dates, warranty expiration details, and maintenance/service logs.
- **Smart Reminders:** Alerts for task deadlines, bill due dates, expiring warranties, and scheduled maintenance.
- **Centralized Dashboard:** An overview screen highlighting pending tasks, upcoming reminders, and key household details.

### Future Enhancements (Out-of-Scope for Current Version)
- Direct online payment processing for household bills.
- Automatic integration with smart-home devices and IoT appliances.
- Direct booking or purchasing of maintenance services from external providers.
- Advanced financial budgeting and direct utility-provider integrations.

---

## Tech Stack

- **Frontend:** Flutter & Dart (Android, iOS, Web, Windows, macOS, Linux)
- **Backend & Database:** Supabase (PostgreSQL, Authentication, Realtime)

---

## Project Structure

```text
HomeGuardian/
├── android/               # Android native configuration
├── assets/                # Images, fonts, and static resources
├── ios/                   # iOS native configuration
├── lib/                   # Core Dart application code (UI, models, services)
├── linux/                 # Linux desktop configuration
├── macos/                 # macOS desktop configuration
├── test/                  # Unit, widget, and Supabase integration tests
├── tool/                  # Asset generation and developer scripts
├── web/                   # Web configuration
├── windows/               # Windows desktop configuration
├── env.example.json       # Template for environment variables
├── pubspec.yaml           # Flutter dependencies and asset declarations
└── supabase_schema.sql    # Database tables, policies, and schema setup
