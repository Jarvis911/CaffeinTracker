<script lang="ts">
	import type { Snippet } from 'svelte';

	let {
		title,
		variant = 'parchment', // 'parchment', 'wood', 'pink', 'green'
		style = '',
		children
	}: {
		title?: string;
		variant?: 'parchment' | 'wood' | 'pink' | 'green';
		style?: string;
		children?: Snippet;
	} = $props();
</script>

<div class="pixel-panel {variant}" {style}>
	{#if title}
		<div class="panel-title-container">
			<div class="panel-title-bg">
				<span class="panel-title-text">{title}</span>
			</div>
		</div>
	{/if}
	<div class="panel-body">
		{@render children?.()}
	</div>
</div>

<style>
	.pixel-panel {
		position: relative;
		border: 4px solid #3d2c2a;
		image-rendering: pixelated;
		box-sizing: border-box;
		display: flex;
		flex-direction: column;
		margin-bottom: 1rem;
		/* Outer pixel-shadow effect */
		box-shadow: 
			0 4px 0 #3d2c2a;
	}

	/* Parchment variant (Paper/Cream) */
	.pixel-panel.parchment {
		background-color: #faf0dd;
		/* Inner bevel shadows for retro feel */
		box-shadow: 
			inset -4px -4px 0 0 #eed4b5,
			inset 4px 4px 0 0 #fffdf9,
			0 5px 0 #3d2c2a;
	}

	/* Wood variant (Forest green planks) */
	.pixel-panel.wood {
		background-color: #5e8f60;
		background-image: 
			linear-gradient(rgba(94, 143, 96, 0.9), rgba(94, 143, 96, 0.9)),
			url('/images/minecraft_green_planks.png');
		background-size: auto, 96px;
		box-shadow: 
			inset -4px -4px 0 0 #4b7856,
			inset 4px 4px 0 0 #8ebf9a,
			0 5px 0 #3d2c2a;
		color: #ffffff;
	}

	/* Pink accent panel */
	.pixel-panel.pink {
		background-color: #e88ba0;
		box-shadow: 
			inset -4px -4px 0 0 #b84d66,
			inset 4px 4px 0 0 #f0a2b5,
			0 5px 0 #3d2c2a;
	}

	/* Green accent panel */
	.pixel-panel.green {
		background-color: #99cc99;
		box-shadow: 
			inset -4px -4px 0 0 #5e8f60,
			inset 4px 4px 0 0 #c2e2c2,
			0 5px 0 #3d2c2a;
	}

	.panel-title-container {
		position: absolute;
		top: -18px;
		left: 50%;
		transform: translateX(-50%);
		z-index: 10;
		display: flex;
		justify-content: center;
		pointer-events: none;
	}

	.panel-title-bg {
		background-color: #faf0dd;
		border: 3px solid #3d2c2a;
		padding: 0.15rem 0.85rem;
		box-shadow: 
			inset -2px -2px 0 0 #eed4b5,
			0 3px 0 #3d2c2a;
		white-space: nowrap;
	}

	.wood .panel-title-bg {
		background-color: #faf0dd;
		color: #3d2c2a;
	}

	.panel-title-text {
		font-family: 'DotGothic16', 'VT323', monospace;
		font-size: 0.75rem;
		font-weight: bold;
		text-transform: uppercase;
		letter-spacing: 0.05em;
		color: #3d2c2a;
	}

	.panel-body {
		padding: 0.95rem 0.75rem 0.75rem;
		flex-grow: 1;
		font-family: 'DotGothic16', 'VT323', 'Quicksand', sans-serif;
	}

	.wood .panel-body {
		padding-top: 1.1rem;
	}
</style>
