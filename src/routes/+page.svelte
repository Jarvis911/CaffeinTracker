<script lang="ts">
	import CaffeineRing from '$lib/components/CaffeineRing.svelte';
	import DrinkToyBox from '$lib/components/DrinkToyBox.svelte';
	import HealthChip from '$lib/components/HealthChip.svelte';
	import MascotHeader from '$lib/components/MascotHeader.svelte';
	import RecommendationCard from '$lib/components/RecommendationCard.svelte';
	import { getCaffeineStatus, getRecommendations } from '$lib/personalization/recommendations';
	import { app } from '$lib/state/app.svelte';
	import { getTodayToyItems } from '$lib/utils/today-logs';

	const caffeine = $derived(getCaffeineStatus(app.profile, app.logs));
	const recommendations = $derived(
		app.hasFitnessData
			? getRecommendations(app.health, app.profile, app.logs)
			: []
	);

	const toyItems = $derived(getTodayToyItems(app.logs));

	const greeting = $derived.by(() => {
		const h = new Date().getHours();
		if (h < 12) return 'Good morning';
		if (h < 17) return 'Good afternoon';
		return 'Good evening';
	});
</script>

<MascotHeader
	title="{greeting}, {app.profile.name}"
	subtitle={app.hasFitnessData
		? 'Your drinks are tuned to today’s health snapshot'
		: 'Connect a fitness app for personalized picks'}
/>

<section class="card-panel fade-in ring-panel">
	<CaffeineRing percent={caffeine.percent} consumed={caffeine.consumed} limit={caffeine.limit} />
</section>

<section class="fade-in">
	<DrinkToyBox items={toyItems} />
</section>

{#if app.hasFitnessData}
	<section class="fade-in" style="animation-delay: 0.05s">
		<h2 class="section-title">Today’s wellness</h2>
		<div class="chip-row">
			<HealthChip icon="😴" label="Sleep" value={`${app.health.sleepHours.toFixed(1)}h`} />
			<HealthChip icon="💓" label="Resting HR" value={`${app.health.restingHeartRate} bpm`} />
			<HealthChip icon="👟" label="Steps" value={app.health.steps.toLocaleString()} />
			<HealthChip icon="💧" label="Water" value={`${Math.round(app.health.hydrationMl / 100) / 10}L`} />
		</div>
	</section>

	<section class="fade-in" style="animation-delay: 0.1s">
		<h2 class="section-title">Picked for you</h2>
		<div class="rec-list">
			{#each recommendations as item, i}
				<div style="animation-delay: {0.12 + i * 0.04}s" class="fade-in">
					<RecommendationCard item={item} onLog={() => app.logDrink(item.drink.id)} />
				</div>
			{/each}
		</div>
	</section>
{:else}
	<section class="card-panel fade-in cta">
		<p>Link Apple Health, Google Fit, Fitbit, or Garmin to personalize caffeine and sugar limits.</p>
		<a href="/connect" class="btn-primary">Connect fitness apps</a>
	</section>
{/if}

<style>
	.ring-panel {
		display: flex;
		justify-content: center;
		margin-bottom: 1.25rem;
	}

	.rec-list {
		display: flex;
		flex-direction: column;
		gap: 0.75rem;
	}

	.cta {
		text-align: center;
		margin-top: 0.5rem;
	}

	.cta p {
		margin: 0 0 1rem;
		font-size: 0.9rem;
		color: var(--color-text-muted);
		line-height: 1.45;
	}

	.cta a {
		text-decoration: none;
	}
</style>
