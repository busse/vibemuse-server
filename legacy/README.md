# TinyMUSE Legacy Code

This directory contains the original TinyMUSE server code and documentation, preserved as reference material for the VibeMUSE modernization project.

## Contents

- **`src/`** - Original TinyMUSE C source code (v2.0)
- **`bin/`** - Compiled binaries directory
- **`run/`** - Runtime files and configuration
- **`ADMIN.md`** - Original TinyMUSE administration guide
- **`CHANGES.md`** - Original TinyMUSE changelog
- **`DATABASE.md`** - Original TinyMUSE database format documentation

## Purpose

The TinyMUSE code in this directory serves as:
- **Reference documentation** for understanding the original system architecture
- **Feature specification** for the VibeMUSE modernization project
- **Historical preservation** of the original codebase

## Building TinyMUSE (Reference)

To build the original TinyMUSE server for reference purposes:

```bash
cd legacy/src
make
make install
```

Run from the repository root:
```bash
legacy/bin/tinymuse
```

## Attribution

This code is based on TinyMUSE v2.0 by Belisarius Smith, which itself builds upon the work of many contributors dating back to the original TinyMUD project. See the main [COPYRIGHT.md](../COPYRIGHT.md) file for complete attribution details.

## VibeMUSE Modernization

The VibeMUSE modernization project is creating a modern web-based version of this system. See the main [README.md](../README.md) for details about the modernization effort.