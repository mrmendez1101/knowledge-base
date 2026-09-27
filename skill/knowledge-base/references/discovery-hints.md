# Discovery hints

These are starting points for search, not a limit. Read **All ecosystems** plus the section for each
language found in Phase 1. Record every hit with `path:line`.

## All ecosystems

| Kind | Search hints |
|---|---|
| Serverless handlers | `handler:` / `Handler:` in `serverless.yml`, `template.yaml` (SAM), CDK `Function(`, Terraform `aws_lambda_function`, `function.json` (Azure), `gcloud functions` configs |
| Messaging and schedules | event source mappings, EventBridge/CloudWatch rules, `schedule:` / `cron:` in IaC or CI, Kubernetes `CronJob`, queue or topic subscriptions in IaC |
| RPC and schema | `.proto` `service` blocks, GraphQL `type Query` / `type Mutation`, OpenAPI/Swagger files, AsyncAPI files |
| Shell and containers | `$VAR` / `${VAR}` in `*.sh`, `Makefile`, Dockerfile `ENV` / `ARG` / `ENTRYPOINT` / `CMD`, compose `environment:` / `env_file:` |
| CI/CD | `env:`, `secrets.`, `vars.` in `.github/workflows/*`; `variables:` in `.gitlab-ci.yml`; `environment {}` in `Jenkinsfile`; `azure-pipelines.yml`, `bitbucket-pipelines.yml` |
| IaC environment | `Environment:` / `Variables:` (CloudFormation/SAM), `environment {}` (Terraform), `env:` / `envFrom:` (Kubernetes), Helm `values*.yaml` |
| SQL | `CREATE TABLE`, migrations folders (`migrations/`, `db/migrate/`, `alembic/`, `flyway`, `liquibase`) |
| Logs and telemetry | Sentry, Datadog, New Relic, OpenTelemetry (`otel`), Prometheus metrics, `statsd` |
| Comments | `TODO`, `FIXME`, `HACK`, `XXX`, `not sure`, `whichever`, `temporary`, `workaround` |

### Configuration file families (cover each one that exists)

- Manifests and lockfiles, with their scripts and tasks.
- Runtime pinning: `engines`, `.nvmrc`, `.node-version`, `.python-version`, `.tool-versions`,
  `global.json`, `rust-toolchain*`.
- Build, compile and bundle config.
- Test and coverage runners.
- Lint and format config: `.editorconfig`, linters, formatters.
- Containers: `Dockerfile*`, `docker-compose*.yml`, `compose*.yml`, `.dockerignore`.
- IaC and deploy: `serverless.yml`, `template.yaml`, `samconfig.toml`, `cdk.json`, `*.tf`,
  Kubernetes manifests, Helm charts.
- CI/CD workflows.
- VCS: `.gitignore`, `.gitattributes`, `CODEOWNERS`.
- Agent and editor: `.vscode/`, `.idea/`, `.claude/`, `CLAUDE.md`, `AGENTS.md`,
  `.github/copilot-instructions.md`, `.github/prompts/`, `.github/instructions/`, `.cursor/`.

## JavaScript / TypeScript (Node, Deno, Bun)

| Kind | Search hints |
|---|---|
| Exports | `module.exports`, `exports.`, `export `, `export default`, `main` / `exports` / `bin` in `package.json` |
| Handlers | `exports.handler`, `export const handler`, `export async function handler` |
| HTTP | `app.get/post/put/patch/delete/use(`, `router.`, `fastify.`, `Hono`, `@Get(` / `@Post(` (NestJS), `createServer(`, Next.js `app/**/route.ts`, `pages/api/`, WebSocket `on('connection'` |
| Messaging | `consume(`, `subscribe(`, `.on('message'`, `Consumer`, `Worker(` (BullMQ) |
| CLI | `process.argv`, `commander`, `yargs`, `meow`, `readline`, `process.stdin` |
| Files | `fs.read`, `readFileSync`, `createReadStream`, `fs.promises`, `writeFile`, `appendFile`, `createWriteStream`, `mkdir`, `os.tmpdir` |
| Cloud SDKs | `@aws-sdk/`, `aws-sdk`, `new \w+Client(`, `@google-cloud/`, `@azure/` |
| HTTP clients | `fetch(`, `axios`, `got(`, `node-fetch`, `undici`, `http.request`, `https.request`, `ky` |
| DB and caches | `pg`, `mysql2`, `mongoose`, `mongodb`, `prisma`, `sequelize`, `typeorm`, `knex`, `drizzle`, `redis`, `ioredis` |
| Queues and email | `sendMessage`, `publish(`, `produce(`, `kafkajs`, `amqplib`, `nodemailer`, SES, `twilio` |
| Logs | `console.`, `logger.`, `winston`, `pino`, `bunyan`, `debug(` |
| Processes | `child_process`, `exec(`, `execSync(`, `spawn(`, `fork(`, `execa` |
| Env reads | `process.env`, `import.meta.env`, `Deno.env.get`, `Bun.env` |
| Env loaders | `dotenv`, `dotenv/config`, `node --env-file`, Next.js / Vite / CRA automatic `.env*` loading |
| Config | `tsconfig*.json`, `babel.config.*`, `.babelrc`, `webpack.config.*`, `vite.config.*`, `rollup.config.*`, `esbuild`, `.mocharc*`, `jest.config*`, `vitest.config*`, `karma.conf*`, `.c8rc*`, `.nycrc*`, `.eslintrc*`, `eslint.config.*`, `.prettierrc*` |

