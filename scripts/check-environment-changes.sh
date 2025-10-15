#!/bin/bash

# Environment Change Validation Script
# Ensures changes are made to only one environment at a time
# Outputs the target environment for pipeline deployment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Main validation function
validate_single_environment_change() {
    log "=== Environment Change Validation ==="
    
    # Get base reference for comparison
    if [ "$GITHUB_EVENT_NAME" = "pull_request" ]; then
        base_ref="origin/$GITHUB_BASE_REF"
        log "Pull Request detected - comparing against: $base_ref"
    else
        base_ref="HEAD~1"
        log "Push event detected - comparing against: $base_ref"
    fi
    
    # Get all changed files in environments directory
    changed_files=$(git diff --name-only "$base_ref"...HEAD | grep "^environments/" || true)
    
    if [ -z "$changed_files" ]; then
        log_error "No environment changes detected in environments/ directory"
        log_error "This pipeline requires changes to at least one environment"
        exit 1
    fi
    
    log "Changed files in environments:"
    echo "$changed_files" | while read -r file; do
        log "  - $file"
    done
    
    # Extract unique environment names from changed files
    changed_envs=$(echo "$changed_files" | cut -d'/' -f2 | sort -u)
    
    # Count number of environments changed
    env_count=$(echo "$changed_envs" | wc -l)
    
    log "Environments with changes:"
    echo "$changed_envs" | while read -r env; do
        log "  - $env"
    done
    
    # Validate single environment rule
    if [ "$env_count" -gt 1 ]; then
        log_error "VALIDATION FAILED: Changes detected in multiple environments ($env_count)"
        log_error "Changed environments: $(echo "$changed_envs" | tr '\n' ', ' | sed 's/,$//')"
        echo ""
        log_error "❌ Policy Violation: Only one environment can be modified per PR"
        log_error "This ensures proper environment promotion workflow:"
        log_error "  1. Make changes to 'dev' environment in separate PR"
        log_error "  2. Make changes to 'staging' environment in separate PR"  
        log_error "  3. Make changes to 'production' environment in separate PR"
        echo ""
        log_error "Please split your changes into separate PRs for each environment."
        exit 1
    else
        changed_env=$(echo "$changed_envs" | head -n1)
        log_success "✅ Validation passed: Changes limited to single environment: '$changed_env'"
        
        # Set output for pipeline
        echo "target_environment=$changed_env" >> $GITHUB_OUTPUT
        
        log_success "Target environment set: $changed_env"
        return 0
    fi
}

# Main execution
main() {
    log "Starting environment change validation..."
    
    # Ensure we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "Not in a git repository"
        exit 1
    fi
    
    # Run validation
    validate_single_environment_change
    
    log_success "Environment change validation completed successfully"
}

# Run main function
main "$@"