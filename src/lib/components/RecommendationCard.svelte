<script lang="ts">
	import type { DrinkRecommendation } from '$lib/types';

	let {
		item,
		onLog
	}: {
		item: DrinkRecommendation;
		onLog: () => void;
	} = $props();

	const scoreColor = $derived(
		item.score >= 75 ? 'high' : item.score >= 50 ? 'mid' : 'low'
	);
</script>

<article class="rec">
	<div class="top">
		{#if item.drink.imageUrl}
			<img src={item.drink.imageUrl} alt={item.drink.name} class="emoji-img" />
		{:else}
			<span class="emoji" aria-hidden="true">{item.drink.emoji}</span>
		{/if}
		<div class="copy">
			<h3>{item.drink.name}</h3>
			<p>{item.reason}</p>
		</div>
		<span class="score {scoreColor}">{item.score}</span>
	</div>
	{#if item.tweaks?.length}
		<ul class="tweaks">
			{#each item.tweaks as tweak}
				<li>{tweak}</li>
			{/each}
		</ul>
	{/if}
	<button type="button" class="log-btn" onclick={onLog}>Log this drink</button>
</article>

<style>
	.rec {
		padding: 1rem;
		border-radius: 1.35rem;
		background: linear-gradient(
			145deg,
			color-mix(in srgb, var(--color-surface) 92%, white),
			var(--color-surface)
		);
		border: 1px solid var(--color-border);
		box-shadow: var(--shadow-soft);
	}

	.top {
		display: flex;
		align-items: flex-start;
		gap: 0.75rem;
	}

	.emoji {
		font-size: 2rem;
	}

	.emoji-img {
		width: 2.5rem;
		height: 2.5rem;
		object-fit: contain;
		flex-shrink: 0;
	}

	.copy {
		flex: 1;
	}

	h3 {
		margin: 0;
		font-size: 1rem;
		font-weight: 800;
	}

	p {
		margin: 0.25rem 0 0;
		font-size: 0.8rem;
		color: var(--color-text-muted);
		line-height: 1.35;
	}

	.score {
		min-width: 2.25rem;
		height: 2.25rem;
		display: grid;
		place-items: center;
		border-radius: 0.75rem;
		font-weight: 800;
		font-size: 0.85rem;
	}

	.score.high {
		background: color-mix(in srgb, var(--color-mint) 30%, white);
		color: var(--color-mint-deep);
	}

	.score.mid {
		background: color-mix(in srgb, var(--color-accent) 25%, white);
		color: var(--color-accent-deep);
	}

	.score.low {
		background: color-mix(in srgb, var(--color-rose) 25%, white);
		color: var(--color-rose-deep);
	}

	.tweaks {
		margin: 0.65rem 0 0;
		padding-left: 1.1rem;
		font-size: 0.75rem;
		color: var(--color-text-muted);
	}

	.log-btn {
		margin-top: 0.75rem;
		width: 100%;
		padding: 0.55rem;
		border: none;
		border-radius: 999px;
		background: var(--color-accent-soft);
		color: var(--color-accent-deep);
		font-weight: 700;
		font-size: 0.85rem;
		cursor: pointer;
		transition: background 0.2s ease;
	}

	.log-btn:hover {
		background: color-mix(in srgb, var(--color-accent) 35%, white);
	}
</style>
