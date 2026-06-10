<script lang="ts">
	import { page } from '$app/state';
	import AuthPanel from '$lib/components/auth/AuthPanel.svelte';
	import { getDailySugarCap } from '$lib/personalization/recommendations';
	import { app } from '$lib/state/app.svelte';
	import type { UserProfile } from '$lib/types';
	import { _, locale } from 'svelte-i18n';
	import {
		checkAchievements,
		getTotalCaffeine,
		getDaysLogged,
		getGardenLevel
	} from '$lib/personalization/achievements';

	// ── Stats (reactive) ──────────────────────────────────────
	const totalCaffeine = $derived(getTotalCaffeine(app.logs));
	const daysLogged = $derived(getDaysLogged(app.logs));
	const gardenLevel = $derived(getGardenLevel(totalCaffeine));
	const achievementsList = $derived(checkAchievements(app.logs, app.profile, app.connectedProviders));
	const unlockedCount = $derived(achievementsList.filter((a) => a.unlocked).length);
	const sugarCap = $derived(getDailySugarCap(app.profile.sugarSensitivity));

	// ── Profile edit ──────────────────────────────────────────
	function setSensitivity(value: UserProfile['sugarSensitivity']) {
		app.updateProfile({ sugarSensitivity: value });
	}

	function setLimit(value: number) {
		app.updateProfile({ dailyCaffeineLimitMg: value });
	}

	function setName(value: string) {
		app.updateProfile({ name: value || 'Friend' });
	}

	function toggleLanguage(newLocale: string) {
		$locale = newLocale;
		if (typeof window !== 'undefined') {
			window.localStorage.setItem('locale', newLocale);
		}
	}

	// ── View state ────────────────────────────────────────────
	type View = 'profile' | 'achievements' | 'edit';
	let activeView = $state<View>('profile');
</script>

<svelte:head>
	<title>Profile — Zakka Caffeine</title>
</svelte:head>

<!-- Top App Bar -->
<header class="top-bar">
	<div class="top-bar-inner">
		<h1 class="app-title">Zakka Caffeine</h1>
		<button class="icon-btn" aria-label="Account">
			<span class="material-symbols-outlined">account_circle</span>
		</button>
	</div>
</header>

