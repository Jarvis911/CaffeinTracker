import { DRINK_CATALOG } from '$lib/drinks/catalog';
import type { LoggedDrink, UserProfile } from '$lib/types';

export interface Achievement {
	id: string;
	titleKey: string;
	descKey: string;
	icon: string;
	unlocked: boolean;
}

export function getTotalCaffeine(logs: LoggedDrink[]): number {
	let total = 0;
	for (const log of logs) {
		const drink = DRINK_CATALOG.find((d) => d.id === log.drinkId);
		if (drink) {
			total += drink.caffeineMg * log.amount;
		}
	}
	return total;
}

export function getDaysLogged(logs: LoggedDrink[]): number {
	const days = new Set(logs.map((log) => new Date(log.at).toDateString()));
	return days.size;
}

export function getGardenLevel(totalCaffeine: number): number {
	return Math.min(10, 1 + Math.floor(totalCaffeine / 500));
}

export function checkAchievements(
	logs: LoggedDrink[],
	profile: UserProfile,
	connectedProviders: string[]
): Achievement[] {
	const totalCaffeine = getTotalCaffeine(logs);
	const gardenLevel = getGardenLevel(totalCaffeine);
	
	const uniqueDrinkIds = new Set(logs.map((l) => l.drinkId));
	
	// 1. Early bird: drink logged before 8:00 AM
	const hasEarlyBird = logs.some((l) => {
		const hr = new Date(l.at).getHours();
		return hr < 8;
	});
	
	// 2. Night owl: drink logged after 8:00 PM (20:00)
	const hasNightOwl = logs.some((l) => {
		const hr = new Date(l.at).getHours();
		return hr >= 20;
	});
	
	// 3. Botanist: garden level >= 3
	const hasBotanist = gardenLevel >= 3;
	
	// 4. Healthy Connection: at least 1 provider connected
	const hasHealthyConnection = connectedProviders.length > 0;
	
	// 5. Steel Discipline: stayed under limit on any day drinks were logged
	const dailyTotals: Record<string, number> = {};
	for (const log of logs) {
		const day = new Date(log.at).toDateString();
		const drink = DRINK_CATALOG.find((d) => d.id === log.drinkId);
		if (drink) {
			dailyTotals[day] = (dailyTotals[day] || 0) + drink.caffeineMg * log.amount;
		}
	}
	const hasSteelDiscipline = Object.keys(dailyTotals).length > 0 &&
		Object.values(dailyTotals).some((total) => total <= profile.dailyCaffeineLimitMg);
		
	// 6. AI Vision: logged a drink with scanned = true
	const hasAiVision = logs.some((l) => l.scanned === true);
	
	// 7. Collector: logged 3 or more unique kinds of drinks
	const hasCollector = uniqueDrinkIds.size >= 3;

	// 8. Caffeine Hunter: total caffeine logged >= 2000mg
	const hasCaffeineHunter = totalCaffeine >= 2000;

	// 9. Tea Master: logged a tea drink
	const hasTeaMaster = logs.some((l) => {
		const drink = DRINK_CATALOG.find((d) => d.id === l.drinkId);
		return drink && drink.category === 'tea';
	});

	return [
		{
			id: 'early_bird',
			titleKey: 'profile.achievement_early_bird',
			descKey: 'profile.achievement_early_bird_desc',
			icon: '/images/achievements/early_bird.png',
			unlocked: hasEarlyBird
		},
		{
			id: 'night_owl',
			titleKey: 'profile.achievement_night_owl',
			descKey: 'profile.achievement_night_owl_desc',
			icon: '/images/achievements/night_owl.png',
			unlocked: hasNightOwl
		},
		{
			id: 'botanist',
			titleKey: 'profile.achievement_botanist',
			descKey: 'profile.achievement_botanist_desc',
			icon: '/images/achievements/botanist.png',
			unlocked: hasBotanist
		},
		{
			id: 'healthy_connection',
			titleKey: 'profile.achievement_healthy_connection',
			descKey: 'profile.achievement_healthy_connection_desc',
			icon: '/images/achievements/healthy_connection.png',
			unlocked: hasHealthyConnection
		},
		{
			id: 'steel_discipline',
			titleKey: 'profile.achievement_steel_discipline',
			descKey: 'profile.achievement_steel_discipline_desc',
			icon: '/images/achievements/steel_discipline.png',
			unlocked: hasSteelDiscipline
		},
		{
			id: 'ai_vision',
			titleKey: 'profile.achievement_ai_vision',
			descKey: 'profile.achievement_ai_vision_desc',
			icon: '/images/achievements/ai_vision.png',
			unlocked: hasAiVision
		},
		{
			id: 'collector',
			titleKey: 'profile.achievement_collector',
			descKey: 'profile.achievement_collector_desc',
			icon: '/images/achievements/collector.png',
			unlocked: hasCollector
		},
		{
			id: 'caffeine_hunter',
			titleKey: 'profile.achievement_caffeine_hunter',
			descKey: 'profile.achievement_caffeine_hunter_desc',
			icon: '/images/achievements/caffeine_hunter.png',
			unlocked: hasCaffeineHunter
		},
		{
			id: 'tea_master',
			titleKey: 'profile.achievement_tea_master',
			descKey: 'profile.achievement_tea_master_desc',
			icon: '/images/achievements/tea_master.png',
			unlocked: hasTeaMaster
		}
	];
}
