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
		<span class="score {scoreColor}" aria-label="Score {item.score}">{item.score}</span>
	</div>
	{#if item.tweaks?.length}
		<ul class="tweaks">
			{#each item.tweaks as tweak}
				<li>{tweak}</li>
			{/each}
		</ul>
	{/if}
	<button type="button" class="log-btn" onclick={onLog}>
		<span class="material-symbols-outlined log-btn-icon">add_circle</span>
		Log this drink
	</button>
</article>

<style>
	.rec {
		padding: var(--space-gutter);
		border-radius: var(--radius-xl);
		border: 1px solid rgba(28, 46, 36, 0.12);
		background: var(--color-surface-container-lowest);
		box-shadow: var(--shadow-card);
		display: flex;
		flex-direction: column;
		gap: 0.75rem;
		transition: border-color 0.2s ease, box-shadow 0.2s ease;
	}

	.rec:hover {
		border-color: rgba(28, 46, 36, 0.2);
		box-shadow: 0px 6px 20px rgba(28, 46, 36, 0.06);
	}

	.top {
		display: flex;
		align-items: flex-start;
		gap: 0.75rem;
	}

	.emoji {
		font-size: 2rem;
		line-height: 1;
		flex-shrink: 0;
	}

	.emoji-img {
		width: 2.5rem;
		height: 2.5rem;
		object-fit: contain;
		flex-shrink: 0;
		border-radius: var(--radius-md);
	}

	.copy {
		flex: 1;
		min-width: 0;
	}

	h3 {
		margin: 0 0 0.2rem;
		font-family: var(--font-display);
		font-size: 1.05rem;
		font-weight: 600;
		color: var(--color-on-surface);
		letter-spacing: -0.01em;
	}

	p {
		margin: 0;
		font-family: var(--font-body);
		font-size: 0.78rem;
		color: var(--color-on-surface-variant);
		line-height: 1.45;
	}

	.score {
		flex-shrink: 0;
		min-width: 2.25rem;
		height: 2.25rem;
		display: grid;
		place-items: center;
		border-radius: var(--radius-full);
		font-family: var(--font-body);
		font-weight: 700;
		font-size: 0.8rem;
	}

	.score.high {
		background: rgba(28, 46, 36, 0.1);
		color: var(--color-primary);
		border: 1px solid rgba(28, 46, 36, 0.2);
	}

	.score.mid {
		background: rgba(186, 109, 86, 0.1);
		color: var(--color-secondary);
		border: 1px solid rgba(186, 109, 86, 0.25);
	}

	.score.low {
		background: rgba(186, 26, 26, 0.08);
		color: var(--color-error);
		border: 1px solid rgba(186, 26, 26, 0.2);
	}

	.tweaks {
		margin: 0;
		padding: 0.5rem 0.75rem;
		list-style: none;
		background: rgba(140, 119, 93, 0.06);
		border-radius: var(--radius-lg);
		border-left: 2px solid var(--color-tertiary-fixed-dim);
		display: flex;
		flex-direction: column;
		gap: 0.25rem;
	}

	.tweaks li {
		font-family: var(--font-body);
		font-size: 0.75rem;
		color: var(--color-on-surface-variant);
		line-height: 1.4;
	}

	.tweaks li::before {
		content: '-> ';
		color: var(--color-tertiary);
		font-weight: 600;
	}

	.log-btn {
		display: inline-flex;
		align-items: center;
		justify-content: center;
		gap: 0.4rem;
		width: 100%;
		padding: 0.625rem 1rem;
		font-family: var(--font-body);
		font-size: 0.78rem;
		font-weight: 600;
		text-transform: uppercase;
		letter-spacing: 0.05em;
		color: var(--color-primary);
		background: transparent;
		border: 1px solid var(--color-primary);
		border-radius: var(--radius-full);
		cursor: pointer;
		transition: background 0.2s ease, color 0.2s ease;
	}

	.log-btn:hover {
		background: var(--color-primary);
		color: var(--color-on-primary);
	}

	.log-btn:active {
		transform: scale(0.97);
	}

	.log-btn-icon {
		font-size: 1rem;
	}
</style>
