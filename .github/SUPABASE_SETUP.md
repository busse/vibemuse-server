# GitHub Actions Supabase Integration

This document outlines the GitHub Actions setup for direct connection to Supabase cloud, following the proven pattern where GitHub Actions owns all database tasks.

## Required GitHub Secrets

Add these secrets to your repository: **Settings → Secrets → Actions**

| Secret Name | Description | Where to Find |
|-------------|-------------|---------------|
| `SUPABASE_PROJECT_ID` | Project reference ID (8-30 chars) or full URL | Dashboard → Project URL `https://app.supabase.com/project/<ref>` or full URL |
| `SUPABASE_DB_PASSWORD` | Database password | Dashboard → **Settings → Database** → *Connection string* |
| `SUPABASE_ACCESS_TOKEN` | Personal access token | Dashboard avatar → **Account Settings → Access Tokens → Generate new token** |
| `SUPABASE_ANON_KEY` | Anonymous key (optional, for tests) | Dashboard → **Settings → API** |
| `SUPABASE_SERVICE_ROLE_KEY` | Service role key (optional, for tests) | Dashboard → **Settings → API** |

## Workflows

### CI Workflow (`.github/workflows/ci.yml`)
- **Trigger**: Pull requests
- **Purpose**: Run tests against ephemeral local Supabase stack
- **Actions**: 
  - Spins up local Supabase container
  - Applies migrations to temp DB
  - Generates TypeScript types
  - Runs unit/integration tests
  - Nothing touches the cloud database

### Release Workflow (`.github/workflows/release.yml`)
- **Trigger**: Push to `main` branch or manual dispatch
- **Purpose**: Deploy to production Supabase cloud project
- **Actions**:
  - Links to cloud project using `SUPABASE_PROJECT_ID`
  - Ships migrations to cloud database
  - Regenerates TypeScript types against remote DB
  - Commits updated types back to repository

## File Structure

```
types/
├── supabase.ts          # Generated from cloud DB (production)
└── supabase.gen.ts      # Generated from local DB (CI only, gitignored)
```

## Benefits

1. **Zero-footprint workflow**: No local Postgres/Docker required
2. **Safe PR testing**: Each PR uses fresh containers, never touches production
3. **Automated deployments**: Main branch changes automatically deploy to cloud
4. **Type safety**: TypeScript types stay in sync with database schema
5. **Non-interactive CI**: All operations run automatically with `--no-confirm`

## Usage

1. **Development**: Work on features in branches, create PRs
2. **CI Testing**: PR CI spins up ephemeral Supabase, runs tests
3. **Production Deploy**: Merge to `main` triggers deployment to cloud project
4. **Type Generation**: Schema changes automatically update TypeScript types

## Troubleshooting

- If CLI asks for confirmation in CI, the `--no-confirm` flag forces non-interactive mode
- Multiple environments can be supported by duplicating workflows with different secrets
- Seeds are automatically executed after `db reset` or can be run with `supabase db seed`