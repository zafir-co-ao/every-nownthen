#!/bin/bash

# Multiple Agentic Archiver Runner
# Runs agentic-archive for multiple companies with their specific configurations

set -e  # Exit on error

echo "=========================================="
echo "Multiple Agentic Archiver"
echo "Started at: $(date)"
echo "=========================================="

# Function to run archiver for a company
run_archiver() {
    local company=$1
    echo ""
    echo ">>> Running agentic-archive for: $company"
    echo "----------------------------------------"

    # Resolve the actual values from environment
    ROOT_FOLDER_ID=$(eval echo \$${company}_ROOT_FOLDER_ID)
    VENDUS_API_KEY=$(eval echo \$${company}_VENDUS_API_KEY)
    COMPANY_NAME=$(eval echo \$${company}_COMPANY_NAME)
    COMPANY_FISCAL_ID=$(eval echo \$${company}_COMPANY_FISCAL_ID)

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

    if [ -z "$COMPANY_FISCAL_ID" ]; then
        echo "ERROR: ${company}_COMPANY_FISCAL_ID is not set"
        return 1
    fi

    echo "Configuration:"
    echo "  ROOT_FOLDER_ID: $ROOT_FOLDER_ID"
    echo "  COMPANY_NAME: $COMPANY_NAME"
    echo "  COMPANY_FISCAL_ID: $COMPANY_FISCAL_ID"
    echo "  VENDUS_API_KEY: [REDACTED]"
    echo ""

    # Run agentic-archive with company-specific environment
    ROOT_FOLDER_ID="$ROOT_FOLDER_ID" \
    VENDUS_API_KEY="$VENDUS_API_KEY" \
    COMPANY_NAME="$COMPANY_NAME" \
    COMPANY_FISCAL_ID="$COMPANY_FISCAL_ID" \
    agentic-archive

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

# Run archiver for Tecnologia
if ! run_archiver "TECNOLOGIA"; then
    echo "WARNING: TECNOLOGIA archiver failed"
    overall_success=1
fi

# Run archiver for Distribuicao
if ! run_archiver "DISTRIBUICAO"; then
    echo "WARNING: DISTRIBUICAO archiver failed"
    overall_success=1
fi

echo ""
echo "=========================================="
echo "Multiple Agentic Archiver Complete"
echo "Finished at: $(date)"
echo "=========================================="

exit $overall_success
