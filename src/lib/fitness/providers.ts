import type { FitnessProvider } from '$lib/types';

export const FITNESS_PROVIDERS: Omit<FitnessProvider, 'connected'>[] = [
	{
		id: 'apple_health',
		name: 'Apple Health',
		emoji: '🍎',
		description: 'Sleep, heart rate, and activity from your iPhone and Watch.',
		connectionType: 'native'
	},
	{
		id: 'google_fit',
		name: 'Google Fit',
		emoji: '💚',
		description: 'Steps, workouts, and wellness data from Android.',
		connectionType: 'oauth'
	},
	{
		id: 'fitbit',
		name: 'Fitbit',
		emoji: '⌚',
		description: 'Sleep stages, resting HR, and daily strain.',
		connectionType: 'oauth'
	},
	{
		id: 'garmin',
		name: 'Garmin Connect',
		emoji: '🏃',
		description: 'Training load, body battery, and recovery.',
		connectionType: 'oauth'
	},
	{
		id: 'samsung_health',
		name: 'Samsung Health',
		emoji: '💙',
		description: 'Stress, sleep, and activity from Galaxy devices.',
		connectionType: 'oauth'
	},
	{
		id: 'manual',
		name: 'Manual check-in',
		emoji: '✏️',
		description: 'Log how you feel when apps are not connected.',
		connectionType: 'manual'
	}
];
