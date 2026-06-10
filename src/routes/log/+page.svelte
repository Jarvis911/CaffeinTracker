<script lang="ts">
	import { onDestroy } from 'svelte';
	import { _ } from 'svelte-i18n';
	import DrinkRoundCard from '$lib/components/DrinkRoundCard.svelte';
	import DrinkGridCard from '$lib/components/DrinkGridCard.svelte';
	import DrinkToyBox from '$lib/components/DrinkToyBox.svelte';
	import { DRINK_CATALOG } from '$lib/drinks/catalog';
	import { app } from '$lib/state/app.svelte';
	import { getTodayToyItems } from '$lib/utils/today-logs';

	const toyItems = $derived(getTodayToyItems(app.logs));

	let loggedId = $state<string | null>(null);
	let quickLogTab = $state<'fav' | 'recent'>('fav');
	let searchQuery = $state('');
	let selectedCategory = $state('all');
	let showScanner = $state(false);

	const categories = [
		{ id: 'all', label: 'All', icon: 'apps' },
		{ id: 'coffee', label: 'Coffee', icon: 'coffee' },
		{ id: 'tea', label: 'Tea', icon: 'eco' },
		{ id: 'energy', label: 'Energy', icon: 'bolt' },
		{ id: 'soda', label: 'Soda', icon: 'local_drink' },
		{ id: 'other', label: 'Other', icon: 'category' }
	];

	const filteredDrinks = $derived.by(() => {
		const query = searchQuery.toLowerCase().trim();
		return DRINK_CATALOG.filter((drink) => {
			const matchesSearch =
				!query ||
				drink.name.toLowerCase().includes(query) ||
				drink.emoji.includes(query);
			const matchesCategory =
				selectedCategory === 'all' || drink.category === selectedCategory;
			return matchesSearch && matchesCategory;
		});
	});

	// CV Scanner States
	type ScanState = 'idle' | 'camera' | 'scanning' | 'detected';
	let scanState = $state<ScanState>('idle');
	let capturedImageUrl = $state<string | null>(null);
	let scanProgress = $state(0);
	let scanLogs = $state<string[]>([]);
	let detectedDrink = $state<typeof DRINK_CATALOG[0] | null>(null);
	let confidence = $state(0);

	let videoElement = $state<HTMLVideoElement | null>(null);
	let fileInput = $state<HTMLInputElement | null>(null);
	let stream = $state<MediaStream | null>(null);

	function log(id: string, scanned = false) {
		app.logDrink(id, 1, scanned);
		loggedId = id;
		setTimeout(() => {
			loggedId = null;
		}, 1800);
	}

	function toggleFavorite(id: string) {
		let preferred = [...app.profile.preferredDrinkIds];
		if (preferred.includes(id)) {
			preferred = preferred.filter((x) => x !== id);
		} else {
			preferred.push(id);
		}
		app.updateProfile({ preferredDrinkIds: preferred });
	}

	const favoriteDrinks = $derived.by(() =>
		DRINK_CATALOG.filter((d) => app.profile.preferredDrinkIds.includes(d.id))
	);

	const recentDrinks = $derived.by(() => {
		const ids: string[] = [];
		for (const entry of app.logs) {
			if (!ids.includes(entry.drinkId)) {
				const exists = DRINK_CATALOG.some((d) => d.id === entry.drinkId);
				if (exists) ids.push(entry.drinkId);
			}
			if (ids.length >= 4) break;
		}
		return ids.map((id) => DRINK_CATALOG.find((d) => d.id === id)!).filter(Boolean);
	});

	async function startCamera() {
		try {
			capturedImageUrl = null;
			detectedDrink = null;
			scanState = 'camera';
			setTimeout(async () => {
				try {
					stream = await navigator.mediaDevices.getUserMedia({
						video: { facingMode: 'environment' }
					});
					if (videoElement) videoElement.srcObject = stream;
				} catch (err) {
					console.error('Camera access failed:', err);
					alert('Camera access denied. Please use "Upload Photo" instead.');
					resetScanner();
				}
			}, 50);
		} catch (err) {
			console.error('Error accessing camera:', err);
			resetScanner();
		}
	}

	function capturePhoto() {
		if (!videoElement) return;
		const canvas = document.createElement('canvas');
		canvas.width = videoElement.videoWidth || 640;
		canvas.height = videoElement.videoHeight || 480;
		const ctx = canvas.getContext('2d');
		if (ctx) {
			ctx.drawImage(videoElement, 0, 0, canvas.width, canvas.height);
			capturedImageUrl = canvas.toDataURL('image/jpeg');
			stopCamera();
			runMockScan();
		}
	}

	function stopCamera() {
		if (stream) {
			stream.getTracks().forEach((track) => track.stop());
			stream = null;
		}
	}

	function triggerUpload() {
		fileInput?.click();
	}

	function handleFileUpload(event: Event) {
		const target = event.target as HTMLInputElement;
		if (target.files && target.files[0]) {
			const file = target.files[0];
			const reader = new FileReader();
			reader.onload = (e) => {
				capturedImageUrl = e.target?.result as string;
				runMockScan();
			};
			reader.readAsDataURL(file);
		}
	}

	let scanInterval: ReturnType<typeof setInterval> | undefined;
	function runMockScan(targetDrinkId?: string) {
		stopCamera();
		scanState = 'scanning';
		scanProgress = 0;
		scanLogs = [];
		detectedDrink = null;

		const logPhrases = [
			'Initializing Computer Vision models...',
			'Extracting pixel matrix...',
			'Analyzing HSV color profile...',
			'Detecting cup edges and volume...',
			'Comparing with drink database signatures...',
			'Calculating caffeine concentration...',
			'Evaluating sugar density predictions...',
			'Finalizing neural network inference...'
		];

		scanInterval = setInterval(() => {
			scanProgress += 10;
			const logIndex = Math.floor((scanProgress / 100) * logPhrases.length);
			if (logPhrases[logIndex] && !scanLogs.includes(`[AI] ${logPhrases[logIndex]}`)) {
				scanLogs = [...scanLogs, `[AI] ${logPhrases[logIndex]}`];
			}
			if (scanProgress >= 100) {
				clearInterval(scanInterval);
				if (targetDrinkId) {
					detectedDrink = DRINK_CATALOG.find((d) => d.id === targetDrinkId) || DRINK_CATALOG[0];
				} else {
					detectedDrink = DRINK_CATALOG[Math.floor(Math.random() * DRINK_CATALOG.length)];
				}
				confidence = Math.floor(88 + Math.random() * 11);
				scanState = 'detected';
			}
		}, 200);
	}

	function resetScanner() {
		stopCamera();
		if (scanInterval) clearInterval(scanInterval);
		scanState = 'idle';
		capturedImageUrl = null;
		scanProgress = 0;
		scanLogs = [];
		detectedDrink = null;
		showScanner = false;
	}

	onDestroy(() => {
		stopCamera();
		if (scanInterval) clearInterval(scanInterval);
	});
