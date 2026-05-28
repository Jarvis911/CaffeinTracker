import type { HealthSnapshot } from '$lib/types';

/** Demo health data — replace with provider API responses after OAuth */
export function createMockHealth(overrides?: Partial<HealthSnapshot>): HealthSnapshot {
	return {
		restingHeartRate: 68,
		sleepHours: 6.5,
		steps: 6200,
		activeMinutes: 42,
		stressLevel: 'medium',
		hydrationMl: 1400,
		updatedAt: new Date().toISOString(),
		...overrides
	};
}

export const HEALTH_PRESETS: { label: string; snapshot: HealthSnapshot }[] = [
	{
		label: 'Well rested',
		snapshot: createMockHealth({
			sleepHours: 8.2,
			restingHeartRate: 62,
			stressLevel: 'low',
			activeMinutes: 55
		})
	},
	{
		label: 'Tired morning',
		snapshot: createMockHealth({
			sleepHours: 5.1,
			restingHeartRate: 74,
			stressLevel: 'high',
			activeMinutes: 20
		})
	},
	{
		label: 'Active day',
		snapshot: createMockHealth({
			sleepHours: 7,
			restingHeartRate: 65,
			steps: 11200,
			activeMinutes: 78,
			stressLevel: 'low'
		})
	}
];
