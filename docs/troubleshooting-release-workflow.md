# GitHub Actions Release Workflow Troubleshooting

## Issue: "Invalid project ref format" Error

### Problem Description
The Release (Production) workflow fails with the error:
```
Invalid project ref format. Must be like `abcdefghijklmnopqrst`. Try rerunning the command with --debug to troubleshoot the error.
```

### Root Cause
The error occurs when the `SUPABASE_PROJECT_ID` environment variable is not properly formatted or referenced in the GitHub Actions workflow.

### Solution Applied
1. **Fixed environment variable reference**: Properly quoted the variable in the bash command
2. **Added validation step**: Validates the project ID format before attempting to use it
3. **Improved error handling**: Clear error messages for debugging

### Required Configuration
The `SUPABASE_PROJECT_ID` secret must be set in the GitHub repository secrets with:
- Exactly 20 characters
- Alphanumeric format (like `abcdefghijklmnopqrst`)
- No spaces or special characters

### Validation Steps
The workflow now includes validation that checks:
- The environment variable is not empty
- The project ID is exactly 20 characters long
- Provides clear error messages if validation fails

### Testing
To test the fix locally, you can simulate the validation:
```bash
export SUPABASE_PROJECT_ID="your-20-char-project-id"
if [ -z "$SUPABASE_PROJECT_ID" ]; then
  echo "Error: SUPABASE_PROJECT_ID environment variable is not set"
  exit 1
fi
if [ ${#SUPABASE_PROJECT_ID} -ne 20 ]; then
  echo "Error: SUPABASE_PROJECT_ID must be exactly 20 characters long"
  echo "Current length: ${#SUPABASE_PROJECT_ID}"
  exit 1
fi
echo "SUPABASE_PROJECT_ID format validation passed"
```

### Related Files
- `.github/workflows/release.yml` - Main release workflow
- `supabase/config.toml` - Supabase configuration
- `.env.example` - Environment variable examples