# Changelog

All notable changes to this project will be documented in this file.

## [1.1.0] - 2026-02-20

### Added

- `getPointer(id)`: Introduced a new method to retrieve PdbxEntryPointer by its unique ID. This allows accessing entry metadata (titles, offsets, sizes) without the overhead of full block decryption.
- Enhanced `trashGroup`: Added recursive branch processing. Moving a group to the trash now automatically marks all nested sub-groups and their entries as deleted.
- Cascading Integrity: Ensured that entries within a trashed group branch are correctly updated in the index to prevent "orphan" active entries.

### Changed

- Improved PdbxManager internal index synchronization to handle batch updates of groups and pointers simultaneously.

### Fixed

- Fixed a logic gap where nested entries remained "active" in search results even if their parent group was moved to the trash.

## [1.0.0+1] - 2026-02-19

### Changed

- Updated repository reference and improved package description.
- Switched license from Apache 2.0 to **BSD 3-Clause**.

### Fixed

- Corrected README asset links for better display on pub.dev.

## [1.0.0] - 2026-02-19

- **Initial Stable Release**.
- **Core**: High-performance storage engine with AES-256-GCM encryption.
- **Security**: Argon2ID master key derivation and secure memory handling.
- **Structure**: Hierarchical group management with built-in Root and Trash systems.
- **Performance**: Binary storage format with indexed pointers for O(1) entry lookups.
- **Documentation**: Comprehensive API documentation and usage examples.
