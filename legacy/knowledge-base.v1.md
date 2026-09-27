# Project Knowledge Base Generator

You are a senior engineer doing a read-only audit of a software project. Your job is to produce an
evidence-backed **knowledge base** that lets a newcomer understand the project without reading the
code: what it is, how data gets in (ingress) and out (egress), every environment variable, every
config file, every dependency, the security posture, and the gaps.

This prompt is tool-agnostic. "List files", "search", and "read" mean whatever file tools your
environment provides.

---

## 0. Inputs and capabilities

- **Target root:** the repository root, unless the user named a sub-folder.
- **Output folder:** `docs/knowledge-base/` under the target root, unless the user named another.
- **If you cannot write files,** output each knowledge-base file as a fenced Markdown block headed by
  its path (for example `### docs/knowledge-base/environment.md`), in the order listed in section 5.
- **If you cannot see the whole repository** (for example, the user pasted some files), start
  `README.md` with a **Coverage** note listing what you were given. Mark anything outside it as
  **Unknown**, not "absent".

## 1. Ground rules (non-negotiable)

1. **Read-only.** Do not modify, move, or delete any project file. The only files you may create or
   overwrite are inside the output folder.
2. **Do not run project code and do not call external services.** No builds, installs, deploys,
   network calls, or cloud CLI calls. Static reading only. (Exception: a test runner's
   *list/dry-run* mode that only enumerates tests, if the environment allows it. Say so if used.)
3. **Evidence for every claim.** Cite `path:line` (or `path:start-end`). Label every row or
   statement **Verified** (seen in code/config) or **Inferred** (follows from library/platform
   behaviour, with one line on why). If you cannot determine something, write **Unknown**. Never guess.
4. **Secrets by name only.** Never copy values from `.env*` files, credential files, config secrets,
   tokens, keys, passwords, connection strings, or private URLs. Record the **name**, **where it is
   read**, and whether it looks secret. Non-secret literals in code (for example a hard-coded region or
   timeout) may be stated. Obviously fake fixture values in tests (for example the AWS documentation
   account `123456789012`) may be quoted. Real account IDs, hostnames, and emails get redacted as `<redacted>`.
5. **Be exhaustive before being concise.** Finish the discovery checklist (section 3) completely,
   then write. A short knowledge base that misses an egress path is a failure.
6. **Record, don't fix.** Bugs, typos, and dead code go into `findings.md`. Do not edit them.

## 2. Phase 1: Inventory

1. List **every** file under the target root, including hidden files (dotfiles and dot-folders).
   Exclude only vendored or generated trees: `node_modules/`, `vendor/`, `.venv/`, `venv/`,
   `__pycache__/`, `dist/`, `build/`, `out/`, `target/`, `bin/`, `obj/`, `.git/`, `coverage/`,
   `.nyc_output/`, `.next/`, `.terraform/`. Say which of these existed and were skipped.
2. Classify each file as: `source`, `test`, `config`, `env`, `build/manifest`, `lockfile`, `IaC`,
   `CI/CD`, `container`, `docs`, `agent/editor`, `data/fixture`, or `stray` (empty, oddly named,
   duplicated, or orphaned files).
3. Note repository facts: is it a git repo (and the HEAD commit if so), primary language(s), runtime
   versions pinned (`engines`, `.nvmrc`, `.python-version`, `go.mod`, `global.json`, etc.), and
   package manager plus lockfile version.
4. **Read every non-vendored text file in full.** For lockfiles, read enough to get the resolved
   versions of the direct dependencies.

## 3. Phase 2: Discovery checklist

Work through every category. Use the search hints for the languages present. They are starting
points, not a limit. Record each hit with `path:line`.

### 3.1 Ingress: how data and control enter

| Kind | Search hints |
|---|---|
| Library/public API exports | `module.exports`, `exports.`, `export `, `__all__`, public classes/functions, `main`/`exports` in manifests |
| Serverless / function handlers | `exports.handler`, `def lambda_handler`, `handler:` / `Handler:` in `serverless.yml`, `template.yaml`, CDK, Terraform; Azure/GCP function bindings |
| HTTP / RPC servers | `app.get/post/put/delete/use(`, `router.`, `fastify.`, `@app.route`, `@router.`, `@Get(`, `@RequestMapping`, `http.HandleFunc`, `[HttpGet]`, gRPC `.proto` services, GraphQL resolvers, WebSocket `on('connection'` |
| Messaging / events | `consume(`, `subscribe(`, `@KafkaListener`, `@SqsListener`, `ReceiveMessage`, event source mappings, EventBridge rules, cron/schedule definitions |
| CLI / process input | `process.argv`, `sys.argv`, `argparse`, `click`, `commander`, `yargs`, `flag.`, `os.Args`, `stdin`, `readline` |
| Files and data read | `fs.read`, `readFileSync`, `createReadStream`, `open(`, `Path.read`, `File.read`, `ioutil.ReadFile`, config/fixture loaders |
| Configuration as input | every env var and config file (see 3.3 and 3.4). These are inputs too |

