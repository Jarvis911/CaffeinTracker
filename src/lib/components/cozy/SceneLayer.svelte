<script lang="ts">
	import type { Snippet } from 'svelte';

	let { children }: { children?: Snippet } = $props();
</script>

<div class="scene-layer">
	<picture class="scene-bg" aria-hidden="true">
		<source
			media="(min-width: 640px)"
			srcset="/images/cozy_home_bg-tablet.webp"
			type="image/webp"
		/>
		<source srcset="/images/cozy_home_bg-mobile.webp" type="image/webp" />
		<img
			src="/images/cozy_home_bg-mobile.webp"
			alt=""
			width="896"
			height="597"
			decoding="async"
			fetchpriority="high"
		/>
	</picture>

	<div class="scene-content">
		{@render children?.()}
	</div>
</div>

<style>
	.scene-layer {
		position: relative;
		width: 100%;
		height: 100%;
		overflow: hidden;
	}

	.scene-bg {
		position: absolute;
		inset: 0;
		display: block;
		width: 100%;
		height: 100%;
		pointer-events: none;
	}

	.scene-bg img {
		width: 100%;
		height: 100%;
		object-fit: cover;
		object-position: center;
		image-rendering: pixelated;
	}

	.scene-content {
		position: absolute;
		inset: 0;
	}
</style>
