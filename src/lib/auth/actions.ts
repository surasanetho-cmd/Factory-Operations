"use server";

import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

export type SignInState = {
  error?: string;
};

function mapAuthError(message: string, email: string) {
  const lower = message.toLowerCase();

  if (lower.includes("invalid login credentials") || lower.includes("invalid credentials")) {
    return `ไม่พบบัญชี ${email} หรือรหัสผ่านไม่ถูกต้อง — ต้องสร้าง user ใน Supabase Auth ก่อน (ดูคำแนะนำด้านล่าง)`;
  }

  if (lower.includes("email not confirmed")) {
    return "อีเมลยังไม่ได้ยืนยัน — เปิด Supabase Auth แล้วตั้ง email_confirm หรือปิด email confirmation";
  }

  return message;
}

export async function signInWithPassword(
  _prevState: SignInState,
  formData: FormData,
): Promise<SignInState> {
  const email = String(formData.get("email") ?? "").trim();
  const password = String(formData.get("password") ?? "");

  if (!email || !password) {
    return { error: "Email and password are required." };
  }

  try {
    const supabase = await createClient();
    const { error } = await supabase.auth.signInWithPassword({ email, password });

    if (error) {
      return { error: mapAuthError(error.message, email) };
    }
  } catch (cause) {
    const message =
      cause instanceof Error ? cause.message : "Unable to reach Supabase. Check Vercel env vars.";
    return { error: message };
  }

  redirect("/dashboard");
}

export async function signOut() {
  const supabase = await createClient();
  await supabase.auth.signOut();
  redirect("/login");
}