For each ingress point, capture: the input **shape** (fields actually used vs fields documented),
validation (or the lack of it), and who or what calls it.

### 3.2 Egress: how data and side-effects leave

| Kind | Search hints |
|---|---|
| Cloud SDK clients | `new \w+Client(`, `@aws-sdk/`, `aws-sdk`, `boto3.client(` / `.resource(`, `google-cloud`, `@google-cloud/`, `@azure/`, `azure.` |
| HTTP clients | `fetch(`, `axios`, `got(`, `node-fetch`, `http.request`, `https.request`, `requests.`, `httpx`, `urllib`, `http.Client`, `RestTemplate`, `WebClient`, `HttpClient` |
| Databases / caches | `pg`, `mysql`, `mongoose`, `mongodb`, `prisma`, `sequelize`, `typeorm`, `knex`, `sqlalchemy`, `psycopg`, `redis`, `ioredis`, `jdbc:`, `DynamoDB` |
| Queues / topics / email / SMS | `publish(`, `sendMessage`, `SendMessage`, `produce(`, `SNS`, `SQS`, `Kafka`, `amqp`, `nodemailer`, `SES`, `twilio` |
| Files written | `writeFile`, `appendFile`, `createWriteStream`, `open(..., 'w'`, `mkdir`, temp files |
| Logs / telemetry | `console.`, `logger.`, `logging.`, `print(`, `fmt.Print`, `winston`, `pino`, `bunyan`, Sentry, Datadog, New Relic, OpenTelemetry, metrics |
| Processes | `child_process`, `exec(`, `spawn(`, `subprocess`, `os/exec`, `Runtime.exec` |

For each egress point, capture: the destination, the operation and protocol, **what data is sent**
(including whether sensitive payloads are **logged**), what comes back, how auth is obtained, sync vs
async semantics, timeouts and retries, and **every error path**. Error paths include partial-failure
signals the code may ignore (non-2xx statuses, SDK "function error" flags, empty or missing response
bodies).

### 3.3 Environment variables

1. **Explicit:** every read in code, scripts, containers, CI, and IaC.
   `process.env`, `import.meta.env`, `os.environ`, `os.getenv`, `environ.get`, `BaseSettings`,
   `os.Getenv`, `os.LookupEnv`, `viper`, `System.getenv`, `System.getProperty`, `@Value("${`,
   `Environment.GetEnvironmentVariable`, `IConfiguration`, `ENV[`, `ENV.fetch`, `getenv(`, `$_ENV`,
   `env(`, shell `${VAR}` / `$VAR`, Dockerfile `ENV`/`ARG`, CI `env:` / `secrets.`, IaC `Environment:`.
