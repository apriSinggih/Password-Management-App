# Graph Report - password management  (2026-11-03)

## Corpus Check
- Corpus is ~16,064 words - fits in a single context window. You may not need a graph.

## Summary
- 726 nodes · 916 edges · 66 communities (37 shown, 29 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 16 edges (avg confidence: 0.91)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Shared UI Foundations
- Credential Categories
- Password Generation Flow
- Project Dependencies
- Authentication State
- Reusable Input Components
- Theme and Color System
- Settings and TOTP
- App Screen Architecture
- Password Generator UI
- Vault Provider State
- Credential Domain Model
- Device Unlock Screen
- Credential Detail Screen
- App Configuration Constants
- Security Requirements
- Feature Services
- Vault Browser UI
- Encrypted Vault Storage
- Product Requirements
- Cryptographic Services
- Backup Import Export
- Credential Presentation
- Neo-brutalist Design System
- User Settings Preferences
- Secure Storage Adapter
- Clipboard Cleanup Utility
- Flutter Project Structure
- Credential Editing Flow
- Automated Tests
- Biometric Authentication
- Dart Lint Configuration
- Android Host Activity
- Clipboard Copy Actions
- Backup Settings Workflow
- Rounded App Icon Style
- Foreground Lock Icon
- High Resolution App Icon
- Password Strength Feedback
- Main Application Shell
- HDPI Launcher Mark
- MDPI Launcher Mark
- XHDPI Lock Foreground
- XHDPI Security Icon
- XHDPI Round Launcher
- XXHDPI Lock Foreground
- XXHDPI Launcher Mark
- Accent Button Styling
- Automatic Vault Locking
- HDPI Foreground Padlock
- MDPI Round Lock Icon
- XXXHDPI Foreground Icon
- XXXHDPI Launcher Icon
- XXXHDPI Round Keyhole
- XXXHDPI Round Padlock
- Password Manager App Icon
- JetBrains Mono Typeface
- Future Platform Support
- Credential Autofill Feature
- Password History Feature
- Password Manager Requirements
- Android Backup Policy
- Secure Screen Protection

## God Nodes (most connected - your core abstractions)
1. `AuthProvider` - 28 edges
2. `VaultProvider` - 16 edges
3. `dependencies` - 16 edges
4. `SettingsProvider` - 12 edges
5. `_SettingsScreenState` - 7 edges
6. `flutter_launcher_icons` - 7 edges
7. `Neobrutalism Design System` - 6 edges
8. `_MainShellState` - 5 edges
9. `BackupService` - 5 edges
10. `_CredentialDetailScreenState` - 5 edges

## Surprising Connections (you probably didn't know these)
- `Neobrutalism UI` --semantically_similar_to--> `Neobrutalism Design System`  [INFERRED] [semantically similar]
  README.md → docs/design/design-guidelines.md
- `Offline-First Local Password Manager` --semantically_similar_to--> `Offline-First Access Requirement`  [INFERRED] [semantically similar]
  README.md → docs/development/prd.md
- `Credential Vault` --semantically_similar_to--> `Credential Storage Requirements`  [INFERRED] [semantically similar]
  README.md → docs/development/prd.md
- `AES-256-GCM` --semantically_similar_to--> `AES-256 Encryption Requirement`  [INFERRED] [semantically similar]
  README.md → docs/development/prd.md
- `Biometric Unlock` --semantically_similar_to--> `Biometric Authentication`  [INFERRED] [semantically similar]
  README.md → docs/development/prd.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Vault Key Derivation and Credential Encryption** — readme_master_password, readme_pbkdf2_hmac_sha256, readme_16_byte_salt, readme_vault_key, readme_aes_256_gcm, readme_credentials_table [EXTRACTED 1.00]
- **Feature Module Structure** — docs_architecture_struktur_folder_proyek_auth_feature, docs_architecture_struktur_folder_proyek_vault_feature, docs_architecture_struktur_folder_proyek_settings_feature [EXTRACTED 1.00]
- **Neobrutalism Visual Principles** — docs_design_design_guidelines_high_contrast_hard_borders, docs_design_design_guidelines_solid_offset_shadows, docs_design_design_guidelines_vibrant_and_muted_palette, docs_design_design_guidelines_bold_typography, docs_design_design_guidelines_playful_and_direct_ui [EXTRACTED 1.00]

## Communities (66 total, 29 thin omitted)

### Community 0 - "Shared UI Foundations"
Cohesion: 0.05
Nodes (38): _AppGate, SecureVaultApp, backgroundColor, borderColor, borderRadius, borderWidth, build, child (+30 more)

### Community 1 - "Credential Categories"
Cohesion: 0.05
Nodes (34): all, banking, email, entertainment, other, shopping, social, values (+26 more)

### Community 2 - "Password Generation Flow"
Cohesion: 0.05
Nodes (36): _acknowledged, build, _confirmController, createState, dispose, _formKey, _loading, _passwordController (+28 more)

### Community 3 - "Project Dependencies"
Cohesion: 0.05
Nodes (41): dependencies, crypto, cryptography, cupertino_icons, file_picker, flutter, flutter_secure_storage, intl (+33 more)

### Community 4 - "Authentication State"
Cohesion: 0.05
Nodes (34): AuthStatus, _autoLockSeconds, _awaitingTotp, _biometricAvailable, _biometricEnabled, _biometrics, cancelTotp, changeMasterPassword (+26 more)

### Community 5 - "Reusable Input Components"
Cohesion: 0.07
Nodes (31): NeobrutalSurface, _NeobrutalSurfaceState, autofillHints, autofocus, build, controller, createState, enabled (+23 more)

### Community 6 - "Theme and Color System"
Cohesion: 0.06
Nodes (23): AppTheme, _build, dark, light, border, canvas, card, coral (+15 more)

### Community 7 - "Settings and TOTP"
Cohesion: 0.08
Nodes (18): _busy, children, _codeController, _confirmController, _controller, _copySecret, _copyUri, createState (+10 more)

### Community 8 - "App Screen Architecture"
Cohesion: 0.09
Nodes (14): _auth, _backgroundedAt, build, createState, didChangeAppLifecycleState, dispose, _handleAuthChange, _handleKeyEvent (+6 more)

### Community 9 - "Password Generator UI"
Cohesion: 0.10
Nodes (18): build, createState, _digits, _generate, GeneratorScreen, _GeneratorScreenState, icon, initState (+10 more)

### Community 10 - "Vault Provider State"
Cohesion: 0.09
Nodes (18): bindKey, categories, _category, countForCategory, _credentials, delete, _error, isLoading (+10 more)

### Community 11 - "Credential Domain Model"
Cohesion: 0.09
Nodes (18): category, changedAt, copyWith, createdAt, empty, fromJson, history, id (+10 more)

### Community 12 - "Device Unlock Screen"
Cohesion: 0.12
Nodes (21): _biometricLoading, build, _buildPasswordForm, _buildTotpForm, createState, dispose, _loading, LockScreen (+13 more)

### Community 13 - "Credential Detail Screen"
Cohesion: 0.10
Nodes (16): createState, credentialId, _dateFormat, _edit, entry, icon, label, monospace (+8 more)

### Community 14 - "App Configuration Constants"
Cohesion: 0.10
Nodes (19): AppConstants, appName, autoLockOptions, clipboardOptions, dbName, defaultAutoLockSeconds, defaultClipboardSeconds, keyAutoLockSeconds (+11 more)

### Community 15 - "Security Requirements"
Cohesion: 0.11
Nodes (18): AES-256 Encryption Requirement, Encrypted Export and Import, Local Encrypted Database, Offline-First Access Requirement, Optional Cloud Sync, 16-Byte Salt, AES-256-GCM, Credentials Table (+10 more)

### Community 16 - "Feature Services"
Cohesion: 0.12
Nodes (8): authProvider, backupService, biometrics, crypto, main, repository, settingsProvider, storage

### Community 17 - "Vault Browser UI"
Cohesion: 0.12
Nodes (8): _buildBody, createState, dispose, _openDetail, _openEditor, _searchController, VaultHomeScreen, _VaultHomeScreenState

### Community 18 - "Encrypted Vault Storage"
Cohesion: 0.12
Nodes (14): close, _crypto, _db, delete, deleteMeta, exportEntriesRaw, importEntriesRaw, loadAll (+6 more)

### Community 19 - "Product Requirements"
Cohesion: 0.13
Nodes (15): Biometric Authentication, Categorization and Tags, Credential Storage Requirements, Master Password Authentication, Password Manager Product, Product Success KPIs, Quick Copy with Clipboard Cleanup, Search and Filter (+7 more)

### Community 20 - "Cryptographic Services"
Cohesion: 0.14
Nodes (10): CryptoService, decryptMap, decryptString, deriveKey, encodeKey, encryptMap, encryptString, keyFromString (+2 more)

### Community 21 - "Backup Import Export"
Cohesion: 0.14
Nodes (8): appId, createBackup, _crypto, formatVersion, _repository, restoreBackup, _storage, VaultRepository

### Community 22 - "Credential Presentation"
Cohesion: 0.20
Nodes (4): Credential, build, credential, onTap

### Community 23 - "Neo-brutalist Design System"
Cohesion: 0.22
Nodes (5): Credential Card Specification, Input Field Specification, NeobrutalContainer Widget, Neobrutalism Design System, Neobrutalism UI

### Community 24 - "User Settings Preferences"
Cohesion: 0.22
Nodes (4): _clipboardSeconds, init, setClipboardSeconds, _storage

### Community 25 - "Secure Storage Adapter"
Cohesion: 0.22
Nodes (6): containsKey, delete, read, SecureStorageService, _storage, write

### Community 26 - "Clipboard Cleanup Utility"
Cohesion: 0.25
Nodes (4): cancelTimer, _clearTimer, ClipboardHelper, copy

### Community 27 - "Flutter Project Structure"
Cohesion: 0.25
Nodes (8): Auth Feature, Core Security Module, Credential Domain Model, Presentation Layer, Project Folder Structure, Providers, Settings Feature, Vault Feature

### Community 28 - "Credential Editing Flow"
Cohesion: 0.25
Nodes (8): build, CredentialDetailScreen, _CredentialDetailScreenState, _delete, _save, build, initState, VaultProvider

### Community 30 - "Biometric Authentication"
Cohesion: 0.29
Nodes (4): authenticate, _authentication, BiometricService, isAvailable

### Community 31 - "Dart Lint Configuration"
Cohesion: 0.33
Nodes (5): analyzer, exclude, include, linter, rules

### Community 33 - "Clipboard Copy Actions"
Cohesion: 0.33
Nodes (5): build, _pickClipboard, SettingsProvider, _copy, _copy

### Community 34 - "Backup Settings Workflow"
Cohesion: 0.40
Nodes (5): _exportBackup, _importBackup, SettingsScreen, _SettingsScreenState, BackupService

### Community 35 - "Rounded App Icon Style"
Cohesion: 0.67
Nodes (3): Padlock App Icon, Padlock Symbol, Password Security

### Community 36 - "Foreground Lock Icon"
Cohesion: 0.67
Nodes (3): Turquoise Padlock, Password Manager Launcher Icon, Password Security

### Community 37 - "High Resolution App Icon"
Cohesion: 0.67
Nodes (3): Keyhole, Padlock Symbol, Password Manager Launcher Icon

### Community 38 - "Password Strength Feedback"
Cohesion: 0.67
Nodes (3): Password Generator Requirements, Password Strength Indicator, Password Generator

## Knowledge Gaps
- **414 isolated node(s):** `_index`, `_inactivityTimer`, `_backgroundedAt`, `_auth`, `_timeoutSeconds` (+409 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 518 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **29 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AuthProvider` connect `Device Unlock Screen` to `Clipboard Copy Actions`, `Password Generation Flow`, `Backup Settings Workflow`, `Authentication State`, `Reusable Input Components`, `Main Application Shell`, `App Screen Architecture`, `Settings and TOTP`, `Vault Browser UI`, `Credential Editing Flow`?**
  _High betweenness centrality (0.047) - this node is a cross-community bridge._
- **What connects `_index`, `_inactivityTimer`, `_backgroundedAt` to the rest of the system?**
  _414 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Shared UI Foundations` be split into smaller, more focused modules?**
  _Cohesion score 0.0463768115942029 - nodes in this community are weakly interconnected._
- **Why does `SecureStorageService` connect `Secure Storage Adapter` to `User Settings Preferences`, `Authentication State`, `Backup Import Export`?**
  _High betweenness centrality (0.020) - this node is a cross-community bridge._
- **Should `Credential Categories` be split into smaller, more focused modules?**
  _Cohesion score 0.048726467331118496 - nodes in this community are weakly interconnected._
- **Why does `VaultProvider` connect `Credential Editing Flow` to `Clipboard Copy Actions`, `Backup Settings Workflow`, `Password Generation Flow`, `Reusable Input Components`, `Settings and TOTP`, `Vault Provider State`, `Credential Detail Screen`, `Vault Browser UI`?**
  _High betweenness centrality (0.020) - this node is a cross-community bridge._
- **Should `Password Generation Flow` be split into smaller, more focused modules?**
  _Cohesion score 0.04983388704318937 - nodes in this community are weakly interconnected._