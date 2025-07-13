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

## 🚀 VibeMUSE Development Status

> **Current Phase**: 🚀 **Phase 1 - Foundation & Database** (Complete)  
> **Status**: Phase 1 complete! Database, API foundation, and CI/CD infrastructure ready for Phase 2 development  
> **Next Phase**: Phase 2 - Core API Infrastructure (Weeks 5-8)

**📊 [View Full Project Tracker](docs/PROJECT_TRACKER.md)** - Track progress through all 7 development phases of the VibeMUSE modernization project.

### What's Working Now
✅ **Complete Phase 1 Foundation:**
- PostgreSQL database schema with 7 core tables
- Supabase integration with real-time capabilities
- Node.js/Express API server with TypeScript
- GitHub Actions CI/CD pipeline
- Local development environment
- Database migrations and seed data

### What's Next
🚀 **Phase 2 - Core API Infrastructure:**
- Authentication system implementation
- User management API endpoints
- Object management system (rooms, things, exits, players)
- Session management with JWT integration

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
- **`api/`** - Node.js/Express API server with TypeScript
- **`supabase/`** - Database migrations and Supabase configuration
- **`types/`** - Generated TypeScript types for Supabase
- **`docs/`** - VibeMUSE modernization documentation and architecture
- **`.github/`** - GitHub Actions workflows and project management
- **`README.md`** - This file, describing the VibeMUSE modernization project

### Legacy TinyMUSE Reference (`legacy/`)
- **`legacy/src/`** - Original TinyMUSE C source code (v2.0)
- **`legacy/bin/`** - Compiled binaries directory
- **`legacy/run/`** - Runtime files and configuration
- **`legacy/ADMIN.md`** - Original TinyMUSE administration guide
- **`legacy/CHANGES.md`** - Original TinyMUSE changelog
- **`legacy/DATABASE.md`** - Original TinyMUSE database format documentation

The legacy directory contains the original TinyMUSE code preserved as reference documentation for the modernization project.

## Development Setup

### Prerequisites
- Node.js 18+
- npm
- Docker (for local Supabase stack)
- Supabase CLI (for database management)

### Quick Start

**For Development:**
```bash
# 1. Clone and install dependencies
git clone [repository-url]
cd vibemuse-server
npm install

# 2. Start local database
npm run supabase:start    # Start local Supabase stack
npm run supabase:reset    # Apply migrations and seed data

# 3. Start development server
npm run dev               # API server runs on http://localhost:3000
```

**For Production Setup:**
See [SETUP.md](SETUP.md) for detailed production deployment instructions.

**For Testing:**
```bash
npm run build
npm run test
npm run lint
```

### Database Management & CI/CD

The project uses a comprehensive CI/CD pipeline with GitHub Actions for database operations:

- **Local Development**: 
  - Use `npm run supabase:start` to start local Supabase stack
  - Use `npm run supabase:reset` to apply migrations and seed data
  - Use `npm run supabase:types` to generate TypeScript types
  
- **Pull Request Testing**: 
  - GitHub Actions automatically spins up ephemeral Supabase containers
  - Runs migrations and tests against temporary database
  - Ensures safe testing without affecting production

- **Production Deployment**: 
  - Merges to main branch automatically deploy to cloud Supabase
  - Database migrations are executed automatically
  - TypeScript types are regenerated and committed back

For detailed CI/CD setup including GitHub secrets configuration, see [GitHub Actions Supabase Integration](.github/SUPABASE_SETUP.md).

### Troubleshooting

**Common Issues:**
- **"Docker not found"**: Install Docker Desktop and ensure it's running
- **"Port already in use"**: Stop other services on ports 54321-54324, or use `npm run supabase:stop` first
- **"Cannot connect to database"**: Ensure Supabase is running with `npm run supabase:start`
- **"TypeScript errors"**: Run `npm run supabase:types` to regenerate database types

**Getting Help:**
1. Check [SETUP.md](SETUP.md) for detailed setup instructions
2. Review [docs/SUPABASE_SETUP.md](docs/SUPABASE_SETUP.md) for database configuration
3. Check existing GitHub issues for similar problems

## Server Administration

See [legacy/ADMIN.md](legacy/ADMIN.md)

## Version

VibeMUSE is currently in **Phase 1: Foundation & Database** (Complete).

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

