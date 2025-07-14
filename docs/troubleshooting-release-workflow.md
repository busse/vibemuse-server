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
- Either a project reference ID (exactly 20 characters, alphanumeric)
- Or a full Supabase project URL (e.g., `https://abcdefghijklmnopqrst.supabase.co`)
- The workflow will automatically extract the project ID from URLs

### Validation Steps
The workflow now includes validation that checks:
- The environment variable is not empty
- Automatically extracts project ID from URLs if needed
- Validates the final project ID is exactly 20 characters long
- Provides clear error messages if validation fails

### Testing
To test the fix locally, you can simulate the validation:
```bash
# Test with URL format
export SUPABASE_PROJECT_ID="https://your-project-id.supabase.co"
# Test with raw project ID
export SUPABASE_PROJECT_ID="your-project-id"

# Validation script
if [ -z "$SUPABASE_PROJECT_ID" ]; then
  echo "Error: SUPABASE_PROJECT_ID environment variable is not set"
  exit 1
fi

# Extract project ID from URL format if needed
if [[ "$SUPABASE_PROJECT_ID" =~ ^https?://([^.]+)\.supabase\.co ]]; then
  EXTRACTED_PROJECT_ID="${BASH_REMATCH[1]}"
  echo "Extracted project ID from URL: $EXTRACTED_PROJECT_ID"
  SUPABASE_PROJECT_REF="$EXTRACTED_PROJECT_ID"
else
  # Use the value as-is if it's not a URL
  echo "Using project ID as-is: $SUPABASE_PROJECT_ID"
  SUPABASE_PROJECT_REF="$SUPABASE_PROJECT_ID"
fi

# Validate the final project ID format
if [ ${#SUPABASE_PROJECT_REF} -ne 20 ]; then
  echo "Error: Project ID must be exactly 20 characters long"
  echo "Current length: ${#SUPABASE_PROJECT_REF}"
  echo "Current value: $SUPABASE_PROJECT_REF"
  exit 1
fi

echo "SUPABASE_PROJECT_ID validation passed"
```

### Related Files
- `.github/workflows/release.yml` - Main release workflow
- `supabase/config.toml` - Supabase configuration
- `.env.example` - Environment variable examples