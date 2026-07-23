# Vercel — Auto Deploy & Login Test

**Repo:** [surasanetho-cmd/Factory-Operations](https://github.com/surasanetho-cmd/Factory-Operations)  
**Supabase:** Factory-Operations · `ilkzavjrjwjebcyitgaj` · `ap-south-1`

---

## 1. One-click import (recommended)

Open this link while logged into Vercel:

**[Import Factory-Operations on Vercel](https://vercel.com/new/clone?repository-url=https%3A%2F%2Fgithub.com%2Fsurasanetho-cmd%2FFactory-Operations&project-name=factory-operations&framework=nextjs)**

During import, add **Environment Variables** (Production + Preview):

| Name | Value | Notes |
|------|-------|-------|
| `NEXT_PUBLIC_SUPABASE_URL` | `https://ilkzavjrjwjebcyitgaj.supabase.co` | From Supabase → Settings → API |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | *(paste anon key)* | Safe for browser; RLS applies |
| `SUPABASE_SERVICE_ROLE_KEY` | *(paste service_role)* | **Server only** — optional for login test |

Framework: **Next.js** (auto-detected)  
Root directory: `/`  
Build command: `npm run build` (default)

Click **Deploy**. Vercel builds from `main` and enables **Auto Deploy** on every push.

---

## 2. Manual connect (existing Vercel project)

1. [Vercel Dashboard](https://vercel.com/dashboard) → **Add New → Project**
2. Import **surasanetho-cmd/Factory-Operations**
3. Production branch: **`main`**
4. Add env vars (table above) for **Production** and **Preview**
5. Deploy

---

## 3. Supabase Auth URLs (required for login on Vercel)

Supabase Dashboard → **Authentication → URL Configuration**

| Setting | Value |
|---------|-------|
| **Site URL** | `https://factory-operations.vercel.app` *(or your production URL)* |
| **Redirect URLs** | Add all of: |

```
http://localhost:3000/**
https://factory-operations.vercel.app/**
https://*.vercel.app/**
```

Save. Without these, sign-in may fail or redirect incorrectly on preview/production.

---

## 4. Smoke test after deploy

1. Open `https://<your-project>.vercel.app/login`
2. Sign in (e.g. `admin@factory.local` — rotate password for shared envs)
3. Expect redirect to `/dashboard`
4. Sign out works

---

## 5. Auto Deploy behavior

| Event | Vercel |
|-------|--------|
| Push to `main` | **Production** deployment |
| Push to other branches / PR | **Preview** deployment (unique URL) |

Ensure Preview env vars include the same Supabase keys unless you use a separate Supabase project for preview.

---

## 6. Troubleshooting

| Symptom | Fix |
|---------|-----|
| Login page loads but sign-in fails | Check env vars on Vercel; redeploy after adding them |
| Redirect loop | Supabase redirect URLs missing `https://*.vercel.app/**` |
| Build fails | Run `npm run build` locally; check Node 20+ on Vercel |
| 500 on protected routes | Confirm anon key is set; check Vercel **Runtime Logs** |

Local check:

```bash
cp .env.example .env.local
npm run supabase:check
npm run build
```

---

## Related

- [SUPABASE.md](../50_Integration/SUPABASE.md)
- [prompts/deployment.md](../../prompts/deployment.md)
- [docs/60-deployment/21_DEPLOYMENT_STANDARD.md](../../docs/60-deployment/21_DEPLOYMENT_STANDARD.md)
