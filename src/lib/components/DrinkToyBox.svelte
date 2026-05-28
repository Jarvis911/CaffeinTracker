<script lang="ts">
	import { browser } from '$app/environment';
	import { _ } from 'svelte-i18n';
	import { DrinkPhysicsBox, type ToyItem } from '$lib/physics/drink-toy-box';
	import { app } from '$lib/state/app.svelte';

	let { items }: { items: ToyItem[] } = $props();

	let physics: DrinkPhysicsBox | null = null;

	function handleDoubleClick(toyId: string) {
		const lastDashIndex = toyId.lastIndexOf('-');
		if (lastDashIndex === -1) return;
		const logId = toyId.substring(0, lastDashIndex);
		app.removeOneFromLog(logId);
	}

	function clearAllToday() {
		app.clearTodayLogs();
	}

	function attachBox(node: HTMLDivElement) {
		if (!browser) return;

		physics = new DrinkPhysicsBox(node, {
			onDoubleClick: handleDoubleClick
		});
		physics.start();
		physics.syncItems(items);

		return {
			destroy() {
				physics?.destroy();
				physics = null;
			}
		};
	}

	$effect(() => {
		physics?.syncItems(items);
	});
</script>

<section class="toy-section" aria-label="Drink toy box">
	<div class="toy-header">
		<div class="title-group">
			<h2 class="section-title">{$_('toybox.title', { default: 'Your drink pile' })}</h2>
			{#if items.length > 0}
				<button class="btn-clear" onclick={clearAllToday} title={$_('toybox.clear_title', { default: "Clear all today's drinks" })}>
					<span class="trash-icon">🗑️</span>
					<span class="btn-text">{$_('toybox.clear', { default: 'Clear' })}</span>
				</button>
			{/if}
		</div>
		<span class="hint">{$_('toybox.hint', { default: 'Tap & drag — physics chaos! Double-click to pop a drink.' })}</span>
	</div>

	<div class="claw-machine">
		<div class="claw-rail" aria-hidden="true">
			<span class="claw">🦾</span>
		</div>
		<div class="playpen" use:attachBox>
			{#if items.length === 0}
				<p class="empty">{$_('toybox.empty', { default: 'Log a drink and watch it plop in here' })}</p>
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
		flex-direction: column;
		gap: 0.25rem;
		margin-bottom: 0.65rem;
	}

	.title-group {
		display: flex;
		align-items: center;
		justify-content: space-between;
		width: 100%;
	}

	.toy-header .section-title {
		margin: 0;
	}

	.btn-clear {
		display: flex;
		align-items: center;
		gap: 0.35rem;
		background: rgba(255, 255, 255, 0.6);
		border: 1px solid color-mix(in srgb, var(--color-accent) 25%, transparent);
		padding: 0.3rem 0.65rem;
		border-radius: 0.75rem;
		font-size: 0.75rem;
		font-weight: 600;
		color: var(--color-accent-deep);
		cursor: pointer;
		transition: all 0.2s ease;
		backdrop-filter: blur(4px);
	}

	.btn-clear:hover {
		background: var(--color-accent-soft);
		border-color: var(--color-accent);
		transform: translateY(-1px);
	}

	.btn-clear:active {
		transform: translateY(0);
	}

	.trash-icon {
		font-size: 0.85rem;
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
		font-size: 3.1rem;
		line-height: 1;
		cursor: grab;
		user-select: none;
		touch-action: none;
		will-change: transform;
		filter: drop-shadow(0 4px 8px rgba(61, 44, 42, 0.15));
		transition: filter 0.15s ease;
		width: 76px;
		height: 76px;
		display: flex;
		align-items: center;
		justify-content: center;
	}

	.playpen :global(.physics-toy.grabbed) {
		cursor: grabbing;
		filter: drop-shadow(0 8px 14px rgba(196, 95, 66, 0.35));
		z-index: 5;
	}

	.playpen :global(.physics-toy:active) {
		cursor: grabbing;
	}

	.playpen :global(.physics-toy.popping) {
		animation: toy-pop-out 0.25s cubic-bezier(0.34, 1.56, 0.64, 1) forwards;
	}

	@keyframes toy-pop-out {
		0% {
			transform: scale(1);
			opacity: 1;
		}
		100% {
			transform: scale(0);
			opacity: 0;
		}
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
