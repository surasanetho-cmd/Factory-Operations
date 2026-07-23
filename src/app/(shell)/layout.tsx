import { redirect } from "next/navigation";
import { AppShell } from "@/components/shell/AppShell";
import { getSessionContext } from "@/lib/auth/session";

export default async function ShellLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const ctx = await getSessionContext();
  if (!ctx?.authenticated) redirect("/login");

  return <AppShell context={ctx}>{children}</AppShell>;
}
