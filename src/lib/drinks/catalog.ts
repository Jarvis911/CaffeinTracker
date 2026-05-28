import type { DrinkTemplate } from '$lib/types';

export const DRINK_CATALOG: DrinkTemplate[] = [
	{
		id: 'espresso',
		name: 'Espresso',
		emoji: '☕',
		caffeineMg: 63,
		sugarG: 0,
		calories: 3,
		category: 'coffee'
	},
	{
		id: 'latte',
		name: 'Caffè Latte',
		emoji: '🥛',
		caffeineMg: 75,
		sugarG: 12,
		calories: 190,
		category: 'coffee'
	},
	{
		id: 'cold-brew',
		name: 'Cold Brew',
		emoji: '🧊',
		caffeineMg: 155,
		sugarG: 0,
		calories: 5,
		category: 'coffee'
	},
	{
		id: 'matcha',
		name: 'Matcha Latte',
		emoji: '🍵',
		caffeineMg: 70,
		sugarG: 14,
		calories: 180,
		category: 'tea'
	},
	{
		id: 'green-tea',
		name: 'Green Tea',
		emoji: '🫖',
		caffeineMg: 28,
		sugarG: 0,
		calories: 2,
		category: 'tea'
	},
	{
		id: 'energy',
		name: 'Energy Drink',
		emoji: '⚡',
		caffeineMg: 160,
		sugarG: 27,
		calories: 110,
		category: 'energy'
	},
	{
		id: 'cola',
		name: 'Cola',
		emoji: '🥤',
		caffeineMg: 34,
		sugarG: 39,
		calories: 140,
		category: 'soda'
	},
	{
		id: 'decaf',
		name: 'Decaf Coffee',
		emoji: '🌙',
		caffeineMg: 4,
		sugarG: 0,
		calories: 2,
		category: 'coffee'
	},
	{
		id: 'chai',
		name: 'Chai Latte',
		emoji: '🫚',
		caffeineMg: 50,
		sugarG: 42,
		calories: 240,
		category: 'tea'
	},
	{
		id: 'bubble-tea',
		name: 'Brown Sugar Boba',
		emoji: '🧋',
		caffeineMg: 45,
		sugarG: 50,
		calories: 320,
		category: 'other'
	},
	{
		id: 'jujube-soup',
		name: 'Jujube Herbal Soup',
		emoji: '🥣',
		imageUrl: '/images/drinks/jujube-herbal-soup.webp',
		caffeineMg: 0,
		sugarG: 12,
		calories: 80,
		category: 'tea'
	},
	{
		id: 'taro-boba',
		name: 'Taro Bubble Tea',
		emoji: '🧋',
		imageUrl: '/images/drinks/taro-bubble-tea.webp',
		caffeineMg: 25,
		sugarG: 45,
		calories: 350,
		category: 'other'
	},
	{
		id: 'teddy-mocha',
		name: 'Teddy Bear Mocha',
		emoji: '☕',
		imageUrl: '/images/drinks/teddy-bear-mocha.webp',
		caffeineMg: 85,
		sugarG: 35,
		calories: 280,
		category: 'coffee'
	},
	{
		id: 'watermelon-passion',
		name: 'Watermelon Passionfruit',
		emoji: '🍉',
		imageUrl: '/images/drinks/watermelon-passionfruit-drink.webp',
		caffeineMg: 0,
		sugarG: 30,
		calories: 120,
		category: 'other'
	},
	{
		id: 'dalgona-latte',
		name: 'Whipped Dalgona Latte',
		emoji: '🥛',
		imageUrl: '/images/drinks/whipped-dalgona-latte.webp',
		caffeineMg: 120,
		sugarG: 25,
		calories: 210,
		category: 'coffee'
	}
];

export function getDrinkById(id: string): DrinkTemplate | undefined {
	return DRINK_CATALOG.find((d) => d.id === id);
}
