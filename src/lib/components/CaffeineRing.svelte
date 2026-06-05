<script lang="ts">
	import { tweened } from 'svelte/motion';
	import { cubicOut } from 'svelte/easing';

	let {
		percent,
		consumed,
		limit
	}: {
		percent: number;
		consumed: number;
		limit: number;
	} = $props();

	const animated = tweened(0, { duration: 900, easing: cubicOut });

	$effect(() => {
		animated.set(percent);
	});

	const radius = 54;
	const circumference = 2 * Math.PI * radius;
	const strokeDash = $derived((($animated / 100) * circumference).toFixed(2));
</script>

<div class="ring-wrap" aria-label="Daily caffeine {Math.round(percent)} percent">
	<svg viewBox="0 0 128 128" class="ring-svg" role="img">
		<circle
			cx="64"
			cy="64"
			r={radius}
			fill="none"
			stroke="var(--color-ring-track)"
			stroke-width="12"
		/>
		<circle
			cx="64"
			cy="64"
			r={radius}
			fill="none"
			stroke="url(#caffeineGradient)"
			stroke-width="12"
			stroke-linecap="round"
			stroke-dasharray="{circumference}"
			stroke-dashoffset={circumference - Number(strokeDash)}
			transform="rotate(-90 64 64)"
			class="ring-progress"
		/>
		<defs>
			<linearGradient id="caffeineGradient" x1="0%" y1="0%" x2="100%" y2="100%">
				<stop offset="0%" stop-color="var(--color-accent)" />
				<stop offset="100%" stop-color="var(--color-accent-deep)" />
			</linearGradient>
		</defs>
	</svg>
	<div class="ring-center">
		<span class="ring-value">{Math.round(consumed)}</span>
		<span class="ring-unit">mg</span>
		<span class="ring-sub">of {limit} mg today</span>
	</div>
</div>

<style>
	.ring-wrap {
		position: relative;
		width: 10.5rem;
		height: 10.5rem;
		margin-inline: auto;
	}

	.ring-svg {
		width: 100%;
		height: 100%;
		filter: drop-shadow(0 8px 24px color-mix(in srgb, var(--color-accent) 35%, transparent));
	}

	.ring-progress {
		transition: stroke-dashoffset 0.3s ease;
	}

	.ring-center {
		position: absolute;
		inset: 0;
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		gap: 0.1rem;
	}

	.ring-value {
		font-family: var(--font-display);
		font-size: 2rem;
		font-weight: 700;
		line-height: 1;
		color: var(--color-text);
	}

	.ring-unit {
		font-size: 0.85rem;
		font-weight: 600;
		color: var(--color-text-muted);
	}

	.ring-sub {
		margin-top: 0.25rem;
		font-size: 0.7rem;
		color: var(--color-text-muted);
	}
</style>