<main class="profile-page fade-in">

	<!-- ── Profile Hero ─────────────────────────────────────── -->
	<section class="hero-section">
		<div class="avatar-ring">
			<div class="avatar-inner">
				<span class="avatar-letter">
					{app.profile.name.charAt(0).toUpperCase()}
				</span>
			</div>
		</div>
		<h2 class="user-name">{app.profile.name}</h2>
		<p class="user-tagline">Mindful Caffeine Tracking</p>
	</section>

	<!-- ── Stats Bento ──────────────────────────────────────── -->
	<section class="bento-grid">
		<div class="bento-card primary-card">
			<span class="bento-label">Daily Limit</span>
			<span class="bento-value">{app.profile.dailyCaffeineLimitMg}<span class="bento-unit">mg</span></span>
		</div>
		<div class="bento-card">
			<span class="bento-label">Days Logged</span>
			<span class="bento-value secondary-val">{daysLogged}</span>
		</div>
		<div class="bento-card">
			<span class="bento-label">Total Caffeine</span>
			<span class="bento-value">{totalCaffeine}<span class="bento-unit">mg</span></span>
		</div>
		<div class="bento-card">
			<span class="bento-label">Achievements</span>
			<span class="bento-value secondary-val">{unlockedCount}<span class="bento-unit"> / {achievementsList.length}</span></span>
		</div>
	</section>

	<!-- ── View Tabs ────────────────────────────────────────── -->
	<div class="view-tabs" role="tablist">
		<button
			type="button"
			class="view-tab"
			class:active={activeView === 'profile'}
			onclick={() => (activeView = 'profile')}
			role="tab"
			aria-selected={activeView === 'profile'}
		>
			<span class="material-symbols-outlined tab-icon">manage_accounts</span>
			Settings
		</button>
		<button
			type="button"
			class="view-tab"
			class:active={activeView === 'achievements'}
			onclick={() => (activeView = 'achievements')}
			role="tab"
			aria-selected={activeView === 'achievements'}
		>
			<span class="material-symbols-outlined tab-icon">workspace_premium</span>
			Achievements
		</button>
	</div>

	<!-- ── Settings View ────────────────────────────────────── -->
	{#if activeView === 'profile'}
		<div class="settings-view fade-in">

			<!-- Auth Panel -->
			<AuthPanel user={page.data.user} />

			<!-- Consumption Settings Group -->
			<div class="settings-label">Consumption</div>
			<div class="settings-group">
				<!-- Daily Limit -->
				<div class="settings-row limit-row">
					<div class="settings-row-lead">
						<span class="material-symbols-outlined settings-icon">coffee_maker</span>
						<div>
							<p class="settings-row-title">Daily Limit</p>
							<p class="settings-row-desc">Your soft ceiling for caffeine</p>
						</div>
					</div>
					<div class="limit-display">
						<span class="limit-value">{app.profile.dailyCaffeineLimitMg}</span>
						<span class="limit-unit">mg</span>
					</div>
				</div>
				<div class="limit-slider-row">
					<input
						type="range"
						min="100"
						max="600"
						step="25"
						value={app.profile.dailyCaffeineLimitMg}
						oninput={(e) => setLimit(Number(e.currentTarget.value))}
						aria-label="Daily caffeine limit"
					/>
					<div class="slider-labels">
						<span>100mg</span>
						<span>600mg</span>
					</div>
				</div>

				<div class="settings-divider"></div>

				<!-- Display Name -->
				<div class="settings-row">
					<div class="settings-row-lead">
						<span class="material-symbols-outlined settings-icon">badge</span>
						<div>
							<p class="settings-row-title">Display Name</p>
						</div>
					</div>
				</div>
				<div class="name-input-row">
					<input
						type="text"
						value={app.profile.name}
						oninput={(e) => setName(e.currentTarget.value)}
						placeholder="Your name"
						aria-label="Display name"
					/>
				</div>

				<div class="settings-divider"></div>

				<!-- Sugar Sensitivity -->
				<div class="settings-row">
					<div class="settings-row-lead">
						<span class="material-symbols-outlined settings-icon">water_drop</span>
						<div>
							<p class="settings-row-title">Sugar Sensitivity</p>
							<p class="settings-row-desc">Daily cap: {sugarCap}g</p>
						</div>
					</div>
				</div>
				<div class="radio-group">
					{#each ['low', 'medium', 'high'] as level (level)}
						<button
							type="button"
							class="radio-btn"
							class:active={app.profile.sugarSensitivity === level}
							onclick={() => setSensitivity(level as UserProfile['sugarSensitivity'])}
						>
							{level}
						</button>
					{/each}
				</div>
			</div>

			<!-- Atmosphere Settings Group -->
			<div class="settings-label">Language</div>
			<div class="settings-group">
				<div class="settings-row">
					<div class="settings-row-lead">
						<span class="material-symbols-outlined settings-icon">translate</span>
						<div>
							<p class="settings-row-title">Interface Language</p>
						</div>
					</div>
				</div>
				<div class="radio-group">
					<button
						type="button"
						class="radio-btn"
						class:active={$locale === 'en'}
						onclick={() => toggleLanguage('en')}
					>
						English
					</button>
					<button
						type="button"
						class="radio-btn"
						class:active={$locale === 'vi'}
						onclick={() => toggleLanguage('vi')}
					>
						Tiếng Việt
					</button>
				</div>
			</div>

			<!-- Fitness Sync Link -->
			<div class="settings-label">Integrations</div>
			<div class="settings-group">
				<a href="/connect" class="settings-row settings-link-row">
					<div class="settings-row-lead">
						<span class="material-symbols-outlined settings-icon">monitor_heart</span>
						<div>
							<p class="settings-row-title">Fitness Sync</p>
							<p class="settings-row-desc">
								{app.connectedProviders.length > 0
									? `${app.connectedProviders.length} provider(s) connected`
									: 'Connect Apple Health, Google Fit & more'}
							</p>
						</div>
					</div>
					<span class="material-symbols-outlined arrow-icon">chevron_right</span>
				</a>
			</div>

			<!-- Footer Actions -->
			<div class="footer-actions">
				<button class="btn-ghost export-btn">
					<span class="material-symbols-outlined">download</span>
					Export Intake History
				</button>
			</div>
		</div>

	<!-- ── Achievements View ─────────────────────────────────── -->
	{:else if activeView === 'achievements'}
		<div class="achievements-view fade-in">
			<div class="garden-level-card">
				<span class="material-symbols-outlined garden-icon fill">nature</span>
				<div>
					<p class="garden-label">Garden Level</p>
					<p class="garden-value">{gardenLevel}</p>
				</div>
			</div>

			<div class="achievements-list">
				{#each achievementsList as ach (ach.titleKey)}
					<div class="achievement-item" class:locked={!ach.unlocked}>
						<div class="ach-icon-wrap" class:unlocked={ach.unlocked}>
							<img src={ach.icon} alt="" class="ach-icon-img" />
							<span class="ach-status-indicator" aria-hidden="true">
								{ach.unlocked ? '✓' : '🔒'}
							</span>
						</div>
						<div class="ach-info">
							<h4 class="ach-title">{$_(ach.titleKey)}</h4>
							<p class="ach-desc">{$_(ach.descKey)}</p>
						</div>
					</div>
				{/each}
			</div>

			{#if app.hasFitnessData}
				<div class="personalize-card">
					<h3 class="personalize-title">How we personalize</h3>
					<ul class="personalize-tips">
						<li>{$_('profile.tip_sleep')}</li>
						<li>{$_('profile.tip_hr')}</li>
						<li>{$_('profile.tip_afternoon')}</li>
						<li>{$_('profile.tip_active')}</li>
					</ul>
				</div>
			{/if}
		</div>
	{/if}
</main>

<style>
	/* ── Top Bar ─────────────────────────────────────────── */
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

	.icon-btn {
		padding: 0.5rem;
		border-radius: var(--radius-full);
		border: none;
		background: transparent;
		color: var(--color-primary);
		cursor: pointer;
		display: grid;
		place-items: center;
		transition: background 0.2s ease;
	}

	.icon-btn:hover {
		background: var(--color-surface-container-low);
	}

	.icon-btn .material-symbols-outlined {
		font-size: 1.75rem;
	}

	/* ── Profile Page ────────────────────────────────────── */
	.profile-page {
		max-width: 768px;
		margin-inline: auto;
		padding: 0 var(--space-container) var(--space-section);
	}

	/* ── Hero ────────────────────────────────────────────── */
	.hero-section {
		display: flex;
		flex-direction: column;
		align-items: center;
		padding: 2rem 0 1.5rem;
		gap: 0.5rem;
	}

	.avatar-ring {
		width: 7rem;
		height: 7rem;
		border-radius: 50%;
		padding: 4px;
		background: linear-gradient(135deg, var(--color-primary), var(--color-secondary));
		margin-bottom: 0.25rem;
	}

	.avatar-inner {
		width: 100%;
		height: 100%;
		border-radius: 50%;
		background: var(--color-surface-container-lowest);
		display: flex;
		align-items: center;
		justify-content: center;
		border: 3px solid var(--color-surface);
	}

	.avatar-letter {
		font-family: var(--font-display);
		font-size: 2.5rem;
		font-weight: 600;
		color: var(--color-primary);
	}

	.user-name {
		font-family: var(--font-display);
		font-size: 1.625rem;
		font-weight: 600;
		color: var(--color-on-surface);
		margin: 0;
		letter-spacing: -0.01em;
	}

	.user-tagline {
		font-family: var(--font-body);
		font-size: 0.875rem;
		color: var(--color-on-surface-variant);
		margin: 0;
	}

	/* ── Bento Stats ─────────────────────────────────────── */
	.bento-grid {
		display: grid;
		grid-template-columns: repeat(2, 1fr);
		gap: 0.75rem;
		margin-bottom: 1.5rem;
	}

	.bento-card {
		background: var(--color-surface-container-lowest);
		border-radius: var(--radius-xl);
		box-shadow: var(--shadow-card);
		padding: var(--space-gutter);
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		text-align: center;
		gap: 0.35rem;
	}

	.primary-card {
		background: rgba(80, 98, 56, 0.06);
		border: 1px solid rgba(80, 98, 56, 0.12);
	}

	.bento-label {
		font-family: var(--font-body);
		font-size: 0.7rem;
		font-weight: 600;
		text-transform: uppercase;
		letter-spacing: 0.08em;
		color: var(--color-on-surface-variant);
	}

	.bento-value {
		font-family: var(--font-display);
		font-size: 1.375rem;
		font-weight: 600;
		color: var(--color-primary);
	}

	.secondary-val {
		color: var(--color-secondary);
	}

	.bento-unit {
		font-family: var(--font-body);
		font-size: 0.75rem;
		font-weight: 500;
		color: var(--color-outline);
	}

	/* ── View Tabs ───────────────────────────────────────── */
	.view-tabs {
		display: flex;
		gap: 0.5rem;
		margin-bottom: 1.25rem;
		background: var(--color-surface-container);
		padding: 0.25rem;
		border-radius: var(--radius-full);
	}

	.view-tab {
		flex: 1;
		display: inline-flex;
		align-items: center;
		justify-content: center;
		gap: 0.4rem;
		padding: 0.5rem 1rem;
		border-radius: var(--radius-full);
		border: none;
		background: transparent;
		color: var(--color-on-surface-variant);
		font-family: var(--font-body);
		font-size: 0.8rem;
		font-weight: 600;
		cursor: pointer;
		transition: background 0.2s ease, color 0.2s ease;
		letter-spacing: 0.02em;
	}

	.view-tab:hover {
		color: var(--color-on-surface);
	}

	.view-tab.active {
		background: var(--color-surface-container-lowest);
		color: var(--color-primary);
		box-shadow: var(--shadow-card);
	}

	.tab-icon {
		font-size: 1.125rem;
	}

	/* ── Settings View ───────────────────────────────────── */
	.settings-view {
		display: flex;
		flex-direction: column;
		gap: 0.5rem;
	}

	.settings-label {
		font-family: var(--font-body);
		font-size: 0.7rem;
		font-weight: 600;
		text-transform: uppercase;
		letter-spacing: 0.1em;
		color: var(--color-outline);
		padding: 0.5rem 0.25rem 0.2rem;
	}

	.settings-group {
		background: var(--color-surface-container-lowest);
		border-radius: var(--radius-xl);
		box-shadow: var(--shadow-card);
		overflow: hidden;
		border: 1px solid rgba(117, 120, 109, 0.08);
		margin-bottom: 0.5rem;
	}

	.settings-row {
		display: flex;
		align-items: center;
		justify-content: space-between;
		padding: var(--space-gutter);
	}

	.settings-link-row {
		text-decoration: none;
		cursor: pointer;
		transition: background 0.2s ease;
	}

	.settings-link-row:hover {
		background: var(--color-surface-container-low);
	}

	.settings-row-lead {
		display: flex;
		align-items: center;
		gap: 0.75rem;
	}

	.settings-icon {
		color: var(--color-primary);
		font-size: 1.375rem;
	}

	.settings-row-title {
		font-family: var(--font-body);
		font-size: 0.95rem;
		font-weight: 600;
		color: var(--color-on-surface);
		margin: 0;
	}

	.settings-row-desc {
		font-family: var(--font-body);
		font-size: 0.75rem;
		color: var(--color-on-surface-variant);
		margin: 0.1rem 0 0;
	}

	.settings-divider {
		height: 1px;
		background: rgba(197, 200, 187, 0.3);
		margin-inline: var(--space-gutter);
	}

	.limit-row {
		border-bottom: none;
	}

	.limit-display {
		display: flex;
		align-items: baseline;
		gap: 0.2rem;
	}

	.limit-value {
		font-family: var(--font-display);
		font-size: 1.25rem;
		font-weight: 600;
		color: var(--color-primary);
	}

	.limit-unit {
		font-family: var(--font-body);
		font-size: 0.75rem;
		color: var(--color-outline);
	}

	.limit-slider-row {
		padding: 0 var(--space-gutter) var(--space-gutter);
	}

	.slider-labels {
		display: flex;
		justify-content: space-between;
		margin-top: 0.35rem;
	}

	.slider-labels span {
		font-family: var(--font-body);
		font-size: 0.65rem;
		color: var(--color-outline);
	}

	.name-input-row {
		padding: 0 var(--space-gutter) var(--space-gutter);
	}

	/* Radio/option buttons */
	.radio-group {
		display: flex;
		gap: 0.5rem;
		padding: 0 var(--space-gutter) var(--space-gutter);
	}

	.radio-btn {
		flex: 1;
		padding: 0.5rem;
		border-radius: var(--radius-lg);
		border: 1px solid var(--color-outline-variant);
		background: transparent;
		color: var(--color-on-surface-variant);
		font-family: var(--font-body);
		font-size: 0.8rem;
		font-weight: 600;
		cursor: pointer;
		text-transform: capitalize;
		transition: background 0.2s ease, color 0.2s ease, border-color 0.2s ease;
	}

	.radio-btn:hover {
		background: var(--color-surface-container);
	}

	.radio-btn.active {
		background: var(--color-primary);
		color: var(--color-on-primary);
		border-color: var(--color-primary);
	}

	.arrow-icon {
		color: var(--color-outline);
		font-size: 1.25rem;
	}

	/* Footer actions */
	.footer-actions {
		display: flex;
		flex-direction: column;
		gap: 0.5rem;
		margin-top: 0.5rem;
	}

	.export-btn {
		width: 100%;
		padding: var(--space-gutter);
		display: flex;
		align-items: center;
		justify-content: center;
		gap: 0.5rem;
		border-radius: var(--radius-xl);
	}

	/* ── Achievements View ─────────────────────────────────── */
	.achievements-view {
		display: flex;
		flex-direction: column;
		gap: 1rem;
	}

	.garden-level-card {
		display: flex;
		align-items: center;
		gap: 1rem;
		background: rgba(80, 98, 56, 0.06);
		border: 1px solid rgba(80, 98, 56, 0.12);
		border-radius: var(--radius-xl);
		padding: var(--space-gutter);
		box-shadow: var(--shadow-card);
	}

	.garden-icon {
		font-size: 2.25rem;
		color: var(--color-primary);
	}

	.garden-icon.fill {
		font-variation-settings: 'FILL' 1;
	}

	.garden-label {
		font-family: var(--font-body);
		font-size: 0.75rem;
		font-weight: 600;
		text-transform: uppercase;
		letter-spacing: 0.08em;
		color: var(--color-on-surface-variant);
		margin: 0;
	}

	.garden-value {
		font-family: var(--font-display);
		font-size: 1.5rem;
		font-weight: 600;
		color: var(--color-primary);
		margin: 0;
	}

	.achievements-list {
		display: flex;
		flex-direction: column;
		gap: 0.625rem;
	}

	.achievement-item {
		display: flex;
		align-items: center;
		gap: 0.875rem;
		background: var(--color-surface-container-lowest);
		border-radius: var(--radius-xl);
		padding: 0.875rem;
		box-shadow: var(--shadow-card);
		border: 1px solid rgba(117, 120, 109, 0.08);
		transition: box-shadow 0.2s ease;
	}

	.achievement-item.locked {
		opacity: 0.55;
	}

	.ach-icon-wrap {
		position: relative;
		width: 3rem;
		height: 3rem;
		border-radius: var(--radius-lg);
		background: var(--color-surface-container);
		display: flex;
		align-items: center;
		justify-content: center;
		flex-shrink: 0;
		border: 1px solid var(--color-outline-variant);
	}

	.ach-icon-wrap.unlocked {
		background: rgba(213, 234, 181, 0.3);
		border-color: rgba(185, 206, 155, 0.4);
	}

	.ach-icon-img {
		width: 1.875rem;
		height: 1.875rem;
		object-fit: contain;
	}

	.achievement-item.locked .ach-icon-img {
		filter: grayscale(1);
	}

	.ach-status-indicator {
		position: absolute;
		bottom: -0.25rem;
		right: -0.25rem;
		font-size: 0.65rem;
		background: var(--color-surface-container-lowest);
		border-radius: 50%;
		width: 1rem;
		height: 1rem;
		display: grid;
		place-items: center;
		border: 1px solid var(--color-outline-variant);
		box-shadow: var(--shadow-card);
	}

	.ach-info {
		flex: 1;
	}

	.ach-title {
		font-family: var(--font-display);
		font-size: 0.9rem;
		font-weight: 600;
		color: var(--color-on-surface);
		margin: 0 0 0.2rem;
	}

	.ach-desc {
		font-family: var(--font-body);
		font-size: 0.75rem;
		color: var(--color-on-surface-variant);
		margin: 0;
		line-height: 1.4;
	}

	.personalize-card {
		background: var(--color-surface-container-lowest);
		border-radius: var(--radius-xl);
		box-shadow: var(--shadow-card);
		padding: var(--space-gutter);
		border-left: 3px solid var(--color-primary);
	}

	.personalize-title {
		font-family: var(--font-display);
		font-size: 0.95rem;
		font-weight: 600;
		color: var(--color-on-surface);
		margin: 0 0 0.5rem;
	}

	.personalize-tips {
		margin: 0;
		padding-left: 1.1rem;
		font-family: var(--font-body);
		font-size: 0.8rem;
		color: var(--color-on-surface-variant);
		line-height: 1.6;
	}
</style>
