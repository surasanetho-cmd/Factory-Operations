"use client";

import { useState } from "react";
import { createClient } from "@/lib/supabase/client";
import { useRouter } from "next/navigation";

export function LoginForm() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    setError(null);
    const supabase = createClient();
    const { error: signError } = await supabase.auth.signInWithPassword({
      email,
      password,
    });
    setLoading(false);
    if (signError) {
      setError(signError.message);
      return;
    }
    router.replace("/dashboard");
    router.refresh();
  }

  const field: React.CSSProperties = {
    display: "grid",
    gap: "0.35rem",
    fontSize: "0.9rem",
    color: "var(--text-muted)",
  };
  const input: React.CSSProperties = {
    background: "var(--bg)",
    border: "1px solid var(--border)",
    borderRadius: 8,
    padding: "0.7rem 0.85rem",
    color: "var(--text)",
  };

  return (
    <form onSubmit={onSubmit} style={{ display: "grid", gap: "1rem" }}>
      <label style={field}>
        Email
        <input
          style={input}
          type="email"
          autoComplete="username"
          required
          value={email}
          onChange={(e) => setEmail(e.target.value)}
        />
      </label>
      <label style={field}>
        Password
        <input
          style={input}
          type="password"
          autoComplete="current-password"
          required
          value={password}
          onChange={(e) => setPassword(e.target.value)}
        />
      </label>
      {error ? (
        <p style={{ color: "var(--danger)", margin: 0, fontSize: "0.9rem" }}>{error}</p>
      ) : null}
      <button
        type="submit"
        disabled={loading}
        style={{
          marginTop: "0.5rem",
          background: "var(--accent)",
          color: "white",
          border: 0,
          borderRadius: 8,
          padding: "0.75rem 1rem",
          fontWeight: 600,
          cursor: loading ? "wait" : "pointer",
          opacity: loading ? 0.7 : 1,
        }}
      >
        {loading ? "Signing in…" : "Sign in"}
      </button>
    </form>
  );
}
