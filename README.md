# VibeMUSE - Modern Multi-User Shared Environment

**VibeMUSE** is a modernization project that transforms the classic TinyMUSE server into a contemporary web-based platform with modern architecture, RESTful APIs, and real-time capabilities. This project preserves all original functionality while enabling modern web and mobile clients through a carefully structured technology stack.

## About VibeMUSE

VibeMUSE stands on the shoulders of the original TinyMUSE project, modernizing its rich feature set for today's web. The project follows a comprehensive 32-week development plan across 7 phases, transforming a 1990s C codebase into a modern web architecture while maintaining complete feature parity.

### Key Features
- **Modern Architecture**: RESTful API with React/TypeScript frontend
- **Real-time Communication**: WebSocket integration for instant updates  
- **Database Modernization**: PostgreSQL with Supabase for scalability
- **Preserved Functionality**: All 200+ original TinyMUSE features maintained
- **Mobile Ready**: Modern responsive design for all devices

### Target Architecture
- **Backend**: Node.js/Express with TypeScript
- **Database**: Supabase (PostgreSQL) with real-time capabilities
- **Frontend**: React/TypeScript with modern UI/UX
- **Authentication**: JWT + session-based hybrid approach
- **Real-time**: WebSocket for live communication

## Original TinyMUSE Attribution

VibeMUSE is built upon the foundation of TinyMUSE, created after the MUD codebase explosion of 1990 and based on version 1.5 of TinyMUSH. We honor and acknowledge the original work and contributors who made this project possible.

### Original TinyMUSE History

TinyMUSE was based on TinyMUD and had a fairly short lifespan, being quickly surpassed by its contemporaries. Though updated occasionally, it was largely a dead project with a small server population. The original v1.9f3 code was outdated and difficult to compile and run.

The original TinyMUSE repository was created by [Belisarius Smith](https://www.belisariussmith.com/ "Belisarius Smith") for preservation and posterity, providing a compilable and working version with minor cleanup and improvements to meet modern C standards.

### Original TinyMUSE Contributors

- Jin (original author)

### v1.0 - v1.8a4
- Nils McCarthy (@shkoo, **nils@chezmoto.ai.mit.edu**)
- Erk (@Erk, **erk@chezmoto.ai.mit.edu**)
- Michael (@Bard **michael@chezmoto.ai.mit.edu**)

### v1.8a4 - v1.9f3
- Mark Eisenstat (@Morgoth **meisen@musenet.org**)
- Jason Hula (@Power_Shaper)
- Rick Harby (@Tabok **rharby@eznet.net**)
- Robert Peperkamp (@Redone **rpeperkamp@envirolink.org**) 

### v2.0
- Belisarius Smith (@Balr)

This project is a work of love, in appreciation for all the hours of fun from running (and playing) the original TinyMUSE server. To all those who wrote, maintained, and played, we thank you.

**VibeMUSE respects and adheres to the original TinyMUSE attribution requirements.** See [COPYRIGHT.md](COPYRIGHT.md) for full details on the original licensing terms, which require proper attribution for academic and educational use.

## 🚀 VibeMUSE Development Status

> **Current Phase**: 📋 **Planning & Documentation** (Complete)  
> **Status**: Documentation phase complete, ready to begin Phase 1 development  
> **Next Phase**: Phase 1 - Foundation & Database (Weeks 1-4)

**📊 [View Full Project Tracker](docs/PROJECT_TRACKER.md)** - Track progress through all 7 development phases of the VibeMUSE modernization project.

## VibeMUSE Documentation

Comprehensive documentation for the VibeMUSE modernization project:

- **[Software Architecture](docs/software-architecture.md)** - Overview of original TinyMUSE system design and components
- **[Server Architecture](docs/server-architecture.md)** - Technical implementation details of the original system
- **[Features](docs/features.md)** - Complete list of features being modernized
- **[Modernization Opportunities](docs/potential-issues.md)** - Areas for improvement and modernization
- **[API Documentation](docs/api/README.md)** - RESTful API specification and documentation
- **[Supabase Setup Guide](docs/SUPABASE_SETUP.md)** - Comprehensive guide for setting up and configuring Supabase

## VibeMUSE Development Documentation

Development plan and architecture for the VibeMUSE modernization:

- **[📊 Project Tracker](docs/PROJECT_TRACKER.md)** - **Live progress tracking** through all 7 development phases with milestones and timelines
- **[Development Plan](docs/DEVELOPMENT_PLAN.md)** - Comprehensive roadmap for modernization with tech stack progression
- **[Modernization Architecture](docs/MODERNIZATION_ARCHITECTURE.md)** - Technical architecture design for modern web stack
- **[Implementation Guide](docs/IMPLEMENTATION_GUIDE.md)** - Practical step-by-step implementation instructions
- **[📋 Changelog](CHANGELOG.md)** - Security updates, infrastructure improvements, and ongoing maintenance activities

## Repository Structure

This repository is organized to clearly separate the legacy TinyMUSE reference code from the modern VibeMUSE development project:

### VibeMUSE Modernization (Root Level)
- **`docs/`** - VibeMUSE modernization documentation and architecture
- **`.github/`** - GitHub issues and project management for development phases
- **`README.md`** - This file, describing the VibeMUSE modernization project

### Legacy TinyMUSE Reference (`legacy/`)
- **`legacy/src/`** - Original TinyMUSE C source code (v2.0)
- **`legacy/bin/`** - Compiled binaries directory
- **`legacy/run/`** - Runtime files and configuration
- **`legacy/ADMIN.md`** - Original TinyMUSE administration guide
- **`legacy/CHANGES.md`** - Original TinyMUSE changelog
- **`legacy/DATABASE.md`** - Original TinyMUSE database format documentation

The legacy directory contains the original TinyMUSE code preserved as reference documentation for the modernization project.

## Server Administration

See [legacy/ADMIN.md](legacy/ADMIN.md)

## Version

VibeMUSE is currently in **Phase 0: Documentation** (Complete).

Original TinyMUSE base version: 2.0 

## Original TinyMUSE Changelog

See [legacy/CHANGES.md](legacy/CHANGES.md) for the original TinyMUSE changelog (pre-git).

## Licensing

### Original TinyMUSE Code
The original TinyMUSE code and its related materials are licensed under custom copyright licenses detailed in [COPYRIGHT.md](COPYRIGHT.md). The original code is primarily governed by academic guidelines for fair use, with attribution required for non-commercial purposes.

### VibeMUSE Modernization Code
Any new code developed for the VibeMUSE modernization project (version 2.0+) is licensed under the MIT license.

![MIT License](https://belisariussmith.com/external/mitlicense.png)

**Important**: When using or contributing to VibeMUSE, you must respect both the original TinyMUSE attribution requirements and the MIT license for new code. See [COPYRIGHT.md](COPYRIGHT.md) for complete details on the original licensing terms.

—

