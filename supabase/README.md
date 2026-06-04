# Supabase Local Development Guide

This directory contains the infrastructure-as-code and local development configuration for our Supabase project. We manage our database schema, edge functions, and project configuration using the Supabase CLI to ensure version control and smooth deployments.

## 🚀 Prerequisites

1. **Docker Desktop:** Must be installed and running (required for local Supabase instance).
2. **Supabase CLI:**
   * macOS/Linux (Homebrew): `brew install supabase/tap/supabase`
   * Windows (Scoop): `scoop bucket add supabase https://github.com/supabase/scoop-bucket.git && scoop install supabase`
   * NPM: `npm install supabase --save-dev` or `npx supabase <command>`

---

## 💻 Local Development Workflow

Instead of making changes directly in the production dashboard, we develop locally and generate migration files.

### 1. Start the Local Database

Start the full Supabase stack locally (Database, Studio, Auth, Storage, Edge Functions).

```bash
npx supabase start

```

*Once running, you can access the local Supabase Studio at `http://localhost:54323`.*

### 2. Stop the Local Database

When you are done working:

```bash
npx supabase stop

```

---

## 🗄️ Database Migrations

Migrations represent changes to the database schema over time. All schema changes must be committed as migration files in the `supabase/migrations/` directory.

### Making Database Changes (The "Diff" Method)

1. Use the local Supabase Studio UI (`http://localhost:54323`) to create tables, add columns, or write RLS policies.
2. Generate a migration file based on the changes you just made:

```bash
npx supabase db diff -f your_descriptive_migration_name

```

1. A new `.sql` file will be created in `supabase/migrations/`. Review it, commit it to Git, and push.

### Creating an Empty Migration (Manual SQL)

If you prefer writing SQL manually:

```bash
npx supabase migration new your_descriptive_migration_name

```

### Resetting the Database

If things get messy or you want to test from a clean slate, you can wipe the local database and re-apply all migrations and `seed.sql` data:

```bash
npx supabase db reset

```

---

## 📦 Type Generation (TypeScript)

Whenever you change the database schema, update the TypeScript definitions so the frontend code stays in sync.

```bash
npx supabase gen types typescript --local > ../types/supabase.ts

```

*(Note: Adjust the output path based on where your frontend keeps its types).*

---

## 🚀 Deployment

Changes are pushed to remote environments (Staging/Production) using the CLI. This is often automated via GitHub Actions, but can be done manually if needed.

### 1. Link to Remote Project

```bash
npx supabase link --project-ref your-project-ref

```

### 2. Push Migrations

Apply your local migration files to the remote database:

```bash
npx supabase db push

```

### 3. Deploy Edge Functions

If you added or updated serverless functions in `supabase/functions/`:

```bash
npx supabase functions deploy

```

---

## ⚠️ Security Notes

* **DO NOT push the `.env` file to Git.** All secrets should remain local.
* Your `config.toml` file contains non-sensitive configuration (like auth settings and storage buckets) and **should** be committed to Git. Use environment variables inside `config.toml` for any sensitive API keys.
