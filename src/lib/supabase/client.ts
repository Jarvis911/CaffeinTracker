import { createBrowserClient } from '@supabase/ssr';
import type { SupabaseClient } from '@supabase/supabase-js';

import { getSupabaseAnonKey, getSupabaseUrl, isSupabaseConfigured } from './config';

let browserClient: SupabaseClient | undefined;

export function getSupabaseBrowserClient(): SupabaseClient {
	if (!isSupabaseConfigured()) {
		throw new Error('Supabase is not configured. Add PUBLIC_SUPABASE_URL and PUBLIC_SUPABASE_ANON_KEY to .env');
	}

	browserClient ??= createBrowserClient(getSupabaseUrl(), getSupabaseAnonKey());
	return browserClient;
}
