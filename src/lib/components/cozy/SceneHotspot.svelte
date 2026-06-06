<script lang="ts">
	import type { SceneAnchor } from './scene-config';
	let {
		anchor,
		label = '',
		class: className = '',
		onclick
	}: {
		anchor: SceneAnchor;
		label?: string;
		class?: string;
		onclick?: () => void;
	} = $props();
</script>

<button
	type="button"
	class="scene-hotspot {className}"
	style:top={anchor.top}
	style:right={anchor.right}
	style:bottom={anchor.bottom}
	style:left={anchor.left}
	style:width={anchor.width}
	style:height={anchor.height}
	style:max-width={anchor.maxWidth}
	aria-label={label || undefined}
	{onclick}
></button>

<style>
	.scene-hotspot {
		position: absolute;
		margin: 0;
		padding: 0;
		border: none;
		background: transparent;
		cursor: pointer;
		z-index: 5;
		touch-action: manipulation;
		-webkit-tap-highlight-color: transparent;
		min-width: 44px;
		min-height: 44px;
	}

	.scene-hotspot:focus-visible {
		outline: 2px solid #3d2c2a;
		outline-offset: 2px;
	}
</style>
