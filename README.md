# Every Now & Then - Autonomous Python Script Runner

An autonomous Python script runner designed to execute scheduled Python scripts in isolated virtual environments using Docker, UV, and cron. Each script runs in its own UV-managed virtual environment to prevent dependency conflicts.

## Overview

Every Now & Then provides a containerized environment for running Python scripts on a schedule using UV's powerful project management. Scripts can be:

1. **Local scripts**: Placed in the `scripts/` directory with UV project configuration
2. **UV tools**: Installed from GitHub repositories as UV tools at container build time

Each script runs in isolation with its own dependencies, managed by UV and `pyproject.toml` files.

## Project Structure

```
every_nownthen/
├── scripts/                         # Local scripts directory
│   ├── multiple_agentic_archiver/  # Multiple company archiver
│   │   ├── run.sh                  # Shell script that runs agentic-archive twice
│   │   └── README.md               # Script documentation
│   └── multiple_vendus_reports/    # Multiple company reports
│       ├── run.sh                  # Shell script that runs vendus-reports twice
│       └── README.md               # Script documentation
├── install_uv_tools.sh             # Install UV tools from Git
├── install_scripts_as_uv_tools.sh  # Install local scripts as UV tools
├── uv_tools.txt                    # List of Git repos to install as UV tools
├── crontab                         # Cron schedule configuration
├── Dockerfile                      # Container definition
├── docker-compose.yml              # Docker Compose configuration
├── .env.example                    # Environment variables template
├── .env.info                       # Environment variables documentation (committed)
├── .env                            # Actual environment values (gitignored, DO NOT COMMIT)
└── README.md                       # This file
```

## Current Scripts

### Multiple Agentic Archiver

Runs the `agentic-archive` tool twice - once for Tecnologia company and once for Distribuicao company. Each run uses company-specific environment variables for:

- Google Drive folder ID (`ROOT_FOLDER_ID`)
- Vendus API key (`VENDUS_API_KEY`)
- Company name (`COMPANY_NAME`)
- Company fiscal ID (`COMPANY_FISCAL_ANY`)

**Schedule**: Daily at 0:00 AM (Africa/Luanda timezone)

**Location**: `scripts/multiple_agentic_archiver/run.sh`

### Multiple Vendus Reports

Runs the `vendus-reports` tool twice - once for Tecnologia company and once for Distribuicao company. Each run uses company-specific environment variables for:

- Vendus API key (`VENDUS_API_KEY`)
- Company name (`COMPANY_NAME`)

Generates and archives all report types to `/tmp`.

**Schedule**: 2nd of each month at 6:00 AM (Africa/Luanda timezone)

**Location**: `scripts/multiple_vendus_reports/run.sh`

## UV Tools (Git-Based Scripts)

Scripts can also be installed as UV tools from Git repositories. This is ideal for:

- Reusable scripts across multiple projects
- Scripts maintained in separate repositories
- Third-party automation tools

### Configuration

Add Git repositories to `uv_tools.txt`:

```txt
# UV Tools - Git repositories to install as tools
git+ssh://git@github.com/kindalus/agentic_document_archiver.git
git+https://github.com/kindalus/vendus_reports.git
```

UV tools are installed at container build time using `install_uv_tools.sh`.

### Current UV Tools

- **agentic-archive**: AI-powered document archiver and classifier
- **vendus-reports**: Report generator for Vendus ERP system

## Environment Variables

All scripts rely on environment variables configured in the `.env` file.

### Important Security Notes

⚠️ **NEVER commit `.env` files to version control** - they contain sensitive data!

- `.env` is in `.gitignore` and should never be committed
- Use `.env.info` to document what variables are needed (this IS committed)
- Use `.env.example` as a template with example/placeholder values
- Environment variables are loaded by Docker Compose from `.env` file

### Environment Configuration Files

- **`.env.info`** - Documents all required environment variables (committed to git)
  - Describes each variable's purpose
  - Lists which scripts use each variable
  - Specifies required vs optional variables
  - **This is your source of truth for environment documentation**

- **`.env.example`** - Template with example values (committed to git)
  - Safe placeholder values
  - Shows the format of each variable
  - Used as a starting point

- **`.env`** - Actual values (GITIGNORED, never committed)
  - Contains real API keys, passwords, etc.
  - Created locally by each developer/deployment
  - Loaded automatically by Docker Compose

### Setup

1. Review `.env.info` to see what variables are needed:

```bash
cat .env.info
```

2. Copy the example environment file:

```bash
cp .env.example .env
```

3. Edit `.env` with your actual configuration:

```bash
# Edit with real values - this file will NEVER be committed
vim .env
```

