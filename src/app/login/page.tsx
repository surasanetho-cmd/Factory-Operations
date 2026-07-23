import { redirect } from "next/navigation";
import { LoginForm } from "@/components/auth/LoginForm";
import { createClient } from "@/lib/supabase/server";

export default async function LoginPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (user) redirect("/dashboard");

  return (
    <div className="login-page">
      <div className="panel">
        <div className="brand">
          <h1>Factory Operations</h1>
          <p>Sign in with Supabase Auth</p>
        </div>
        <LoginForm />
      </div>
      <style>{`
        .login-page {
          min-height: 100vh;
          display: grid;
          place-items: center;
          padding: 1.5rem;
          background:
            radial-gradient(900px 500px at 80% 0%, rgba(61,139,253,0.18), transparent 60%),
            radial-gradient(700px 400px at 0% 100%, rgba(62,207,142,0.12), transparent 55%),
            var(--bg);
        }
        .panel {
          width: min(420px, 100%);
          background: rgba(26, 34, 44, 0.92);
          border: 1px solid var(--border);
          border-radius: 16px;
          padding: 1.75rem;
          box-shadow: 0 24px 60px rgba(0,0,0,0.35);
        }
        .brand h1 {
          margin: 0 0 0.35rem;
          font-size: 1.55rem;
        }
        .brand p {
          margin: 0 0 1.5rem;
          color: var(--text-muted);
        }
      `}</style>
    </div>
  );
}
