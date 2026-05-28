<script lang="ts">
	import { browser } from '$app/environment';
	import { DrinkPhysicsBox, type ToyItem } from '$lib/physics/drink-toy-box';

	let { items }: { items: ToyItem[] } = $props();

	let physics: DrinkPhysicsBox | null = null;

	function attachBox(node: HTMLDivElement) {
		if (!browser) return;

		physics = new DrinkPhysicsBox(node);
		physics.start();
		physics.syncItems(items);

		return () => {
			physics?.destroy();
			physics = null;
		};
	}

	$effect(() => {
		physics?.syncItems(items);
	});
</script>

<section class="toy-section" aria-label="Drink toy box">
	<div class="toy-header">
		<h2 class="section-title">Your drink pile</h2>
		<span class="hint">Tap & drag — physics chaos!</span>
	</div>

	<div class="claw-machine">
		<div class="claw-rail" aria-hidden="true">
			<span class="claw">🦾</span>
		</div>
		<div class="playpen" {@attach attachBox}>
			{#if items.length === 0}
				<p class="empty">Log a drink and watch it plop in here</p>
			{/if}
		</div>
		<div class="glass-shine" aria-hidden="true"></div>
	</div>
</section>

<style>
	.toy-section {
		margin-top: 0.25rem;
	}

	.toy-header {
		display: flex;
		align-items: baseline;
		justify-content: space-between;
		gap: 0.5rem;
		margin-bottom: 0.65rem;
	}

	.toy-header .section-title {
		margin: 0;
	}

	.hint {
		font-size: 0.7rem;
		font-weight: 600;
		color: var(--color-accent-deep);
	}

	.claw-machine {
		position: relative;
		border-radius: 1.35rem;
		padding: 0.55rem;
		background: linear-gradient(160deg, #ffece4, #fff5ef 45%, #f8e8ff);
		border: 3px solid color-mix(in srgb, var(--color-accent) 55%, white);
		box-shadow:
			inset 0 0 0 1px rgba(255, 255, 255, 0.7),
			var(--shadow-lift);
	}

	.claw-rail {
		position: relative;
		height: 1.75rem;
		margin-bottom: 0.35rem;
		border-radius: 999px;
		background: linear-gradient(90deg, #e8d5cf, #f5ebe6, #e8d5cf);
		overflow: hidden;
	}

	.claw {
		position: absolute;
		left: 50%;
		top: 50%;
		transform: translate(-50%, -50%);
		font-size: 1.1rem;
		animation: claw-dangle 2.8s ease-in-out infinite;
	}

	@keyframes claw-dangle {
		0%,
		100% {
			transform: translate(-50%, -50%) rotate(-6deg);
		}
		50% {
			transform: translate(-48%, -42%) rotate(8deg);
		}
	}

	.playpen {
		position: relative;
		height: 14.5rem;
		border-radius: 1rem;
		overflow: hidden;
		background:
			radial-gradient(ellipse 90% 60% at 50% 110%, rgba(232, 137, 107, 0.18), transparent),
			linear-gradient(180deg, #fffdfb 0%, #fff4ec 100%);
		border: 2px dashed color-mix(in srgb, var(--color-accent) 35%, white);
	}

	.playpen :global(.physics-toy) {
		position: absolute;
		top: 0;
		left: 0;
		margin: 0;
		padding: 0;
		border: none;
		background: transparent;
		font-size: 2.1rem;
		line-height: 1;
		cursor: grab;
		user-select: none;
		touch-action: none;
		will-change: transform;
		filter: drop-shadow(0 4px 8px rgba(61, 44, 42, 0.15));
		transition: filter 0.15s ease;
	}

	.playpen :global(.physics-toy.grabbed) {
		cursor: grabbing;
		filter: drop-shadow(0 8px 14px rgba(196, 95, 66, 0.35));
		z-index: 5;
	}

	.playpen :global(.physics-toy:active) {
		cursor: grabbing;
	}

	.empty {
		position: absolute;
		inset: 0;
		display: grid;
		place-items: center;
		margin: 0;
		padding: 1rem;
		text-align: center;
		font-size: 0.85rem;
		font-weight: 600;
		color: var(--color-text-muted);
		pointer-events: none;
	}

	.glass-shine {
		pointer-events: none;
		position: absolute;
		inset: 0.55rem;
		border-radius: 1rem;
		background: linear-gradient(
			125deg,
			rgba(255, 255, 255, 0.45) 0%,
			transparent 38%,
			transparent 62%,
			rgba(255, 255, 255, 0.12) 100%
		);
	}
</style>
