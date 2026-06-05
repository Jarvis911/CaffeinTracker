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
		border-radius: 20px;
		border: 2.5px solid var(--color-border);
		background: 
			linear-gradient(rgba(250, 240, 221, 0.9), rgba(250, 240, 221, 0.9)),
			url('/images/minecraft_green_planks.png');
		background-size: auto, 144px;
		box-shadow:
			inset 0 3px 0 rgba(255, 255, 255, 0.6),
			inset 0 -3px 0 rgba(0, 0, 0, 0.08),
			0 4px 0 var(--color-border);
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
		border-radius: 12px;
		border: 1.5px solid var(--color-border);
		font-weight: 700;
		font-size: 0.85rem;
		box-shadow: 0 1.5px 0 var(--color-border);
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
		font-family: var(--font-display);
		font-weight: 600;
		color: var(--color-text);
		text-shadow: none;
		background: 
			linear-gradient(rgba(250, 240, 221, 0.9), rgba(250, 240, 221, 0.9)),
			url('/images/minecraft_green_planks.png');
		background-size: auto, 96px;
		border: 2.5px solid var(--color-btn-border);
		border-radius: var(--btn-radius);
		padding: 0.55rem;
		cursor: pointer;
		box-shadow:
			inset 0 2.5px 0 rgba(255, 255, 255, 0.85),
			inset 0 -2.5px 0 rgba(0, 0, 0, 0.25),
			0 3px 0 var(--color-btn-border);
		transition: transform 0.1s ease, box-shadow 0.1s ease, filter 0.15s ease;
		display: inline-flex;
		align-items: center;
		justify-content: center;
		text-transform: uppercase;
		font-size: 0.75rem;
		letter-spacing: 0.03em;
	}

	.log-btn:hover {
		filter: brightness(1.15);
	}

	.log-btn:active {
		transform: translateY(4px);
		box-shadow:
			inset 0 2px 0 rgba(255, 255, 255, 0.85),
			inset 0 -2px 0 rgba(0, 0, 0, 0.45),
			0 0px 0 var(--color-btn-border);
		filter: brightness(0.85);
	}
</style>
