export type SceneAnchor = {
	top?: string;
	right?: string;
	bottom?: string;
	left?: string;
	width?: string;
	height?: string;
	maxWidth?: string;
};

export type SignpostLink = {
	href: string;
	label: string;
	plankClass: 'stats' | 'goals' | 'drinks';
};

export const COZY_SCENE: Record<string, SceneAnchor> = {
	character: { bottom: '15%', left: '25%', width: '30%', height: '35%' },
	dialog: { top: '15%', left: '10%', maxWidth: '55%' },
	teaQuick: { bottom: '35%', right: '32%' },
	coffeeQuick: { bottom: '15%', right: '5%' },
	signpost: { top: 'max(12px, env(safe-area-inset-top))', right: 'max(12px, env(safe-area-inset-right))' }
};

export const SIGNPOST_LINKS: SignpostLink[] = [
	{ href: '/insights', label: 'STATS 📊', plankClass: 'stats' },
	{ href: '/connect', label: 'GOALS 💗', plankClass: 'goals' },
	{ href: '/log', label: 'LOG ☕', plankClass: 'drinks' }
];

export const QUICK_DRINKS = [
	{ id: 'chai', label: 'TRÀ (50mg) 🫖', tail: 'bottom-right' as const, anchor: 'teaQuick' },
	{ id: 'latte', label: 'CAFE (75mg) ☕', tail: 'left' as const, anchor: 'coffeeQuick' }
];
