import { redirect } from '@sveltejs/kit';

import type { RequestHandler } from './$types';

export const GET: RequestHandler = async ({ url, locals }) => {
	const code = url.searchParams.get('code');
	const next = url.searchParams.get('next') ?? '/home-cozy';

	if (!code || !locals.supabase) {
		redirect(303, '/login?error=auth');
	}

	const { error } = await locals.supabase.auth.exchangeCodeForSession(code);

	if (error) {
		redirect(303, '/login?error=auth');
	}

	redirect(303, next);
};
