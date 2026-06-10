<script lang="ts">
	import '../lib/i18n';
	import { isLoading } from 'svelte-i18n';
	import './layout.css';
	import BottomNav from '$lib/components/BottomNav.svelte';
	import favicon from '$lib/assets/favicon.svg';

	let { children } = $props();
</script>

<svelte:head>
	<link rel="preconnect" href="https://fonts.googleapis.com" />
	<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="" />
	<link
		rel="stylesheet"
		href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;600;700;800&family=Plus+Jakarta+Sans:ital,wght@0,400;0,500;0,600;0,700;1,400&display=swap"
	/>
	<link
		rel="stylesheet"
		href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200"
	/>
	<link rel="icon" href={favicon} />
	<title>Zakka Caffeine</title>
	<meta
		name="description"
		content="A mindful caffeine companion. Track your ritual with intention."
	/>
</svelte:head>

{#if $isLoading}
	<!-- Dictionary loading -->
{:else}
	<div class="app-shell">
		{@render children()}
	</div>

	<BottomNav />
{/if}
