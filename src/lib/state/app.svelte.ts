import { browser } from '$app/environment';
import { createMockHealth } from '$lib/fitness/mock-health';
import { FITNESS_PROVIDERS } from '$lib/fitness/providers';
import type {
	FitnessProviderId,
	HealthSnapshot,
	LoggedDrink,
	UserProfile
} from '$lib/types';

const STORAGE_KEY = 'caffein-tracker-v1';

interface PersistedState {
	profile: UserProfile;
	health: HealthSnapshot;
	connectedProviders: FitnessProviderId[];
	logs: LoggedDrink[];
}

const defaultState: PersistedState = {
	profile: {
		name: 'Friend',
		dailyCaffeineLimitMg: 400,
		sugarSensitivity: 'medium',
		preferredDrinkIds: ['latte', 'matcha']
	},
	health: createMockHealth(),
	connectedProviders: [],
	logs: []
};

function load(): PersistedState {
	if (!browser) return structuredClone(defaultState);
	try {
		const raw = localStorage.getItem(STORAGE_KEY);
		if (!raw) return structuredClone(defaultState);
		return { ...defaultState, ...JSON.parse(raw) } as PersistedState;
	} catch {
		return structuredClone(defaultState);
	}
}

function save(data: PersistedState) {
	if (!browser) return;
	localStorage.setItem(STORAGE_KEY, JSON.stringify(data));
}

class AppState {
	profile = $state<UserProfile>(defaultState.profile);
	health = $state<HealthSnapshot>(defaultState.health);
	connectedProviders = $state<FitnessProviderId[]>(defaultState.connectedProviders);
	logs = $state<LoggedDrink[]>(defaultState.logs);

	constructor() {
		if (browser) {
			const stored = load();
			this.profile = stored.profile;
			this.health = stored.health;
			this.connectedProviders = stored.connectedProviders;
			this.logs = stored.logs;
		}
	}

	private persist() {
		save({
			profile: this.profile,
			health: this.health,
			connectedProviders: this.connectedProviders,
			logs: this.logs
		});
	}

	isProviderConnected(id: FitnessProviderId) {
		return this.connectedProviders.includes(id);
	}

	toggleProvider(id: FitnessProviderId) {
		if (this.isProviderConnected(id)) {
			this.connectedProviders = this.connectedProviders.filter((p) => p !== id);
		} else {
			this.connectedProviders = [...this.connectedProviders, id];
			if (id !== 'manual') {
				this.health = { ...createMockHealth(), updatedAt: new Date().toISOString() };
			}
		}
		this.persist();
	}

	setHealth(snapshot: HealthSnapshot) {
		this.health = { ...snapshot, updatedAt: new Date().toISOString() };
		this.persist();
	}

	updateProfile(patch: Partial<UserProfile>) {
		this.profile = { ...this.profile, ...patch };
		this.persist();
	}

	logDrink(drinkId: string, amount = 1) {
		const entry: LoggedDrink = {
			id: crypto.randomUUID(),
			drinkId,
			at: new Date().toISOString(),
			amount
		};
		this.logs = [entry, ...this.logs];
		this.persist();
	}

	removeLog(id: string) {
		this.logs = this.logs.filter((l) => l.id !== id);
		this.persist();
	}

	get providers() {
		return FITNESS_PROVIDERS.map((p) => ({
			...p,
			connected: this.connectedProviders.includes(p.id)
		}));
	}

	get hasFitnessData() {
		return this.connectedProviders.length > 0;
	}
}

export const app = new AppState();
