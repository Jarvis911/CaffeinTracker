<script lang="ts">
	import { _ } from 'svelte-i18n';
	import DrinkGridCard from '$lib/components/DrinkGridCard.svelte';
	import DrinkRoundCard from '$lib/components/DrinkRoundCard.svelte';
	import DrinkToyBox from '$lib/components/DrinkToyBox.svelte';
	import MascotHeader from '$lib/components/MascotHeader.svelte';
	import { DRINK_CATALOG } from '$lib/drinks/catalog';
	import { app } from '$lib/state/app.svelte';
	import { getTodayToyItems } from '$lib/utils/today-logs';

	const toyItems = $derived(getTodayToyItems(app.logs));

	let loggedId = $state<string | null>(null);
	let searchQuery = $state('');
	let selectedCategory = $state('all');
	let quickLogTab = $state<'fav' | 'recent'>('fav');
	let isSearching = $state(false);

	// Log drink logic
	function log(id: string) {
		app.logDrink(id);
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

	// Filtered drinks list
	const filteredDrinks = $derived.by(() => {
		const q = searchQuery.toLowerCase().trim();
		return DRINK_CATALOG.filter((drink) => {
			const matchesSearch =
				!q ||
				drink.name.toLowerCase().includes(q) ||
				$_(`log.category_${drink.category}`).toLowerCase().includes(q);
			const matchesCategory = selectedCategory === 'all' || drink.category === selectedCategory;
			return matchesSearch && matchesCategory;
		});
	});

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
</script>

<div class="compact-header wood-board fade-in">
	<div class="header-inner">
		<span class="header-icon" aria-hidden="true">☕</span>
		{#if !isSearching}
			<div class="header-titles fade-in">
				<h2 class="header-title">{$_('log.title')}</h2>
				<p class="header-subtitle">{$_('log.subtitle')}</p>
			</div>
		{:else}
			<div class="compact-search-wrapper fade-in">
				<input
					type="text"
					placeholder={$_('log.search_placeholder')}
					bind:value={searchQuery}
					class="compact-search-input"
					autofocus
				/>
				{#if searchQuery}
					<button
						type="button"
						class="clear-search-compact"
						onclick={() => (searchQuery = '')}
						aria-label="Clear search"
					>×</button>
				{/if}
			</div>
		{/if}
		<button
			type="button"
			class="btn-3d-cute search-toggle-btn"
			class:active={isSearching}
			onclick={() => {
				isSearching = !isSearching;
				if (!isSearching) searchQuery = '';
			}}
			aria-label="Toggle search"
		>
			🔍
		</button>
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

	<!-- Grid selection of drinks (Scrollable internally) -->
	<div class="grid-section fade-in wood-board" style="animation-delay: 0.2s">
		<div class="wood-inner-board scrollable-grid-container">
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
</div>

<!-- Floating Logged Toast (Retro OS Warning Dialog) -->
{#if loggedId}
	<div class="toast-overlay" role="status">
		<div class="toast-box retro-dialog">
			<div class="dialog-title-bar">
				<span class="dialog-title">WARNING.EXE</span>
				<span class="dialog-close-x">X</span>
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

	/* Compact Search Styles inside Header */
	.compact-search-wrapper {
		position: relative;
		flex-grow: 1;
		display: flex;
		align-items: center;
		border: 3px solid var(--color-border);
		background-color: var(--color-wood-tan);
		border-radius: 8px;
		box-shadow: inset 0 2px 0 rgba(0, 0, 0, 0.08);
		margin-right: 0.25rem;
		height: 1.85rem;
	}

	.compact-search-input {
		width: 100%;
		border: none;
		background: transparent;
		outline: none;
		font-family: var(--font-body);
		font-weight: 700;
		font-size: 0.72rem;
		color: var(--color-text);
		padding: 0.15rem 1.6rem 0.15rem 0.45rem;
	}

	.clear-search-compact {
		position: absolute;
		right: 0.35rem;
		background: none;
		border: none;
		color: var(--color-text-muted);
		font-size: 1rem;
		cursor: pointer;
		padding: 0;
		line-height: 1;
		display: grid;
		place-items: center;
		width: 1.15rem;
		height: 1.15rem;
		border-radius: 50%;
		transition: background-color 0.2s ease;
	}

	.clear-search-compact:hover {
		background: var(--color-accent);
		color: var(--color-text);
	}

	.search-toggle-btn {
		padding: 0.35rem 0.45rem !important;
		font-size: 0.72rem !important;
		border-radius: 8px !important;
		box-shadow:
			inset 0 2px 0 rgba(255, 255, 255, 0.5),
			inset 0 -2px 0 rgba(0, 0, 0, 0.1),
			0 3px 0 var(--color-border) !important;
		min-width: unset;
		height: unset;
	}

	.search-toggle-btn:active,
	.search-toggle-btn.active {
		transform: translateY(3px) !important;
		box-shadow:
			inset 0 2px 0 rgba(255, 255, 255, 0.5),
			inset 0 -2px 0 rgba(0, 0, 0, 0.1),
			0 0px 0 var(--color-border) !important;
		background-color: #99cc99 !important;
	}

	/* Compact Header */
	.compact-header {
		padding: 0.45rem 0.75rem;
		margin-bottom: 0.65rem;
		border-radius: 10px;
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
		border: 2.5px solid var(--color-border);
		border-radius: 6px;
		padding: 0.2rem 0.55rem;
		cursor: pointer;
		box-shadow: 0 2px 0 var(--color-border);
		transition: transform 0.1s ease, box-shadow 0.1s ease, background-color 0.2s ease;
		text-transform: uppercase;
	}
	.tab-btn:hover {
		background-color: #ffdca8;
	}
	.tab-btn:active, .tab-btn.active {
		background-color: #99cc99; /* sprout green */
		transform: translateY(2px);
		box-shadow: 0 0px 0 var(--color-border);
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

	.scrollable-grid-container {
		max-height: 10.5rem;
		overflow-y: auto;
		padding: 0.5rem 0.45rem !important;
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
		padding: 2.5rem 1rem;
		text-align: center;
	}

	.empty-emoji {
		font-size: 2.2rem;
		margin-bottom: 0.45rem;
	}

	.empty-state p {
		font-family: var(--font-body);
		font-size: 0.8rem;
		font-weight: 700;
		color: var(--color-text-muted);
		margin: 0;
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
		border: 3.5px solid var(--color-border);
		box-shadow: 0 6px 0 var(--color-border);
		border-radius: 12px;
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
		border-bottom: 3.5px solid var(--color-border);
		font-family: var(--font-display);
		font-size: 0.55rem;
		font-weight: 700;
	}

	.dialog-close-x {
		font-weight: 800;
		cursor: pointer;
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
			0 3.5px 0 #3d2c2a;
	}

	.dialog-ok-btn:active {
		transform: translateY(3.5px);
		box-shadow:
			inset 0 2px 0 rgba(255, 255, 255, 0.5),
			inset 0 -2px 0 rgba(0, 0, 0, 0.1),
			0 0px 0 #3d2c2a;
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
