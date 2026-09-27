# Implicit environment variables

These are variables that SDKs, runtimes and tools read without the project's code naming them.
Include a family only if the project uses that SDK, runtime or tool. Mark each one **Inferred**
and name the library that reads it.

For each variable, check whether a hard-coded value **overrides** it. For example, a client built
with a literal `region` ignores `AWS_REGION`.

## Cloud SDKs

- **AWS SDKs (credential and region chain):**
  - Credentials: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`, `AWS_PROFILE`
  - Region: `AWS_REGION`, `AWS_DEFAULT_REGION`
  - Config files: `AWS_CONFIG_FILE`, `AWS_SHARED_CREDENTIALS_FILE`, `~/.aws/credentials`,
    `~/.aws/config`
  - Other credential sources: SSO profiles, container credentials
    (`AWS_CONTAINER_CREDENTIALS_RELATIVE_URI`), EC2 instance metadata, web identity
    (`AWS_ROLE_ARN`, `AWS_WEB_IDENTITY_TOKEN_FILE`)
  - Behaviour: `AWS_ENDPOINT_URL` (and per-service `AWS_ENDPOINT_URL_<SERVICE>`),
    `AWS_MAX_ATTEMPTS`, `AWS_RETRY_MODE`
- **AWS Lambda runtime (reserved):** `AWS_LAMBDA_FUNCTION_NAME`, `AWS_LAMBDA_FUNCTION_VERSION`,
  `AWS_EXECUTION_ENV`, `LAMBDA_TASK_ROOT`, `_HANDLER`, `AWS_LAMBDA_LOG_LEVEL`
- **Google Cloud:** `GOOGLE_APPLICATION_CREDENTIALS`, `GOOGLE_CLOUD_PROJECT`, `GCLOUD_PROJECT`,
  metadata server credentials
- **Azure:** `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_CLIENT_SECRET`,
  `AZURE_FEDERATED_TOKEN_FILE`, managed identity endpoints

## Network and TLS

- Proxies: `HTTP_PROXY`, `HTTPS_PROXY`, `NO_PROXY`, and their lower-case forms.
- CA bundles: `NODE_EXTRA_CA_CERTS`, `SSL_CERT_FILE`, `REQUESTS_CA_BUNDLE`, `CURL_CA_BUNDLE`.

## Runtimes and frameworks

- **Node:** `NODE_ENV`, `NODE_OPTIONS`, `NODE_EXTRA_CA_CERTS`, `DEBUG` (the `debug` package),
  `TZ`. In Vite, only `VITE_*` variables are exposed to client code; in Next.js, only
  `NEXT_PUBLIC_*`.
- **Python:** `PYTHONPATH`, `PYTHONUNBUFFERED`, `PYTHONDONTWRITEBYTECODE`,
  `DJANGO_SETTINGS_MODULE`. pydantic `BaseSettings` maps field names to env vars, with an
  optional prefix.
- **JVM:** `JAVA_TOOL_OPTIONS`, `JAVA_OPTS`, `SPRING_PROFILES_ACTIVE`. Spring relaxed binding
  means any property can be overridden by an env var (for example `SERVER_PORT`).
- **.NET:** `ASPNETCORE_ENVIRONMENT`, `DOTNET_ENVIRONMENT`, `ASPNETCORE_URLS`. Any
  `IConfiguration` key can be overridden by an env var, with `__` as the section separator.
- **Go:** `GOFLAGS`, `GOPROXY` (build time only), `GODEBUG`.

## Tooling and CI

- `CI`, `GITHUB_*`, `RUNNER_*` (GitHub Actions), `GITLAB_CI`, `BUILD_*` (Azure Pipelines).
- Test runners and coverage tools, for example `JEST_WORKER_ID`, `NODE_V8_COVERAGE`
  (c8), `PYTEST_ADDOPTS`, `COVERAGE_FILE`.
- Containers: variables injected by the orchestrator, such as Kubernetes service discovery
  `<SERVICE>_SERVICE_HOST` and the downward API.

## Env file loaders

Only list an env file as "loaded" if one of these loads it:
- **JS/TS:** `dotenv`, `node --env-file`, or framework auto-loading (Next.js, Vite, Create React
  App).
- **Python:** `python-dotenv`, or pydantic `env_file`.
- **Compose:** `env_file:`, or automatic `.env` interpolation of variables in the compose file
  itself.
- **Frameworks:** Laravel and Symfony load `.env` themselves.
- **Tooling:** `direnv` (`.envrc`).

A git-ignored `.env` with no loader is a finding.
