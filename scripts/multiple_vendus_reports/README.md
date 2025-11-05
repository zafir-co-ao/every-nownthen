# Multiple Vendus Reports

Runs the `vendus-reports` tool twice with different company configurations.

## Overview

This script orchestrates the `vendus-reports` tool for two companies:

1. **Tecnologia** - Technology company
2. **Distribuicao** - Distribution company

Each execution uses company-specific environment variables to generate and archive reports from the Vendus ERP system using separate API credentials.

## How It Works

The `run.sh` script:

1. Loads company-specific environment variables for Tecnologia:
   - `TECNOLOGIA_ROOT_FOLDER_ID` → `ROOT_FOLDER_ID`
   - `TECNOLOGIA_VENDUS_API_KEY` → `VENDUS_API_KEY`
   - `TECNOLOGIA_COMPANY_NAME` → `COMPANY_NAME`

2. Runs `vendus-reports --output /tmp --archive all` for Tecnologia

3. Loads company-specific environment variables for Distribuicao:
   - `DISTRIBUICAO_ROOT_FOLDER_ID` → `ROOT_FOLDER_ID`
   - `DISTRIBUICAO_VENDUS_API_KEY` → `VENDUS_API_KEY`
   - `DISTRIBUICAO_COMPANY_NAME` → `COMPANY_NAME`

4. Runs `vendus-reports --output /tmp --archive all` for Distribuicao

5. Returns overall success/failure status

## Required Environment Variables

### Tecnologia Company

```bash
TECNOLOGIA_ROOT_FOLDER_ID=your-google-drive-folder-id
TECNOLOGIA_VENDUS_API_KEY=your-vendus-api-key
TECNOLOGIA_COMPANY_NAME=Your Company Name
```

### Distribuicao Company

```bash
DISTRIBUICAO_ROOT_FOLDER_ID=your-google-drive-folder-id
DISTRIBUICAO_VENDUS_API_KEY=your-vendus-api-key
DISTRIBUICAO_COMPANY_NAME=Your Company Name
```

See `.env.info` in the project root for detailed documentation.

## Usage

### Local Development

```bash
# Set environment variables first
export TECNOLOGIA_ROOT_FOLDER_ID=...
export TECNOLOGIA_VENDUS_API_KEY=...
export TECNOLOGIA_COMPANY_NAME=...
export DISTRIBUICAO_ROOT_FOLDER_ID=...
export DISTRIBUICAO_VENDUS_API_KEY=...
export DISTRIBUICAO_COMPANY_NAME=...

# Run directly
./scripts/multiple_vendus_reports/run.sh
```

### Docker

```bash
# Run manually
docker-compose exec app /app/scripts/multiple_vendus_reports/run.sh

# View logs
docker-compose logs -f
```

### Kubernetes

```bash
# Run manually
kubectl exec -it -n zafir deployment/ubiquus-every-nownthen -- /app/scripts/multiple_vendus_reports/run.sh

# View logs
kubectl logs -f -n zafir deployment/ubiquus-every-nownthen
```

## Scheduled Execution

This script runs automatically via cron:

```bash
# Every 2nd day of the month at 6:00 AM (Africa/Luanda timezone)
0 6 2 * * . /etc/environment; /app/scripts/multiple_vendus_reports/run.sh >> /var/log/cron.log 2>&1
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
Multiple Vendus Reports
Started at: Wed Nov  5 06:00:01 WAT 2025
==========================================

>>> Running vendus-reports for: TECNOLOGIA
----------------------------------------
Configuration:
  ROOT_FOLDER_ID: 18jjTLw06hEU_BAmiU7jaOFFTC0g3yEJS
  COMPANY_NAME: Ubiquus
  VENDUS_API_KEY: [REDACTED]
  OUTPUT: /tmp

[vendus-reports output for Tecnologia...]
✓ Successfully completed for TECNOLOGIA

>>> Running vendus-reports for: DISTRIBUICAO
----------------------------------------
Configuration:
  ROOT_FOLDER_ID: 18jjTLw06hEU_BAmiU7jaOFFTC0g3yEJS
  COMPANY_NAME: Ubiquus
  VENDUS_API_KEY: [REDACTED]
  OUTPUT: /tmp

[vendus-reports output for Distribuicao...]
✓ Successfully completed for DISTRIBUICAO

==========================================
Multiple Vendus Reports Complete
Finished at: Wed Nov  5 06:02:45 WAT 2025
==========================================
```

## Dependencies

- `vendus-reports` UV tool (installed from Git)
- Bash shell
- Vendus API credentials for both companies

## Files

- `run.sh` - Main shell script that orchestrates the report generation
- `README.md` - This file

## Troubleshooting

### Missing Environment Variables

If you see errors like:

```
ERROR: TECNOLOGIA_ROOT_FOLDER_ID is not set
ERROR: TECNOLOGIA_VENDUS_API_KEY is not set
```

Make sure all required variables are set in your `.env` file.

### vendus-reports Not Found

Ensure the `vendus-reports` tool is installed:

```bash
uv tool list | grep vendus-reports
```

If missing, install it:

```bash
uv tool install git+ssh://git@github.com/kindalus/vendus_reports.git
```

### Permission Denied

Make sure `run.sh` is executable:

```bash
chmod +x scripts/multiple_vendus_reports/run.sh
```

### Reports Not Generated

Check that:

1. Vendus API keys are valid
2. `/tmp` directory is writable
3. Network connectivity to Vendus API is available

## Related Documentation

- Main project: `../../README.md`
- Environment variables: `../../.env.info`
- Cron schedule: `../../crontab`
- Vendus Reports tool: https://github.com/kindalus/vendus_reports
