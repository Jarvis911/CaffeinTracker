<script lang="ts">
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

	function getProviderIcon(emoji: string): string {
		const map: Record<string, string> = {
			'': 'monitor_heart',
			'🍎': 'health_and_safety',
			'🟢': 'fitness_center',
			'💙': 'favorite',
			'🏃': 'directions_run',
			'⌚': 'watch',
			'📱': 'smartphone'
		};
		return map[emoji] || 'monitor_heart';
	}
</script>

<svelte:head>
	<title>Fitness Sync | Zakka Caffeine</title>
</svelte:head>

<!-- Top Bar -->
<header class="top-bar">
	<div class="top-bar-inner">
		<a href="/insights" class="back-btn" aria-label="Back to Profile">
			<span class="material-symbols-outlined">arrow_back</span>
		</a>
		<h1 class="page-headline">Fitness Sync</h1>
		<div style="width:2.5rem"></div>
	</div>
</header>

<main class="connect-page fade-in">
	<p class="page-subtitle">
		Connect your health apps to receive personalized caffeine & sugar guidance based on your sleep,
		heart rate, and activity.
	</p>

	<!-- ── Provider List ─────────────────────────────────────── -->
	<section class="section-gap">
		<h2 class="section-heading">Health Providers</h2>
		<div class="provider-list">
			{#each app.providers as provider (provider.id)}
				<button
					type="button"
					class="provider-card"
					class:connected={provider.connected}
					onclick={() => connect(provider.id)}
				>
					<div class="provider-icon-wrap" class:connected={provider.connected}>
						<span class="provider-emoji" aria-hidden="true">{provider.emoji}</span>
					</div>
					<div class="provider-info">
						<strong class="provider-name">{provider.name}</strong>
						<p class="provider-desc">{provider.description}</p>
						<span class="provider-badge">{provider.connectionType}</span>
					</div>
					<div class="provider-status" class:connected={provider.connected}>
						{#if provider.connected}
							<span class="material-symbols-outlined status-icon fill">check_circle</span>
							<span class="status-label">Connected</span>
						{:else}
							<span class="status-label">Connect</span>
							<span class="material-symbols-outlined">add_circle</span>
						{/if}
					</div>
				</button>
			{/each}
		</div>
	</section>

	<!-- ── Demo Health Presets ───────────────────────────────── -->
	<section class="section-gap">
		<h2 class="section-heading">Try Demo Profiles</h2>
		<p class="section-desc">
			Simulate data you'd receive from a fitness API after connecting.
		</p>
		<div class="preset-grid">
			{#each HEALTH_PRESETS as preset, i (i)}
				<button type="button" class="preset-btn" onclick={() => applyPreset(i)}>
					<span class="material-symbols-outlined preset-icon">person</span>
					{preset.label}
				</button>
			{/each}
		</div>
	</section>

	<!-- ── Integration Notes ─────────────────────────────────── -->
	<section class="info-card">
		<div class="info-header">
			<span class="material-symbols-outlined info-icon">info</span>
			<h3 class="info-title">Production Integration</h3>
		</div>
		<ul class="info-list">
			<li><strong>Google Fit / Fitbit / Garmin</strong>: OAuth 2.0 + REST APIs</li>
			<li><strong>Apple Health</strong>: HealthKit via native iOS companion</li>
			<li>Server routes under <code>/api/fitness/*</code> handle tokens securely</li>
		</ul>
	</section>
</main>

<style>
	/* ── Top Bar ──────────────────────────────────────────── */
	.top-bar {
		background: var(--color-surface);
		border-bottom: 1px solid rgba(197, 200, 187, 0.2);
		position: sticky;
		top: 0;
		z-index: 40;
	}

	.top-bar-inner {
		display: flex;
		align-items: center;
		justify-content: space-between;
		max-width: 768px;
		margin-inline: auto;
		padding: var(--space-unit) var(--space-container);
	}

	.back-btn {
		padding: 0.5rem;
		border-radius: var(--radius-full);
		color: var(--color-on-surface-variant);
		text-decoration: none;
		display: grid;
		place-items: center;
		transition: background 0.2s ease;
	}

	.back-btn:hover {
		background: var(--color-surface-container);
	}

	.back-btn .material-symbols-outlined {
		font-size: 1.5rem;
	}

	.page-headline {
		font-family: var(--font-display);
		font-size: 1.1rem;
		font-weight: 600;
		color: var(--color-primary);
		margin: 0;
	}

	/* ── Connect Page ────────────────────────────────────── */
	.connect-page {
		max-width: 768px;
		margin-inline: auto;
		padding: 1.25rem var(--space-container) var(--space-section);
	}

	.page-subtitle {
		font-family: var(--font-body);
		font-size: 0.9rem;
		color: var(--color-on-surface-variant);
		margin: 0 0 var(--space-section);
		line-height: 1.6;
	}

	.section-gap {
		margin-bottom: var(--space-section);
	}

	.section-heading {
		font-family: var(--font-display);
		font-size: 1.1rem;
		font-weight: 600;
		color: var(--color-on-surface);
		margin: 0 0 0.75rem;
	}

	.section-desc {
		font-family: var(--font-body);
		font-size: 0.85rem;
		color: var(--color-on-surface-variant);
		margin: 0 0 0.875rem;
	}

	/* ── Provider Cards ──────────────────────────────────── */
	.provider-list {
		display: flex;
		flex-direction: column;
		gap: 0.625rem;
	}

	.provider-card {
		display: flex;
		align-items: center;
		gap: 0.875rem;
		width: 100%;
		padding: 0.875rem;
		border-radius: var(--radius-xl);
		border: 1px solid rgba(117, 120, 109, 0.12);
		background: var(--color-surface-container-lowest);
		box-shadow: var(--shadow-card);
		text-align: left;
		cursor: pointer;
		transition: border-color 0.2s ease, background 0.2s ease, transform 0.15s ease;
	}

	.provider-card:hover {
		border-color: var(--color-outline-variant);
		transform: translateY(-1px);
	}

	.provider-card:active {
		transform: scale(0.98);
		box-shadow: var(--shadow-press);
	}

	.provider-card.connected {
		background: rgba(213, 234, 181, 0.12);
		border-color: rgba(185, 206, 155, 0.4);
	}

	.provider-icon-wrap {
		width: 3rem;
		height: 3rem;
		border-radius: var(--radius-lg);
		background: var(--color-surface-container);
		display: flex;
		align-items: center;
		justify-content: center;
		flex-shrink: 0;
		transition: background 0.2s ease;
	}

	.provider-icon-wrap.connected {
		background: rgba(80, 98, 56, 0.1);
	}

	.provider-emoji {
		font-size: 1.5rem;
	}

	.provider-info {
		flex: 1;
		min-width: 0;
	}

	.provider-name {
		display: block;
		font-family: var(--font-body);
		font-size: 0.95rem;
		font-weight: 600;
		color: var(--color-on-surface);
		margin-bottom: 0.15rem;
	}

	.provider-desc {
		font-family: var(--font-body);
		font-size: 0.75rem;
		color: var(--color-on-surface-variant);
		margin: 0 0 0.35rem;
		line-height: 1.4;
	}

	.provider-badge {
		display: inline-block;
		padding: 0.1rem 0.45rem;
		border-radius: var(--radius-full);
		border: 1px solid var(--color-outline-variant);
		font-family: var(--font-body);
		font-size: 0.65rem;
		font-weight: 600;
		text-transform: uppercase;
		letter-spacing: 0.05em;
		color: var(--color-outline);
		background: var(--color-surface-container);
	}

	.provider-status {
		display: flex;
		flex-direction: column;
		align-items: center;
		gap: 0.15rem;
		flex-shrink: 0;
		color: var(--color-outline);
	}

	.provider-status.connected {
		color: var(--color-primary);
	}

	.status-icon {
		font-size: 1.375rem;
	}

	.status-icon.fill {
		font-variation-settings: 'FILL' 1;
	}

	.status-label {
		font-family: var(--font-body);
		font-size: 0.65rem;
		font-weight: 600;
		text-transform: uppercase;
		letter-spacing: 0.05em;
	}

	/* ── Demo Presets ────────────────────────────────────── */
	.preset-grid {
		display: flex;
		flex-wrap: wrap;
		gap: 0.5rem;
	}

	.preset-btn {
		display: inline-flex;
		align-items: center;
		gap: 0.4rem;
		padding: 0.5rem 1rem;
		border-radius: var(--radius-full);
		border: 1px solid var(--color-outline-variant);
		background: var(--color-surface-container-lowest);
		color: var(--color-on-surface-variant);
		font-family: var(--font-body);
		font-size: 0.8rem;
		font-weight: 600;
		cursor: pointer;
		box-shadow: var(--shadow-card);
		transition: background 0.2s ease, color 0.2s ease, border-color 0.2s ease;
	}

	.preset-btn:hover {
		background: var(--color-primary-container);
		color: var(--color-on-primary-container);
		border-color: transparent;
	}

	.preset-icon {
		font-size: 1rem;
	}

	/* ── Info Card ───────────────────────────────────────── */
	.info-card {
		background: var(--color-surface-container);
		border-radius: var(--radius-xl);
		padding: var(--space-gutter);
		border: 1px solid rgba(117, 120, 109, 0.1);
	}

	.info-header {
		display: flex;
		align-items: center;
		gap: 0.5rem;
		margin-bottom: 0.625rem;
	}

	.info-icon {
		color: var(--color-primary);
		font-size: 1.25rem;
	}

	.info-title {
		font-family: var(--font-display);
		font-size: 0.95rem;
		font-weight: 600;
		color: var(--color-on-surface);
		margin: 0;
	}

	.info-list {
		margin: 0;
		padding-left: 1.25rem;
		font-family: var(--font-body);
		font-size: 0.8rem;
		color: var(--color-on-surface-variant);
		line-height: 1.6;
	}

	.info-list li {
		margin-bottom: 0.3rem;
	}

	code {
		font-size: 0.75rem;
		background: rgba(0, 0, 0, 0.06);
		padding: 0.1rem 0.35rem;
		border-radius: var(--radius-sm);
		font-family: 'Courier New', monospace;
	}
</style>
