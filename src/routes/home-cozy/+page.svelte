<script lang="ts">
	import { app } from '$lib/state/app.svelte';
	import { getCaffeineStatus, getRecommendations } from '$lib/personalization/recommendations';
	import { DRINK_CATALOG } from '$lib/drinks/catalog';
	import HealthChip from '$lib/components/HealthChip.svelte';
	import RecommendationCard from '$lib/components/RecommendationCard.svelte';
	import { _ } from 'svelte-i18n';

	const caffeine = $derived(getCaffeineStatus(app.profile, app.logs));

	const recommendations = $derived(
		getRecommendations(app.health, app.profile, app.logs)
	);

	const zenQuotes = [
		"Find beauty in the steam rising from your cup. Today's clarity is found in the smallest sips.",
		'A cup held with intention nourishes more than caffeine alone.',
		'The ritual matters as much as the drink itself.',
		'Breathe. Sip. Be present. The day unfolds gently.',
		'Each cup is a quiet conversation with yourself.',
		'Slow down. Your best thinking arrives with stillness.',
		'The kettle sings. The moment is yours.'
	];

	const warningQuotes = [
		'Your cup is full for today. Rest is the next ritual.',
		'Approaching your limit, perhaps water is the wiser companion now.',
		'The body whispers before it shouts. Listen gently.',
		'A mindful pause serves better than another cup.'
	];

	let quoteIndex = $state(Math.floor(Math.random() * zenQuotes.length));

	const currentQuote = $derived(
		caffeine.percent >= 90
			? warningQuotes[Math.floor(quoteIndex % warningQuotes.length)]
			: zenQuotes[quoteIndex % zenQuotes.length]
	);

	function shuffleQuote() {
		quoteIndex = (quoteIndex + 1) % zenQuotes.length;
	}

	function getStatusLabel(percent: number): string {
		if (percent === 0) return 'Fresh Start';
		if (percent < 25) return 'Serene';
		if (percent < 50) return 'Gently Alert';
		if (percent < 75) return 'Well Balanced';
		if (percent < 90) return 'Approaching Limit';
		return 'Over the Threshold';
	}

	const statusLabel = $derived(getStatusLabel(caffeine.percent));

	const quickDrinks = [
		{ id: 'espresso', icon: 'coffee', label: 'Espresso', sub: '63mg · Short' },
		{ id: 'matcha', icon: 'eco', label: 'Matcha', sub: '70mg · Whisked' },
		{ id: 'green-tea', icon: 'local_cafe', label: 'Green Tea', sub: '28mg · Sencha' }
	];

	let loggedDrinkName = $state<string | null>(null);

	function logDrink(drinkId: string) {
		const drink = DRINK_CATALOG.find((d) => d.id === drinkId);
		if (!drink) return;
		app.logDrink(drinkId);
		loggedDrinkName = drink.name;
		shuffleQuote();
		setTimeout(() => {
			loggedDrinkName = null;
		}, 2200);
	}

	const fillPercent = $derived(Math.min(caffeine.percent, 100));

	// Wellness chip data derived from health snapshot
	const wellnessChips = $derived([
		{
			icon: '😴',
			label: $_('health.sleep'),
			value: `${app.health.sleepHours}h`
		},
		{
			icon: '❤️',
			label: $_('health.resting_hr'),
			value: `${app.health.restingHeartRate} bpm`
		},
		{
			icon: '👟',
			label: $_('health.steps'),
			value: app.health.steps.toLocaleString()
		},
		{
			icon: '💧',
			label: $_('health.water'),
			value: `${app.health.hydrationMl}ml`
		}
	]);
</script>

<svelte:head>
	<title>Ritual | Zakka Caffeine</title>
</svelte:head>

<!-- Top App Bar -->
<header class="top-bar">
	<div class="top-bar-inner">
		<h1 class="app-title">Zakka Caffeine</h1>
		<a href="/insights" class="profile-btn" aria-label="Profile">
			<span class="material-symbols-outlined">account_circle</span>
		</a>
	</div>
</header>

