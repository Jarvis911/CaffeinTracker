<script lang="ts">
	import { _ } from 'svelte-i18n';
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
	<button type="button" class="grid-card" onclick={onSelect} aria-label="Log {drink.name}">
		{#if drink.imageUrl}
			<img src={drink.imageUrl} alt={drink.name} class="drink-img" />
		{:else}
			<span class="drink-emoji" aria-hidden="true">{drink.emoji}</span>
		{/if}
		<span class="drink-name">{drink.name}</span>

		<!-- Tooltip containing details -->
		<div class="tooltip" role="tooltip">
			<span class="tooltip-title">{drink.name}</span>
			<span class="tooltip-detail">⚡ {drink.caffeineMg} mg {$_('log.caffeine')}</span>
			<span class="tooltip-detail">🍬 {drink.sugarG}g {$_('log.sugar')}</span>
			<span class="tooltip-detail">🔥 {drink.calories} kcal</span>
		</div>
	</button>

	<!-- Heart/Favorite icon button -->
	{#if onToggleFavorite}
		<button
			type="button"
			class="heart-btn"
			class:is-favorite={isFavorite}
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
		aspect-ratio: 1 / 1;
	}

	.grid-card {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		width: 100%;
		height: 100%;
		padding: 0.75rem 0.5rem;
		border-radius: 1.25rem;
		border: 1px solid var(--color-border);
		background: var(--color-surface);
		box-shadow: var(--shadow-soft);
		cursor: pointer;
		text-align: center;
		gap: 0.4rem;
		transition:
			transform 0.2s cubic-bezier(0.34, 1.56, 0.64, 1),
			box-shadow 0.2s ease,
			border-color 0.2s ease;
	}

	.grid-card:hover {
		transform: translateY(-4px) scale(1.02);
		box-shadow: var(--shadow-lift);
		border-color: var(--color-accent-soft);
	}

	.grid-card:active {
		transform: scale(0.96);
	}

	.drink-img {
		width: 2.75rem;
		height: 2.75rem;
		object-fit: contain;
		flex-shrink: 0;
		filter: drop-shadow(0 4px 8px rgba(0, 0, 0, 0.06));
		transition: transform 0.2s ease;
	}

	.grid-card:hover .drink-img {
		transform: scale(1.08) rotate(3deg);
	}

	.drink-emoji {
		font-size: 2.25rem;
		line-height: 1;
		transition: transform 0.2s ease;
	}

	.grid-card:hover .drink-emoji {
		transform: scale(1.08) rotate(-3deg);
	}

	.drink-name {
		font-family: var(--font-display);
		font-weight: 700;
		font-size: 0.78rem;
		line-height: 1.2;
		color: var(--color-text);
		display: -webkit-box;
		-webkit-line-clamp: 2;
		line-clamp: 2;
		-webkit-box-orient: vertical;
		overflow: hidden;
		text-overflow: ellipsis;
		word-break: break-word;
		max-width: 100%;
		padding-inline: 0.15rem;
	}

	/* Heart Button style */
	.heart-btn {
		position: absolute;
		top: 0.5rem;
		right: 0.5rem;
		width: 1.75rem;
		height: 1.75rem;
		border-radius: 999px;
		border: none;
		background: rgba(255, 255, 255, 0.85);
		backdrop-filter: blur(4px);
		display: grid;
		place-items: center;
		cursor: pointer;
		box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);
		color: var(--color-text-muted);
		transition:
			transform 0.2s cubic-bezier(0.34, 1.56, 0.64, 1),
			background 0.2s ease,
			color 0.2s ease;
		padding: 0;
		z-index: 10;
	}

	.heart-btn:hover {
		transform: scale(1.15);
		background: #ffffff;
		color: var(--color-rose);
	}

	.heart-btn:active {
		transform: scale(0.9);
	}

	.heart-icon {
		width: 0.95rem;
		height: 0.95rem;
		fill: none;
		stroke: currentColor;
		stroke-width: 2.5;
		transition:
			fill 0.2s ease,
			stroke 0.2s ease;
	}

	.heart-btn.is-favorite {
		color: var(--color-rose);
		background: #ffffff;
		box-shadow: 0 2px 8px rgba(232, 139, 160, 0.2);
	}

	.heart-btn.is-favorite .heart-icon {
		fill: var(--color-rose);
		stroke: var(--color-rose-deep);
	}

	/* Tooltip implementation */
	.tooltip {
		position: absolute;
		bottom: 108%;
		left: 50%;
		transform: translateX(-50%) translateY(8px);
		background: rgba(61, 44, 42, 0.96);
		backdrop-filter: blur(8px);
		color: #ffffff;
		padding: 0.5rem 0.75rem;
		border-radius: 0.75rem;
		font-size: 0.72rem;
		white-space: nowrap;
		display: flex;
		flex-direction: column;
		gap: 0.2rem;
		opacity: 0;
		pointer-events: none;
		z-index: 50;
		box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
		transition:
			opacity 0.2s cubic-bezier(0.25, 0.8, 0.25, 1),
			transform 0.2s cubic-bezier(0.25, 0.8, 0.25, 1);
		border: 1px solid rgba(255, 255, 255, 0.1);
		text-align: left;
	}

	/* Arrow/caret for tooltip */
	.tooltip::after {
		content: '';
		position: absolute;
		top: 100%;
		left: 50%;
		transform: translateX(-50%);
		border-width: 5px;
		border-style: solid;
		border-color: rgba(61, 44, 42, 0.96) transparent transparent transparent;
	}

	/* Show tooltip on hover or active/focus states */
	.grid-card:hover .tooltip,
	.grid-card:focus-within .tooltip {
		opacity: 1;
		transform: translateX(-50%) translateY(0);
	}

	/* On mobile, support touch trigger by making tooltip persistent while active is pressed or via parent focus */
	@media (hover: none) {
		.grid-card:active .tooltip {
			opacity: 1;
			transform: translateX(-50%) translateY(0);
		}
	}
</style>
