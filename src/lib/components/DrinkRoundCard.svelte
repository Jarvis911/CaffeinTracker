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
	<div class="circle">
		{#if drink.imageUrl}
			<img src={drink.imageUrl} alt={drink.name} class="drink-img" />
		{:else}
			<span class="drink-emoji" aria-hidden="true">{drink.emoji}</span>
		{/if}
	</div>
	<span class="name">{drink.name}</span>
</button>

<style>
	.round-card {
		display: flex;
		flex-direction: column;
		align-items: center;
		gap: 0.35rem;
		border: none;
		background: none;
		cursor: pointer;
		padding: 0.15rem 0.25rem;
		width: 4.25rem;
		flex-shrink: 0;
		text-align: center;
		transition: transform 0.2s ease;
	}

	.circle {
		width: 3.25rem;
		height: 3.25rem;
		border-radius: 999px;
		border: 1px solid var(--color-border);
		background: var(--color-surface);
		display: grid;
		place-items: center;
		box-shadow: var(--shadow-soft);
		transition:
			transform 0.2s cubic-bezier(0.34, 1.56, 0.64, 1),
			box-shadow 0.2s ease,
			border-color 0.2s ease;
	}

	.round-card:hover .circle {
		transform: scale(1.08) translateY(-2px);
		box-shadow: var(--shadow-lift);
		border-color: var(--color-accent-soft);
	}

	.round-card:active .circle {
		transform: scale(0.94);
	}

	.drink-img {
		width: 2rem;
		height: 2rem;
		object-fit: contain;
		filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.05));
		transition: transform 0.2s ease;
	}

	.round-card:hover .drink-img {
		transform: scale(1.1) rotate(5deg);
	}

	.drink-emoji {
		font-size: 1.6rem;
		line-height: 1;
		transition: transform 0.2s ease;
	}

	.round-card:hover .drink-emoji {
		transform: scale(1.1) rotate(-5deg);
	}

	.name {
		font-family: var(--font-body);
		font-size: 0.68rem;
		font-weight: 700;
		color: var(--color-text-muted);
		width: 100%;
		white-space: nowrap;
		overflow: hidden;
		text-overflow: ellipsis;
		display: block;
		transition: color 0.2s ease;
	}

	.round-card:hover .name {
		color: var(--color-text);
	}
</style>
