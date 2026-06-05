<script lang="ts">
	import { browser } from '$app/environment';
	import { _ } from 'svelte-i18n';
	import {
		DrinkPhysicsBox,
		TOY_DISPLAY_PX,
		type PhysicsMode,
		type ToyItem
	} from '$lib/physics/drink-toy-box';
	import { app } from '$lib/state/app.svelte';
	import { getCaffeineStatus } from '$lib/personalization/recommendations';

	const MODE_STORAGE_KEY = 'caffein-tracker-toybox-mode';

	let { items }: { items: ToyItem[] } = $props();

	let physics: DrinkPhysicsBox | null = null;
	let splashes = $state<{ id: string; x: number; y: number; size: number }[]>([]);

	function loadSavedMode(): PhysicsMode {
		if (!browser) return 'chaos';
		const saved = localStorage.getItem(MODE_STORAGE_KEY);
		return saved === 'water' ? 'water' : 'chaos';
	}

	let physicsMode = $state<PhysicsMode>(loadSavedMode());

	const caffeine = $derived(getCaffeineStatus(app.profile, app.logs));
	const waterPercentage = $derived(
		caffeine.limit > 0 ? 0.15 + (Math.min(100, caffeine.percent) / 100) * 0.65 : 0.15
	);
	const isWaterMode = $derived(physicsMode === 'water');

	function setPhysicsMode(mode: PhysicsMode) {
		physicsMode = mode;
		if (browser) localStorage.setItem(MODE_STORAGE_KEY, mode);
		if (mode === 'chaos') splashes = [];
	}

	function handleDoubleClick(toyId: string) {
		const lastDashIndex = toyId.lastIndexOf('-');
		if (lastDashIndex === -1) return;
		const logId = toyId.substring(0, lastDashIndex);
		app.removeOneFromLog(logId);
	}

	function clearAllToday() {
		app.clearTodayLogs();
	}

	function handleSplash(x: number, y: number, velocityY: number) {
		if (physicsMode !== 'water') return;
		const id = Math.random().toString(36).substring(2, 9);
		const size = Math.min(1.6, 0.5 + velocityY * 0.15);
		splashes = [...splashes, { id, x, y, size }];
		setTimeout(() => {
			splashes = splashes.filter((s) => s.id !== id);
		}, 600);
	}

	function attachBox(node: HTMLDivElement) {
		if (!browser) return;

		physics = new DrinkPhysicsBox(node, {
			onDoubleClick: handleDoubleClick,
			onSplash: handleSplash,
			mode: physicsMode
		});
		physics.start();
		physics.syncItems(items);
		physics.setWaterPercentage(waterPercentage);
		physics.setMode(physicsMode);

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

	$effect(() => {
		if (physicsMode === 'water') {
			physics?.setWaterPercentage(waterPercentage);
		}
	});

	$effect(() => {
		physics?.setMode(physicsMode);
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
		<div class="mode-row">
			<span class="mode-label" id="toybox-mode-label">{$_('toybox.mode_label', { default: 'Physics mode' })}</span>
			<div class="mode-toggle" role="group" aria-labelledby="toybox-mode-label">
				<button
					type="button"
					class="mode-btn"
					class:active={physicsMode === 'chaos'}
					aria-pressed={physicsMode === 'chaos'}
					onclick={() => setPhysicsMode('chaos')}
				>
					<span aria-hidden="true">🎲</span>
					{$_('toybox.mode_chaos', { default: 'Chaos' })}
				</button>
				<button
					type="button"
					class="mode-btn"
					class:active={physicsMode === 'water'}
					aria-pressed={physicsMode === 'water'}
					onclick={() => setPhysicsMode('water')}
				>
					<span aria-hidden="true">🌊</span>
					{$_('toybox.mode_water', { default: 'Water' })}
				</button>
			</div>
		</div>
		<span class="hint">
			{#if isWaterMode}
				{$_('toybox.hint_water', {
					default: 'Drinks sink into the water — level follows your caffeine. Double-click to pop.'
				})}
			{:else}
				{$_('toybox.hint', { default: 'Tap & drag — physics chaos! Double-click to pop a drink.' })}
			{/if}
		</span>
	</div>

	<div class="claw-machine" class:mode-water={isWaterMode} class:mode-chaos={!isWaterMode}>
		{#if !isWaterMode}
			<div class="claw-rail" aria-hidden="true">
				<span class="claw">🦾</span>
			</div>
		{/if}
		<div
			class="playpen"
			class:playpen-water={isWaterMode}
			style="--toy-size: {TOY_DISPLAY_PX}px"
			use:attachBox
		>
			{#if items.length === 0}
				<p class="empty">{$_('toybox.empty', { default: 'Log a drink and watch it plop in here' })}</p>
			{/if}

			{#if isWaterMode}
			<!-- Water BG: Back wave, middle wave and rising bubbles -->
			<div class="water-container water-bg" style="height: {waterPercentage * 100}%;">
				<div class="wave wave-back">
					<svg viewBox="0 0 240 28" preserveAspectRatio="none" class="wave-svg">
						<defs>
							<linearGradient id="back-grad" x1="0%" y1="0%" x2="0%" y2="100%">
								<stop offset="0%" stop-color="#4db6ac" stop-opacity="0.04" />
								<stop offset="100%" stop-color="#00695c" stop-opacity="0.10" />
							</linearGradient>
						</defs>
						<path d="M0 15 Q 30 5, 60 15 T 120 15 T 180 15 T 240 15 L 240 28 L 0 28 Z" fill="url(#back-grad)" />
						<path d="M0 15 Q 30 5, 60 15 T 120 15 T 180 15 T 240 15" fill="none" stroke="rgba(0, 105, 92, 0.10)" stroke-width="0.2" stroke-linecap="round" />
					</svg>
				</div>
				<div class="wave wave-middle">
					<svg viewBox="0 0 240 28" preserveAspectRatio="none" class="wave-svg">
						<defs>
							<linearGradient id="mid-grad" x1="0%" y1="0%" x2="0%" y2="100%">
								<stop offset="0%" stop-color="#26a69a" stop-opacity="0.06" />
								<stop offset="100%" stop-color="#004d40" stop-opacity="0.12" />
							</linearGradient>
						</defs>
						<path d="M0 15 Q 30 25, 60 15 T 120 15 T 180 15 T 240 15 L 240 28 L 0 28 Z" fill="url(#mid-grad)" />
						<path d="M0 15 Q 30 25, 60 15 T 120 15 T 180 15 T 240 15" fill="none" stroke="rgba(0, 77, 64, 0.15)" stroke-width="0.2" stroke-linecap="round" />
					</svg>
				</div>

				<div class="water-bubbles">
					<span class="bubble bubble-1"></span>
					<span class="bubble bubble-2"></span>
					<span class="bubble bubble-3"></span>
					<span class="bubble bubble-4"></span>
					<span class="bubble bubble-5"></span>
				</div>
			</div>

			{#each splashes as splash (splash.id)}
				<div 
					class="splash-effect" 
					style="left: {splash.x}px; top: {splash.y}px; transform: translate(-50%, -100%) scale({splash.size});"
				>
					<span class="bubble-particle b1"></span>
					<span class="bubble-particle b2"></span>
					<span class="bubble-particle b3"></span>
					<span class="splash-wave"></span>
				</div>
			{/each}

			<div class="water-container water-fg" style="height: {waterPercentage * 100}%;">
				<div class="wave wave-front">
					<svg viewBox="0 0 240 28" preserveAspectRatio="none" class="wave-svg">
						<defs>
							<linearGradient id="front-grad" x1="0%" y1="0%" x2="0%" y2="100%">
								<stop offset="0%" stop-color="#4db6ac" stop-opacity="0.08" />
								<stop offset="100%" stop-color="#00796b" stop-opacity="0.16" />
							</linearGradient>
						</defs>
						<path d="M0 15 Q 30 10, 60 15 T 120 15 T 180 15 T 240 15 L 240 28 L 0 28 Z" fill="url(#front-grad)" />
						<path d="M0 15 Q 30 10, 60 15 T 120 15 T 180 15 T 240 15" fill="none" stroke="rgba(0, 77, 64, 0.22)" stroke-width="0.2" stroke-linecap="round" />
					</svg>
				</div>
			</div>
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
		font-size: 0.75rem;
		letter-spacing: 0.05em;
	}

	.btn-clear {
		display: flex;
		align-items: center;
		gap: 0.3rem;
		background: #e88ba0; /* rose pink clear button */
		border: 3px solid var(--color-border);
		box-shadow:
			inset 0 2.5px 0 rgba(255, 255, 255, 0.5),
			inset 0 -2.5px 0 rgba(0, 0, 0, 0.1),
			0 3.5px 0 var(--color-border);
		color: #3d2c2a;
		padding: 0.35rem 0.65rem;
		border-radius: 8px;
		font-family: var(--font-display);
		font-size: 0.55rem;
		font-weight: 700;
		cursor: pointer;
		text-transform: uppercase;
		transition: transform 0.1s ease, box-shadow 0.1s ease;
	}

	.btn-clear:hover {
		background: #f0a2b5;
	}

	.btn-clear:active {
		transform: translateY(3.5px);
		box-shadow:
			inset 0 2.5px 0 rgba(255, 255, 255, 0.5),
			inset 0 -2.5px 0 rgba(0, 0, 0, 0.1),
			0 0px 0 var(--color-border);
	}

	.trash-icon {
		font-size: 0.75rem;
	}

	.btn-text {
		font-family: var(--font-display);
	}

	.mode-row {
		display: flex;
		flex-wrap: wrap;
		align-items: center;
		gap: 0.45rem;
	}

	.mode-label {
		font-family: var(--font-body);
		font-size: 0.62rem;
		font-weight: 700;
		color: var(--color-text-muted);
		text-transform: uppercase;
		letter-spacing: 0.04em;
	}

	.mode-toggle {
		display: inline-flex;
		border-radius: 8px;
		border: 3px solid var(--color-border);
		box-shadow: 0 3px 0 var(--color-border);
		overflow: hidden;
		background: rgba(250, 240, 221, 0.65);
	}

	.mode-btn {
		display: inline-flex;
		align-items: center;
		gap: 0.25rem;
		padding: 0.3rem 0.55rem;
		border: none;
		background: transparent;
		font-family: var(--font-display);
		font-size: 0.52rem;
		font-weight: 700;
		text-transform: uppercase;
		color: var(--color-text-muted);
		cursor: pointer;
		transition:
			background 0.12s ease,
			color 0.12s ease;
	}

	.mode-btn + .mode-btn {
		border-left: 2px solid var(--color-border);
	}

	.mode-btn.active {
		background: #7ec8b8;
		color: #1b3d36;
	}

	.mode-btn:not(.active):hover {
		background: rgba(126, 200, 184, 0.35);
	}

	.hint {
		font-family: var(--font-body);
		font-size: 0.68rem;
		font-weight: 700;
		color: var(--color-text-muted);
	}

	.claw-machine.mode-water {
		padding-top: 0.55rem;
	}

	.playpen-water {
		background:
			linear-gradient(rgba(224, 247, 250, 0.55), rgba(224, 247, 250, 0.35)),
			linear-gradient(rgba(250, 240, 221, 0.85), rgba(250, 240, 221, 0.85)),
			url('/images/minecraft_green_planks.png');
		background-size:
			auto,
			auto,
			144px;
	}

	.claw-machine {
		position: relative;
		border-radius: 12px;
		padding: 0.55rem;
		background-image: url('/images/minecraft_green_planks.png');
		background-size: 96px;
		border: 4px solid var(--color-border);
		box-shadow:
			inset 0 3px 0 var(--color-wood-light),
			inset 0 -3px 0 var(--color-wood-dark),
			0 5px 0 var(--color-border);
	}

	.claw-rail {
		position: relative;
		height: 1.6rem;
		margin-bottom: 0.45rem;
		border-radius: 8px;
		background: 
			linear-gradient(rgba(75, 120, 86, 0.85), rgba(75, 120, 86, 0.85)),
			url('/images/minecraft_green_planks.png');
		background-size: auto, 80px;
		border: 3px solid var(--color-border);
		box-shadow: inset 0 2.5px 0 rgba(0, 0, 0, 0.2);
		overflow: hidden;
	}

	.claw {
		position: absolute;
		left: 50%;
		top: 50%;
		transform: translate(-50%, -50%);
		font-size: 1rem;
		animation: claw-dangle 4.5s ease-in-out infinite;
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
		height: 9.5rem;
		border-radius: 8px;
		overflow: hidden;
		background:
			linear-gradient(rgba(250, 240, 221, 0.9), rgba(250, 240, 221, 0.9)),
			url('/images/minecraft_green_planks.png');
		background-size: auto, 144px;
		border: 3px solid var(--color-border);
		box-shadow: inset 0 4px 0 rgba(0, 0, 0, 0.15);
	}

	.playpen :global(.physics-toy) {
		position: absolute;
		top: 0;
		left: 0;
		margin: 0;
		padding: 0;
		border: none;
		background: transparent;
		box-shadow: none;
		line-height: 1;
		cursor: grab;
		user-select: none;
		touch-action: none;
		text-size-adjust: none;
		-webkit-text-size-adjust: none;
		will-change: transform;
		width: var(--toy-size);
		height: var(--toy-size);
		display: flex;
		align-items: center;
		justify-content: center;
		z-index: 2;
	}

	.playpen :global(.physics-toy-emoji) {
		display: block;
		line-height: 1;
		font-family: 'Apple Color Emoji', 'Segoe UI Emoji', 'Noto Color Emoji', sans-serif;
		text-size-adjust: none;
		-webkit-text-size-adjust: none;
	}

	.playpen-water :global(.physics-toy) {
		cursor: default;
		z-index: 4;
	}

	.playpen :global(.physics-toy.grabbed) {
		cursor: grabbing;
		z-index: 5;
	}

	.playpen :global(.physics-toy:active) {
		cursor: grabbing;
	}

	.playpen-water :global(.physics-toy:active) {
		cursor: default;
	}

	.playpen :global(.physics-toy.popping) {
		animation: toy-pop-out 0.22s cubic-bezier(0.34, 1.56, 0.64, 1) forwards;
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
		font-size: 0.8rem;
		font-weight: 700;
		color: var(--color-text-muted);
		pointer-events: none;
	}

	.glass-shine {
		pointer-events: none;
		position: absolute;
		inset: 0.55rem;
		border-radius: 8px;
		background: linear-gradient(
			125deg,
			rgba(255, 255, 255, 0.3) 0%,
			transparent 40%,
			transparent 60%,
			rgba(255, 255, 255, 0.08) 100%
		);
	}

	/* Water & Wave Styling */
	.water-container {
		position: absolute;
		left: 0;
		right: 0;
		bottom: 0;
		overflow: hidden;
		pointer-events: none;
		transition: height 0.8s cubic-bezier(0.34, 1.56, 0.64, 1);
	}

	.water-bg {
		z-index: 1;
	}

	.water-fg {
		z-index: 3;
	}

	.wave {
		position: absolute;
		left: 0;
		width: 200%;
		height: calc(100% + 22px);
		bottom: 0;
		will-change: transform;
	}

	.wave-svg {
		width: 100%;
		height: 100%;
		display: block;
	}

	.wave-back {
		height: calc(100% + 18px);
		animation: wave-slide-left 8s linear infinite;
	}

	.wave-middle {
		height: calc(100% + 22px);
		animation: wave-slide-right 5.5s linear infinite;
	}

	.wave-front {
		height: calc(100% + 20px);
		animation: wave-slide-left 3.8s linear infinite;
	}

	@keyframes wave-slide-left {
		0% {
			transform: translateX(0);
		}
		100% {
			transform: translateX(-50%);
		}
	}

	@keyframes wave-slide-right {
		0% {
			transform: translateX(-50%);
		}
		100% {
			transform: translateX(0);
		}
	}

	/* Bubble Particle Animations in Water */
	.water-bubbles {
		position: absolute;
		inset: 0;
		overflow: hidden;
		pointer-events: none;
	}

	.bubble {
		position: absolute;
		bottom: -10px;
		background: rgba(255, 255, 255, 0.35);
		border-radius: 50%;
		animation: bubble-rise 4.5s ease-in infinite;
	}

	.bubble-1 {
		width: 4px;
		height: 4px;
		left: 15%;
		animation-duration: 3.5s;
		animation-delay: 0.2s;
		--bubble-sway: 8px;
	}
	.bubble-2 {
		width: 6px;
		height: 6px;
		left: 38%;
		animation-duration: 4.8s;
		animation-delay: 1.5s;
		--bubble-sway: -12px;
	}
	.bubble-3 {
		width: 3px;
		height: 3px;
		left: 58%;
		animation-duration: 3s;
		animation-delay: 0.8s;
		--bubble-sway: 6px;
	}
	.bubble-4 {
		width: 5px;
		height: 5px;
		left: 78%;
		animation-duration: 4.2s;
		animation-delay: 2.2s;
		--bubble-sway: -8px;
	}
	.bubble-5 {
		width: 4px;
		height: 4px;
		left: 88%;
		animation-duration: 3.9s;
		animation-delay: 1.1s;
		--bubble-sway: 10px;
	}

	@keyframes bubble-rise {
		0% {
			transform: translateY(0) translateX(0);
			opacity: 0;
		}
		10% {
			opacity: 0.6;
		}
		90% {
			opacity: 0.6;
		}
		100% {
			transform: translateY(-130px) translateX(var(--bubble-sway, 10px));
			opacity: 0;
		}
	}

	/* Splash Particle Effect */
	.splash-effect {
		position: absolute;
		pointer-events: none;
		z-index: 5;
		display: flex;
		justify-content: center;
		align-items: flex-end;
		width: 40px;
		height: 30px;
	}

	.splash-wave {
		position: absolute;
		bottom: 0;
		width: 24px;
		height: 8px;
		border-radius: 50%;
		border: 2px solid rgba(255, 255, 255, 0.85);
		animation: splash-ring 0.6s ease-out forwards;
	}

	.bubble-particle {
		position: absolute;
		width: 6px;
		height: 6px;
		background: rgba(255, 255, 255, 0.95);
		border-radius: 50%;
		bottom: 0;
	}

	.b1 {
		animation: splash-particle-left 0.5s cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards;
	}

	.b2 {
		animation: splash-particle-center 0.55s cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards;
		animation-delay: 0.05s;
	}

	.b3 {
		animation: splash-particle-right 0.5s cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards;
	}

	@keyframes splash-ring {
		0% {
			transform: scale(0.3);
			opacity: 1;
		}
		100% {
			transform: scale(2);
			opacity: 0;
		}
	}

	@keyframes splash-particle-left {
		0% {
			transform: translate(0, 0) scale(1);
			opacity: 1;
		}
		100% {
			transform: translate(-20px, -28px) scale(0.3);
			opacity: 0;
		}
	}

	@keyframes splash-particle-center {
		0% {
			transform: translate(0, 0) scale(1);
			opacity: 1;
		}
		100% {
			transform: translate(0, -36px) scale(0.3);
			opacity: 0;
		}
	}

	@keyframes splash-particle-right {
		0% {
			transform: translate(0, 0) scale(1);
			opacity: 1;
		}
		100% {
			transform: translate(20px, -28px) scale(0.3);
			opacity: 0;
		}
	}
</style>
