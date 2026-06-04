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
		padding: 0.85rem 1rem;
		border-radius: var(--btn-radius);
		border: 3.5px solid var(--color-btn-border);
		background: 
			linear-gradient(rgba(250, 240, 221, 0.9), rgba(250, 240, 221, 0.9)),
			url('/images/minecraft_green_planks.png');
		background-size: auto, 96px;
		box-shadow:
			inset 0 3px 0 rgba(255, 255, 255, 0.85),
			inset 0 -5px 0 rgba(0, 0, 0, 0.2),
			0 5px 0 var(--color-btn-border);
		text-align: left;
		cursor: pointer;
		transition:
			transform 0.1s ease,
			box-shadow 0.1s ease,
			filter 0.15s ease;
	}

	.provider.connected {
		background: url('/images/minecraft_green_planks.png');
		background-size: 96px;
		box-shadow:
			inset 0 3px 0 rgba(255, 255, 255, 0.85),
			inset 0 -5px 0 rgba(0, 0, 0, 0.25),
			0 5px 0 var(--color-btn-border);
	}

	.provider:hover {
		filter: brightness(1.1);
	}

	.provider:active {
		transform: translateY(5px);
		box-shadow:
			inset 0 2px 0 rgba(255, 255, 255, 0.85),
			inset 0 -2px 0 rgba(0, 0, 0, 0.2),
			0 0px 0 var(--color-btn-border);
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
		color: var(--color-text);
	}

	.provider.connected .info strong {
		color: var(--color-text);
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
		border: 1.5px solid var(--color-border);
		font-size: 0.65rem;
		font-weight: 700;
		text-transform: uppercase;
		background: var(--color-wood-tan);
		color: var(--color-text);
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
		font-family: var(--font-display);
		font-weight: 600;
		color: #ffffff;
		text-shadow: 1.5px 1.5px 0 var(--color-btn-border);
		background-image: url('/images/minecraft_green_planks.png');
		background-size: 80px;
		border: 3px solid var(--color-btn-border);
		border-radius: var(--btn-radius);
		padding: 0.35rem 0.65rem;
		cursor: pointer;
		box-shadow:
			inset 0 2px 0 rgba(255, 255, 255, 0.85),
			inset 0 -3px 0 rgba(0, 0, 0, 0.3),
			0 3.5px 0 var(--color-btn-border);
		font-size: 0.7rem;
		transition: transform 0.1s ease, box-shadow 0.1s ease, filter 0.15s ease;
	}

	.preset:hover {
		filter: brightness(1.15);
	}

	.preset:active {
		transform: translateY(3.5px);
		box-shadow:
			inset 0 2px 0 rgba(255, 255, 255, 0.85),
			inset 0 -2px 0 rgba(0, 0, 0, 0.3),
			0 0px 0 var(--color-btn-border);
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
		background: rgba(0, 0, 0, 0.05);
		padding: 0.1rem 0.35rem;
		border-radius: 0.25rem;
	}
</style>
