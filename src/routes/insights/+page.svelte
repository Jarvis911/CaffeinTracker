<script lang="ts">
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

	let isEditing = $state(false);

	// Calculate stats reactively
	const totalCaffeine = $derived(getTotalCaffeine(app.logs));
	const daysLogged = $derived(getDaysLogged(app.logs));
	const gardenLevel = $derived(getGardenLevel(totalCaffeine));
	const achievementsList = $derived(checkAchievements(app.logs, app.profile, app.connectedProviders));
	const unlockedAchievementsCount = $derived(achievementsList.filter(a => a.unlocked).length);

	const sugarCap = $derived(getDailySugarCap(app.profile.sugarSensitivity));

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

	// Slide navigation
	let activeSlide = $state<'profile' | 'achievements'>('profile');
	let containerElement = $state<HTMLDivElement | null>(null);

	function scrollToSlide(slide: 'profile' | 'achievements') {
		activeSlide = slide;
		if (containerElement) {
			const targetX = slide === 'profile' ? 0 : containerElement.clientWidth;
			containerElement.scrollTo({ left: targetX, behavior: 'smooth' });
		}
	}

	function handleScroll(e: Event) {
		const target = e.currentTarget as HTMLDivElement;
		const slideWidth = target.clientWidth;
		if (target.scrollLeft < slideWidth / 2) {
			activeSlide = 'profile';
		} else {
			activeSlide = 'achievements';
		}
	}
</script>