<main class="ritual-page fade-in">
	<!-- ── Beaker Progress Section ────────────────────────────── -->
	<section class="bowl-section">
		<div class="bowl-outer">
			<!-- Beaker Container -->
			<div class="beaker" aria-label="Caffeine balance: {caffeine.consumed}mg of {caffeine.limit}mg">
				<svg class="beaker-svg" viewBox="0 0 160 200" fill="none" xmlns="http://www.w3.org/2000/svg">
					<defs>
						<clipPath id="beaker-clip">
							<path d="M72,21 L88,21 L88,58 L117,158 C120,168 112,185 96,185 L64,185 C48,185 40,168 43,158 L72,58 Z"/>
						</clipPath>
					</defs>

					<!-- Glow effect background -->
					<path class="glass-bg" d="M70,20 L90,20 L90,60 L120,160 C124,175 112,188 96,188 L64,188 C48,188 36,175 40,160 L70,60 Z" fill="rgba(28, 46, 36, 0.02)"/>

					<!-- Clipped Liquid -->
					<g clip-path="url(#beaker-clip)">
						<rect class="liquid-rect" x="20" y={185 - (165 * fillPercent / 100)} width="120" height="200" fill="url(#liquid-gradient)"/>
					</g>

					<!-- Glass Contour Flask Outline -->
					<path class="glass-contour" d="M62,20 L98,20 M70,20 L70,60 L40,160 C36,175 48,188 64,188 L96,188 C112,188 124,175 120,160 L90,60 L90,20" stroke="var(--color-primary)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>

					<!-- Graduations / Measurement marks -->
					<line x1="50" y1="150" x2="58" y2="150" stroke="var(--color-outline-variant)" stroke-width="1"/>
					<line x1="57" y1="120" x2="64" y2="120" stroke="var(--color-outline-variant)" stroke-width="1"/>
					<line x1="64" y1="90" x2="70" y2="90" stroke="var(--color-outline-variant)" stroke-width="1"/>

					<text x="63" y="153" fill="var(--color-outline)" font-family="var(--font-body)" font-size="6.5" font-weight="600">100</text>
					<text x="69" y="123" fill="var(--color-outline)" font-family="var(--font-body)" font-size="6.5" font-weight="600">200</text>
					<text x="75" y="93" fill="var(--color-outline)" font-family="var(--font-body)" font-size="6.5" font-weight="600">300</text>

					<linearGradient id="liquid-gradient" x1="0%" y1="100%" x2="0%" y2="0%">
						<stop offset="0%" stop-color="var(--color-primary)"/>
						<stop offset="100%" stop-color="var(--color-primary-container)"/>
					</linearGradient>
				</svg>
			</div>

			<!-- Caffeine badge -->
			<div class="stats-badge" aria-label="{caffeine.consumed} milligrams consumed">
				<span class="stats-mg">{caffeine.consumed}</span>
				<span class="stats-unit">mg</span>
			</div>
		</div>

		<div class="bowl-caption">
			<p class="bowl-label">Current Balance</p>
			<h2 class="bowl-status">{statusLabel}</h2>
		</div>
	</section>

	<!-- ── Daily Ritual Card ──────────────────────────────── -->
	<section class="ritual-card-section section-gap">
		<button
			type="button"
			class="ritual-card"
			onclick={shuffleQuote}
			aria-label="Refresh zen quote"
		>
			<blockquote class="zen-quote">"{currentQuote}"</blockquote>

			<div class="ritual-card-footer">
				<span class="footer-hint">Last: {caffeine.consumed}mg · Goal: {caffeine.limit}mg</span>
				<span class="footer-hint">{Math.round(caffeine.percent)}% of daily limit</span>
			</div>

			<div class="progress-track" aria-hidden="true">
				<div class="progress-fill" style:width="{fillPercent}%"></div>
			</div>
		</button>
	</section>

	<!-- ── Wellness Chips (only when fitness data connected) ── -->
	{#if app.hasFitnessData}
		<section class="wellness-section section-gap">
			<h3 class="section-label">{$_('home.wellness')}</h3>
			<div class="chips-row">
				{#each wellnessChips as chip (chip.label)}
					<HealthChip icon={chip.icon} label={chip.label} value={chip.value} />
				{/each}
			</div>
		</section>
	{/if}

	<!-- ── Personalized Picks (when fitness data connected) ── -->
	{#if app.hasFitnessData && recommendations.length > 0}
		<section class="picks-section section-gap">
			<h3 class="section-label">{$_('home.picked_for_you')}</h3>
			<div class="picks-list">
				{#each recommendations.slice(0, 3) as rec (rec.drink.id)}
					<RecommendationCard item={rec} onLog={() => logDrink(rec.drink.id)} />
				{/each}
			</div>
		</section>
	{:else if !app.hasFitnessData}
		<!-- Connect prompt -->
		<section class="connect-prompt section-gap">
			<span class="material-symbols-outlined connect-icon">monitor_heart</span>
			<p class="connect-text">{$_('home.connect_prompt')}</p>
			<a href="/connect" class="btn-primary connect-btn">{$_('home.connect_btn')}</a>
		</section>
	{/if}

	<!-- ── Quick Log ─────────────────────────────────────── -->
	<section class="quick-log-section">
		<h3 class="quick-log-title">Quick Log</h3>
		<div class="quick-log-grid">
			{#each quickDrinks as drink (drink.id)}
				<button
					type="button"
					class="quick-drink-card"
					onclick={() => logDrink(drink.id)}
					aria-label="Log {drink.label}"
				>
					<div class="quick-drink-icon">
						<span class="material-symbols-outlined">{drink.icon}</span>
					</div>
					<div class="quick-drink-info">
						<span class="quick-drink-name">{drink.label}</span>
						<span class="quick-drink-sub">{drink.sub}</span>
					</div>
				</button>
			{/each}
		</div>

		<a href="/log" class="custom-entry-btn" aria-label="Browse all drinks">
			<span class="material-symbols-outlined">add</span>
			Browse All Drinks
		</a>
	</section>
</main>

<!-- Log confirmation toast -->
{#if loggedDrinkName}
	<div class="toast" role="status" aria-live="polite">
		<span class="material-symbols-outlined toast-icon fill">check_circle</span>
		<span><strong>{loggedDrinkName}</strong> added to your ritual</span>
	</div>
{/if}

<style>
	/* ── Top Bar ──────────────────────────────────────────── */
	.top-bar {
		position: sticky;
		top: 0;
		z-index: 40;
		background: var(--color-surface);
		border-bottom: 1px solid rgba(197, 200, 187, 0.2);
	}

	.top-bar-inner {
		display: flex;
		justify-content: space-between;
		align-items: center;
		max-width: 768px;
		margin-inline: auto;
		padding: var(--space-unit) var(--space-container);
	}

	.app-title {
		font-family: var(--font-display);
		font-size: 1.25rem;
		font-weight: 600;
		color: var(--color-primary);
		margin: 0;
	}

	.profile-btn {
		padding: 0.5rem;
		border-radius: var(--radius-full);
		color: var(--color-primary);
		text-decoration: none;
		display: grid;
		place-items: center;
		transition: background 0.2s ease;
	}

	.profile-btn:hover {
		background: var(--color-surface-container-low);
	}

	.profile-btn .material-symbols-outlined {
		font-size: 1.75rem;
	}

	/* ── Main Page ────────────────────────────────────────── */
	.ritual-page {
		max-width: 768px;
		margin-inline: auto;
		padding: 0 var(--space-container) var(--space-section);
	}

	/* ── Beaker Section ─────────────────────────────────────── */
	.bowl-section {
		display: flex;
		flex-direction: column;
		align-items: center;
		padding: 2.5rem 0 1.5rem;
	}

	.bowl-outer {
		position: relative;
		width: 16rem;
		height: 16rem;
		display: flex;
		align-items: center;
		justify-content: center;
	}

	.beaker {
		position: relative;
		z-index: 10;
		width: 11.5rem;
		height: 14.5rem;
		display: flex;
		align-items: center;
		justify-content: center;
	}

	.beaker-svg {
		width: 100%;
		height: 100%;
		overflow: visible;
	}

	.liquid-rect {
		transition: y 1.2s cubic-bezier(0.16, 1, 0.3, 1);
	}

	.glass-contour {
		transition: stroke 0.3s ease;
	}

	.stats-badge {
		position: absolute;
		bottom: 1.5rem;
		right: 0.5rem;
		z-index: 20;
		width: 4rem;
		height: 4rem;
		background: var(--color-secondary);
		color: var(--color-on-secondary);
		border-radius: 50%;
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		box-shadow: var(--shadow-card);
		transform: rotate(-8deg);
		border: 1px solid rgba(255, 255, 255, 0.2);
	}

	.stats-mg {
		font-family: var(--font-display);
		font-size: 1.25rem;
		font-weight: 700;
		line-height: 1;
	}

	.stats-unit {
		font-family: var(--font-body);
		font-size: 0.65rem;
		font-weight: 600;
		text-transform: uppercase;
		opacity: 0.9;
	}

	.bowl-caption {
		margin-top: 1rem;
		text-align: center;
	}

	.bowl-label {
		font-family: var(--font-body);
		font-size: 0.72rem;
		font-weight: 600;
		letter-spacing: 0.08em;
		text-transform: uppercase;
		color: var(--color-outline);
		margin: 0 0 0.15rem;
	}

	.bowl-status {
		font-family: var(--font-display);
		font-size: 1.75rem;
		font-weight: 500;
		color: var(--color-on-surface);
		margin: 0;
		letter-spacing: -0.01em;
	}

	/* ── Ritual Card ──────────────────────────────────────── */
	.ritual-card-section {
		width: 100%;
	}

	.ritual-card {
		width: 100%;
		background: var(--color-surface-container-lowest);
		border-radius: var(--radius-lg);
		box-shadow: var(--shadow-card);
		border: 1px solid rgba(28, 46, 36, 0.12);
		padding: 1.75rem var(--space-gutter) 1.5rem;
		cursor: pointer;
		text-align: center;
		transition: box-shadow 0.25s ease, border-color 0.25s ease, transform 0.15s ease;
		position: relative;
	}

	.ritual-card::before {
		content: '☘';
		display: block;
		font-size: 1.25rem;
		color: var(--color-secondary);
		margin-bottom: 0.75rem;
		line-height: 1;
	}

	.ritual-card:hover {
		border-color: var(--color-primary);
		box-shadow: 0px 6px 24px rgba(28, 46, 36, 0.06);
	}

	.ritual-card:active {
		transform: translateY(1px);
	}

	.zen-quote {
		font-family: var(--font-display);
		font-size: 1.375rem;
		font-style: italic;
		font-weight: 400;
		color: var(--color-on-surface);
		margin: 0 0 1.25rem;
		line-height: 1.5;
		padding: 0 0.5rem;
		padding-bottom: 2px;
	}

	.ritual-card-footer {
		display: flex;
		flex-direction: column;
		gap: 0.25rem;
		align-items: center;
		margin-bottom: 0.75rem;
	}

	.footer-hint {
		font-family: var(--font-body);
		font-size: 0.72rem;
		font-weight: 600;
		text-transform: uppercase;
		letter-spacing: 0.05em;
		color: var(--color-outline);
	}

	.progress-track {
		width: 100%;
		height: 3px;
		background: var(--color-surface-container);
		border-radius: var(--radius-full);
		overflow: hidden;
	}

	.progress-fill {
		height: 100%;
		background: var(--color-primary);
		border-radius: var(--radius-full);
		transition: width 0.8s cubic-bezier(0.16, 1, 0.3, 1);
	}

	/* ── Section label ────────────────────────────────────── */
	.section-label {
		font-family: var(--font-body);
		font-size: 0.72rem;
		font-weight: 600;
		letter-spacing: 0.08em;
		text-transform: uppercase;
		color: var(--color-outline);
		margin: 0 0 0.875rem;
		padding: 0 0.25rem;
	}

	/* ── Wellness Chips ──────────────────────────────────── */
	.wellness-section {
		width: 100%;
	}

	.chips-row {
		display: grid;
		grid-template-columns: repeat(2, 1fr);
		gap: 0.625rem;
	}

	@media (min-width: 480px) {
		.chips-row {
			grid-template-columns: repeat(4, 1fr);
		}
	}

	/* ── Personalized Picks ──────────────────────────────── */
	.picks-section {
		width: 100%;
	}

	.picks-list {
		display: flex;
		flex-direction: column;
		gap: 0.75rem;
	}

	/* ── Connect prompt ──────────────────────────────────── */
	.connect-prompt {
		display: flex;
		flex-direction: column;
		align-items: center;
		gap: 0.75rem;
		padding: 1.75rem var(--space-gutter);
		border-radius: var(--radius-lg);
		border: 1px dashed rgba(28, 46, 36, 0.2);
		background: var(--color-surface-container-lowest);
		text-align: center;
	}

	.connect-icon {
		font-size: 2rem;
		color: var(--color-outline);
	}

	.connect-text {
		font-family: var(--font-body);
		font-size: 0.85rem;
		color: var(--color-on-surface-variant);
		margin: 0;
		max-width: 28ch;
		line-height: 1.5;
	}

	.connect-btn {
		font-size: 0.78rem;
		padding: 0.625rem 1.25rem;
	}

	/* ── Quick Log ────────────────────────────────────────── */
	.quick-log-section {
		width: 100%;
	}

	.quick-log-title {
		font-family: var(--font-body);
		font-size: 0.72rem;
		font-weight: 600;
		letter-spacing: 0.08em;
		text-transform: uppercase;
		color: var(--color-outline);
		margin: 0 0 0.875rem;
		padding: 0 0.25rem;
	}

	.quick-log-grid {
		display: flex;
		flex-direction: column;
		gap: 0.75rem;
	}

	@media (min-width: 480px) {
		.quick-log-grid {
			display: grid;
			grid-template-columns: repeat(3, 1fr);
		}
	}

	.quick-drink-card {
		display: flex;
		align-items: center;
		gap: 0.875rem;
		background: var(--color-surface-container-lowest);
		padding: 0.875rem;
		border-radius: var(--radius-lg);
		border: 1px solid rgba(28, 46, 36, 0.12);
		box-shadow: var(--shadow-card);
		cursor: pointer;
		text-align: left;
		transition: border-color 0.2s ease, transform 0.15s ease, box-shadow 0.15s ease;
	}

	.quick-drink-card:hover {
		border-color: var(--color-primary);
		transform: translateY(-2px);
	}

	.quick-drink-card:active {
		transform: scale(0.97);
		box-shadow: var(--shadow-press);
	}

	.quick-drink-icon {
		width: 3rem;
		height: 3rem;
		border-radius: var(--radius-md);
		background: rgba(28, 46, 36, 0.04);
		display: flex;
		align-items: center;
		justify-content: center;
		color: var(--color-primary);
		flex-shrink: 0;
		transition: background 0.2s ease, color 0.2s ease;
	}

	.quick-drink-card:hover .quick-drink-icon {
		background: var(--color-primary);
		color: #ffffff;
	}

	.quick-drink-icon .material-symbols-outlined {
		font-size: 1.375rem;
	}

	.quick-drink-info {
		display: flex;
		flex-direction: column;
		gap: 0.1rem;
	}

	.quick-drink-name {
		font-family: var(--font-display);
		font-size: 1.15rem;
		font-weight: 500;
		color: var(--color-on-surface);
	}

	.quick-drink-sub {
		font-family: var(--font-body);
		font-size: 0.72rem;
		font-weight: 500;
		color: var(--color-outline);
	}

	.custom-entry-btn {
		display: inline-flex;
		align-items: center;
		justify-content: center;
		gap: 0.5rem;
		width: 100%;
		margin-top: 0.875rem;
		padding: 0.75rem;
		border-radius: var(--radius-full);
		border: 1px solid var(--color-primary);
		background: transparent;
		color: var(--color-primary);
		font-family: var(--font-body);
		font-size: 0.8rem;
		font-weight: 600;
		text-transform: uppercase;
		letter-spacing: 0.05em;
		text-decoration: none;
		transition: background 0.2s ease, color 0.2s ease;
	}

	.custom-entry-btn:hover {
		background: var(--color-primary);
		color: #ffffff;
	}

	.custom-entry-btn .material-symbols-outlined {
		font-size: 1.125rem;
	}

	/* ── Toast ────────────────────────────────────────────── */
	.toast {
		position: fixed;
		bottom: 6rem;
		left: 50%;
		transform: translateX(-50%);
		z-index: 100;
		display: flex;
		align-items: center;
		gap: 0.5rem;
		background: var(--color-inverse-surface);
		color: var(--color-inverse-on-surface);
		padding: 0.75rem 1.25rem;
		border-radius: var(--radius-full);
		box-shadow: 0px 8px 24px rgba(0, 0, 0, 0.15);
		font-family: var(--font-body);
		font-size: 0.875rem;
		white-space: nowrap;
		animation: toastIn 0.35s cubic-bezier(0.175, 0.885, 0.32, 1.275) both,
			toastOut 0.3s ease 1.8s both;
	}

	.toast-icon {
		color: var(--color-primary-fixed-dim);
		font-size: 1.125rem;
	}

	.toast-icon.fill {
		font-variation-settings: 'FILL' 1;
	}

	@keyframes toastIn {
		from {
			opacity: 0;
			transform: translateX(-50%) translateY(12px) scale(0.9);
		}
		to {
			opacity: 1;
			transform: translateX(-50%) translateY(0) scale(1);
		}
	}

	@keyframes toastOut {
		from {
			opacity: 1;
		}
		to {
			opacity: 0;
		}
	}
</style>