## Python

| Kind | Search hints |
|---|---|
| Exports | `__all__`, public top-level functions and classes, `[project.scripts]` / `entry_points` |
| Handlers | `def lambda_handler`, `def handler(`, `functions_framework` |
| HTTP | `@app.route`, `@app.get/post`, `@router.`, `APIRouter`, `urlpatterns`, `path(`, `class .*View`, `websocket` |
| Messaging | `consumer`, `subscribe`, `@app.task` / `@shared_task` (Celery), `receive_messages`, `basic_consume` |
| CLI | `sys.argv`, `argparse`, `click`, `typer`, `input(` |
| Files | `open(`, `Path(...).read_text` / `write_text`, `shutil`, `tempfile` |
| Cloud SDKs | `boto3.client(`, `boto3.resource(`, `google.cloud`, `azure.` |
| HTTP clients | `requests.`, `httpx`, `urllib`, `aiohttp.ClientSession` |
| DB and caches | `sqlalchemy`, `psycopg`, `pymysql`, `pymongo`, `django.db`, `redis` |
| Logs | `logging.`, `logger.`, `print(`, `structlog`, `loguru` |
| Processes | `subprocess`, `os.system`, `os.popen` |
| Env reads | `os.environ`, `os.getenv`, `environ.get`, `BaseSettings` (pydantic), `decouple.config`, `env(` (django-environ) |
| Env loaders | `python-dotenv` / `load_dotenv`, `pydantic` `env_file`, Django `settings` |
| Config | `pyproject.toml`, `setup.cfg`, `setup.py`, `requirements*.txt`, `Pipfile`, `poetry.lock`, `uv.lock`, `pytest.ini`, `tox.ini`, `noxfile.py`, `ruff.toml`, `.flake8`, `mypy.ini` |

## JVM (Java, Kotlin, Scala)

| Kind | Search hints |
|---|---|
| HTTP | `@RestController`, `@RequestMapping`, `@GetMapping` / `@PostMapping`, `@Path` (JAX-RS), Ktor `routing {` |
| Messaging | `@KafkaListener`, `@SqsListener`, `@RabbitListener`, `@JmsListener`, `@Scheduled` |
| Handlers | `implements RequestHandler`, `RequestStreamHandler` |
| Egress | `RestTemplate`, `WebClient`, `HttpClient`, `OkHttpClient`, `Feign`, `software.amazon.awssdk`, `JdbcTemplate`, `jdbc:`, `@Repository`, `KafkaTemplate` |
| Logs and processes | `LoggerFactory`, `log.`, `System.out`, `Runtime.exec`, `ProcessBuilder` |
| Env reads | `System.getenv`, `System.getProperty`, `@Value("${`, `@ConfigurationProperties`, `Environment.getProperty` |
| Config | `pom.xml`, `build.gradle*`, `settings.gradle*`, `application*.yml`, `application*.properties`, `logback*.xml` |

## Go

| Kind | Search hints |
|---|---|
| HTTP and RPC | `http.HandleFunc`, `mux.Handle`, `gin.`, `echo.`, `chi.`, `fiber.`, `grpc.NewServer`, `Register\w+Server` |
| Handlers | `lambda.Start(` |
| Egress | `http.Get` / `http.Post`, `http.Client`, `github.com/aws/aws-sdk-go-v2`, `database/sql`, `sql.Open`, `gorm`, `redis.NewClient` |
| CLI and processes | `os.Args`, `flag.`, `cobra`, `os/exec` |
| Logs | `log.`, `slog.`, `zap`, `zerolog`, `fmt.Print` |
| Env reads | `os.Getenv`, `os.LookupEnv`, `viper`, `envconfig` |
| Config | `go.mod`, `go.sum`, `.golangci.yml` |

## .NET (C#, F#)

| Kind | Search hints |
|---|---|
| HTTP | `[HttpGet]` / `[HttpPost]`, `[Route(`, `ControllerBase`, `app.MapGet` / `MapPost`, gRPC `: \w+Base` |
| Messaging | `IHostedService`, `BackgroundService`, `ServiceBusProcessor`, `[FunctionName(` / `[Function(`, `TimerTrigger` |
| Egress | `HttpClient`, `IHttpClientFactory`, `AmazonS3Client` / `Amazon\w+Client`, `DbContext`, `SqlConnection`, `ConnectionMultiplexer` |
| Logs and processes | `ILogger`, `Log.`, `Console.Write`, `Process.Start` |
| Env reads | `Environment.GetEnvironmentVariable`, `IConfiguration`, `IOptions<`, `builder.Configuration[` |
| Config | `*.csproj`, `*.sln`, `global.json`, `Directory.Build.props`, `appsettings*.json`, `launchSettings.json` |

## Ruby, PHP, Rust (brief)

- **Ruby:** `get '/`, `resources :`, `routes.rb`, `ENV[`, `ENV.fetch`, `Net::HTTP`, `Faraday`,
  `ActiveRecord`, `Sidekiq`, `Gemfile`, `config/*.yml`
- **PHP:** `Route::get`, `#[Route(`, `$_GET` / `$_POST` / `$_ENV`, `getenv(`, `env(`, `Guzzle`, `PDO`,
  `composer.json`, `.env` (Laravel/Symfony load it automatically)
- **Rust:** `#[get(`, `Router::new().route(`, `std::env::var`, `dotenvy`, `reqwest`, `sqlx`,
  `tokio::process`, `Cargo.toml`, `Cargo.lock`