<div class="profile-page fade-in">
	<!-- Custom Garden Scroll Header -->
	<header class="scroll-header">
		<div class="scroll-inner">
			<div class="scroll-rolls-left" aria-hidden="true"></div>
			<div class="scroll-center">
				<h1 class="header-title">{$_('profile.garden_title')}</h1>
			</div>
			<div class="scroll-rolls-right" aria-hidden="true"></div>
		</div>
		<div class="subtitle-banner">
			<span>{$_('profile.garden_subtitle')}</span>
		</div>
	</header>

	<!-- Carousel Navigation Dots -->
	<div class="carousel-nav" aria-label="Slide navigation">
		<button
			type="button"
			class="dot-btn"
			class:active={activeSlide === 'profile'}
			onclick={() => scrollToSlide('profile')}
		>
			{$_('profile.title')}
		</button>
		<button
			type="button"
			class="dot-btn"
			class:active={activeSlide === 'achievements'}
			onclick={() => scrollToSlide('achievements')}
		>
			{$_('profile.achievements_title')}
		</button>
	</div>

	<!-- Carousel Container -->
	<div 
		class="carousel-container" 
		bind:this={containerElement}
		onscroll={handleScroll}
	>
		<!-- Slide 1: Profile View / Edit View -->
		<div class="carousel-slide">
			{#if !isEditing}
				<!-- Profile Card -->
				<div class="garden-card profile-card-inner">
					<!-- Avatar Card Header -->
					<div class="avatar-card-header">
						<div class="avatar-frame">
							<img src="/images/bunny_avatar.png" alt="Bunny avatar" class="avatar-img" />
						</div>
						<div class="avatar-details">
							<h2 class="user-name">{app.profile.name}</h2>
							<p class="user-level">
								{$_('profile.level_title', { values: { level: gardenLevel } })}
							</p>
						</div>
					</div>

					<div class="profile-card-content">
						<!-- Left Stats List -->
						<div class="stats-list">
							<div class="stat-item">
								<span class="stat-icon" aria-hidden="true">🫘</span>
								<div class="stat-text">
									<strong class="stat-label">[{$_('profile.total_caffeine')}]</strong>
									<span class="stat-value">{totalCaffeine}mg</span>
								</div>
							</div>
							<div class="stat-item">
								<span class="stat-icon" aria-hidden="true">🌳</span>
								<div class="stat-text">
									<strong class="stat-label">[{$_('profile.garden_level')}]</strong>
									<span class="stat-value">{gardenLevel}</span>
								</div>
							</div>
							<div class="stat-item">
								<span class="stat-icon" aria-hidden="true">📅</span>
								<div class="stat-text">
									<strong class="stat-label">[{$_('profile.days_logged')}]</strong>
									<span class="stat-value">{daysLogged}</span>
								</div>
							</div>
							<div class="stat-item">
								<span class="stat-icon" aria-hidden="true">🏅</span>
								<div class="stat-text">
									<strong class="stat-label">[{$_('profile.achievements_count')}]</strong>
									<span class="stat-value">{unlockedAchievementsCount} / {achievementsList.length}</span>
								</div>
							</div>
						</div>

						<!-- Right Illustration -->
						<div class="illustration-side">
							<img src="/images/profile_picnic.png" alt="Picnic Illustration" class="picnic-img" />
						</div>
					</div>
				</div>

				<!-- Wooden Edit Sign Button -->
				<div class="wooden-button-wrapper">
					<div class="pole left"></div>
					<div class="pole right"></div>
					<button
						type="button"
						class="wooden-sign-btn"
						onclick={() => (isEditing = true)}
					>
						{$_('profile.edit_profile')}
					</button>
				</div>
			{:else}
				<!-- Edit View Card -->
				<div class="garden-card edit-card-inner">
					<h2 class="edit-card-title">{$_('profile.edit_profile')}</h2>

					<form class="edit-form" onsubmit={(e) => e.preventDefault()}>
						<label class="field">
							<span class="field-title">{$_('profile.display_name')}</span>
							<input
								type="text"
								value={app.profile.name}
								oninput={(e) => setName(e.currentTarget.value)}
								class="pixel-input"
							/>
						</label>

						<label class="field">
							<span class="field-title">{$_('profile.caffeine_limit')}</span>
							<input
								type="range"
								min="100"
								max="600"
								step="25"
								value={app.profile.dailyCaffeineLimitMg}
								oninput={(e) => setLimit(Number(e.currentTarget.value))}
								class="pixel-range"
							/>
							<output class="pixel-output">{app.profile.dailyCaffeineLimitMg} mg</output>
						</label>

						<fieldset class="field border-none p-0">
							<span class="field-title">{$_('profile.sugar_sensitivity')}</span>
							<div class="radio-row">
								{#each ['low', 'medium', 'high'] as level}
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
							<p class="hint">{$_('profile.sugar_guidance', { values: { cap: sugarCap } })}</p>
						</fieldset>

						<fieldset class="field border-none p-0 mt-3">
							<span class="field-title">{$_('profile.language')}</span>
							<div class="radio-row">
								<button
									type="button"
									class="radio-btn"
									class:active={$locale === 'en'}
									onclick={() => toggleLanguage('en')}
								>
									{$_('profile.lang_en')}
								</button>
								<button
									type="button"
									class="radio-btn"
									class:active={$locale === 'vi'}
									onclick={() => toggleLanguage('vi')}
								>
									{$_('profile.lang_vi')}
								</button>
							</div>
						</fieldset>
					</form>
				</div>

				<!-- Wooden Back Sign Button -->
				<div class="wooden-button-wrapper">
					<div class="pole left"></div>
					<div class="pole right"></div>
					<button
						type="button"
						class="wooden-sign-btn save-btn"
						onclick={() => (isEditing = false)}
					>
						{$_('profile.back_to_profile')}
					</button>
				</div>
			{/if}
		</div>

		<!-- Slide 2: Achievements View -->
		<div class="carousel-slide">
			<div class="garden-card achievements-card-inner">
				<h2 class="achievements-card-title">{$_('profile.achievements_title')}</h2>
				
				<div class="achievements-scroll-wrapper">
					<div class="achievements-list">
						{#each achievementsList as ach}
							<div class="achievement-item" class:locked={!ach.unlocked}>
								<div class="achievement-icon-wrapper">
									<img src={ach.icon} alt="" class="achievement-icon-img" />
									{#if !ach.unlocked}
										<span class="lock-indicator" aria-label="Locked">🔒</span>
									{:else}
										<span class="check-indicator" aria-label="Unlocked">✅</span>
									{/if}
								</div>
								<div class="achievement-info">
									<h3 class="achievement-title">{$_(ach.titleKey)}</h3>
									<p class="achievement-desc">{$_(ach.descKey)}</p>
								</div>
							</div>
						{/each}
					</div>
				</div>
			</div>
			
			<!-- Spacer to match height of Slide 1 with button post spacing -->
			<div class="slide-bottom-spacer"></div>
		</div>
	</div>

	<!-- Bottom Section: How we personalize / Sync tips -->
	<footer class="footer-tips">
		{#if app.hasFitnessData}
			<section class="card-panel">
				<h2 class="section-title">{$_('profile.how_we_personalize')}</h2>
				<ul class="tips">
					<li>{$_('profile.tip_sleep')}</li>
					<li>{$_('profile.tip_hr')}</li>
					<li>{$_('profile.tip_afternoon')}</li>
					<li>{$_('profile.tip_active')}</li>
				</ul>
			</section>
		{:else}
			<section class="card-panel">
				<p class="hint m-0">{$_('profile.connect_hint')}</p>
				<a href="/connect" class="btn-primary go-to-sync-btn">{$_('profile.go_to_sync')}</a>
			</section>
		{/if}
	</footer>
</div>

<style>
	/* Custom styles mapping to Sprout Lands & Cozy pixel design */
	.profile-page {
		display: flex;
		flex-direction: column;
		gap: 1rem;
		padding-bottom: 2rem;
	}

	/* Scroll Header */
	.scroll-header {
		position: relative;
		margin-bottom: 0.2rem;
		text-align: center;
	}

	.scroll-inner {
		display: flex;
		align-items: center;
		justify-content: center;
		height: 3.5rem;
		background-color: #faf0dd; /* scroll paper background */
		border-top: 3px solid #3d2c2a;
		border-bottom: 3px solid #3d2c2a;
		position: relative;
		margin-inline: 14px;
		box-shadow: 0 4px 0 rgba(61, 44, 42, 0.15);
	}

	.scroll-rolls-left,
	.scroll-rolls-right {
		position: absolute;
		width: 14px;
		top: -3px;
		bottom: -3px;
		background-color: #e5cc9c;
		border: 3px solid #3d2c2a;
		border-radius: 4px;
	}

	.scroll-rolls-left {
		left: -14px;
		box-shadow: -2px 4px 0 rgba(61, 44, 42, 0.15);
	}

	.scroll-rolls-right {
		right: -14px;
		box-shadow: 2px 4px 0 rgba(61, 44, 42, 0.15);
	}

	.scroll-center {
		flex: 1;
		display: grid;
		place-items: center;
	}

	.scroll-header .header-title {
		margin: 0;
		font-family: var(--font-display);
		font-size: 0.95rem;
		font-weight: 800;
		color: #3d2c2a;
		letter-spacing: 0.05em;
		text-transform: uppercase;
		text-align: center;
	}

	.subtitle-banner {
		display: inline-flex;
		background-color: #3d2c2a;
		color: #faf0dd;
		padding: 0.25rem 1rem;
		border-radius: 12px;
		font-size: 0.68rem;
		font-weight: 700;
		margin-top: -6px;
		position: relative;
		z-index: 2;
		box-shadow: 0 2.5px 0 rgba(0, 0, 0, 0.15);
	}

	/* Carousel navigation */
	.carousel-nav {
		display: flex;
		justify-content: center;
		gap: 0.6rem;
		margin-top: 0.25rem;
	}

	.dot-btn {
		font-family: var(--font-display);
		font-size: 0.68rem;
		font-weight: 700;
		color: var(--color-text-muted);
		background-color: var(--color-bg-accent);
		border: 2px solid var(--color-border);
		border-radius: 14px;
		padding: 0.25rem 0.75rem;
		cursor: pointer;
		box-shadow: 0 2.5px 0 var(--color-border);
		transition: all 0.1s ease;
	}

	.dot-btn:hover {
		background-color: var(--color-accent);
	}

	.dot-btn.active {
		background-color: #e88ba0; /* Soft pink */
		color: #ffffff;
		border-color: #b84d66;
		box-shadow: 0 2.5px 0 #b84d66;
		transform: translateY(1px);
	}

	/* Swipe Carousel */
	.carousel-container {
		display: flex;
		overflow-x: auto;
		scroll-snap-type: x mandatory;
		scrollbar-width: none;
		gap: 1.25rem;
		margin-inline: -1.25rem;
		padding-inline: 1.25rem;
		scroll-behavior: smooth;
	}

	.carousel-container::-webkit-scrollbar {
		display: none;
	}

	.carousel-slide {
		flex: 0 0 100%;
		scroll-snap-align: start;
		box-sizing: border-box;
		display: flex;
		flex-direction: column;
	}

	/* Garden custom frame card */
	.garden-card {
		background-image: url('/images/frame.png');
		background-size: 100% 100%;
		background-repeat: no-repeat;
		image-rendering: pixelated;
		padding: 1.5rem 1.6rem;
		position: relative;
		display: flex;
		flex-direction: column;
		min-height: 18.5rem;
	}

	/* Avatar Section */
	.avatar-card-header {
		display: flex;
		align-items: center;
		gap: 0.75rem;
		margin-bottom: 0.9rem;
		border-bottom: 2px dashed rgba(61, 44, 42, 0.15);
		padding-bottom: 0.75rem;
	}

	.avatar-frame {
		width: 3.8rem;
		height: 3.8rem;
		border: 3px solid #3d2c2a;
		border-radius: 12px;
		overflow: hidden;
		background-color: #eed4b5;
		image-rendering: pixelated;
		box-shadow: inset 0 2px 5px rgba(0, 0, 0, 0.1);
	}

	.avatar-img {
		width: 100%;
		height: 100%;
		object-fit: cover;
		image-rendering: pixelated;
	}

	.avatar-details {
		display: flex;
		flex-direction: column;
		gap: 0.15rem;
	}

	.user-name {
		margin: 0;
		font-family: var(--font-display);
		font-size: 1.05rem;
		font-weight: 800;
		color: #3d2c2a;
	}

	.user-level {
		margin: 0;
		font-size: 0.72rem;
		font-weight: 700;
		color: #8b6f6a;
	}

	/* Card Content Layout */
	.profile-card-content {
		display: flex;
		flex-grow: 1;
		gap: 0.5rem;
		align-items: center;
	}

	.stats-list {
		flex: 1.1;
		display: flex;
		flex-direction: column;
		gap: 0.55rem;
	}

	.stat-item {
		display: flex;
		align-items: center;
		gap: 0.5rem;
	}

	.stat-icon {
		font-size: 1.15rem;
		filter: drop-shadow(0 1.5px 0 rgba(0, 0, 0, 0.15));
	}

	.stat-text {
		display: flex;
		flex-direction: column;
		line-height: 1.15;
	}

	.stat-label {
		font-size: 0.55rem;
		color: #8b6f6a;
		text-transform: uppercase;
		letter-spacing: 0.02em;
	}

	.stat-value {
		font-family: var(--font-display);
		font-size: 0.78rem;
		font-weight: 800;
		color: #3d2c2a;
	}

	.illustration-side {
		flex: 0.9;
		display: flex;
		justify-content: center;
		align-items: center;
	}

	.picnic-img {
		max-width: 100%;
		max-height: 9rem;
		object-fit: contain;
		image-rendering: pixelated;
		filter: drop-shadow(0 4px 6px rgba(61, 44, 42, 0.15));
	}

	/* Wooden Button sign style */
	.wooden-button-wrapper {
		position: relative;
		display: flex;
		flex-direction: column;
		align-items: center;
		margin-top: 1rem;
		margin-bottom: 0.2rem;
		z-index: 5;
	}

	.wooden-button-wrapper .pole {
		width: 7px;
		height: 1.25rem;
		background-color: #795238;
		border: 2px solid #3d2c2a;
		position: absolute;
		top: -0.65rem;
		z-index: -1;
	}

	.wooden-button-wrapper .pole.left {
		left: 28%;
	}

	.wooden-button-wrapper .pole.right {
		right: 28%;
	}

	.wooden-sign-btn {
		background-color: #d1a179;
		border: 3px solid #3d2c2a;
		padding: 0.45rem 1.6rem;
		color: #3d2c2a;
		font-family: var(--font-display);
		font-size: 0.8rem;
		font-weight: 800;
		cursor: pointer;
		text-transform: uppercase;
		box-shadow:
			inset -2.5px -2.5px 0 0 #b37f58,
			inset 2.5px 2.5px 0 0 #fbe2cd,
			0 4px 0 #3d2c2a;
		transition: transform 0.1s ease, box-shadow 0.1s ease;
		border-radius: 4px;
	}

	.wooden-sign-btn:hover {
		background-color: #e5bd98;
	}

	.wooden-sign-btn:active {
		transform: translateY(4px);
		box-shadow:
			inset -2.5px -2.5px 0 0 #b37f58,
			inset 2.5px 2.5px 0 0 #fbe2cd,
			0 0px 0 #3d2c2a;
	}

	/* Slide bottom spacing */
	.slide-bottom-spacer {
		height: 2.85rem;
	}

	/* Edit View Card Content */
	.edit-card-inner {
		min-height: 18.5rem;
	}

	.edit-card-title {
		margin: 0 0 0.8rem;
		font-family: var(--font-display);
		font-size: 0.95rem;
		font-weight: 800;
		color: #3d2c2a;
		text-transform: uppercase;
		text-align: center;
		border-bottom: 2px dashed rgba(61, 44, 42, 0.15);
		padding-bottom: 0.45rem;
	}

	.edit-form {
		display: flex;
		flex-direction: column;
		gap: 0.7rem;
	}

	.field {
		display: flex;
		flex-direction: column;
		gap: 0.25rem;
		border: none;
		padding: 0;
		margin: 0;
	}

	.field-title {
		font-size: 0.68rem;
		font-weight: 800;
		color: #8b6f6a;
		text-transform: uppercase;
		letter-spacing: 0.02em;
	}

	.pixel-input {
		padding: 0.4rem 0.65rem !important;
		border-radius: 8px !important;
		font-size: 0.78rem !important;
	}

	.pixel-range {
		margin: 0.15rem 0 !important;
	}

	.pixel-output {
		font-size: 0.8rem;
		font-weight: 800;
		align-self: flex-end;
		margin-top: -0.1rem;
	}

	.radio-row {
		display: flex;
		gap: 0.4rem;
	}

	.radio-btn {
		flex: 1;
		font-family: var(--font-display);
		font-weight: 700;
		color: #ffffff;
		text-shadow: 1px 1px 0 var(--color-btn-border);
		background-image: url('/images/minecraft_green_planks.png');
		background-size: 64px;
		border: 2px solid var(--color-btn-border);
		border-radius: 12px;
		padding: 0.3rem;
		cursor: pointer;
		box-shadow:
			inset 0 1.5px 0 rgba(255, 255, 255, 0.8),
			inset 0 -2px 0 rgba(0, 0, 0, 0.25),
			0 2.5px 0 var(--color-btn-border);
		font-size: 0.62rem;
		text-transform: uppercase;
		transition: all 0.1s ease;
	}

	.radio-btn:hover {
		filter: brightness(1.1);
	}

	.radio-btn:active {
		transform: translateY(2.5px);
		box-shadow:
			inset 0 1.5px 0 rgba(255, 255, 255, 0.8),
			inset 0 -1.5px 0 rgba(0, 0, 0, 0.25),
			0 0px 0 var(--color-btn-border);
	}

	.radio-btn.active {
		background: 
			linear-gradient(rgba(250, 240, 221, 0.9), rgba(250, 240, 221, 0.9)),
			url('/images/minecraft_green_planks.png');
		background-size: auto, 64px;
		color: var(--color-text);
		text-shadow: none;
		box-shadow:
			inset 0 1.5px 0 rgba(255, 255, 255, 0.8),
			inset 0 -2px 0 rgba(0, 0, 0, 0.15),
			0 2.5px 0 var(--color-btn-border);
	}

	.hint {
		margin: 0.15rem 0 0;
		font-size: 0.64rem;
		color: var(--color-text-muted);
		font-weight: 600;
	}

	/* Achievements Card Content */
	.achievements-card-inner {
		min-height: 18.5rem;
	}

	.achievements-card-title {
		margin: 0 0 0.65rem;
		font-family: var(--font-display);
		font-size: 0.95rem;
		font-weight: 800;
		color: #3d2c2a;
		text-transform: uppercase;
		text-align: center;
		border-bottom: 2px dashed rgba(61, 44, 42, 0.15);
		padding-bottom: 0.45rem;
	}

	.achievements-scroll-wrapper {
		overflow-y: auto;
		flex-grow: 1;
		max-height: 13rem;
		padding-right: 0.2rem;
		scrollbar-width: thin;
		scrollbar-color: var(--color-border) transparent;
	}

	.achievements-scroll-wrapper::-webkit-scrollbar {
		width: 4px;
	}
	
	.achievements-scroll-wrapper::-webkit-scrollbar-thumb {
		background-color: var(--color-border);
		border-radius: 4px;
	}

	.achievements-list {
		display: flex;
		flex-direction: column;
		gap: 0.55rem;
	}

	.achievement-item {
		display: flex;
		align-items: center;
		gap: 0.65rem;
		background-color: rgba(238, 212, 181, 0.3);
		border: 2px solid #3d2c2a;
		border-radius: 12px;
		padding: 0.45rem 0.6rem;
		transition: background-color 0.2s ease;
	}

	.achievement-item.locked {
		opacity: 0.55;
		background-color: rgba(61, 44, 42, 0.05);
	}

	.achievement-icon-wrapper {
		position: relative;
		width: 2.2rem;
		height: 2.2rem;
		display: grid;
		place-items: center;
		background-color: #eed4b5;
		border: 2px solid #3d2c2a;
		border-radius: 8px;
		font-size: 1.15rem;
	}

	.achievement-icon-img {
		width: 100%;
		height: 100%;
		object-fit: contain;
		image-rendering: pixelated;
	}

	.achievement-item.locked .achievement-icon-img {
		filter: grayscale(1);
	}

	.lock-indicator,
	.check-indicator {
		position: absolute;
		font-size: 0.6rem;
		bottom: -3px;
		right: -3px;
		background-color: #ffffff;
		border: 1.5px solid #3d2c2a;
		border-radius: 50%;
		width: 0.95rem;
		height: 0.95rem;
		display: grid;
		place-items: center;
		box-shadow: 0 1px 2px rgba(0, 0, 0, 0.15);
	}

	.achievement-info {
		display: flex;
		flex-direction: column;
		gap: 0.08rem;
		flex: 1;
	}

	.achievement-title {
		margin: 0;
		font-family: var(--font-display);
		font-size: 0.72rem;
		font-weight: 800;
		color: #3d2c2a;
	}

	.achievement-desc {
		margin: 0;
		font-size: 0.58rem;
		font-weight: 700;
		color: #8b6f6a;
		line-height: 1.2;
	}

	/* Footer section styling */
	.footer-tips {
		margin-top: 0.4rem;
	}

	.tips {
		margin: 0;
		padding-left: 1.1rem;
		font-size: 0.72rem;
		font-weight: 700;
		line-height: 1.45;
		color: var(--color-text-muted);
	}

	.go-to-sync-btn {
		display: inline-flex;
		margin-top: 0.6rem;
		text-decoration: none;
	}
</style>
