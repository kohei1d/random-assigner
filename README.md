# Random Assignner

A random assignment API built with AWS Lambda + AWS SAM.  
Local development, testing, and deployment all work seamlessly within a Docker environment.

## Demo

https://github.com/user-attachments/assets/ce13ab2c-cd8f-4b55-9435-a67a2a173a5d


## Features

Provides an API that randomly selects one person from a list of candidates.

### Request Methods

#### 1. GET Request (Query Parameters)
```bash
GET /?list=Alice,Bob,Carol
```

#### 2. POST Request (JSON Body)
```bash
POST /
Content-Type: application/json

{
  "list": ["Alice", "Bob", "Carol"]
}
```

Or

```bash
POST /
Content-Type: application/json

{
  "list": "Alice,Bob,Carol"
}
```

### Success Response Example

```json
{
  "winner": "Alice",
  "candidates": ["Alice", "Bob", "Carol"]
}
```

### Error Response Example

When no candidates are specified:

```json
{
  "error": "BadRequest",
  "message": "Please specify candidates in the list parameter. Example: ?list=Alice,Bob,Carol"
}
```

> **Note**: The actual error message in the implementation is currently in Japanese. The example above shows what the message would be in English.

---

## Tech Stack

- **Runtime**: Python 3.12 (AWS Lambda official image)
- **Infrastructure**: AWS Lambda + Lambda Function URL
- **Deployment Tool**: AWS SAM (Serverless Application Model)
- **Development Environment**: Docker (`public.ecr.aws/lambda/python:3.12`) + docker compose

---

## Quick Start

Steps to get up and running quickly:

```bash
# 1. Clone the repository (or navigate to it)
cd /path/to/random-assign-python-lambda

# 2. .env file is already created (with license key configured)

# 3. Install dependencies
docker compose run --rm app npm install

# 4. Start local server
docker compose run --rm --service-ports app npm run local

# 5. Test from another terminal
curl "http://localhost:3000/?list=Alice,Bob,Carol"
```

---

## Setup

### 1. Environment Variables Configuration

```bash
# AWS credentials (required for deployment)
AWS_ACCESS_KEY_ID=your-aws-access-key-id
AWS_SECRET_ACCESS_KEY=your-aws-secret-access-key
AWS_REGION=ap-northeast-1

# Optional: SAM deployment parameters
SAM_STACK_NAME=random-assigner
```

For new setup, you can copy from the template:

```bash
cp env.template .env
```

### 2. Install Dependencies

```bash
docker compose run --rm app npm install
```

---

## Local Development

### Start Local Server

Run the following command:

```bash
docker compose run --rm --service-ports app npm run local
```

Once the server is running, you can access it via browser or curl:

```bash
# Open in browser
open http://localhost:3000/?list=Alice,Bob,Carol

# Test with curl (GET)
curl "http://localhost:3000/?list=Alice,Bob,Carol"

# Test with curl (POST)
curl -X POST http://localhost:3000/ \
  -H "Content-Type: application/json" \
  -d '{"list": ["Alice", "Bob", "Carol"]}'
```

### Using Test Scripts

#### 1. Direct Lambda Function Test (No Server Required)

```bash
docker compose run --rm app npm run test
```

This script directly executes the Lambda function without starting a server and runs multiple test cases.

#### 2. API Endpoint Test

```bash
# Test local server (from host machine)
./test-api.sh

# Test deployed AWS Lambda
./test-api.sh https://your-lambda-url.lambda-url.ap-northeast-1.on.aws
```

This script tests the API by sending actual HTTP requests.

### Local Invoke Test (Individual Execution)

You can test by directly executing the Lambda function without starting a server:

```bash
docker compose run --rm app npm run invoke-local
```

---

## Deploy to AWS

### 1. Execute Deployment

First, build the application:

```bash
docker compose run --rm app npm run build
```

Then deploy (first time deployment requires guided mode):

```bash
docker compose run --rm app npm run deploy
```

Follow the prompts to configure:
- Stack Name (default: random-assigner)
- AWS Region (e.g., ap-northeast-1)
- Confirm changes before deploy
- Allow SAM CLI IAM role creation
- RandomAssignFunction has no authorization defined, Is this okay? [y/N]: y
- Save arguments to configuration file

For subsequent deployments, you can use:

```bash
docker compose run --rm app npm run deploy-no-confirm
```

When deployment completes, the Lambda Function URL will be displayed:

```
CloudFormation outputs from deployed stack
--------------------------------------------------------------------------------
Outputs                                                                                                                                                                               
--------------------------------------------------------------------------------
Key                 RandomAssignFunctionUrl                                                                                                                                           
Description         Lambda Function URL for Random Assigner                                                                                                                           
Value               https://xxxxxxxxxx.lambda-url.ap-northeast-1.on.aws/                                                                                                              
--------------------------------------------------------------------------------
```

### 2. Test Deployed API

```bash
# GET request
curl "https://xxxxxxxxxx.lambda-url.ap-northeast-1.on.aws/?list=Alice,Bob,Carol"

# POST request
curl -X POST https://xxxxxxxxxx.lambda-url.ap-northeast-1.on.aws/ \
  -H "Content-Type: application/json" \
  -d '{"list": ["Alice", "Bob", "Carol"]}'
```

### 3. View Logs

```bash
docker compose run --rm app npm run logs
```

### 4. Validate Template

```bash
docker compose run --rm app npm run validate
```

### 5. Remove Resources

```bash
docker compose run --rm app npm run delete
```

---

## Available Commands

| Command | Description |
|---------|------|
| `docker compose run --rm --service-ports app npm run local` | Start local server (localhost:3000) |
| `docker compose run --rm app npm run invoke-local` | Execute Lambda function locally |
| `docker compose run --rm app npm run build` | Build SAM application |
| `docker compose run --rm app npm run deploy` | Deploy to AWS (guided mode) |
| `docker compose run --rm app npm run deploy-no-confirm` | Deploy to AWS (using saved config) |
| `docker compose run --rm app npm run validate` | Validate SAM template |
| `docker compose run --rm app npm run delete` | Remove resources from AWS |
| `docker compose run --rm app npm run logs` | Display CloudWatch logs |

> **Note**: The `--service-ports` flag is required for `npm run local` to expose port 3000 to the host machine.

---

## Troubleshooting

### AWS Authentication Error

```
Error: AWS credentials not found
```

Check that AWS credentials are correctly configured in the `.env` file.

### Port Already in Use

```
Error: Port 3000 is already in use
```

If another process is using port 3000, you can change the port in the `npm run local` command or kill the process using that port.

---

## Project Structure

```
.
├── handler.py              # Lambda function handler
├── template.yaml           # AWS SAM template
├── events/                 # Test event files for local invoke
│   └── test-event.json     # Sample test event
├── templates/              # HTML templates
│   └── winner.html         # Winner display HTML
├── package.json            # Node.js dependencies and scripts
├── Dockerfile              # Docker image definition
├── docker-compose.yml      # Docker Compose configuration
├── env.template            # Environment variables template
├── .env                    # Environment variables (auto-generated, Git ignored)
├── test-local.sh           # Lambda function direct test script
├── test-api.sh             # API endpoint test script
└── README.md               # This file
```

---

## Security Notes

- **Never** commit the `.env` file to Git
- It is recommended to add proper authentication and authorization mechanisms for production environments
- Lambda Function URL is a public URL, so do not include sensitive information