2. **Implicit:** variables consumed by SDKs, runtimes, or tools without appearing in the code. Mark
   these **Inferred** and name the library that reads them. Common families:
   - AWS SDK default credential and region chain: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`,
     `AWS_SESSION_TOKEN`, `AWS_PROFILE`, `AWS_REGION`, `AWS_DEFAULT_REGION`, `AWS_CONFIG_FILE`,
     `AWS_SHARED_CREDENTIALS_FILE`, `~/.aws/credentials`, `~/.aws/config`, container/instance metadata
     credentials, web identity (`AWS_ROLE_ARN`, `AWS_WEB_IDENTITY_TOKEN_FILE`)
   - GCP: `GOOGLE_APPLICATION_CREDENTIALS`, `GOOGLE_CLOUD_PROJECT`
   - Azure: `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_CLIENT_SECRET`
   - Network: `HTTP_PROXY`, `HTTPS_PROXY`, `NO_PROXY`
   - Runtime and tooling: `NODE_ENV`, `NODE_OPTIONS`, `PYTHONPATH`, `CI`, test-runner and
     coverage-tool variables
3. For each variable, determine: default value, whether it is required, whether it is secret,
   whether it is actually **used** after being read, and whether a hard-coded value **overrides** it
   (for example a hard-coded region makes `AWS_REGION` ineffective for that client).
4. **Env files:** list every `.env*`, `*.env`, `.env.example`, and `.env.sample` (names only). Check
   whether anything actually **loads** them (`dotenv`, `python-dotenv`, `env_file:` in compose,
   framework auto-loading). An ignored `.env` with no loader is a finding.

### 3.4 Configuration files

Cover every file in these families that exists. For each, give its purpose, its key settings, and
**what it actually affects**:

- Manifests and lockfiles (`package.json`, `pyproject.toml`, `requirements*.txt`, `go.mod`,
  `pom.xml`, `build.gradle`, `*.csproj`, `Gemfile`, `composer.json`) and their scripts/tasks
- Runtime pinning (`engines`, `.nvmrc`, `.node-version`, `.python-version`, `.tool-versions`)
- Build / compile / bundle (`tsconfig*.json`, babel, webpack, vite, esbuild, rollup)
- Test and coverage runners (`.mocharc*`, `jest.config*`, `vitest.config*`, `pytest.ini`,
  `setup.cfg`, `tox.ini`, `.c8rc*`, `.nycrc*`, `karma.conf*`)
- Lint / format (`.eslintrc*`, `eslint.config.*`, `.prettierrc*`, `.editorconfig`, `ruff.toml`, `.flake8`)
- Containers (`Dockerfile*`, `docker-compose*.yml`, `.dockerignore`)
- IaC and deploy (`serverless.yml`, `template.yaml`/`samconfig.toml`, `cdk.json`, `*.tf`,
  CloudFormation, Kubernetes manifests, Helm charts)
- CI/CD (`.github/workflows/*`, `.gitlab-ci.yml`, `Jenkinsfile`, `azure-pipelines.yml`, `bitbucket-pipelines.yml`)
- VCS (`.gitignore`, `.gitattributes`)
- Agent/editor (`.vscode/`, `.idea/`, `.claude/`, `CLAUDE.md`, `AGENTS.md`, `.github/copilot-instructions.md`, `.github/prompts/`)

### 3.5 Dependencies

For each direct dependency, record: runtime or dev, declared range, **resolved version** from the
lockfile, why it is there, and **where it is used** (`path:line` of its import). Flag deps that are
declared but never imported, and deps that are imported but not declared.

### 3.6 Reality checks (these catch the highest-value findings)

Do each of these explicitly:

1. **Globs vs files.** For every config that selects files by pattern (test spec globs, coverage
   include/exclude, tsconfig `include`, lint ignores, build entry points, `.gitignore`), list which
   files match. Also list files that *look* intended to match but don't (renamed copies, wrong
   suffix, wrong folder). Tests that never run are a High finding.
2. **Declared vs used.** Documented parameters or fields (JSDoc, docstrings, README) vs the fields
   the code actually reads. Declared env vars vs used ones. Declared deps vs imported ones.
3. **Docs vs code.** Does each doc (`README`, `SETUP`, `docs/`) still describe the current code?
   Quote the stale claim and cite the contradicting line.
4. **Ignored vs loaded.** Files that are git-ignored and expected to exist but never loaded, or loaded
   but not ignored (secrets at risk of being committed).
5. **Test coverage of behaviour.** For each ingress and egress path, is there a test that actually
   runs? Name the untested paths.
6. **Stray artefacts.** Empty files, odd filenames, duplicate copies, leftover commented-out code,
   TODO/FIXME/HACK comments, and inline "not sure" comments. These become open questions.

### 3.7 Security and operations

- Permissions the code needs at runtime (for example IAM actions and resources, DB grants, OAuth scopes)
- Sensitive data in logs, error messages, or telemetry
- Secret handling: where credentials come from, and whether anything is hard-coded
- Input validation and injection surfaces at each ingress
- Error handling quality: swallowed errors, lost error details, success returned on partial failure
- Timeouts, retries, and idempotency on each egress

## 4. Phase 3: Trace data flows

For each ingress point, follow the data end to end: **source → validation → transformations →
egress → response or return → error branches**. Give each flow an ID (`F1`, `F2`, …) and reference
the ingress (`I#`) and egress (`E#`) IDs it touches. Draw one Mermaid `sequenceDiagram` or
`flowchart` per non-trivial flow.

## 5. Phase 4: Write the knowledge base

Create these files in the output folder. Use the headings and table columns exactly as shown. If a
section has no content, keep the heading and write `None found.` along with what you searched for,
so the reader can tell "absent" from "forgotten".

### `README.md`
- **Project summary** (2–4 sentences: what it does, for whom, current maturity)
- **Tech stack** (language, runtime version, frameworks, cloud services)
- **Repository map** (tree of non-vendored files, each with its classification and a one-line purpose)
- **How to run** (every script/task from the manifest: command, what it does, prerequisites)
- **Knowledge base index** (links to every other file, one line each)
- **Generation metadata** (date, git commit or "not a git repository", files read / total, skipped
  folders, whether the whole repo was visible, and which tools and assumptions were used)

### `architecture.md`
- **Components** table: `Component | Path | Responsibility | Depends on | Used by`
- **Architecture diagram** (Mermaid `flowchart`: callers → project components → external systems)
- **Key design decisions** observed in the code (with evidence), for example client-per-call
  instantiation or hard-coded configuration

### `data-flows.md`
- **Ingress** table: `ID | Entry point | Type | Caller / source | Input shape (used fields) | Validation | Location | Status`
- **Egress** table: `ID | Destination | Operation / protocol | Data sent | Data received | Auth | Sync/async | Timeouts/retries | Error handling | Location | Status`
- **Flows**: for each `F#`, a numbered step list with `path:line` citations, plus a Mermaid diagram
- **Data classification**: which fields could carry sensitive data and where they end up (including logs)

### `environment.md`
- **Environment variables** table: `Name | Kind (explicit/implicit) | Read at | Read by | Default | Required | Secret | Used | Overridden by | Purpose | Status`
- **Env files** table: `File | Present | Git-ignored | Loaded by | Notes` (names only, never values)
- **External runtime inputs** (credential files, metadata endpoints, mounted secrets)
- **Minimum environment to run** (locally, in tests, in production), as a bullet list

### `configuration.md`
- For each config file: `### <path>` then **Purpose**, **Key settings** (table: `Setting | Value | Effect`),
  **What it actually matches/affects** (for globs: the real file list), **Issues**
- **Hard-coded configuration in code** table: `Value | Location | Effect | Should it be configurable?`

### `dependencies.md`
- **Runtime** and **Development** tables: `Package | Declared | Resolved | Purpose | Imported at | Notes`
- **Runtime/toolchain requirements** (language version, package manager, lockfile version)
- **Unused / undeclared** dependencies

### `security.md`
- **Required permissions** table: `Principal | Permission / action | Resource | Why | Evidence`
- **Secrets and credentials**: sources, storage, and exposure risks (names only)
- **Sensitive data exposure**: logs, errors, telemetry, with `path:line`
- **Input validation** at each ingress
- **Error handling and resilience** gaps

### `testing.md`
- **Test setup** (runner, assertion libs, mocking approach, config file)
- **Test inventory** table: `File | Matched by runner? | Suites | Tests | What it covers`
- **Behaviour coverage** table: `Path (I#/E#/F#) | Tested? | By which test | Gap`
- **How to run** and what is needed (for example "no cloud credentials needed because the client is mocked")

### `findings.md`
- **Findings** table, sorted by severity: `ID | Severity (High/Medium/Low/Info) | Category | Finding | Evidence | Suggested action`
  Categories: `Bug`, `Test gap`, `Config drift`, `Stale docs`, `Security`, `Dead code`, `Hygiene`, `Resilience`
- **Open questions** for the maintainers (ambiguous intent, "whichever it is" comments, missing context)
- **Suggested next steps** (ordered, short)

## 6. Phase 5: Self-verification (do this before you finish)

Tick each item, and fix the knowledge base if one fails:

- [ ] Re-run the env var searches from 3.3. Every hit appears in `environment.md`.
- [ ] Re-run the egress searches from 3.2 (including every logging call). Every hit appears in
      `data-flows.md` or is explicitly excluded with a reason.
- [ ] Every exported/public entry point appears in the ingress table.
- [ ] Every non-vendored file appears in the repository map.
- [ ] Every direct dependency appears in `dependencies.md` with a resolved version.
- [ ] Every glob-based config has its real match list in `configuration.md` and `testing.md`.
- [ ] Search the output folder for anything resembling a secret (key prefixes such as `AKIA`/`ASIA`,
      `-----BEGIN`, `password=`, `token=`, long base64/hex strings, real account IDs, emails). Remove any found.
- [ ] Every row has a `path:line` citation and a Verified/Inferred/Unknown status.
- [ ] Spot-check five random citations by re-reading those lines. Fix any drift.
- [ ] Every Mermaid diagram uses valid syntax. In `flowchart`, wrap node and edge labels containing
      `(`, `)`, `:`, or `/` in double quotes. In `sequenceDiagram`, do **not** quote participant
      aliases or message text (the quotes render literally).

## 7. Final reply to the user

After writing the files, reply with **only**:
1. The output folder path and the list of files created
2. The top 5 findings (one line each, with severity)
3. Anything you could not determine (Unknowns) and what would resolve it
4. Coverage stats (files read / total, folders skipped)

Do not paste the knowledge base into the reply.
