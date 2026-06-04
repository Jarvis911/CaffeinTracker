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
	<button type="button" class="grid-card" class:is-favorite-card={isFavorite} onclick={onSelect} aria-label="Log {drink.name}">
		{#if drink.imageUrl}
			<img src={drink.imageUrl} alt={drink.name} class="drink-img" />
		{:else}
			<span class="drink-emoji" aria-hidden="true">{drink.emoji}</span>
		{/if}

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
		padding: 0.65rem 0.4rem;
		border-radius: 18px;
		border: 2.5px solid var(--color-border);
		background: 
			linear-gradient(rgba(250, 240, 221, 0.9), rgba(250, 240, 221, 0.9)),
			url('/images/minecraft_green_planks.png');
		background-size: auto, 96px;
		box-shadow:
			inset 0 3px 0 rgba(255, 255, 255, 0.85),
			inset 0 -5px 0 rgba(0, 0, 0, 0.2),
			0 4px 0 var(--color-border);
		cursor: pointer;
		text-align: center;
		gap: 0.35rem;
		position: relative;
		transition:
			transform 0.1s ease,
			box-shadow 0.1s ease,
			filter 0.15s ease;
	}

	/* Favorite highlighted style */
	.grid-card.is-favorite-card {
		background: url('/images/minecraft_green_planks.png');
		background-size: 96px;
		box-shadow:
			inset 0 3px 0 rgba(255, 255, 255, 0.85),
			inset 0 -5px 0 rgba(0, 0, 0, 0.25),
			0 4px 0 var(--color-border);
	}

	.grid-card:hover {
		filter: brightness(1.15);
		transform: translateY(-2px);
		box-shadow:
			inset 0 3px 0 rgba(255, 255, 255, 0.85),
			inset 0 -5px 0 rgba(0, 0, 0, 0.35),
			0 5.5px 0 var(--color-border);
	}

	.grid-card.is-favorite-card:hover {
		filter: brightness(1.15);
		transform: translateY(-2px);
		box-shadow:
			inset 0 3px 0 rgba(255, 255, 255, 0.85),
			inset 0 -5px 0 rgba(0, 0, 0, 0.45),
			0 5.5px 0 var(--color-border);
	}

	.grid-card:active {
		transform: translateY(4px);
		box-shadow:
			inset 0 2px 0 rgba(255, 255, 255, 0.85),
			inset 0 -2px 0 rgba(0, 0, 0, 0.35),
			0 0px 0 var(--color-border);
		filter: brightness(0.85);
	}

	.drink-img {
		width: 3.8rem;
		height: 3.8rem;
		object-fit: contain;
		flex-shrink: 0;
		filter: drop-shadow(0 2px 4px rgba(61, 44, 42, 0.15));
		transition: transform 0.2s ease;
	}

	.grid-card:hover .drink-img {
		transform: scale(1.1) rotate(4deg);
	}

	.drink-emoji {
		font-size: 3.4rem;
		line-height: 1;
		transition: transform 0.2s ease;
	}

	.grid-card:hover .drink-emoji {
		transform: scale(1.1) rotate(-4deg);
	}

	.drink-name {
		font-family: var(--font-body);
		font-weight: 700;
		font-size: 0.72rem;
		line-height: 1.15;
		color: var(--color-text);
		display: -webkit-box;
		-webkit-line-clamp: 2;
		line-clamp: 2;
		-webkit-box-orient: vertical;
		overflow: hidden;
		text-overflow: ellipsis;
		word-break: break-word;
		max-width: 100%;
		padding-inline: 0.1rem;
	}

	/* Heart Button style (3D tactile style) */
	.heart-btn {
		position: absolute;
		top: -0.25rem;
		right: -0.25rem;
		width: 1.75rem;
		height: 1.75rem;
		border-radius: 50%;
		border: 1.5px solid var(--color-border);
		background: #faf0dd;
		display: grid;
		place-items: center;
		cursor: pointer;
		box-shadow: 0 2px 0 var(--color-border);
		color: var(--color-text-muted);
		transition:
			transform 0.1s ease,
			box-shadow 0.1s ease,
			background 0.2s ease;
		padding: 0;
		z-index: 10;
	}

	.heart-btn:hover {
		background: #ffffff;
		color: var(--color-rose);
	}

	.heart-btn:active {
		transform: translateY(2px);
		box-shadow: 0 0px 0 var(--color-border);
	}

	.heart-icon {
		width: 0.85rem;
		height: 0.85rem;
		fill: none;
		stroke: currentColor;
		stroke-width: 3;
		transition:
			fill 0.2s ease,
			stroke 0.2s ease;
	}

	.heart-btn.is-favorite {
		color: var(--color-rose);
		background: #fff0f3;
	}

	.heart-btn.is-favorite .heart-icon {
		fill: var(--color-rose);
		stroke: var(--color-rose-deep);
	}

	/* Tooltip implementation (wooden signboard styled) */
	.tooltip {
		position: absolute;
		bottom: 110%;
		left: 50%;
		transform: translateX(-50%) translateY(6px);
		background: var(--color-accent-deep); /* dark brown wood */
		border: 1.75px solid var(--color-border);
		box-shadow: 0 2px 0 var(--color-border);
		color: #faf0dd;
		padding: 0.45rem 0.65rem;
		border-radius: 12px;
		font-size: 0.65rem;
		white-space: nowrap;
		display: flex;
		flex-direction: column;
		gap: 0.15rem;
		opacity: 0;
		pointer-events: none;
		z-index: 50;
		transition:
			opacity 0.15s ease,
			transform 0.15s ease;
		text-align: left;
	}

	.tooltip-title {
		font-family: var(--font-display);
		font-size: 0.62rem;
		font-weight: 700;
		letter-spacing: 0.03em;
		text-transform: uppercase;
		border-bottom: 1.5px solid rgba(255, 255, 255, 0.2);
		padding-bottom: 0.15rem;
		margin-bottom: 0.15rem;
	}

	/* Arrow/caret for tooltip */
	.tooltip::after {
		content: '';
		position: absolute;
		top: 100%;
		left: 50%;
		transform: translateX(-50%);
		border-width: 4px;
		border-style: solid;
		border-color: var(--color-border) transparent transparent transparent;
	}

	/* Show tooltip on hover or active/focus states */
	.grid-card:hover .tooltip,
	.grid-card:focus-within .tooltip {
		opacity: 1;
		transform: translateX(-50%) translateY(0);
	}

	/* On mobile, support touch trigger */
	@media (hover: none) {
		.grid-card:active .tooltip {
			opacity: 1;
			transform: translateX(-50%) translateY(0);
		}
	}
</style>
