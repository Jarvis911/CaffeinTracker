<script lang="ts">
	import { app } from '$lib/state/app.svelte';
	import { getCaffeineStatus } from '$lib/personalization/recommendations';
	import { DRINK_CATALOG } from '$lib/drinks/catalog';

	const caffeine = $derived(getCaffeineStatus(app.profile, app.logs));

	const zenQuotes = [
		'Find beauty in the steam rising from your cup. Today\'s clarity is found in the smallest sips.',
		'A cup held with intention nourishes more than caffeine alone.',
		'The ritual matters as much as the drink itself.',
		'Breathe. Sip. Be present. The day unfolds gently.',
		'Each cup is a quiet conversation with yourself.',
		'Slow down. Your best thinking arrives with stillness.',
		'The kettle sings. The moment is yours.'
	];

	const warningQuotes = [
		'Your cup is full for today. Rest is the next ritual.',
		'Approaching your limit — perhaps water is the wiser companion now.',
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
	const fillColor = $derived(
		caffeine.percent >= 90
			? 'from-red-400 to-red-300'
			: caffeine.percent >= 75
			? 'from-amber-500 to-amber-300'
			: 'from-[#99462a] to-[#fe9572]'
	);
</script>

<svelte:head>
	<title>Ritual — Zakka Caffeine</title>
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
	<!-- ── Ceramic Bowl Section ────────────────────────────── -->
	<section class="bowl-section">
		<div class="bowl-outer">
			<!-- Ambient glow -->
			<div class="bowl-glow" aria-hidden="true"></div>

			<!-- Bowl container -->
			<div class="bowl" aria-label="Caffeine balance: {caffeine.consumed}mg of {caffeine.limit}mg">
				<!-- Liquid fill -->
				<div
					class="liquid"
					style:height="{fillPercent}%"
					aria-hidden="true"
				>
					<div class="liquid-shine" aria-hidden="true"></div>
				</div>
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
			<div class="ritual-card-header">
				<span class="material-symbols-outlined ritual-icon fill">spa</span>
				<span class="ritual-card-label">Daily Ritual</span>
			</div>

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

	/* ── Bowl Section ─────────────────────────────────────── */
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

	.bowl-glow {
		position: absolute;
		inset: 0;
		background: var(--color-surface-container);
		border-radius: 50%;
		opacity: 0.4;
		filter: blur(2rem);
		transform: scale(0.75);
	}

	.bowl {
		position: relative;
		z-index: 10;
		width: 12rem;
		height: 12rem;
		background: var(--color-surface-container-highest);
		border-radius: 50%;
		border: 4px solid rgba(197, 200, 187, 0.3);
		overflow: hidden;
		box-shadow: var(--shadow-card);
	}

	.liquid {
		position: absolute;
		bottom: 0;
		left: 0;
		width: 100%;
		background: linear-gradient(to top, var(--color-secondary), var(--color-secondary-container));
		opacity: 0.82;
		transition: height 1s cubic-bezier(0.4, 0, 0.2, 1);
	}

	.liquid-shine {
		position: absolute;
		top: 0;
		left: 0;
		width: 100%;
		height: 1rem;
		background: rgba(255, 255, 255, 0.2);
		filter: blur(4px);
	}

	.stats-badge {
		position: absolute;
		top: -0.5rem;
		right: -0.5rem;
		z-index: 20;
		width: 5rem;
		height: 5rem;
		background: var(--color-primary);
		color: var(--color-on-primary);
		border-radius: 50%;
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		box-shadow: var(--shadow-card);
		transform: rotate(12deg);
	}

	.stats-mg {
		font-family: var(--font-display);
		font-size: 1.25rem;
		font-weight: 600;
		line-height: 1;
	}

	.stats-unit {
		font-size: 0.7rem;
		font-weight: 500;
		opacity: 0.85;
	}

	.bowl-caption {
		margin-top: 1.5rem;
		text-align: center;
	}

	.bowl-label {
		font-family: var(--font-body);
		font-size: 0.75rem;
		font-weight: 600;
		letter-spacing: 0.1em;
		text-transform: uppercase;
		color: var(--color-outline);
		margin: 0 0 0.25rem;
	}

	.bowl-status {
		font-family: var(--font-display);
		font-size: 1.625rem;
		font-weight: 600;
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
		border-radius: var(--radius-xl);
		box-shadow: var(--shadow-card);
		border: 1px solid rgba(117, 120, 109, 0.1);
		padding: var(--space-gutter);
		cursor: pointer;
		text-align: left;
		transition: box-shadow 0.2s ease, transform 0.15s ease;
	}

	.ritual-card:hover {
		box-shadow: 0px 6px 24px rgba(93, 64, 55, 0.09);
	}

	.ritual-card:active {
		transform: translateY(2px);
		box-shadow: var(--shadow-press);
	}

	.ritual-card-header {
		display: flex;
		align-items: center;
		gap: 0.6rem;
		margin-bottom: 0.75rem;
	}

	.ritual-icon {
		color: var(--color-primary);
		font-size: 1.25rem;
	}

	.ritual-icon.fill {
		font-variation-settings: 'FILL' 1;
	}

	.ritual-card-label {
		font-family: var(--font-body);
		font-size: 0.875rem;
		font-weight: 600;
		letter-spacing: 0.02em;
		color: var(--color-primary);
	}

	.zen-quote {
		font-family: var(--font-body);
		font-size: 0.95rem;
		font-style: italic;
		color: var(--color-on-surface-variant);
		border-left: 2px solid var(--color-primary-fixed-dim);
		padding-left: 0.875rem;
		margin: 0 0 1rem;
		line-height: 1.6;
	}

	.ritual-card-footer {
		display: flex;
		justify-content: space-between;
		align-items: center;
		margin-bottom: 0.5rem;
	}

	.footer-hint {
		font-family: var(--font-body);
		font-size: 0.7rem;
		font-weight: 500;
		color: var(--color-outline);
		letter-spacing: 0.02em;
	}

	.progress-track {
		width: 100%;
		height: 4px;
		background: var(--color-surface-container);
		border-radius: var(--radius-full);
		overflow: hidden;
	}

	.progress-fill {
		height: 100%;
		background: var(--color-primary);
		border-radius: var(--radius-full);
		transition: width 0.8s cubic-bezier(0.4, 0, 0.2, 1);
	}

	/* ── Quick Log ────────────────────────────────────────── */
	.quick-log-section {
		width: 100%;
	}

	.quick-log-title {
		font-family: var(--font-body);
		font-size: 0.75rem;
		font-weight: 600;
		letter-spacing: 0.1em;
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
		border-radius: var(--radius-xl);
		border: 1px solid transparent;
		box-shadow: var(--shadow-card);
		cursor: pointer;
		text-align: left;
		transition: border-color 0.2s ease, transform 0.15s ease, box-shadow 0.15s ease;
	}

	.quick-drink-card:hover {
		border-color: rgba(254, 149, 114, 0.4);
		transform: translateY(-1px);
	}

	.quick-drink-card:active {
		transform: scale(0.97);
		box-shadow: var(--shadow-press);
	}

	.quick-drink-icon {
		width: 3rem;
		height: 3rem;
		border-radius: var(--radius-lg);
		background: rgba(153, 70, 42, 0.1);
		display: flex;
		align-items: center;
		justify-content: center;
		color: var(--color-secondary);
		flex-shrink: 0;
		transition: background 0.2s ease, color 0.2s ease;
	}

	.quick-drink-card:nth-child(2) .quick-drink-icon {
		background: rgba(80, 98, 56, 0.1);
		color: var(--color-primary);
	}

	.quick-drink-card:nth-child(3) .quick-drink-icon {
		background: rgba(116, 85, 75, 0.1);
		color: var(--color-tertiary);
	}

	.quick-drink-card:hover .quick-drink-icon {
		background: var(--color-secondary-container);
		color: #ffffff;
	}

	.quick-drink-card:nth-child(2):hover .quick-drink-icon {
		background: var(--color-primary);
		color: #ffffff;
	}

	.quick-drink-card:nth-child(3):hover .quick-drink-icon {
		background: var(--color-tertiary);
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
		font-size: 1rem;
		font-weight: 600;
		color: var(--color-on-surface);
	}

	.quick-drink-sub {
		font-family: var(--font-body);
		font-size: 0.75rem;
		font-weight: 500;
		color: var(--color-outline);
	}

	.custom-entry-btn {
		display: flex;
		align-items: center;
		justify-content: center;
		gap: 0.5rem;
		width: 100%;
		margin-top: 0.875rem;
		padding: 0.875rem;
		border-radius: var(--radius-full);
		border: 2px dashed rgba(117, 120, 109, 0.3);
		background: transparent;
		color: var(--color-outline);
		font-family: var(--font-body);
		font-size: 0.875rem;
		font-weight: 600;
		letter-spacing: 0.02em;
		text-decoration: none;
		transition: background 0.2s ease, border-color 0.2s ease, color 0.2s ease;
	}

	.custom-entry-btn:hover {
		background: var(--color-surface-container);
		border-color: var(--color-outline-variant);
		color: var(--color-on-surface-variant);
	}

	.custom-entry-btn .material-symbols-outlined {
		font-size: 1.25rem;
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
