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

<MascotHeader title={$_('log.title')} subtitle={$_('log.subtitle')} />

<div class="log-page-container">
	<!-- Search bar -->
	<div class="search-container fade-in" style="animation-delay: 0.05s">
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
				>×</button>
			{/if}
		</div>
	</div>

	<!-- Category Filter Chips -->
	<div class="categories-row fade-in" style="animation-delay: 0.1s">
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

	<!-- Favorites Row -->
	{#if favoriteDrinks.length > 0}
		<div class="favorites-section fade-in" style="animation-delay: 0.15s">
			<h3 class="section-title-small">{$_('log.favorites')}</h3>
			<div class="horizontal-scroll">
				{#each favoriteDrinks as drink (drink.id)}
					<DrinkRoundCard drink={drink} onSelect={() => log(drink.id)} />
				{/each}
			</div>
		</div>
	{/if}

	<!-- Recents Row -->
	{#if recentDrinks.length > 0}
		<div class="recent-section fade-in" style="animation-delay: 0.2s">
			<h3 class="section-title-small">{$_('log.recent')}</h3>
			<div class="horizontal-scroll">
				{#each recentDrinks as drink (drink.id)}
					<DrinkRoundCard drink={drink} onSelect={() => log(drink.id)} />
				{/each}
			</div>
		</div>
	{/if}

	<!-- Grid selection of drinks -->
	<div class="grid-section fade-in" style="animation-delay: 0.25s">
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

<!-- Floating Logged Toast -->
{#if loggedId}
	<div class="toast-overlay" role="status">
		<div class="toast-box">
			<span class="toast-emoji" aria-hidden="true">🥤</span>
			{$_('log.logged_toast')}
		</div>
	</div>
{/if}

<section class="fade-in toy-wrap" style="animation-delay: 0.3s">
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
		border-radius: 1.5rem;
		border: 1px solid var(--color-border);
		background: var(--color-surface);
		box-shadow: var(--shadow-soft);
		outline: none;
		transition:
			border-color 0.2s ease,
			box-shadow 0.2s ease;
	}

	.search-input:focus {
		border-color: var(--color-accent);
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
		border-radius: 999px;
		border: 1px solid var(--color-border);
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
		border-color: var(--color-accent-soft);
		transform: translateY(-1px);
	}

	.category-chip:active {
		transform: scale(0.96);
	}

	.category-chip.active {
		background: linear-gradient(135deg, var(--color-accent), var(--color-accent-deep));
		color: #ffffff;
		border-color: transparent;
		box-shadow: 0 4px 12px rgba(232, 137, 107, 0.35);
	}

	/* Scroll Sections (Favorites & Recent) */
	.favorites-section,
	.recent-section {
		display: flex;
		flex-direction: column;
		gap: 0.45rem;
	}

	.section-title-small {
		font-family: var(--font-display);
		font-size: 0.72rem;
		font-weight: 800;
		text-transform: uppercase;
		letter-spacing: 0.08em;
		color: var(--color-text-muted);
		margin: 0;
		padding-left: 0.25rem;
	}

	.horizontal-scroll {
		display: flex;
		gap: 0.75rem;
		overflow-x: auto;
		scroll-behavior: smooth;
		scrollbar-width: none;
		padding: 0.25rem 0.25rem 0.65rem;
		margin-inline: -1.25rem;
		padding-inline: 1.5rem;
	}

	.horizontal-scroll::-webkit-scrollbar {
		display: none;
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
		border-radius: 1.5rem;
		border: 1px dashed var(--color-border);
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

	/* Premium Floating Toast styles */
	.toast-overlay {
		position: fixed;
		bottom: 5.5rem;
		left: 50%;
		transform: translateX(-50%);
		z-index: 100;
		pointer-events: none;
	}

	.toast-box {
		background: rgba(126, 201, 168, 0.95);
		backdrop-filter: blur(8px);
		color: var(--color-mint-deep);
		padding: 0.65rem 1.25rem;
		border-radius: 999px;
		font-family: var(--font-display);
		font-weight: 800;
		font-size: 0.82rem;
		display: flex;
		align-items: center;
		gap: 0.45rem;
		box-shadow: 0 6px 20px rgba(126, 201, 168, 0.3);
		border: 1px solid rgba(126, 201, 168, 0.3);
		animation:
			toastPop 0.35s cubic-bezier(0.175, 0.885, 0.32, 1.275) both,
			toastFadeOut 0.3s ease 1.5s both;
	}

	.toast-emoji {
		font-size: 1.05rem;
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
		100% {
			opacity: 0;
		}
	}
</style>
