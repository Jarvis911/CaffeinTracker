import { env } from '$env/dynamic/public';

export function getSupabaseUrl(): string {
	return env.PUBLIC_SUPABASE_URL ?? '';
}

export function getSupabaseAnonKey(): string {
	return env.PUBLIC_SUPABASE_ANON_KEY ?? '';
}

export function isSupabaseConfigured(): boolean {
	const url = getSupabaseUrl();
	const key = getSupabaseAnonKey();

	return Boolean(url && key && !url.includes('YOUR_PROJECT'));
}
