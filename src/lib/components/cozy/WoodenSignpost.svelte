<script lang="ts">
	import type { SignpostLink } from './scene-config';

	let { links, anchor }: { links: SignpostLink[]; anchor: { top?: string; right?: string } } =
		$props();
</script>

<nav
	class="wooden-signpost"
	style:top={anchor.top}
	style:right={anchor.right}
	aria-label="Quick navigation"
>
	<div class="pole" aria-hidden="true"></div>
	{#each links as link (link.href)}
		<a href={link.href} class="sign-plank {link.plankClass}-plank">
			<span>{link.label}</span>
		</a>
	{/each}
</nav>

<style>
	.wooden-signpost {
		position: absolute;
		display: flex;
		flex-direction: column;
		align-items: center;
		z-index: 8;
	}

	.pole {
		width: 6px;
		height: 120px;
		background-color: #795238;
		border: 2px solid #3d2c2a;
		position: absolute;
		top: 0;
		z-index: -1;
	}

	.sign-plank {
		display: flex;
		align-items: center;
		justify-content: center;
		background-color: #d1a179;
		border: 2.5px solid #3d2c2a;
		padding: 0.35rem 0.65rem;
		margin-bottom: 0.35rem;
		color: #3d2c2a;
		font-family: var(--font-body);
		font-size: 0.75rem;
		font-weight: bold;
		text-decoration: none;
		text-align: center;
		box-shadow:
			inset -2px -2px 0 0 #b37f58,
			inset 2px 2px 0 0 #fbe2cd,
			0 2px 0 rgba(0, 0, 0, 0.15);
		transition: transform 0.1s ease;
		min-width: 72px;
		min-height: 44px;
		touch-action: manipulation;
		-webkit-tap-highlight-color: transparent;
	}

	.sign-plank:active {
		transform: scale(0.97);
		background-color: #fbe2cd;
	}

	@media (hover: hover) {
		.sign-plank:hover {
			transform: scale(1.05) rotate(1deg);
			background-color: #fbe2cd;
		}
	}

	.stats-plank {
		transform: rotate(-3deg) translateX(-4px);
	}

	.goals-plank {
		transform: rotate(2deg) translateX(4px);
	}

	.drinks-plank {
		transform: rotate(-1deg) translateX(-2px);
	}
</style>
