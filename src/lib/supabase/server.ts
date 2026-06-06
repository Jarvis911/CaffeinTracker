import { createServerClient } from '@supabase/ssr';
import type { Cookies } from '@sveltejs/kit';

import { getSupabaseAnonKey, getSupabaseUrl } from './config';

export function createSupabaseServerClient(cookies: Cookies) {
	return createServerClient(getSupabaseUrl(), getSupabaseAnonKey(), {
		cookies: {
			getAll: () => cookies.getAll(),
			setAll: (cookiesToSet) => {
				cookiesToSet.forEach(({ name, value, options }) => {
					cookies.set(name, value, { ...options, path: '/' });
				});
			}
		}
	});
}
