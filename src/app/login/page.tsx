import { redirect } from "next/navigation";
import { LoginForm } from "@/components/auth/LoginForm";
import { createClient } from "@/lib/supabase/server";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

export default async function LoginPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (user) redirect("/dashboard");

  return (
    <div className="grid min-h-screen place-items-center p-6">
      <Card className="w-full max-w-md border-[var(--app-border)] bg-[rgba(26,34,44,0.92)] text-[var(--text)] shadow-2xl">
        <CardHeader>
          <CardTitle className="text-2xl">Factory Operations</CardTitle>
          <CardDescription className="text-[var(--text-muted)]">
            Sign in with Supabase Auth
          </CardDescription>
        </CardHeader>
        <CardContent>
          <LoginForm />
        </CardContent>
      </Card>
    </div>
  );
}