</script>

<svelte:head>
	<title>Log — Zakka Caffeine</title>
</svelte:head>

<!-- Top App Bar -->
<header class="top-bar">
	<div class="top-bar-inner">
		<div class="top-bar-title">
			<h2 class="page-headline">New Log Entry</h2>
			<p class="page-subtitle">Finding focus through the ritual of brewing.</p>
		</div>
	</div>
</header>

<div class="log-page fade-in">

	<!-- ── Quick Log Row (Favorites / Recent) ────────────────── -->
	{#if favoriteDrinks.length > 0 || recentDrinks.length > 0}
		<section class="quick-section">
			<div class="quick-tabs">
				{#if favoriteDrinks.length > 0}
					<button
						type="button"
						class="tab-btn"
						class:active={quickLogTab === 'fav'}
						onclick={() => (quickLogTab = 'fav')}
					>
						<span class="material-symbols-outlined tab-icon">favorite</span>
						Favorites
					</button>
				{/if}
				{#if recentDrinks.length > 0}
					<button
						type="button"
						class="tab-btn"
						class:active={quickLogTab === 'recent' || (favoriteDrinks.length === 0)}
						onclick={() => (quickLogTab = 'recent')}
					>
						<span class="material-symbols-outlined tab-icon">history</span>
						Recent
					</button>
				{/if}
			</div>
			<div class="quick-scroll">
				{#if quickLogTab === 'fav' && favoriteDrinks.length > 0}
					{#each favoriteDrinks as drink (drink.id)}
						<DrinkRoundCard {drink} onSelect={() => log(drink.id)} />
					{/each}
				{:else if recentDrinks.length > 0}
					{#each recentDrinks as drink (drink.id)}
						<DrinkRoundCard {drink} onSelect={() => log(drink.id)} />
					{/each}
				{/if}
			</div>
		</section>
	{/if}

	<!-- ── AI Scanner Toggle ─────────────────────────────────── -->
	<div class="scanner-toggle-row">
		<button
			type="button"
			class="scanner-toggle-btn"
			class:active={showScanner}
			onclick={() => {
				showScanner = !showScanner;
				if (!showScanner) stopCamera();
			}}
		>
			<span class="material-symbols-outlined">{showScanner ? 'close' : 'photo_camera'}</span>
			{showScanner ? 'Hide AI Scanner' : 'AI Drink Scanner'}
		</button>
	</div>

	<!-- ── CV Scanner ────────────────────────────────────────── -->
	{#if showScanner}
		<section class="scanner-section fade-in">
			<div class="scanner-header">
				<h3 class="scanner-title">AI Vision Scanner</h3>
				<p class="scanner-subtitle">Point your camera or upload a photo of any drink</p>
			</div>

			<div class="scanner-body">
				{#if scanState === 'idle'}
					<div class="scanner-idle">
						<div class="scanner-placeholder">
							<span class="material-symbols-outlined scanner-ph-icon">photo_camera</span>
							<p class="scanner-ph-text">Capture or upload a drink photo</p>
						</div>
						<div class="scanner-actions">
							<button type="button" class="btn-primary scan-btn" onclick={startCamera}>
								<span class="material-symbols-outlined">videocam</span>
								Open Camera
							</button>
							<button type="button" class="btn-ghost scan-btn" onclick={triggerUpload}>
								<span class="material-symbols-outlined">upload</span>
								Upload Photo
							</button>
							<input
								type="file"
								accept="image/*"
								bind:this={fileInput}
								onchange={handleFileUpload}
								style="display: none;"
							/>
						</div>
					</div>

				{:else if scanState === 'camera'}
					<div class="scanner-camera">
						<div class="camera-wrapper">
							<video bind:this={videoElement} autoplay playsinline class="camera-feed">
								<track kind="captions" />
							</video>
							<div class="camera-reticle" aria-hidden="true"></div>
						</div>
						<div class="scanner-actions">
							<button type="button" class="btn-primary scan-btn" onclick={capturePhoto}>
								<span class="material-symbols-outlined">camera</span>
								Capture
							</button>
							<button type="button" class="btn-ghost scan-btn" onclick={resetScanner}>
								Cancel
							</button>
						</div>
					</div>

				{:else if scanState === 'scanning'}
					<div class="scanner-analyzing">
						<div class="scan-target">
							{#if capturedImageUrl}
								<img src={capturedImageUrl} alt="Scanning source" class="scan-img" />
							{:else}
								<div class="scan-placeholder-img">
									<span aria-hidden="true">🔍☕🥤</span>
								</div>
							{/if}
							<div class="laser" aria-hidden="true"></div>
						</div>
						<div class="progress-row">
							<div class="progress-track-wide">
								<div class="progress-fill-wide" style:width="{scanProgress}%"></div>
							</div>
							<span class="progress-pct">{scanProgress}%</span>
						</div>
						<div class="terminal-logs" aria-live="polite">
							{#each scanLogs as line, i (i)}
								<div class="log-line fade-in">{line}</div>
							{/each}
						</div>
					</div>

				{:else if scanState === 'detected' && detectedDrink}
					<div class="scanner-result fade-in">
						<div class="result-badge">
							<span class="material-symbols-outlined fill" style="font-size:1rem">check_circle</span>
							Drink Detected
						</div>

						<div class="result-card">
							<div class="result-emoji-wrap">
								<span class="result-emoji" aria-hidden="true">{detectedDrink.emoji}</span>
							</div>
							<div class="result-details">
								<h4 class="result-name">{detectedDrink.name}</h4>
								<div class="confidence-row">
									<span class="confidence-label">Confidence: {confidence}%</span>
									<div class="confidence-bar">
										<div class="confidence-fill" style:width="{confidence}%"></div>
									</div>
								</div>
							</div>
						</div>

						<div class="nutrition-chips">
							<div class="nut-chip caffeine">
								<span class="nut-val">{detectedDrink.caffeineMg}mg</span>
								<span class="nut-key">Caffeine</span>
							</div>
							<div class="nut-chip sugar">
								<span class="nut-val">{detectedDrink.sugarG}g</span>
								<span class="nut-key">Sugar</span>
							</div>
							<div class="nut-chip calories">
								<span class="nut-val">{detectedDrink.calories}</span>
								<span class="nut-key">kcal</span>
							</div>
						</div>

						<div class="correction-row">
							<label for="drink-correction" class="correction-label">Not your drink?</label>
							<select
								id="drink-correction"
								class="correction-select"
								value={detectedDrink.id}
								onchange={(e) => {
									const val = (e.target as HTMLSelectElement).value;
									const found = DRINK_CATALOG.find((d) => d.id === val);
									if (found) detectedDrink = found;
								}}
							>
								{#each DRINK_CATALOG as drink (drink.id)}
									<option value={drink.id}>{drink.emoji} {drink.name}</option>
								{/each}
							</select>
						</div>

						<div class="scanner-actions">
							<button
								type="button"
								class="btn-primary scan-btn"
								onclick={() => {
									log(detectedDrink!.id, true);
									resetScanner();
								}}
							>
								<span class="material-symbols-outlined">add_circle</span>
								Add to Ritual
							</button>
							<button type="button" class="btn-ghost scan-btn" onclick={resetScanner}>
								Scan Again
							</button>
						</div>
					</div>
				{/if}
			</div>
		</section>
	{/if}

	<!-- ── Search Bar ─────────────────────────────────────────── -->
	<div class="search-row">
		<div class="search-wrapper">
			<span class="material-symbols-outlined search-icon">search</span>
			<input
				type="text"
				placeholder="Search drinks..."
				bind:value={searchQuery}
				class="search-input"
				aria-label="Search drinks"
			/>
			{#if searchQuery}
				<button
					type="button"
					class="search-clear"
					onclick={() => (searchQuery = '')}
					aria-label="Clear search"
				>
					<span class="material-symbols-outlined">close</span>
				</button>
			{/if}
		</div>
	</div>

	<!-- ── Category Filter Chips ──────────────────────────────── -->
	<div class="categories-scroll" role="group" aria-label="Filter by category">
		{#each categories as cat (cat.id)}
			<button
				type="button"
				class="cat-chip"
				class:active={selectedCategory === cat.id}
				onclick={() => (selectedCategory = cat.id)}
				aria-pressed={selectedCategory === cat.id}
			>
				<span class="material-symbols-outlined cat-icon">{cat.icon}</span>
				{cat.label}
			</button>
		{/each}
	</div>

	<!-- ── Drink Grid ─────────────────────────────────────────── -->
	<section class="grid-section">
		{#if filteredDrinks.length > 0}
			<div class="drink-grid">
				{#each filteredDrinks as drink (drink.id)}
					<DrinkGridCard
						{drink}
						isFavorite={app.profile.preferredDrinkIds.includes(drink.id)}
						onSelect={() => log(drink.id)}
						onToggleFavorite={() => toggleFavorite(drink.id)}
					/>
				{/each}
			</div>
		{:else}
			<div class="empty-state">
				<span class="empty-icon" aria-hidden="true">🥤</span>
				<p>No drinks found. Try a different search.</p>
			</div>
		{/if}
	</section>

	<!-- ── Drink Toy Box (Physics Sandbox) ───────────────────── -->
	<section class="toybox-section">
		<DrinkToyBox items={toyItems} />
	</section>
</div>

<!-- Log Toast Notification -->
{#if loggedId}
	{@const drink = DRINK_CATALOG.find((d) => d.id === loggedId)}
	<div class="toast" role="status" aria-live="polite">
		<span class="material-symbols-outlined toast-icon fill">check_circle</span>
		<span><strong>{drink?.name ?? 'Drink'}</strong> added to your ritual</span>
	</div>
{/if}

<style>
	/* ── Top Bar ──────────────────────────────────────────── */
	.top-bar {
		background: var(--color-surface);
		border-bottom: 1px solid rgba(197, 200, 187, 0.2);
		padding: 1.25rem var(--space-container) 1rem;
		max-width: 768px;
		margin-inline: auto;
	}

	.top-bar-inner {
		max-width: 768px;
		margin-inline: auto;
	}

	.page-headline {
		font-family: var(--font-display);
		font-size: 1.625rem;
		font-weight: 600;
		color: var(--color-on-surface);
		margin: 0 0 0.25rem;
		letter-spacing: -0.01em;
	}

	.page-subtitle {
		font-family: var(--font-body);
		font-size: 0.9rem;
		font-style: italic;
		color: var(--color-on-surface-variant);
		margin: 0;
	}

	/* ── Log Page ────────────────────────────────────────── */
	.log-page {
		max-width: 768px;
		margin-inline: auto;
		padding: var(--space-gutter) var(--space-container);
		display: flex;
		flex-direction: column;
		gap: 1.25rem;
	}

	/* ── Quick Log ───────────────────────────────────────── */
	.quick-section {
		display: flex;
		flex-direction: column;
		gap: 0.6rem;
	}

	.quick-tabs {
		display: flex;
		gap: 0.5rem;
	}

	.tab-btn {
		display: inline-flex;
		align-items: center;
		gap: 0.35rem;
		padding: 0.4rem 0.875rem;
		border-radius: var(--radius-full);
		border: 1px solid var(--color-outline-variant);
		background: transparent;
		color: var(--color-on-surface-variant);
		font-family: var(--font-body);
		font-size: 0.8rem;
		font-weight: 600;
		cursor: pointer;
		transition: background 0.2s ease, color 0.2s ease, border-color 0.2s ease;
	}

	.tab-btn:hover {
		background: var(--color-surface-container);
	}

	.tab-btn.active {
		background: var(--color-primary-container);
		color: var(--color-on-primary-container);
		border-color: transparent;
	}

	.tab-icon {
		font-size: 1rem;
	}

	.quick-scroll {
		display: flex;
		gap: 0.5rem;
		overflow-x: auto;
		scrollbar-width: none;
		padding: 0.15rem 0;
	}

	.quick-scroll::-webkit-scrollbar {
		display: none;
	}

	/* ── Scanner Toggle ──────────────────────────────────── */
	.scanner-toggle-row {
		display: flex;
		justify-content: center;
	}

	.scanner-toggle-btn {
		display: inline-flex;
		align-items: center;
		gap: 0.5rem;
		padding: 0.625rem 1.25rem;
		border-radius: var(--radius-full);
		border: 1px solid var(--color-outline-variant);
		background: var(--color-surface-container-lowest);
		color: var(--color-on-surface-variant);
		font-family: var(--font-body);
		font-size: 0.875rem;
		font-weight: 600;
		cursor: pointer;
		box-shadow: var(--shadow-card);
		transition: background 0.2s ease, color 0.2s ease;
	}

	.scanner-toggle-btn:hover,
	.scanner-toggle-btn.active {
		background: var(--color-surface-container);
		color: var(--color-primary);
	}

	.scanner-toggle-btn .material-symbols-outlined {
		font-size: 1.125rem;
	}

	/* ── Scanner Section ─────────────────────────────────── */
	.scanner-section {
		background: var(--color-surface-container-lowest);
		border-radius: var(--radius-xl);
		box-shadow: var(--shadow-card);
		border: 1px solid rgba(117, 120, 109, 0.1);
		overflow: hidden;
	}

	.scanner-header {
		padding: var(--space-gutter) var(--space-gutter) 0;
	}

	.scanner-title {
		font-family: var(--font-display);
		font-size: 1rem;
		font-weight: 600;
		color: var(--color-on-surface);
		margin: 0 0 0.2rem;
	}

	.scanner-subtitle {
		font-family: var(--font-body);
		font-size: 0.8rem;
		color: var(--color-on-surface-variant);
		margin: 0 0 0.875rem;
	}

	.scanner-body {
		padding: 0 var(--space-gutter) var(--space-gutter);
	}

	.scanner-idle {
		display: flex;
		flex-direction: column;
		gap: 1rem;
		align-items: center;
	}

	.scanner-placeholder {
		display: flex;
		flex-direction: column;
		align-items: center;
		gap: 0.5rem;
		padding: 2rem;
		width: 100%;
		background: var(--color-surface-container);
		border-radius: var(--radius-lg);
		border: 1px dashed var(--color-outline-variant);
	}

	.scanner-ph-icon {
		font-size: 2.5rem;
		color: var(--color-outline);
	}

	.scanner-ph-text {
		font-family: var(--font-body);
		font-size: 0.85rem;
		color: var(--color-outline);
		margin: 0;
	}

	.scanner-actions {
		display: flex;
		gap: 0.75rem;
		width: 100%;
		justify-content: center;
		flex-wrap: wrap;
	}

	.scan-btn {
		flex: 1;
		min-width: 8rem;
		max-width: 14rem;
		padding: 0.75rem 1rem;
		font-size: 0.875rem;
	}

	.scanner-camera {
		display: flex;
		flex-direction: column;
		align-items: center;
		gap: 0.875rem;
	}

	.camera-wrapper {
		position: relative;
		width: 100%;
		max-width: 20rem;
		aspect-ratio: 4 / 3;
		border-radius: var(--radius-xl);
		overflow: hidden;
		background: #000;
	}

	.camera-feed {
		width: 100%;
		height: 100%;
		object-fit: cover;
	}

	.camera-reticle {
		position: absolute;
		inset: 1.5rem;
		border: 2px dashed rgba(176, 206, 155, 0.7);
		border-radius: var(--radius-lg);
		pointer-events: none;
	}

	.scanner-analyzing {
		display: flex;
		flex-direction: column;
		align-items: center;
		gap: 0.75rem;
	}

	.scan-target {
		position: relative;
		width: 100%;
		max-width: 14rem;
		aspect-ratio: 4 / 3;
		border-radius: var(--radius-xl);
		overflow: hidden;
		background: var(--color-surface-container);
	}

	.scan-img {
		width: 100%;
		height: 100%;
		object-fit: cover;
	}

	.scan-placeholder-img {
		width: 100%;
		height: 100%;
		display: flex;
		align-items: center;
		justify-content: center;
		font-size: 2rem;
		animation: pulse 1.2s ease-in-out infinite alternate;
	}

	@keyframes pulse {
		from { opacity: 0.7; transform: scale(0.95); }
		to { opacity: 1; transform: scale(1.05); }
	}

	.laser {
		position: absolute;
		left: 0;
		right: 0;
		height: 3px;
		background: var(--color-primary);
		box-shadow: 0 0 8px var(--color-primary);
		animation: scan-move 1.8s ease-in-out infinite alternate;
	}

	@keyframes scan-move {
		0% { top: 0%; }
		100% { top: 100%; }
	}

	.progress-row {
		width: 100%;
		display: flex;
		align-items: center;
		gap: 0.75rem;
	}

	.progress-track-wide {
		flex: 1;
		height: 6px;
		background: var(--color-surface-container);
		border-radius: var(--radius-full);
		overflow: hidden;
	}

	.progress-fill-wide {
		height: 100%;
		background: var(--color-primary);
		border-radius: var(--radius-full);
		transition: width 0.2s ease;
	}

	.progress-pct {
		font-family: var(--font-body);
		font-size: 0.75rem;
		font-weight: 600;
		color: var(--color-primary);
		min-width: 2.5rem;
		text-align: right;
	}

	.terminal-logs {
		width: 100%;
		background: var(--color-inverse-surface);
		border-radius: var(--radius-lg);
		padding: 0.625rem 0.875rem;
		height: 5.5rem;
		overflow-y: auto;
		display: flex;
		flex-direction: column;
		gap: 0.2rem;
		scrollbar-width: thin;
		scrollbar-color: rgba(255,255,255,0.2) transparent;
	}

	.log-line {
		color: #b9ce9b;
		font-family: 'Courier New', Courier, monospace;
		font-size: 0.6rem;
		font-weight: 600;
	}

	/* Detected Result */
	.scanner-result {
		display: flex;
		flex-direction: column;
		align-items: center;
		gap: 0.875rem;
		width: 100%;
	}

	.result-badge {
		display: inline-flex;
		align-items: center;
		gap: 0.35rem;
		background: rgba(80, 98, 56, 0.1);
		color: var(--color-primary);
		padding: 0.25rem 0.875rem;
		border-radius: var(--radius-full);
		font-family: var(--font-body);
		font-size: 0.75rem;
		font-weight: 600;
		letter-spacing: 0.05em;
		text-transform: uppercase;
	}

	.result-badge .material-symbols-outlined {
		font-size: 1rem;
	}

	.result-badge .fill {
		font-variation-settings: 'FILL' 1;
	}

	.result-card {
		display: flex;
		align-items: center;
		gap: 0.875rem;
		background: var(--color-surface-container);
		border-radius: var(--radius-xl);
		padding: 0.875rem;
		width: 100%;
	}

	.result-emoji-wrap {
		width: 3.5rem;
		height: 3.5rem;
		border-radius: var(--radius-lg);
		background: var(--color-surface-container-lowest);
		border: 1px solid var(--color-outline-variant);
		display: flex;
		align-items: center;
		justify-content: center;
		box-shadow: var(--shadow-card);
		flex-shrink: 0;
	}

	.result-emoji {
		font-size: 2rem;
	}

	.result-details {
		flex: 1;
		display: flex;
		flex-direction: column;
		gap: 0.35rem;
	}

	.result-name {
		font-family: var(--font-display);
		font-size: 1rem;
		font-weight: 600;
		color: var(--color-on-surface);
		margin: 0;
	}

	.confidence-row {
		display: flex;
		flex-direction: column;
		gap: 0.2rem;
	}

	.confidence-label {
		font-family: var(--font-body);
		font-size: 0.7rem;
		font-weight: 500;
		color: var(--color-on-surface-variant);
	}

	.confidence-bar {
		height: 4px;
		background: var(--color-surface-container-high);
		border-radius: var(--radius-full);
		overflow: hidden;
	}

	.confidence-fill {
		height: 100%;
		background: var(--color-primary);
		border-radius: var(--radius-full);
	}

	.nutrition-chips {
		display: flex;
		gap: 0.5rem;
		width: 100%;
	}

	.nut-chip {
		flex: 1;
		display: flex;
		flex-direction: column;
		align-items: center;
		padding: 0.5rem 0.25rem;
		border-radius: var(--radius-lg);
		box-shadow: var(--shadow-card);
		text-align: center;
	}

	.nut-chip.caffeine { background: rgba(213, 234, 181, 0.4); }
	.nut-chip.sugar { background: rgba(255, 219, 208, 0.4); }
	.nut-chip.calories { background: rgba(240, 238, 233, 0.8); }

	.nut-val {
		font-family: var(--font-display);
		font-size: 0.85rem;
		font-weight: 600;
		color: var(--color-on-surface);
	}

	.nut-key {
		font-family: var(--font-body);
		font-size: 0.65rem;
		font-weight: 500;
		color: var(--color-outline);
		text-transform: uppercase;
		letter-spacing: 0.05em;
	}

	.correction-row {
		width: 100%;
		display: flex;
		flex-direction: column;
		gap: 0.35rem;
	}

	.correction-label {
		font-family: var(--font-body);
		font-size: 0.75rem;
		font-weight: 600;
		color: var(--color-outline);
		text-transform: uppercase;
		letter-spacing: 0.05em;
	}

	.correction-select {
		padding: 0.5rem 0.75rem;
		border-radius: var(--radius-lg);
		border: 1px solid var(--color-outline-variant);
		background: var(--color-surface-container-lowest);
		font-family: var(--font-body);
		font-size: 0.875rem;
		color: var(--color-on-surface);
		outline: none;
		cursor: pointer;
		width: 100%;
		box-shadow: var(--shadow-card);
	}

	.correction-select:focus {
		border-color: var(--color-primary);
	}

	/* ── Search Bar ───────────────────────────────────────── */
	.search-row {
		width: 100%;
	}

	.search-wrapper {
		position: relative;
		display: flex;
		align-items: center;
	}

	.search-icon {
		position: absolute;
		left: 0.875rem;
		color: var(--color-outline);
		font-size: 1.25rem;
		pointer-events: none;
	}

	.search-input {
		width: 100%;
		padding: 0.75rem 2.75rem 0.75rem 2.75rem;
		border-radius: var(--radius-full);
		border: 1px solid var(--color-outline-variant);
		background: var(--color-surface-container-lowest);
		font-family: var(--font-body);
		font-size: 0.95rem;
		color: var(--color-on-surface);
		box-shadow: var(--shadow-card);
		outline: none;
		transition: border-color 0.2s ease, box-shadow 0.2s ease;
	}

	.search-input:focus {
		border-color: var(--color-primary);
	}

	.search-clear {
		position: absolute;
		right: 0.75rem;
		background: none;
		border: none;
		color: var(--color-outline);
		cursor: pointer;
		padding: 0.25rem;
		border-radius: 50%;
		display: grid;
		place-items: center;
		transition: background 0.2s ease;
	}

	.search-clear:hover {
		background: var(--color-surface-container);
	}

	.search-clear .material-symbols-outlined {
		font-size: 1.125rem;
	}

	/* ── Category Chips ──────────────────────────────────── */
	.categories-scroll {
		display: flex;
		gap: 0.5rem;
		overflow-x: auto;
		scrollbar-width: none;
		padding: 0.1rem 0 0.25rem;
		margin-inline: calc(-1 * var(--space-container));
		padding-inline: var(--space-container);
	}

	.categories-scroll::-webkit-scrollbar {
		display: none;
	}

	.cat-chip {
		flex-shrink: 0;
		display: inline-flex;
		align-items: center;
		gap: 0.35rem;
		padding: 0.45rem 0.875rem;
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

	.cat-chip:hover {
		background: var(--color-surface-container);
	}

	.cat-chip.active {
		background: var(--color-primary);
		color: var(--color-on-primary);
		border-color: transparent;
	}

	.cat-icon {
		font-size: 1rem;
	}

	/* ── Drink Grid ───────────────────────────────────────── */
	.grid-section {
		width: 100%;
	}

	.drink-grid {
		display: grid;
		grid-template-columns: repeat(3, 1fr);
		gap: 0.75rem;
	}

	@media (min-width: 480px) {
		.drink-grid {
			grid-template-columns: repeat(4, 1fr);
		}
	}

	.empty-state {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		padding: 3rem 1.5rem;
		border-radius: var(--radius-xl);
		border: 1px dashed var(--color-outline-variant);
		background: var(--color-surface-container-lowest);
		text-align: center;
	}

	.empty-icon {
		font-size: 2.5rem;
		margin-bottom: 0.5rem;
	}

	.empty-state p {
		font-family: var(--font-body);
		font-size: 0.875rem;
		color: var(--color-outline);
		margin: 0;
	}

	/* ── Toy Box ─────────────────────────────────────────── */
	.toybox-section {
		margin-top: 0.5rem;
	}

	/* ── Toast ───────────────────────────────────────────── */
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
			toastOut 0.3s ease 1.5s both;
	}

	.toast-icon {
		color: var(--color-primary-fixed-dim);
		font-size: 1.125rem;
	}

	.toast-icon.fill {
		font-variation-settings: 'FILL' 1;
	}

	@keyframes toastIn {
		from { opacity: 0; transform: translateX(-50%) translateY(12px) scale(0.9); }
		to { opacity: 1; transform: translateX(-50%) translateY(0) scale(1); }
	}

	@keyframes toastOut {
		from { opacity: 1; }
		to { opacity: 0; }
	}
</style>
