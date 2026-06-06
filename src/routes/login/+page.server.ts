import { redirect } from '@sveltejs/kit';

import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals, url }) => {
	const { session } = await locals.safeGetSession();

	if (session) {
		const next = url.searchParams.get('next') ?? '/home-cozy';
		redirect(303, next);
	}
};
