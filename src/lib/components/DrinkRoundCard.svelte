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

<button type="button" class="chip" onclick={onSelect} aria-label="Quick log {drink.name}">
	{#if drink.imageUrl}
		<img src={drink.imageUrl} alt="" class="chip-img" aria-hidden="true" />
	{:else}
		<span class="chip-emoji" aria-hidden="true">{drink.emoji}</span>
	{/if}
	<span class="chip-name">{drink.name}</span>
	<span class="chip-mg">{drink.caffeineMg}mg</span>
</button>

<style>
	.chip {
		display: inline-flex;
		align-items: center;
		gap: 0.4rem;
		flex-shrink: 0;
		padding: 0.4rem 0.875rem 0.4rem 0.625rem;
		border-radius: var(--radius-full);
		background: var(--color-surface-container-lowest);
		border: 1px solid rgba(28, 46, 36, 0.15);
		box-shadow: var(--shadow-card);
		cursor: pointer;
		text-align: left;
		transition: background 0.2s ease, border-color 0.2s ease, transform 0.15s ease;
	}

	.chip:hover {
		background: rgba(28, 46, 36, 0.04);
		border-color: var(--color-primary);
	}

	.chip:active {
		transform: scale(0.96);
	}

	.chip-img {
		width: 1.5rem;
		height: 1.5rem;
		object-fit: contain;
		border-radius: var(--radius-md);
	}

	.chip-emoji {
		font-size: 1.25rem;
		line-height: 1;
	}

	.chip-name {
		font-family: var(--font-display);
		font-size: 0.95rem;
		font-weight: 500;
		color: var(--color-on-surface);
	}

	.chip-mg {
		font-family: var(--font-body);
		font-size: 0.625rem;
		font-weight: 600;
		color: var(--color-primary);
		background: rgba(28, 46, 36, 0.05);
		border: 1px solid rgba(28, 46, 36, 0.08);
		padding: 0.1rem 0.35rem;
		border-radius: var(--radius-full);
		letter-spacing: 0.02em;
	}
</style>