4. Set up company-specific variables for both Tecnologia and Distribuicao:

```bash
# Tecnologia company
TECNOLOGIA_ROOT_FOLDER_ID=your-google-drive-folder-id
TECNOLOGIA_VENDUS_API_KEY=your-vendus-api-key
TECNOLOGIA_COMPANY_NAME=Your Company Name
TECNOLOGIA_COMPANY_FISCAL_ANY=123456789

# Distribuicao company
DISTRIBUICAO_ROOT_FOLDER_ID=your-google-drive-folder-id
DISTRIBUICAO_VENDUS_API_KEY=your-vendus-api-key
DISTRIBUICAO_COMPANY_NAME=Your Company Name
DISTRIBUICAO_COMPANY_FISCAL_ANY=987654321

# Google service account (shared)
SERVICE_ACCOUNT_KEY_PATH=/etc/service_account.json
```

5. Variables are automatically loaded by Docker Compose (via `env_file` in docker-compose.yml)

## Docker Deployment

### Build and Run

```bash
# Build the container
docker-compose build

# Start the container
docker-compose up -d

# View logs
docker-compose logs -f

# Stop the container
docker-compose down
```

### Container Features

- Based on Python 3.12 slim image
- UV package manager pre-installed
- Git support for cloning script repositories
- Cron service for scheduled execution
- Environment variables from .env file
- Isolated virtual environments per script

## Scheduling Scripts with Cron

Configure cron jobs in the `crontab` file:

```bash
# Edit crontab file
vim crontab
```

### Current Crontab

```bash
# Every day at 0:00 AM run multiple agentic archive for both companies
0 0 * * * . /etc/environment; /app/scripts/multiple_agentic_archiver/run.sh >> /var/log/cron.log 2>&1

# Every 2nd day of the month at 6:00 AM run vendus reports for both companies
0 6 2 * * . /etc/environment; /app/scripts/multiple_vendus_reports/run.sh >> /var/log/cron.log 2>&1
```

**Important**:

- Source environment variables: `. /etc/environment;`
- Use full path to script: `/app/scripts/multiple_agentic_archiver/run.sh`
- Redirect output: `>> /var/log/cron.log 2>&1`

Cron format: `minute hour day month weekday command`

See: https://crontab.guru/ for help with cron expressions

## Development

### Adding a New Local Script

1. Create the script directory:

```bash
mkdir -p scripts/my_script
```

2. Create your script (Python or shell):

```bash
# For a shell script
touch scripts/my_script/run.sh
chmod +x scripts/my_script/run.sh

# Or for a Python script
touch scripts/my_script/my_script.py
```

3. (Optional) If your Python script needs dependencies, create `pyproject.toml`:

```bash
cat > scripts/my_script/pyproject.toml << EOF
[project]
name = "my-script"
version = "1.0.0"
requires-python = ">=3.12"
dependencies = [
    "requests>=2.31.0",
]

[project.scripts]
my-script = "my_script:main"

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"
EOF
```

4. Test locally:

```bash
# For shell scripts
./scripts/my_script/run.sh

# For Python scripts with dependencies
cd scripts/my_script
uv run my_script.py

# For Python scripts with pyproject.toml as UV tool
./install_scripts_as_uv_tools.sh
my-script
```

### Adding a UV Tool from Git

1. Edit `uv_tools.txt`:

```txt
git+ssh://git@github.com:your-org/your-tool.git
```

2. For private repositories, configure SSH keys in Dockerfile

3. Rebuild the container:

```bash
docker-compose build
```

### Adding a Cron Schedule

1. Edit the `crontab` file:

```bash
# For a shell script
0 9 * * * . /etc/environment; /app/scripts/my_script/run.sh >> /var/log/cron.log 2>&1

# For a UV tool
0 9 * * * . /etc/environment; /root/.local/bin/my-script >> /var/log/cron.log 2>&1
```

2. Rebuild the container:

```bash
docker-compose build
docker-compose up -d
```

## Virtual Environment Management

Every Now & Then uses UV to manage per-script virtual environments:

- **Location**: `scripts/<script_name>/.venv/`
- **Creation**: Automatic when running `uv run`
- **Dependencies**: Installed from `pyproject.toml` using `uv sync`
- **Isolation**: Each script has its own packages

### Benefits

- No dependency conflicts between scripts
- Fast environment creation with UV
- Easy to update per-script dependencies
- Clean separation of concerns
- UV's lockfile support for reproducible builds

## Kubernetes Deployment

This project is designed to run on Kubernetes (DigitalOcean):

### Prerequisites

Create required ConfigMaps:

```bash
# Create environment variables ConfigMap
kubectl create configmap ubiquus-every-nownthen-env-config \
  --from-env-file=.env \
  --namespace=zafir

# Create service account key ConfigMap
kubectl create configmap ubiquus-every-nownthen-service-account-key-path-config \
  --from-file=service_account.json=/path/to/key.json \
  --namespace=zafir
```

### Deploy

```bash
# Apply deployment
kubectl apply -f .deployments/k8s/deployment.yaml

# Check status
kubectl get pods -n zafir -l app=ubiquus-every-nownthen

# View logs
kubectl logs -f -n zafir deployment/ubiquus-every-nownthen

# Execute into pod
kubectl exec -it -n zafir deployment/ubiquus-every-nownthen -- /bin/bash
```

### CI/CD

GitHub Actions automatically deploys on Git tags:

```bash
# Create and push a tag
git tag v1.0.0
git push origin v1.0.0
```

The workflow:

1. Builds Docker image with timestamp tag
2. Pushes to Docker Hub
3. Deploys to DigitalOcean Kubernetes
4. Verifies deployment rollout

## Requirements

- **Docker** and **Docker Compose** (for local development)
- **UV** (for local development)
- **Git** (for UV tools from private repos)
- **kubectl** and **doctl** (for Kubernetes deployment)
- **SSH keys** configured (if using private repositories)

## Troubleshooting

### Environment Variables Not Loading

Verify `.env` file exists and contains required variables:

```bash
cat .env
```

Check that all company-specific variables are set:

```bash
# For Tecnologia
echo $TECNOLOGIA_ROOT_FOLDER_ID
echo $TECNOLOGIA_VENDUS_API_KEY
echo $TECNOLOGIA_COMPANY_NAME
echo $TECNOLOGIA_COMPANY_FISCAL_ANY

# For Distribuicao
echo $DISTRIBUICAO_ROOT_FOLDER_ID
echo $DISTRIBUICAO_VENDUS_API_KEY
echo $DISTRIBUICAO_COMPANY_NAME
echo $DISTRIBUICAO_COMPANY_FISCAL_ANY
```

### Cron Not Running

Check cron logs inside the container:

```bash
docker-compose exec app cat /var/log/cron.log
```

Or in Kubernetes:

```bash
kubectl exec -it -n zafir deployment/ubiquus-every-nownthen -- cat /var/log/cron.log
```

### UV Tool Installation Failures

Check if tools are installed:

```bash
docker-compose exec app uv tool list
```

Or in Kubernetes:

```bash
kubectl exec -it -n zafir deployment/ubiquus-every-nownthen -- uv tool list
```

### Script Execution Errors

Test the script manually:

```bash
# Local
./scripts/multiple_agentic_archiver/run.sh

# Docker
docker-compose exec app /root/.local/bin/run-multiple-archiver

# Kubernetes
kubectl exec -it -n zafir deployment/ubiquus-every-nownthen -- /root/.local/bin/run-multiple-archiver
```

## Security Considerations

1. **Environment Variables**:
   - ⚠️ **NEVER commit `.env` files** - they are gitignored for security
   - `.env` contains sensitive data (API keys, passwords, credentials)
   - Use `.env.info` to document variables (safe to commit)
   - Use `.env.example` for templates (safe to commit)
   - Docker Compose loads variables automatically from `.env`

2. **SSH Keys**: Use read-only deploy keys for Git repositories

3. **Container Isolation**: Scripts run in isolated environments

4. **Secrets Management**: Use Kubernetes Secrets (not ConfigMaps) for production

5. **File Permissions**: Ensure `.env` has restricted permissions (600)

## UV Features Used

- **`uv run`**: Executes scripts in their own virtual environments
- **`uv sync`**: Installs dependencies from pyproject.toml
- **`uv tool install`**: Installs tools from Git repositories and local scripts
- **`uv tool run`**: Runs globally installed UV tools
- **`pyproject.toml`**: Modern Python project configuration

## Cron File

The `crontab` file in the project root contains all scheduled jobs. This file is:

- Version controlled (safe to commit)
- Loaded into the container at build time
- Easy to review and modify
- Supports comments and documentation

Current schedule:

```bash
# Every day at 0:00 AM run multiple agentic archive for both companies
0 0 * * * . /etc/environment; /root/.local/bin/run-multiple-archiver >> /var/log/cron.log 2>&1
```

## License

[Add your license information here]

## Support

For issues and questions:

- Create an issue in the repository
- Review cron logs: `docker-compose exec app cat /var/log/cron.log`
- Check UV tool status: `docker-compose exec app uv tool list`
