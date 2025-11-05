#!/bin/bash

# Multiple Vendus Reports Runner
# Runs vendus-reports for multiple companies with their specific configurations

set -e  # Exit on error

echo "=========================================="
echo "Multiple Vendus Reports"
echo "Started at: $(date)"
echo "=========================================="

# Function to run vendus-reports for a company
run_vendus_reports() {
    local company=$1
    echo ""
    echo ">>> Running vendus-reports for: $company"
    echo "----------------------------------------"

    # Resolve the actual values from environment
    ROOT_FOLDER_ID=$(eval echo \$${company}_ROOT_FOLDER_ID)
    VENDUS_API_KEY=$(eval echo \$${company}_VENDUS_API_KEY)
    COMPANY_NAME=$(eval echo \$${company}_COMPANY_NAME)

    # Validate required variables
    if [ -z "$ROOT_FOLDER_ID" ]; then
        echo "ERROR: ${company}_ROOT_FOLDER_ID is not set"
        return 1
    fi

    if [ -z "$VENDUS_API_KEY" ]; then
        echo "ERROR: ${company}_VENDUS_API_KEY is not set"
        return 1
    fi

    if [ -z "$COMPANY_NAME" ]; then
        echo "ERROR: ${company}_COMPANY_NAME is not set"
        return 1
    fi

    echo "Configuration:"
    echo "  ROOT_FOLDER_ID: $ROOT_FOLDER_ID"
    echo "  COMPANY_NAME: $COMPANY_NAME"
    echo "  VENDUS_API_KEY: [REDACTED]"
    echo "  OUTPUT: /tmp"
    echo ""

    # Run vendus-reports with company-specific environment
    ROOT_FOLDER_ID="$ROOT_FOLDER_ID" \
    VENDUS_API_KEY="$VENDUS_API_KEY" \
    COMPANY_NAME="$COMPANY_NAME" \
    vendus-reports --output /tmp --archive all

    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        echo "✓ Successfully completed for $company"
    else
        echo "✗ Failed for $company (exit code: $exit_code)"
        return $exit_code
    fi
}

# Track overall success
overall_success=0

# Run vendus-reports for Tecnologia
if ! run_vendus_reports "TECNOLOGIA"; then
    echo "WARNING: TECNOLOGIA reports failed"
    overall_success=1
fi

# Run vendus-reports for Distribuicao
if ! run_vendus_reports "DISTRIBUICAO"; then
    echo "WARNING: DISTRIBUICAO reports failed"
    overall_success=1
fi

echo ""
echo "=========================================="
echo "Multiple Vendus Reports Complete"
echo "Finished at: $(date)"
echo "=========================================="

exit $overall_success
