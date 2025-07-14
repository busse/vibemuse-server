# Deployment Secrets Configuration

This document explains the required GitHub secrets for the Release (Production) workflow.

## Required Secrets

The following secrets must be configured in your GitHub repository settings (Settings > Secrets and variables > Actions):

### 1. SUPABASE_ACCESS_TOKEN
- **Description**: Personal access token for Supabase CLI authentication
- **How to obtain**: 
  1. Go to [Supabase Dashboard](https://app.supabase.com/account/tokens)
  2. Generate a new access token
  3. Copy the token immediately (it won't be shown again)
- **Example format**: `sbp_abc123...` (starts with `sbp_`)
- **Required for**: Authenticating with Supabase services

### 2. SUPABASE_DB_PASSWORD
- **Description**: Database password for your Supabase project
- **How to obtain**:
  1. Go to your Supabase project dashboard
  2. Navigate to Settings > Database
  3. Find the "Database Password" section
  4. Either use the existing password or reset it
- **Example format**: `your-secure-database-password`
- **Required for**: Database operations and migrations

### 3. SUPABASE_PROJECT_ID
- **Description**: Your Supabase project reference ID
- **How to obtain**:
  1. Go to your Supabase project dashboard
  2. Navigate to Settings > General
  3. Find "Project ID" or "Reference ID"
  4. Copy the 20-character alphanumeric string
- **Example format**: `wdduyssicccrdfzpqusn` (exactly 20 characters, lowercase letters and numbers only)
- **Required for**: Project identification and linking

## Setting Up Secrets

1. Go to your GitHub repository
2. Click on "Settings" tab
3. In the left sidebar, click "Secrets and variables" > "Actions"
4. Click "New repository secret"
5. Add each secret with the exact name and value

## Validation

The workflow will validate that:
- All required secrets are present
- `SUPABASE_PROJECT_ID` is exactly 20 characters long
- `SUPABASE_PROJECT_ID` contains only lowercase letters and numbers

## Troubleshooting

### Common Issues

1. **"Environment variable is not set"**
   - Ensure the secret is added to GitHub with the exact name
   - Check that the secret has a value (not empty)

2. **"Project ID must be exactly 20 characters long"**
   - Verify the project ID from your Supabase dashboard
   - Ensure no extra spaces or characters are copied

3. **"Database password failed"**
   - Verify the password is correct
   - Try resetting the database password in Supabase dashboard

4. **"Access token invalid"**
   - Generate a new access token from Supabase
   - Ensure the token has the necessary permissions

### Testing Locally

To test your configuration locally, you can:

1. Set the environment variables:
   ```bash
   export SUPABASE_ACCESS_TOKEN="your-token"
   export SUPABASE_DB_PASSWORD="your-password"
   export SUPABASE_PROJECT_ID="your-project-id"
   ```

2. Test the connection:
   ```bash
   supabase link --project-ref "$SUPABASE_PROJECT_ID" --password "$SUPABASE_DB_PASSWORD"
   supabase status
   ```

## Security Best Practices

- Never commit secrets to your repository
- Rotate access tokens regularly
- Use strong, unique passwords for your database
- Monitor access logs in your Supabase dashboard
- Remove unused secrets from GitHub settings