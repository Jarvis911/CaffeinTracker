export type FitnessProviderId =
	| 'apple_health'
	| 'google_fit'
	| 'fitbit'
	| 'garmin'
	| 'samsung_health'
	| 'manual';

export interface HealthSnapshot {
	restingHeartRate: number;
	sleepHours: number;
	steps: number;
	activeMinutes: number;
	stressLevel: 'low' | 'medium' | 'high';
	hydrationMl: number;
	updatedAt: string;
}

export interface UserProfile {
	name: string;
	dailyCaffeineLimitMg: number;
	sugarSensitivity: 'low' | 'medium' | 'high';
	preferredDrinkIds: string[];
}

export interface DrinkTemplate {
	id: string;
	name: string;
	emoji: string;
	imageUrl?: string;
	caffeineMg: number;
	sugarG: number;
	calories: number;
	category: 'coffee' | 'tea' | 'energy' | 'soda' | 'other';
}

export interface LoggedDrink {
	id: string;
	drinkId: string;
	at: string;
	amount: number;
}

export interface DrinkRecommendation {
	drink: DrinkTemplate;
	score: number;
	reason: string;
	tweaks?: string[];
}

export interface FitnessProvider {
	id: FitnessProviderId;
	name: string;
	emoji: string;
	description: string;
	/** OAuth or native bridge — not available in pure web demo */
	connectionType: 'oauth' | 'native' | 'manual';
	connected: boolean;
}
