<script lang="ts">
	import MascotHeader from '$lib/components/MascotHeader.svelte';
	import { HEALTH_PRESETS } from '$lib/fitness/mock-health';
	import { app } from '$lib/state/app.svelte';
	import type { FitnessProviderId } from '$lib/types';

	function connect(id: FitnessProviderId) {
		app.toggleProvider(id);
	}

	function applyPreset(index: number) {
		app.setHealth(HEALTH_PRESETS[index].snapshot);
		if (!app.isProviderConnected('manual')) {
			app.toggleProvider('manual');
		}
	}
</script>

<MascotHeader
	title="Fitness sync"
	subtitle="Connect apps to personalize caffeine & sugar guidance"
/>

<section class="providers fade-in">
	{#each app.providers as provider}
		<button
			type="button"
			class="provider"
			class:connected={provider.connected}
			onclick={() => connect(provider.id)}
		>
			<span class="emoji" aria-hidden="true">{provider.emoji}</span>
			<div class="info">
				<strong>{provider.name}</strong>
				<p>{provider.description}</p>
				<span class="badge">{provider.connectionType}</span>
			</div>
			<span class="status">{provider.connected ? 'Connected' : 'Connect'}</span>
		</button>
	{/each}
</section>

<section class="card-panel demo fade-in">
	<h2 class="section-title">Try demo health profiles</h2>
	<p class="hint">Simulates data you’d get from a fitness API after OAuth.</p>
	<div class="preset-row">
		{#each HEALTH_PRESETS as preset, i}
			<button type="button" class="preset" onclick={() => applyPreset(i)}>{preset.label}</button>
		{/each}
	</div>
</section>

<section class="card-panel note fade-in">
	<h2 class="section-title">Production integration</h2>
	<ul>
		<li><strong>Google Fit / Fitbit / Garmin</strong> — OAuth 2.0 + REST APIs</li>
		<li><strong>Apple Health</strong> — HealthKit via a native iOS companion app</li>
		<li>Server routes under <code>/api/fitness/*</code> will handle tokens securely</li>
	</ul>
</section>

<style>
	.providers {
		display: flex;
		flex-direction: column;
		gap: 0.65rem;
		margin-bottom: 1rem;
	}

	.provider {
		display: flex;
		align-items: center;
		gap: 0.75rem;
		width: 100%;
		padding: 1rem;
		border-radius: 1.25rem;
		border: 1px solid var(--color-border);
		background: var(--color-surface);
		box-shadow: var(--shadow-soft);
		text-align: left;
		cursor: pointer;
		transition:
			border-color 0.2s ease,
			transform 0.2s ease;
	}

	.provider.connected {
		border-color: var(--color-mint);
		background: color-mix(in srgb, var(--color-mint-soft) 40%, white);
	}

	.provider:hover {
		transform: translateY(-1px);
	}

	.emoji {
		font-size: 1.75rem;
	}

	.info {
		flex: 1;
	}

	.info strong {
		display: block;
		font-size: 0.95rem;
	}

	.info p {
		margin: 0.2rem 0 0.35rem;
		font-size: 0.75rem;
		color: var(--color-text-muted);
		line-height: 1.35;
	}

	.badge {
		display: inline-block;
		padding: 0.15rem 0.45rem;
		border-radius: 0.35rem;
		font-size: 0.65rem;
		font-weight: 700;
		text-transform: uppercase;
		background: var(--color-accent-soft);
		color: var(--color-accent-deep);
	}

	.status {
		font-size: 0.75rem;
		font-weight: 700;
		color: var(--color-accent-deep);
	}

	.provider.connected .status {
		color: var(--color-mint-deep);
	}

	.demo .hint {
		margin: 0 0 0.75rem;
		font-size: 0.8rem;
		color: var(--color-text-muted);
	}

	.preset-row {
		display: flex;
		flex-wrap: wrap;
		gap: 0.5rem;
	}

	.preset {
		padding: 0.45rem 0.75rem;
		border-radius: 999px;
		border: 1px solid var(--color-border);
		background: white;
		font-size: 0.8rem;
		font-weight: 600;
		cursor: pointer;
	}

	.preset:hover {
		background: var(--color-accent-soft);
	}

	.note ul {
		margin: 0;
		padding-left: 1.1rem;
		font-size: 0.8rem;
		color: var(--color-text-muted);
		line-height: 1.5;
	}

	.note li {
		margin-bottom: 0.35rem;
	}

	code {
		font-size: 0.75rem;
		background: var(--color-accent-soft);
		padding: 0.1rem 0.35rem;
		border-radius: 0.25rem;
	}
</style>
