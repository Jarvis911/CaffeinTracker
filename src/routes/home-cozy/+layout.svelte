<script lang="ts">
	import { onMount } from 'svelte';

	let { children } = $props();

	onMount(() => {
		document.body.classList.add('home-cozy-mode');
		return () => document.body.classList.remove('home-cozy-mode');
	});
</script>

<div class="home-cozy-shell">
	{@render children()}
</div>

<style>
	.home-cozy-shell {
		display: flex;
		flex-direction: column;
		height: 100%;
		width: 100%;
		overflow: hidden;
	}

	:global(body.home-cozy-mode) {
		overflow: hidden;
		height: 100dvh;
		margin: 0;
		padding: 0;
	}

	:global(body.home-cozy-mode .app-shell) {
		height: 100dvh;
		display: flex;
		flex-direction: column;
		padding: 0;
		box-sizing: border-box;
		overflow: hidden;
		max-width: 28rem;
		margin-inline: auto;
	}
</style>
