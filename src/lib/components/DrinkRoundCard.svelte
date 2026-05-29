<script lang="ts">
	import type { DrinkTemplate } from '$lib/types';

	let {
		drink,
		onSelect
	}: {
		drink: DrinkTemplate;
		onSelect?: () => void;
	} = $props();
</script>

<button type="button" class="round-card" onclick={onSelect} aria-label="Log {drink.name}">
	<div class="tile">
		{#if drink.imageUrl}
			<img src={drink.imageUrl} alt={drink.name} class="drink-img" />
		{:else}
			<span class="drink-emoji" aria-hidden="true">{drink.emoji}</span>
		{/if}
	</div>
</button>

<style>
	.round-card {
		display: flex;
		flex-direction: column;
		align-items: center;
		border: none;
		background: none;
		cursor: pointer;
		padding: 0.1rem;
		width: 3.5rem;
		flex-shrink: 0;
		text-align: center;
	}

	.tile {
		width: 3.25rem;
		height: 3.25rem;
		border-radius: 10px;
		border: 3px solid var(--color-border);
		background: 
			linear-gradient(rgba(250, 240, 221, 0.9), rgba(250, 240, 221, 0.9)),
			url('/images/minecraft_green_planks.png');
		background-size: auto, 80px;
		display: grid;
		place-items: center;
		box-shadow:
			inset 0 3px 0 rgba(255, 255, 255, 0.85),
			inset 0 -6px 0 rgba(0, 0, 0, 0.2),
			0 5px 0 var(--color-border);
		transition:
			transform 0.1s ease,
			box-shadow 0.1s ease,
			filter 0.15s ease;
	}

	.round-card:hover .tile {
		filter: brightness(1.15);
		transform: translateY(-2px);
		box-shadow:
			inset 0 3px 0 rgba(255, 255, 255, 0.85),
			inset 0 -6px 0 rgba(0, 0, 0, 0.35),
			0 7px 0 var(--color-border);
	}

	.round-card:active .tile {
		transform: translateY(5px);
		box-shadow:
			inset 0 2px 0 rgba(255, 255, 255, 0.85),
			inset 0 -2px 0 rgba(0, 0, 0, 0.35),
			0 0px 0 var(--color-border);
		filter: brightness(0.85);
	}

	.drink-img {
		width: 2.4rem;
		height: 2.4rem;
		object-fit: contain;
		filter: drop-shadow(0 2px 4px rgba(61, 44, 42, 0.1));
		transition: transform 0.2s ease;
	}

	.round-card:hover .drink-img {
		transform: scale(1.1) rotate(5deg);
	}

	.drink-emoji {
		font-size: 2.1rem;
		line-height: 1;
		transition: transform 0.2s ease;
	}

	.round-card:hover .drink-emoji {
		transform: scale(1.1) rotate(-5deg);
	}
</style>
