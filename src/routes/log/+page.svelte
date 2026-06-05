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

	// Log drink logic
	function log(id: string, scanned = false) {
		app.logDrink(id, 1, scanned);
		loggedId = id;
		setTimeout(() => {
			loggedId = null;
		}, 1800);
	}

	// Toggle favorite in user profile
	function toggleFavorite(id: string) {
		let preferred = [...app.profile.preferredDrinkIds];
		if (preferred.includes(id)) {
			preferred = preferred.filter((x) => x !== id);
		} else {
			preferred.push(id);
		}
		app.updateProfile({ preferredDrinkIds: preferred });
	}

	// Favorites list from profile
	const favoriteDrinks = $derived.by(() => {
		return DRINK_CATALOG.filter((d) => app.profile.preferredDrinkIds.includes(d.id));
	});

	// Last 4 unique logged drinks
	const recentDrinks = $derived.by(() => {
		const ids: string[] = [];
		for (const entry of app.logs) {
			if (!ids.includes(entry.drinkId)) {
				const exists = DRINK_CATALOG.some((d) => d.id === entry.drinkId);
				if (exists) {
					ids.push(entry.drinkId);
				}
			}
			if (ids.length >= 4) break;
		}
		return ids.map((id) => DRINK_CATALOG.find((d) => d.id === id)!).filter(Boolean);
	});

	// Start Camera Stream
	async function startCamera() {
		try {
			capturedImageUrl = null;
			detectedDrink = null;
			scanState = 'camera';
			// Wait for video element to render
			setTimeout(async () => {
				try {
					stream = await navigator.mediaDevices.getUserMedia({
						video: { facingMode: 'environment' }
					});
					if (videoElement) {
						videoElement.srcObject = stream;
					}
				} catch (err) {
					console.error('Camera access failed inside timeout:', err);
					alert('Camera access denied or unavailable. Please use "Upload Photo" instead.');
					resetScanner();
				}
			}, 50);
		} catch (err) {
			console.error('Error accessing camera:', err);
			alert('Camera access denied or unavailable. Please use "Upload Photo" instead.');
			resetScanner();
		}
	}

	// Capture Photo from Camera Stream
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

	// Stop Camera Stream
	function stopCamera() {
		if (stream) {
			stream.getTracks().forEach((track) => track.stop());
			stream = null;
		}
	}

	// Trigger File input click
	function triggerUpload() {
		fileInput?.click();
	}

	// Handle Image File Upload
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



	let scanInterval: any;
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

		let step = 0;
		scanInterval = setInterval(() => {
			scanProgress += 10;
			
			// Append logs at specific progress points
			const logIndex = Math.floor((scanProgress / 100) * logPhrases.length);
			if (logPhrases[logIndex] && !scanLogs.includes(`[AI] ${logPhrases[logIndex]}`)) {
				scanLogs = [...scanLogs, `[AI] ${logPhrases[logIndex]}`];
			}

			if (scanProgress >= 100) {
				clearInterval(scanInterval);
				
				// Determine detected drink
				if (targetDrinkId) {
					detectedDrink = DRINK_CATALOG.find(d => d.id === targetDrinkId) || DRINK_CATALOG[0];
				} else {
					// Random selection from catalog if uploaded/photographed
					const randomIndex = Math.floor(Math.random() * DRINK_CATALOG.length);
					detectedDrink = DRINK_CATALOG[randomIndex];
				}
				confidence = Math.floor(88 + Math.random() * 11); // 88% - 98%
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

<div class="compact-header wood-board fade-in">
	<div class="header-inner">
		<span class="header-icon" aria-hidden="true">☕</span>
		<div class="header-titles fade-in">
			<h2 class="header-title">{$_('log.title')}</h2>
			<p class="header-subtitle">{$_('log.subtitle')}</p>
		</div>
	</div>
</div>

<div class="log-page-container">

	<!-- Tabbed Quick Log Row -->
	{#if favoriteDrinks.length > 0 || recentDrinks.length > 0}
		<div class="quick-log-section fade-in wood-board" style="animation-delay: 0.15s">
			<div class="quick-log-tabs">
				{#if favoriteDrinks.length > 0}
					<button
						type="button"
						class="tab-btn"
						class:active={quickLogTab === 'fav'}
						onclick={() => (quickLogTab = 'fav')}
					>
						❤️ {$_('log.favorites')}
					</button>
				{/if}
				{#if recentDrinks.length > 0}
					<button
						type="button"
						class="tab-btn"
						class:active={quickLogTab === 'recent' || (favoriteDrinks.length === 0 && quickLogTab === 'fav')}
						onclick={() => (quickLogTab = 'recent')}
					>
						⚡ {$_('log.recent')}
					</button>
				{/if}
			</div>
			<div class="wood-inner-board quick-log-inner">
				<div class="horizontal-scroll">
					{#if (quickLogTab === 'fav' && favoriteDrinks.length > 0) || (favoriteDrinks.length > 0 && recentDrinks.length === 0)}
						{#each favoriteDrinks as drink (drink.id)}
							<DrinkRoundCard drink={drink} onSelect={() => log(drink.id)} />
						{/each}
					{:else if recentDrinks.length > 0}
						{#each recentDrinks as drink (drink.id)}
							<DrinkRoundCard drink={drink} onSelect={() => log(drink.id)} />
						{/each}
					{:else}
						<p class="quick-log-empty">{$_('log.no_results')}</p>
					{/if}
				</div>
			</div>
		</div>
	{/if}

	<!-- AI Scanner Trigger Button -->
	<div class="scanner-toggle-container fade-in" style="animation-delay: 0.18s">
		<button
			type="button"
			class="btn-3d-cute scanner-toggle-btn"
			class:active={showScanner}
			onclick={() => {
				showScanner = !showScanner;
				if (!showScanner) {
					stopCamera();
				}
			}}
		>
			{#if showScanner}
				✕ {$_('log.cv_btn_hide_scanner')}
			{:else}
				🤖📷 {$_('log.cv_btn_show_scanner')}
			{/if}
		</button>
	</div>

	<!-- Computer Vision Scanner Section -->
	{#if showScanner}
		<div class="grid-section fade-in wood-board" style="animation-delay: 0.2s">
			<h2 class="section-title">{$_('log.cv_title')}</h2>
			<p class="cv-subtitle">{$_('log.cv_subtitle')}</p>
			
			<div class="wood-inner-board cv-scanner-container">
				{#if scanState === 'idle'}
					<!-- Idle Mode: Choice to upload or open camera -->
					<div class="scanner-idle-view">
						<div class="scanner-actions">
							<button type="button" class="btn-3d-cute action-btn" onclick={startCamera}>
								{$_('log.cv_btn_camera')}
							</button>
							<button type="button" class="btn-primary action-btn" onclick={triggerUpload}>
								{$_('log.cv_btn_upload')}
							</button>
							<input
								type="file"
								accept="image/*"
								bind:this={fileInput}
								onchange={handleFileUpload}
								class="hidden-file-input"
								style="display: none;"
							/>
						</div>
					</div>

				{:else if scanState === 'camera'}
					<!-- Camera Mode: Live stream -->
					<div class="scanner-camera-view">
						<div class="camera-feed-wrapper">
							<video bind:this={videoElement} autoplay playsinline class="camera-video">
								<track kind="captions" />
							</video>
							<div class="camera-overlay-reticle"></div>
						</div>
						<div class="scanner-actions">
							<button type="button" class="btn-3d-cute capture-btn" onclick={capturePhoto}>
								{$_('log.cv_btn_capture')}
							</button>
							<button type="button" class="btn-primary cancel-btn" onclick={resetScanner}>
								{$_('log.cv_btn_cancel')}
							</button>
						</div>
					</div>

				{:else if scanState === 'scanning'}
					<!-- Scanning Mode: Animation overlay & Logs -->
					<div class="scanner-scanning-view">
						<div class="scan-target-wrapper">
							{#if capturedImageUrl}
								<img src={capturedImageUrl} alt="Scanning source" class="scan-image" />
							{:else}
								<!-- Fallback preset Svelte card -->
								<div class="scan-placeholder-card">
									<span class="scan-placeholder-emoji">🔍☕🥤</span>
								</div>
							{/if}
							<div class="laser-scanner"></div>
						</div>
						
						<div class="scan-progress-bar-wrapper">
							<div class="scan-progress-bar" style="width: {scanProgress}%"></div>
						</div>
						<span class="scan-percentage">{scanProgress}%</span>
						
						<div class="scan-terminal-logs">
							{#each scanLogs as logMsg}
								<div class="log-line fade-in">{logMsg}</div>
							{/each}
						</div>
					</div>

				{:else if scanState === 'detected' && detectedDrink}
					<!-- Detected Mode: Display result + options -->
					<div class="scanner-detected-view fade-in">
						<div class="detected-badge">{$_('log.cv_detected_title')}</div>
						
						<div class="detected-card">
							<div class="detected-emoji-wrap">
								<span class="detected-emoji">{detectedDrink.emoji}</span>
							</div>
							<div class="detected-details">
								<h3 class="detected-name">{detectedDrink.name}</h3>
								<div class="confidence-meter">
									<span class="confidence-label">{$_('log.cv_confidence')}: {confidence}%</span>
									<div class="confidence-bar-outer">
										<div class="confidence-bar-inner" style="width: {confidence}%"></div>
									</div>
								</div>
							</div>
						</div>

						<div class="detected-nutrition">
							<div class="nutrition-chip caffeine-color">
								<span class="nut-val">{detectedDrink.caffeineMg} mg</span>
								<span class="nut-label">{$_('log.caffeine')}</span>
							</div>
							<div class="nutrition-chip sugar-color">
								<span class="nut-val">{detectedDrink.sugarG} g</span>
								<span class="nut-label">{$_('log.sugar')}</span>
							</div>
							<div class="nutrition-chip calories-color">
								<span class="nut-val">{detectedDrink.calories} kcal</span>
								<span class="nut-label">calories</span>
							</div>
						</div>

						<!-- Correction selection if AI was wrong -->
						<div class="correction-wrapper">
							<label for="drink-correction" class="correction-label">{$_('log.cv_not_your_drink')}</label>
							<select
								id="drink-correction"
								class="correction-select"
								value={detectedDrink.id}
								onchange={(e) => {
									const val = (e.target as HTMLSelectElement).value;
									const found = DRINK_CATALOG.find(d => d.id === val);
									if (found) detectedDrink = found;
								}}
							>
								{#each DRINK_CATALOG as drink}
									<option value={drink.id}>{drink.emoji} {drink.name}</option>
								{/each}
							</select>
						</div>

						<div class="scanner-actions">
							<button type="button" class="btn-3d-cute confirm-btn" onclick={() => {
								log(detectedDrink!.id, true);
								resetScanner();
							}}>
								{$_('log.cv_btn_confirm_log')}
							</button>
							<button type="button" class="btn-primary reset-btn" onclick={resetScanner}>
								{$_('log.cv_btn_scan_again')}
							</button>
						</div>
					</div>
				{/if}
			</div>
		</div>
	{/if}

	<!-- Search Bar -->
	<div class="search-container fade-in" style="animation-delay: 0.22s">
		<div class="search-input-wrapper">
			<span class="search-icon" aria-hidden="true">🔍</span>
			<input
				type="text"
				placeholder={$_('log.search_placeholder')}
				bind:value={searchQuery}
				class="search-input"
			/>
			{#if searchQuery}
				<button
					type="button"
					class="clear-search"
					onclick={() => (searchQuery = '')}
					aria-label="Clear search"
				>✕</button>
			{/if}
		</div>
	</div>

	<!-- Category Filter Chips -->
	<div class="categories-row fade-in" style="animation-delay: 0.25s">
		{#each ['all', 'coffee', 'tea', 'energy', 'soda', 'other'] as cat}
			<button
				type="button"
				class="category-chip"
				class:active={selectedCategory === cat}
				onclick={() => (selectedCategory = cat)}
			>
				{$_(`log.category_${cat}`)}
			</button>
		{/each}
	</div>

	<!-- Grid selection of drinks -->
	<div class="grid-section fade-in" style="animation-delay: 0.28s">
		{#if filteredDrinks.length > 0}
			<div class="grid">
				{#each filteredDrinks as drink (drink.id)}
					<DrinkGridCard
						drink={drink}
						isFavorite={app.profile.preferredDrinkIds.includes(drink.id)}
						onSelect={() => log(drink.id)}
						onToggleFavorite={() => toggleFavorite(drink.id)}
					/>
				{/each}
			</div>
		{:else}
			<div class="empty-state">
				<span class="empty-emoji" aria-hidden="true">🥤🔍</span>
				<p>{$_('log.no_results')}</p>
			</div>
		{/if}
	</div>
</div>

<!-- Floating Logged Toast (Retro OS Warning Dialog) -->
{#if loggedId}
	<div class="toast-overlay" role="status">
		<div class="toast-box retro-dialog">
			<div class="dialog-title-bar">
				<span class="dialog-title">WARNING.EXE</span>
				<button type="button" class="dialog-close-x" onclick={() => (loggedId = null)} aria-label="Close dialog">X</button>
			</div>
			<div class="dialog-body">
				<span class="toast-emoji" aria-hidden="true">🥤</span>
				<div class="dialog-content">
					<p class="dialog-text">{$_('log.logged_toast')}</p>
					<div class="dialog-buttons">
						<button class="btn-3d-cute dialog-ok-btn" onclick={() => (loggedId = null)}>OK</button>
					</div>
				</div>
			</div>
		</div>
	</div>
{/if}

<section class="fade-in toy-wrap" style="animation-delay: 0.25s">
	<DrinkToyBox items={toyItems} />
</section>

<style>
	.log-page-container {
		display: flex;
		flex-direction: column;
		gap: 1.15rem;
		margin-top: 0.5rem;
	}

	.toy-wrap {
		margin-top: 1.5rem;
	}

	.scanner-toggle-container {
		display: flex;
		justify-content: center;
		width: 100%;
		margin-bottom: 0.15rem;
	}

	.scanner-toggle-btn {
		width: 100%;
		max-width: 18rem;
		text-align: center;
	}

	/* Search bar styles */
	.search-container {
		width: 100%;
	}

	.search-input-wrapper {
		position: relative;
		width: 100%;
		display: flex;
		align-items: center;
	}

	.search-icon {
		position: absolute;
		left: 1.1rem;
		font-size: 0.95rem;
		color: var(--color-text-muted);
		pointer-events: none;
	}

	.search-input {
		width: 100%;
		padding: 0.85rem 2.5rem 0.85rem 2.6rem;
		font-family: var(--font-body);
		font-size: 0.95rem;
		color: var(--color-text);
		border-radius: 16px;
		border: 2.5px solid var(--color-border);
		background: var(--color-surface);
		box-shadow: var(--shadow-soft);
		outline: none;
		transition:
			border-color 0.2s ease,
			box-shadow 0.2s ease;
	}

	.search-input:focus {
		border-color: var(--color-mint-deep);
		box-shadow: var(--shadow-lift);
	}

	.clear-search {
		position: absolute;
		right: 1rem;
		background: none;
		border: none;
		color: var(--color-text-muted);
		font-size: 1.3rem;
		cursor: pointer;
		padding: 0;
		line-height: 1;
		display: grid;
		place-items: center;
		width: 1.5rem;
		height: 1.5rem;
		border-radius: 999px;
		transition:
			background 0.2s ease,
			color 0.2s ease;
	}

	.clear-search:hover {
		background: var(--color-bg-accent);
		color: var(--color-text);
	}

	/* Category chips styles */
	.categories-row {
		display: flex;
		gap: 0.5rem;
		overflow-x: auto;
		scroll-behavior: smooth;
		scrollbar-width: none; /* Hide standard Firefox scrollbar */
		padding-bottom: 0.25rem;
		margin-inline: -1.25rem;
		padding-inline: 1.25rem;
	}

	.categories-row::-webkit-scrollbar {
		display: none; /* Hide Chrome/Safari scrollbar */
	}

	.category-chip {
		flex-shrink: 0;
		padding: 0.5rem 1.05rem;
		border-radius: var(--btn-radius);
		border: 2px solid var(--color-border);
		background: var(--color-surface);
		color: var(--color-text-muted);
		font-family: var(--font-display);
		font-weight: 700;
		font-size: 0.8rem;
		cursor: pointer;
		box-shadow: var(--shadow-soft);
		transition:
			background 0.25s ease,
			color 0.25s ease,
			border-color 0.25s ease,
			transform 0.15s ease,
			box-shadow 0.25s ease;
	}

	.category-chip:hover {
		border-color: var(--color-btn-border);
		transform: translateY(-1px);
	}

	.category-chip:active {
		transform: scale(0.96);
	}

	.category-chip.active {
		background: linear-gradient(135deg, var(--color-mint), var(--color-mint-deep));
		color: #ffffff;
		border-color: transparent;
		box-shadow: 0 4px 12px rgba(94, 143, 96, 0.35);
	}

	/* Grid styles */
	.grid-section {
		margin-top: 0.15rem;
	}

	.grid {
		display: grid;
		grid-template-columns: repeat(3, 1fr);
		gap: 0.75rem;
		width: 100%;
	}

	.empty-state {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		padding: 3rem 1.5rem;
		border-radius: 20px;
		border: 2px dashed var(--color-border);
		background: var(--color-surface);
		text-align: center;
	}

	.empty-emoji {
		font-size: 2.5rem;
		margin-bottom: 0.6rem;
		filter: drop-shadow(0 4px 8px rgba(0, 0, 0, 0.05));
	}

	.empty-state p {
		font-family: var(--font-body);
		font-size: 0.88rem;
		font-weight: 700;
		color: var(--color-text-muted);
		margin: 0;
	}

	/* Compact Header */
	.compact-header {
		padding: 0.45rem 0.75rem;
		margin-bottom: 0.65rem;
		border-radius: 16px;
	}
	.header-inner {
		display: flex;
		align-items: center;
		gap: 0.55rem;
	}
	.header-icon {
		font-size: 1.25rem;
	}
	.header-titles {
		display: flex;
		flex-direction: column;
		gap: 0.02rem;
	}
	.header-title {
		margin: 0;
		font-size: 0.72rem;
		font-weight: 700;
		color: var(--color-text);
		line-height: 1.15;
	}
	.header-subtitle {
		margin: 0;
		font-family: var(--font-body);
		font-size: 0.58rem;
		font-weight: 700;
		color: var(--color-text);
		line-height: 1.2;
	}

	/* Tabbed Quick Log */
	.quick-log-section {
		display: flex;
		flex-direction: column;
		gap: 0.35rem;
		padding: 0.55rem 0.65rem 0.45rem;
	}
	.quick-log-tabs {
		display: flex;
		gap: 0.35rem;
		margin-bottom: 0.15rem;
	}
	.tab-btn {
		font-family: var(--font-display);
		font-weight: 700;
		font-size: 0.58rem;
		color: var(--color-text);
		background-color: #eed4b5;
		border: 1.75px solid var(--color-btn-border);
		border-radius: var(--btn-radius);
		padding: 0.2rem 0.55rem;
		cursor: pointer;
		box-shadow: 0 1.5px 0 var(--color-btn-border);
		transition: transform 0.1s ease, box-shadow 0.1s ease, background-color 0.2s ease;
		text-transform: uppercase;
	}
	.tab-btn:hover {
		background-color: #ffdca8;
	}
	.tab-btn:active, .tab-btn.active {
		background-color: #99cc99; /* sprout green */
		transform: translateY(1.5px);
		box-shadow: 0 0px 0 var(--color-btn-border);
	}
	.quick-log-inner {
		padding: 0.35rem !important;
	}
	.quick-log-empty {
		margin: 0;
		font-family: var(--font-body);
		font-size: 0.68rem;
		font-weight: 700;
		color: var(--color-text-muted);
		padding: 0.3rem;
	}

	.horizontal-scroll {
		display: flex;
		gap: 0.55rem;
		overflow-x: auto;
		scroll-behavior: smooth;
		scrollbar-width: none;
		padding: 0.1rem;
	}

	.horizontal-scroll::-webkit-scrollbar {
		display: none;
	}

	/* Grid styles */
	.grid-section {
		padding: 0.55rem;
	}

	/* CV Scanner Styles */
	.cv-subtitle {
		margin: -0.35rem 0 0.75rem 0;
		font-family: var(--font-body);
		font-size: 0.68rem;
		font-weight: 700;
		color: var(--color-text-muted);
	}

	.cv-scanner-container {
		padding: 0.75rem !important;
		min-height: 14.5rem;
		display: flex;
		flex-direction: column;
		justify-content: center;
	}

	/* Idle view */
	.scanner-idle-view {
		display: flex;
		flex-direction: column;
		gap: 0.85rem;
		width: 100%;
		align-items: center;
	}

	.scanner-actions {
		display: flex;
		gap: 0.65rem;
		width: 100%;
		justify-content: center;
		margin-top: 0.25rem;
	}

	.action-btn {
		flex: 1;
		max-width: 10rem;
	}



	/* Camera View */
	.scanner-camera-view {
		display: flex;
		flex-direction: column;
		align-items: center;
		gap: 0.65rem;
		width: 100%;
	}

	.camera-feed-wrapper {
		position: relative;
		width: 100%;
		max-width: 14rem;
		aspect-ratio: 4 / 3;
		border: 2.5px solid var(--color-border);
		border-radius: 16px;
		overflow: hidden;
		background: #000;
	}

	.camera-video {
		width: 100%;
		height: 100%;
		object-fit: cover;
	}

	.camera-overlay-reticle {
		position: absolute;
		inset: 1.5rem;
		border: 2px dashed rgba(153, 204, 153, 0.65);
		pointer-events: none;
		border-radius: 6px;
	}

	.camera-overlay-reticle::before,
	.camera-overlay-reticle::after {
		content: '';
		position: absolute;
		width: 12px;
		height: 12px;
		border-color: #99cc99;
		border-style: solid;
		pointer-events: none;
	}

	.camera-overlay-reticle::before {
		top: -3px;
		left: -3px;
		border-width: 3px 0 0 3px;
	}
	
	.camera-overlay-reticle::after {
		bottom: -3px;
		right: -3px;
		border-width: 0 3px 3px 0;
	}

	/* Scanning view */
	.scanner-scanning-view {
		display: flex;
		flex-direction: column;
		align-items: center;
		gap: 0.55rem;
		width: 100%;
	}

	.scan-target-wrapper {
		position: relative;
		width: 100%;
		max-width: 12rem;
		aspect-ratio: 4 / 3;
		border: 2.5px solid var(--color-border);
		border-radius: 16px;
		overflow: hidden;
		background: var(--color-surface);
		display: flex;
		align-items: center;
		justify-content: center;
	}

	.scan-image {
		width: 100%;
		height: 100%;
		object-fit: cover;
	}

	.scan-placeholder-card {
		width: 100%;
		height: 100%;
		background: linear-gradient(135deg, var(--color-wood-medium), var(--color-wood-dark));
		display: flex;
		align-items: center;
		justify-content: center;
	}

	.scan-placeholder-emoji {
		font-size: 2.2rem;
		animation: pulse-emoji 1.2s ease-in-out infinite alternate;
	}

	@keyframes pulse-emoji {
		from { transform: scale(0.95); opacity: 0.8; }
		to { transform: scale(1.15); opacity: 1; }
	}

	.laser-scanner {
		position: absolute;
		left: 0;
		right: 0;
		height: 4px;
		background: #99cc99;
		box-shadow: 0 0 8px #99cc99, 0 0 16px #99cc99;
		animation: scan-move 1.8s ease-in-out infinite alternate;
	}

	@keyframes scan-move {
		0% { top: 0%; }
		100% { top: 100%; }
	}

	.scan-progress-bar-wrapper {
		width: 100%;
		height: 12px;
		background: var(--color-surface);
		border: 2px solid var(--color-border);
		border-radius: 10px;
		overflow: hidden;
		position: relative;
		box-shadow: inset 0 1.5px 0 rgba(0, 0, 0, 0.1);
	}

	.scan-progress-bar {
		height: 100%;
		background: #5e8f60;
		transition: width 0.2s ease;
	}

	.scan-percentage {
		font-family: var(--font-display);
		font-size: 0.65rem;
		font-weight: 700;
	}

	.scan-terminal-logs {
		width: 100%;
		background: #1e1e1e;
		border: 2px solid var(--color-border);
		border-radius: 14px;
		padding: 0.45rem;
		height: 4.8rem;
		overflow-y: auto;
		display: flex;
		flex-direction: column;
		gap: 0.25rem;
		box-shadow: inset 0 2px 0 rgba(0, 0, 0, 0.4);
	}

	.log-line {
		color: #5eff5e;
		font-family: 'Courier New', Courier, monospace;
		font-size: 0.55rem;
		font-weight: bold;
		text-align: left;
	}

	/* Detected View */
	.scanner-detected-view {
		display: flex;
		flex-direction: column;
		align-items: center;
		gap: 0.75rem;
		width: 100%;
	}

	.detected-badge {
		background: #b84d66;
		color: #ffffff;
		border: 1.5px solid var(--color-border);
		box-shadow: 0 1.5px 0 var(--color-border);
		font-family: var(--font-display);
		font-weight: 700;
		font-size: 0.55rem;
		padding: 0.15rem 0.55rem;
		border-radius: 14px;
		text-transform: uppercase;
		letter-spacing: 0.05em;
	}

	.detected-card {
		display: flex;
		align-items: center;
		gap: 0.75rem;
		background: var(--color-surface);
		border: 2px solid var(--color-border);
		box-shadow: 0 3px 0 var(--color-border);
		border-radius: 16px;
		padding: 0.55rem;
		width: 100%;
	}

	.detected-emoji-wrap {
		width: 2.8rem;
		height: 2.8rem;
		border-radius: 12px;
		background: var(--color-wood-tan);
		border: 1.75px solid var(--color-border);
		display: flex;
		align-items: center;
		justify-content: center;
		font-size: 1.8rem;
		box-shadow: inset 0 1.5px 0 rgba(0,0,0,0.06);
	}

	.detected-details {
		flex: 1;
		display: flex;
		flex-direction: column;
		gap: 0.2rem;
	}

	.detected-name {
		margin: 0;
		font-size: 0.85rem;
		color: var(--color-text);
		font-weight: 800;
	}

	.confidence-meter {
		display: flex;
		flex-direction: column;
		gap: 0.15rem;
	}

	.confidence-label {
		font-size: 0.52rem;
		font-weight: 700;
		color: var(--color-text-muted);
	}

	.confidence-bar-outer {
		height: 6px;
		background: var(--color-wood-tan);
		border: 1px solid var(--color-border);
		border-radius: 6px;
		overflow: hidden;
	}

	.confidence-bar-inner {
		height: 100%;
		background: #99cc99;
	}

	.detected-nutrition {
		display: flex;
		gap: 0.45rem;
		width: 100%;
		justify-content: center;
	}

	.nutrition-chip {
		display: flex;
		flex-direction: column;
		align-items: center;
		padding: 0.25rem 0.5rem;
		border: 1.5px solid var(--color-border);
		border-radius: 12px;
		flex: 1;
		box-shadow: 0 1.5px 0 var(--color-border);
	}

	.caffeine-color { background-color: #eed4b5; }
	.sugar-color { background-color: #f7d2db; }
	.calories-color { background-color: #e2f3e4; }

	.nut-val {
		font-family: var(--font-display);
		font-weight: 700;
		font-size: 0.68rem;
		color: var(--color-text);
	}

	.nut-label {
		font-family: var(--font-body);
		font-size: 0.48rem;
		font-weight: 700;
		color: var(--color-text-muted);
		text-transform: uppercase;
	}

	.correction-wrapper {
		width: 100%;
		display: flex;
		flex-direction: column;
		gap: 0.2rem;
		align-items: center;
		margin-top: 0.15rem;
	}

	.correction-label {
		font-family: var(--font-display);
		font-size: 0.55rem;
		font-weight: 700;
		color: var(--color-text-muted);
		text-transform: uppercase;
	}

	.correction-select {
		padding: 0.25rem 0.45rem;
		border-radius: 12px;
		border: 2px solid var(--color-border);
		background-color: var(--color-surface);
		font-family: var(--font-body);
		font-weight: 700;
		font-size: 0.65rem;
		color: var(--color-text);
		outline: none;
		cursor: pointer;
		box-shadow: 0 1.5px 0 var(--color-border);
		max-width: 10rem;
		width: 100%;
		text-align: center;
	}
	
	.correction-select:focus {
		border-color: var(--color-mint-deep);
	}

	/* Premium Floating Toast styles */
	.toast-overlay {
		position: fixed;
		top: 6.5rem;
		left: 50%;
		transform: translateX(-50%);
		z-index: 100;
	}

	.retro-dialog {
		background: var(--color-surface);
		border: 2.5px solid var(--color-border);
		box-shadow: 0 4.5px 0 var(--color-border);
		border-radius: 18px;
		width: 16rem;
		overflow: hidden;
		animation:
			toastPop 0.35s cubic-bezier(0.175, 0.885, 0.32, 1.275) both,
			toastFadeOut 0.3s ease 2.5s both;
	}

	.dialog-title-bar {
		background: #b22222; /* Warning Red */
		color: #ffffff;
		padding: 0.35rem 0.55rem;
		display: flex;
		justify-content: space-between;
		align-items: center;
		border-bottom: 2.5px solid var(--color-border);
		font-family: var(--font-display);
		font-size: 0.55rem;
		font-weight: 700;
	}

	.dialog-close-x {
		background: none;
		border: none;
		padding: 0;
		color: #ffffff;
		font-weight: 800;
		cursor: pointer;
		font-family: inherit;
	}

	.dialog-body {
		padding: 0.75rem;
		display: flex;
		align-items: flex-start;
		gap: 0.65rem;
		background: var(--color-wood-tan);
	}

	.toast-emoji {
		font-size: 1.6rem;
		flex-shrink: 0;
	}

	.dialog-content {
		display: flex;
		flex-direction: column;
		gap: 0.55rem;
		flex-grow: 1;
	}

	.dialog-text {
		margin: 0;
		font-family: var(--font-body);
		font-size: 0.75rem;
		font-weight: 700;
		line-height: 1.35;
		color: var(--color-text);
	}

	.dialog-buttons {
		display: flex;
		justify-content: flex-end;
	}

	.dialog-ok-btn {
		padding: 0.3rem 0.85rem;
		font-size: 0.62rem;
		box-shadow:
			inset 0 2px 0 rgba(255, 255, 255, 0.5),
			inset 0 -2px 0 rgba(0, 0, 0, 0.1),
			0 3.5px 0 var(--color-btn-border);
	}

	.dialog-ok-btn:active {
		transform: translateY(3.5px);
		box-shadow:
			inset 0 2px 0 rgba(255, 255, 255, 0.5),
			inset 0 -2px 0 rgba(0, 0, 0, 0.1),
			0 0px 0 var(--color-btn-border);
	}

	@keyframes toastPop {
		0% {
			opacity: 0;
			transform: scale(0.8) translateY(12px);
		}
		100% {
			opacity: 1;
			transform: scale(1) translateY(0);
		}
	}

	@keyframes toastFadeOut {
		0% {
			opacity: 1;
		}
		90% {
			opacity: 1;
		}
		100% {
			opacity: 0;
			pointer-events: none;
		}
	}
</style>
