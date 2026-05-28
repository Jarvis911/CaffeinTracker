import { json } from '@sveltejs/kit';
import type { RequestHandler } from './$types';

/**
 * OAuth initiation stub — wire to Google Fit, Fitbit, Garmin OAuth URLs in production.
 * GET /api/fitness/google_fit/connect
 */
export const GET: RequestHandler = async ({ params }) => {
	const provider = params.provider;

	return json({
		status: 'not_implemented',
		message: `OAuth flow for ${provider} will redirect to the provider authorize URL.`,
		nextSteps: [
			'Register app with the fitness provider developer console',
			'Store CLIENT_ID and CLIENT_SECRET in environment variables',
			'Implement callback at /api/fitness/[provider]/callback',
			'Fetch health metrics and map to HealthSnapshot'
		]
	});
};
