# Multiple Agentic Archiver

Runs the `agentic-archive` tool twice with different company configurations.

## Overview

This script orchestrates the `agentic-archive` tool for two companies:

1. **Tecnologia** - Technology company
2. **Distribuicao** - Distribution company

Each execution uses company-specific environment variables to process documents from separate Google Drive folders and create invoices using separate Vendus API credentials.

## How It Works

The `run.sh` script:

1. Loads company-specific environment variables for Tecnologia:
   - `TECNOLOGIA_ROOT_FOLDER_ID` → `ROOT_FOLDER_ID`
   - `TECNOLOGIA_VENDUS_API_KEY` → `VENDUS_API_KEY`
   - `TECNOLOGIA_COMPANY_NAME` → `COMPANY_NAME`
   - `TECNOLOGIA_COMPANY_FISCAL_ANY` → `COMPANY_FISCAL_ANY`

2. Runs `agentic-archive` for Tecnologia

3. Loads company-specific environment variables for Distribuicao:
   - `DISTRIBUICAO_ROOT_FOLDER_ID` → `ROOT_FOLDER_ID`
   - `DISTRIBUICAO_VENDUS_API_KEY` → `VENDUS_API_KEY`
   - `DISTRIBUICAO_COMPANY_NAME` → `COMPANY_NAME`
   - `DISTRIBUICAO_COMPANY_FISCAL_ANY` → `COMPANY_FISCAL_ANY`

4. Runs `agentic-archive` for Distribuicao

5. Returns overall success/failure status

## Required Environment Variables

### Tecnologia Company

```bash
TECNOLOGIA_ROOT_FOLDER_ID=your-google-drive-folder-id
TECNOLOGIA_VENDUS_API_KEY=your-vendus-api-key
TECNOLOGIA_COMPANY_NAME=Your Company Name
TECNOLOGIA_COMPANY_FISCAL_ANY=123456789
```

### Distribuicao Company

```bash
DISTRIBUICAO_ROOT_FOLDER_ID=your-google-drive-folder-id
DISTRIBUICAO_VENDUS_API_KEY=your-vendus-api-key
DISTRIBUICAO_COMPANY_NAME=Your Company Name
DISTRIBUICAO_COMPANY_FISCAL_ANY=987654321
```

### Shared Configuration

```bash
SERVICE_ACCOUNT_KEY_PATH=/etc/service_account.json
```

See `.env.info` in the project root for detailed documentation.

## Usage

### Local Development

```bash
# Set environment variables first
export TECNOLOGIA_ROOT_FOLDER_ID=...
export TECNOLOGIA_VENDUS_API_KEY=...
# ... (set all required variables)

# Run directly
./scripts/multiple_agentic_archiver/run.sh
```

### Docker

```bash
# Run manually
docker-compose exec app /app/scripts/multiple_agentic_archiver/run.sh

# View logs
docker-compose logs -f
```

### Kubernetes

```bash
# Run manually
kubectl exec -it -n zafir deployment/ubiquus-every-nownthen -- /app/scripts/multiple_agentic_archiver/run.sh

# View logs
kubectl logs -f -n zafir deployment/ubiquus-every-nownthen
```

## Scheduled Execution

This script runs automatically via cron:

```bash
# Every day at 0:00 AM (Africa/Luanda timezone)
0 0 * * * . /etc/environment; /app/scripts/multiple_agentic_archiver/run.sh >> /var/log/cron.log 2>&1
```

See `crontab` in the project root.

## Error Handling

- If Tecnologia processing fails, the script continues to Distribuicao
- If Distribuicao processing fails, the script still reports it
- Exit code indicates overall success (0) or failure (1)
- All errors are logged to stdout/stderr

## Output

The script provides detailed output:

```
==========================================
Multiple Agentic Archiver
Started at: Wed Nov  5 00:00:01 WAT 2025
==========================================

>>> Running agentic-archive for: TECNOLOGIA
----------------------------------------
Configuration:
  ROOT_FOLDER_ID: 1yStonR5SunFaBUPBCIw8WBzaw_dRWxph
  COMPANY_NAME: Tecnologia Lda
  COMPANY_FISCAL_ANY: 5480033140
  VENDUS_API_KEY: [REDACTED]

[agentic-archive output for Tecnologia...]
✓ Successfully completed for TECNOLOGIA

>>> Running agentic-archive for: DISTRIBUICAO
----------------------------------------
Configuration:
  ROOT_FOLDER_ID: 1aBcDefGhIjKlMnOpQrStUvWxYz1234567
  COMPANY_NAME: Distribuicao Lda
  COMPANY_FISCAL_ANY: 5417196215
  VENDUS_API_KEY: [REDACTED]

[agentic-archive output for Distribuicao...]
✓ Successfully completed for DISTRIBUICAO

==========================================
Multiple Agentic Archiver Complete
Finished at: Wed Nov  5 00:05:32 WAT 2025
==========================================
```

## Dependencies

- `agentic-archive` UV tool (installed from Git)
- Bash shell
- Google service account with Drive API access
- Vendus API credentials for both companies

## Files

- `run.sh` - Main shell script that orchestrates the archiving
- `README.md` - This file

## Troubleshooting

### Missing Environment Variables

If you see errors like:

```
ERROR: TECNOLOGIA_ROOT_FOLDER_ID is not set
```

Make sure all required variables are set in your `.env` file.

### agentic-archive Not Found

Ensure the `agentic-archive` tool is installed:

```bash
uv tool list | grep agentic-archive
```

If missing, install it:

```bash
uv tool install git+ssh://git@github.com/kindalus/agentic_document_archiver.git
```

### Permission Denied

Make sure `run.sh` is executable:

```bash
chmod +x scripts/multiple_agentic_archiver/run.sh
```

## Related Documentation

- Main project: `../../README.md`
- Environment variables: `../../.env.info`
- Cron schedule: `../../crontab`
