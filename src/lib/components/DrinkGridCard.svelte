<script lang="ts">
	import type { DrinkTemplate } from '$lib/types';

	let {
		drink,
		isFavorite = false,
		onSelect,
		onToggleFavorite
	}: {
		drink: DrinkTemplate;
		isFavorite?: boolean;
		onSelect?: () => void;
		onToggleFavorite?: () => void;
	} = $props();
</script>

<div class="card-wrapper">
	<button
		type="button"
		class="grid-card"
		class:is-favorite={isFavorite}
		onclick={onSelect}
		aria-label="Log {drink.name}"
	>
		{#if drink.imageUrl}
			<img src={drink.imageUrl} alt={drink.name} class="drink-img" />
		{:else}
			<span class="drink-emoji" aria-hidden="true">{drink.emoji}</span>
		{/if}
		<span class="drink-name">{drink.name}</span>
		<span class="caffeine-badge">{drink.caffeineMg}mg</span>

		<!-- Tooltip -->
		<div class="tooltip" role="tooltip">
			<span class="tooltip-title">{drink.name}</span>
			<span class="tooltip-row">⚡ {drink.caffeineMg} mg caffeine</span>
			<span class="tooltip-row">🍬 {drink.sugarG}g sugar</span>
			<span class="tooltip-row">🔥 {drink.calories} kcal</span>
		</div>
	</button>

	{#if onToggleFavorite}
		<button
			type="button"
			class="heart-btn"
			class:active={isFavorite}
			onclick={(e) => {
				e.stopPropagation();
				onToggleFavorite();
			}}
			aria-label={isFavorite ? 'Remove from favorites' : 'Add to favorites'}
		>
			<svg class="heart-icon" viewBox="0 0 24 24" aria-hidden="true">
				<path
					d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"
				/>
			</svg>
		</button>
	{/if}
</div>

<style>
	.card-wrapper {
		position: relative;
		width: 100%;
	}

	.grid-card {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: flex-start;
		width: 100%;
		padding: 0.875rem 0.5rem 0.75rem;
		border-radius: var(--radius-xl);
		background: var(--color-surface-container-lowest);
		border: 1px solid transparent;
		box-shadow: var(--shadow-card);
		cursor: pointer;
		text-align: center;
		gap: 0.25rem;
		position: relative;
		transition: border-color 0.2s ease, transform 0.15s ease, box-shadow 0.15s ease;
	}

	.grid-card:hover {
		border-color: rgba(197, 200, 187, 0.5);
		transform: translateY(-2px);
	}

	.grid-card.is-favorite {
		background: rgba(213, 234, 181, 0.15);
		border-color: rgba(185, 206, 155, 0.4);
	}

	.grid-card:active {
		transform: scale(0.96);
		box-shadow: var(--shadow-press);
	}

	.drink-img {
		width: 3rem;
		height: 3rem;
		object-fit: contain;
		border-radius: var(--radius-lg);
		transition: transform 0.2s ease;
	}

	.grid-card:hover .drink-img {
		transform: scale(1.08);
	}

	.drink-emoji {
		font-size: 2.25rem;
		line-height: 1;
		transition: transform 0.2s ease;
	}

	.grid-card:hover .drink-emoji {
		transform: scale(1.08);
	}

	.drink-name {
		font-family: var(--font-body);
		font-weight: 600;
		font-size: 0.72rem;
		line-height: 1.2;
		color: var(--color-on-surface);
		display: -webkit-box;
		-webkit-line-clamp: 2;
		line-clamp: 2;
		-webkit-box-orient: vertical;
		overflow: hidden;
		max-width: 100%;
	}

	.caffeine-badge {
		font-family: var(--font-body);
		font-size: 0.65rem;
		font-weight: 600;
		color: var(--color-primary);
		background: rgba(80, 98, 56, 0.08);
		padding: 0.1rem 0.4rem;
		border-radius: var(--radius-full);
		letter-spacing: 0.02em;
	}

	/* Heart button */
	.heart-btn {
		position: absolute;
		top: -0.35rem;
		right: -0.35rem;
		width: 1.625rem;
		height: 1.625rem;
		border-radius: 50%;
		border: 1px solid var(--color-outline-variant);
		background: var(--color-surface-container-lowest);
		box-shadow: var(--shadow-card);
		display: grid;
		place-items: center;
		cursor: pointer;
		padding: 0;
		z-index: 10;
		transition: background 0.2s ease, border-color 0.2s ease;
	}

	.heart-btn:hover {
		background: #fff0f3;
		border-color: var(--color-secondary);
	}

	.heart-icon {
		width: 0.8rem;
		height: 0.8rem;
		fill: none;
		stroke: var(--color-outline);
		stroke-width: 2.5;
		transition: fill 0.2s ease, stroke 0.2s ease;
	}

	.heart-btn.active .heart-icon {
		fill: var(--color-secondary);
		stroke: var(--color-secondary);
	}

	/* Tooltip */
	.tooltip {
		position: absolute;
		bottom: 110%;
		left: 50%;
		transform: translateX(-50%) translateY(6px);
		background: var(--color-inverse-surface);
		color: var(--color-inverse-on-surface);
		padding: 0.5rem 0.75rem;
		border-radius: var(--radius-lg);
		font-size: 0.7rem;
		white-space: nowrap;
		display: flex;
		flex-direction: column;
		gap: 0.15rem;
		opacity: 0;
		pointer-events: none;
		z-index: 50;
		transition: opacity 0.15s ease, transform 0.15s ease;
		text-align: left;
		box-shadow: 0px 4px 16px rgba(0, 0, 0, 0.2);
	}

	.tooltip::after {
		content: '';
		position: absolute;
		top: 100%;
		left: 50%;
		transform: translateX(-50%);
		border-width: 4px;
		border-style: solid;
		border-color: var(--color-inverse-surface) transparent transparent transparent;
	}

	.tooltip-title {
		font-family: var(--font-display);
		font-size: 0.7rem;
		font-weight: 600;
		border-bottom: 1px solid rgba(255, 255, 255, 0.15);
		padding-bottom: 0.2rem;
		margin-bottom: 0.15rem;
	}

	.tooltip-row {
		font-family: var(--font-body);
		font-size: 0.65rem;
		opacity: 0.85;
	}

	.grid-card:hover .tooltip,
	.grid-card:focus-within .tooltip {
		opacity: 1;
		transform: translateX(-50%) translateY(0);
	}

	@media (hover: none) {
		.grid-card:active .tooltip {
			opacity: 1;
			transform: translateX(-50%) translateY(0);
		}
	}
</style>
