<script lang="ts">
	import type { Snippet } from 'svelte';
	import { fade } from 'svelte/transition';

	let { children }: { children?: Snippet } = $props();
</script>

<div class="pixel-toast" transition:fade={{ duration: 150 }} role="status" aria-live="polite">
	<div class="toast-pixel-box">
		{@render children?.()}
	</div>
</div>

<style>
	.pixel-toast {
		position: fixed;
		bottom: calc(85px + env(safe-area-inset-bottom));
		left: 50%;
		transform: translateX(-50%);
		z-index: 100;
		max-width: calc(100% - 2rem);
	}

	.toast-pixel-box {
		background-color: #faf0dd;
		border: 3px solid #3d2c2a;
		padding: 0.5rem 1rem;
		box-shadow:
			inset -2px -2px 0 0 #eed4b5,
			0 4px 0 #3d2c2a;
		font-family: var(--font-body);
		font-size: 0.78rem;
		font-weight: 700;
		color: #3d2c2a;
		text-align: center;
	}
</style>
