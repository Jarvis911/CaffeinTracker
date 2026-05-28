<script lang="ts">
	import DrinkCard from '$lib/components/DrinkCard.svelte';
	import DrinkToyBox from '$lib/components/DrinkToyBox.svelte';
	import MascotHeader from '$lib/components/MascotHeader.svelte';
	import { DRINK_CATALOG } from '$lib/drinks/catalog';
	import { app } from '$lib/state/app.svelte';
	import { getTodayToyItems } from '$lib/utils/today-logs';

	const toyItems = $derived(getTodayToyItems(app.logs));

	let loggedId = $state<string | null>(null);

	function log(id: string) {
		app.logDrink(id);
		loggedId = id;
		setTimeout(() => {
			loggedId = null;
		}, 1800);
	}
</script>

<MascotHeader title="Log a drink" subtitle="Tap what you’re sipping — we’ll track caffeine & sugar" />

<div class="list fade-in">
	{#each DRINK_CATALOG as drink}
		<div class="row">
			<DrinkCard drink={drink} onSelect={() => log(drink.id)} />
			{#if loggedId === drink.id}
				<span class="toast" role="status">Logged!</span>
			{/if}
		</div>
	{/each}
</div>

<section class="fade-in toy-wrap">
	<DrinkToyBox items={toyItems} />
</section>

<style>
	.toy-wrap {
		margin-top: 1.25rem;
	}
	.list {
		display: flex;
		flex-direction: column;
		gap: 0.65rem;
	}

	.row {
		position: relative;
	}

	.toast {
		position: absolute;
		right: 1rem;
		top: 50%;
		transform: translateY(-50%);
		padding: 0.25rem 0.6rem;
		border-radius: 999px;
		background: var(--color-mint-soft);
		color: var(--color-mint-deep);
		font-size: 0.75rem;
		font-weight: 700;
		animation: pop 0.35s ease;
	}

	@keyframes pop {
		from {
			opacity: 0;
			transform: translateY(-50%) scale(0.9);
		}
		to {
			opacity: 1;
			transform: translateY(-50%) scale(1);
		}
	}
</style>
