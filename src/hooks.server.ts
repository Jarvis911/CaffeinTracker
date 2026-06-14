import { createServerClient } from '@supabase/ssr';
import type { Session, User } from '@supabase/supabase-js';
import { type Handle } from '@sveltejs/kit';
import { sequence } from '@sveltejs/kit/hooks';

import { isSupabaseConfigured, getSupabaseAnonKey, getSupabaseUrl } from '$lib/supabase/config';

const supabaseHandle: Handle = async ({ event, resolve }) => {
	if (!isSupabaseConfigured()) {
		event.locals.supabase = null;
		event.locals.safeGetSession = async () => ({ session: null, user: null });
		return resolve(event);
	}

	event.locals.supabase = createServerClient(getSupabaseUrl(), getSupabaseAnonKey(), {
		cookies: {
			getAll: () => event.cookies.getAll(),
			setAll: (cookiesToSet) => {
				cookiesToSet.forEach(({ name, value, options }) => {
					event.cookies.set(name, value, { ...options, path: '/' });
				});
			}
		}
	});

	let sessionPromise: Promise<{ session: Session | null; user: User | null }> | null = null;

	event.locals.safeGetSession = () => {
		sessionPromise ??= (async () => {
			try {
				const {
					data: { session }
				} = await event.locals.supabase!.auth.getSession();

				if (!session) {
					return { session: null, user: null };
				}

				const {
					data: { user },
					error
				} = await event.locals.supabase!.auth.getUser();

				if (error) {
					return { session: null, user: null };
				}

				return {
					session: {
						access_token: session.access_token,
						refresh_token: session.refresh_token,
						expires_in: session.expires_in,
						token_type: session.token_type,
						expires_at: session.expires_at,
						user: user as User
					},
					user
				};
			} catch {
				// Network/DNS failures (e.g. ENOTFOUND) — treat as logged out
				return { session: null, user: null };
			}
		})();

		return sessionPromise;
	};

	return resolve(event, {
		filterSerializedResponseHeaders(name) {
			return name === 'content-range' || name === 'x-supabase-api-version';
		}
	});
};

const sessionHandle: Handle = async ({ event, resolve }) => {
	const { session, user } = await event.locals.safeGetSession();
	event.locals.session = session;
	event.locals.user = user;
	return resolve(event);
};

export const handle = sequence(supabaseHandle, sessionHandle);
