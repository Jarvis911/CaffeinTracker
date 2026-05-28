import { DRINK_CATALOG } from '$lib/drinks/catalog';
import type {
	DrinkRecommendation,
	DrinkTemplate,
	HealthSnapshot,
	LoggedDrink,
	UserProfile
} from '$lib/types';

function hourOfDay(): number {
	return new Date().getHours();
}

function consumedToday(logs: LoggedDrink[], catalog: DrinkTemplate[]): {
	caffeineMg: number;
	sugarG: number;
} {
	let caffeineMg = 0;
	let sugarG = 0;
	const today = new Date().toDateString();

	for (const log of logs) {
		if (new Date(log.at).toDateString() !== today) continue;
		const drink = catalog.find((d) => d.id === log.drinkId);
		if (!drink) continue;
		caffeineMg += drink.caffeineMg * log.amount;
		sugarG += drink.sugarG * log.amount;
	}

	return { caffeineMg, sugarG };
}

function healthPenalty(health: HealthSnapshot): number {
	let penalty = 0;
	if (health.sleepHours < 6) penalty += 25;
	else if (health.sleepHours < 7) penalty += 12;
	if (health.restingHeartRate > 72) penalty += 15;
	if (health.stressLevel === 'high') penalty += 18;
	if (health.hydrationMl < 1200) penalty += 8;
	return penalty;
}

function scoreDrink(
	drink: DrinkTemplate,
	health: HealthSnapshot,
	profile: UserProfile,
	remainingCaffeine: number,
	remainingSugar: number,
	hour: number
): { score: number; reasons: string[]; tweaks: string[] } {
	let score = 100;
	const reasons: string[] = [];
	const tweaks: string[] = [];

	if (drink.caffeineMg > remainingCaffeine) {
		score -= 40;
		reasons.push('Would exceed your remaining caffeine budget');
	} else if (drink.caffeineMg <= remainingCaffeine * 0.5) {
		score += 8;
		reasons.push('Fits comfortably in today’s caffeine budget');
	}

	if (drink.sugarG > remainingSugar) {
		score -= 35;
		reasons.push('High sugar for your sensitivity today');
	} else if (drink.sugarG === 0) {
		score += 6;
	}

	if (health.sleepHours < 6 && drink.caffeineMg > 80) {
		score -= 30;
		reasons.push('Short sleep — gentler caffeine is safer');
		tweaks.push('Try half-caf or a smaller size');
	}

	if (health.restingHeartRate > 72 && drink.caffeineMg > 100) {
		score -= 22;
		reasons.push('Elevated resting heart rate');
		tweaks.push('Consider decaf or green tea');
	}

	if (hour >= 15 && drink.caffeineMg > 50) {
		score -= 20;
		reasons.push('Afternoon — caffeine may affect tonight’s sleep');
		tweaks.push('Switch to decaf or herbal after 2pm');
	}

	if (health.activeMinutes > 60 && drink.caffeineMg >= 50 && drink.caffeineMg <= 120) {
		score += 10;
		reasons.push('Good match after an active morning');
	}

	if (profile.preferredDrinkIds.includes(drink.id)) {
		score += 12;
		reasons.push('One of your favorites');
	}

	if (profile.sugarSensitivity === 'high' && drink.sugarG > 15) {
		score -= 25;
		tweaks.push('Ask for less syrup or sugar-free milk');
	}

	return {
		score: Math.max(0, Math.min(100, score)),
		reasons,
		tweaks
	};
}

export function getDailySugarCap(sensitivity: UserProfile['sugarSensitivity']): number {
	switch (sensitivity) {
		case 'low':
			return 50;
		case 'high':
			return 25;
		default:
			return 35;
	}
}

export function getRecommendations(
	health: HealthSnapshot,
	profile: UserProfile,
	logs: LoggedDrink[]
): DrinkRecommendation[] {
	const { caffeineMg, sugarG } = consumedToday(logs, DRINK_CATALOG);
	const remainingCaffeine = Math.max(0, profile.dailyCaffeineLimitMg - caffeineMg);
	const remainingSugar = Math.max(0, getDailySugarCap(profile.sugarSensitivity) - sugarG);
	const hour = hourOfDay();
	const penalty = healthPenalty(health);

	return DRINK_CATALOG.map((drink) => {
		const { score, reasons, tweaks } = scoreDrink(
			drink,
			health,
			profile,
			remainingCaffeine,
			remainingSugar,
			hour
		);
		const adjusted = Math.max(0, score - penalty * 0.15);
		const topReason =
			reasons[0] ??
			(adjusted > 70 ? 'Looks like a cozy fit for today' : 'Okay in moderation today');

		return {
			drink,
			score: Math.round(adjusted),
			reason: topReason,
			tweaks: tweaks.length ? tweaks : undefined
		};
	})
		.sort((a, b) => b.score - a.score)
		.slice(0, 5);
}

export function getCaffeineStatus(
	profile: UserProfile,
	logs: LoggedDrink[]
): { consumed: number; limit: number; percent: number } {
	const { caffeineMg } = consumedToday(logs, DRINK_CATALOG);
	const limit = profile.dailyCaffeineLimitMg;
	const percent = limit > 0 ? Math.min(100, (caffeineMg / limit) * 100) : 0;
	return { consumed: caffeineMg, limit, percent };
}
