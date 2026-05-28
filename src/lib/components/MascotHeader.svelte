<script lang="ts">
	let { title, subtitle }: { title: string; subtitle?: string } = $props();
</script>

<header class="hero">
	<div class="mascot" aria-hidden="true">
		<span class="cup">☕</span>
		<span class="spark s1">✦</span>
		<span class="spark s2">✧</span>
	</div>
	<div>
		<h1>{title}</h1>
		{#if subtitle}
			<p>{subtitle}</p>
		{/if}
	</div>
</header>

<style>
	.hero {
		display: flex;
		align-items: center;
		gap: 1rem;
		margin-bottom: 1.25rem;
	}

	.mascot {
		position: relative;
		width: 4rem;
		height: 4rem;
		display: grid;
		place-items: center;
		border-radius: 1.35rem;
		background: linear-gradient(145deg, var(--color-accent-soft), var(--color-mint-soft));
		box-shadow: var(--shadow-soft);
	}

	.cup {
		font-size: 2rem;
		animation: float 3s ease-in-out infinite;
	}

	.spark {
		position: absolute;
		font-size: 0.75rem;
		color: var(--color-accent-deep);
		animation: twinkle 2s ease-in-out infinite;
	}

	.s1 {
		top: 0.35rem;
		right: 0.45rem;
	}

	.s2 {
		bottom: 0.5rem;
		left: 0.4rem;
		animation-delay: 0.6s;
	}

	h1 {
		margin: 0;
		font-size: 1.45rem;
		font-weight: 800;
		letter-spacing: -0.02em;
	}

	p {
		margin: 0.2rem 0 0;
		font-size: 0.85rem;
		color: var(--color-text-muted);
	}

	@keyframes float {
		0%,
		100% {
			transform: translateY(0);
		}
		50% {
			transform: translateY(-4px);
		}
	}

	@keyframes twinkle {
		0%,
		100% {
			opacity: 0.4;
			transform: scale(0.9);
		}
		50% {
			opacity: 1;
			transform: scale(1.1);
		}
	}
</style>
