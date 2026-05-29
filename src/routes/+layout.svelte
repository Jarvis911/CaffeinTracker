<script lang="ts">
	import '../lib/i18n';
	import { isLoading } from 'svelte-i18n';
	import './layout.css';
	import BottomNav from '$lib/components/BottomNav.svelte';
	import favicon from '$lib/assets/favicon.svg';

	let { children } = $props();
</script>

<svelte:head>
	<link
		rel="stylesheet"
		href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800&family=Quicksand:wght@400;500;600;700&display=swap"
	/>
	<link rel="icon" href={favicon} />
	<title>Caffein Tracker</title>
	<meta
		name="description"
		content="A cute caffeine companion that personalizes your coffee and sugar drinks using fitness health data."
	/>
</svelte:head>

{#if $isLoading}
	<!-- Do not render until dictionary is loaded -->
{:else}
	<div class="app-shell">
		{@render children()}
	</div>

	<BottomNav />
{/if}
