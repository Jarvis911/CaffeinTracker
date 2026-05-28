<script lang="ts">
	import type { DrinkTemplate } from '$lib/types';

	let {
		drink,
		onSelect,
		compact = false
	}: {
		drink: DrinkTemplate;
		onSelect?: () => void;
		compact?: boolean;
	} = $props();
</script>

<button type="button" class="card" class:compact onclick={onSelect} disabled={!onSelect}>
	{#if drink.imageUrl}
		<img src={drink.imageUrl} alt={drink.name} class="emoji-img" />
	{:else}
		<span class="emoji" aria-hidden="true">{drink.emoji}</span>
	{/if}
	<div class="info">
		<span class="name">{drink.name}</span>
		<span class="meta">{drink.caffeineMg} mg · {drink.sugarG}g sugar</span>
	</div>
	{#if onSelect}
		<span class="add" aria-hidden="true">+</span>
	{/if}
</button>

<style>
	.card {
		display: flex;
		align-items: center;
		gap: 0.75rem;
		width: 100%;
		padding: 0.85rem 1rem;
		border-radius: 1.25rem;
		border: 1px solid var(--color-border);
		background: var(--color-surface);
		box-shadow: var(--shadow-soft);
		text-align: left;
		transition:
			transform 0.2s ease,
			box-shadow 0.2s ease;
	}

	.card:not(:disabled):hover {
		transform: translateY(-2px);
		box-shadow: var(--shadow-lift);
	}

	.card:not(:disabled):active {
		transform: scale(0.98);
	}

	.card.compact {
		padding: 0.65rem 0.85rem;
	}

	.emoji {
		font-size: 1.75rem;
	}

	.emoji-img {
		width: 2.25rem;
		height: 2.25rem;
		object-fit: contain;
		flex-shrink: 0;
	}

	.info {
		flex: 1;
		display: flex;
		flex-direction: column;
		gap: 0.15rem;
	}

	.name {
		font-weight: 700;
		font-size: 0.95rem;
		color: var(--color-text);
	}

	.meta {
		font-size: 0.75rem;
		color: var(--color-text-muted);
	}

	.add {
		width: 2rem;
		height: 2rem;
		display: grid;
		place-items: center;
		border-radius: 999px;
		background: var(--color-accent-soft);
		color: var(--color-accent-deep);
		font-weight: 800;
		font-size: 1.1rem;
	}
</style>
