import { getDrinkById } from '$lib/drinks/catalog';
import type { LoggedDrink } from '$lib/types';
import type { ToyItem } from '$lib/physics/drink-toy-box';

export function getTodayToyItems(logs: LoggedDrink[]): ToyItem[] {
	const today = new Date().toDateString();

	return logs
		.filter((log) => new Date(log.at).toDateString() === today)
		.flatMap((log) => {
			const drink = getDrinkById(log.drinkId);
			if (!drink) return [];

			return Array.from({ length: log.amount }, (_, i) => ({
				id: `${log.id}-${i}`,
				emoji: drink.emoji,
				name: drink.name,
				imageUrl: drink.imageUrl
			}));
		});
}
