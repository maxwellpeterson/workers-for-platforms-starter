# Workers for Platforms Terraform Starter

This starter provisions a minimal Workers for Platforms setup with Terraform:

- Worker: `app-gateway`
- Worker version with a dispatch namespace binding named `APPS`
- Deployment routing 100% of traffic to that version
- Dispatch namespace: `apps`
- Custom domain: `apps.<zone_name>`

## Required environment variables

Copy `.env.example` and fill in values:

```sh
cp .env.example .env
```

- `CLOUDFLARE_API_TOKEN`
- `CLOUDFLARE_ACCOUNT_ID`
- `CLOUDFLARE_ZONE_NAME`

## Usage

Install dependencies:

```sh
npm install
```

Run Terraform plan:

```sh
npm run plan
```

Apply deployment:

```sh
npm run deploy
```

`npm run plan` and `npm run deploy` load values from `.env` via `dotenv-cli`.

`npm run build` compiles `index.ts` into `build/index.js`, which is referenced by `cloudflare_worker_version`.
