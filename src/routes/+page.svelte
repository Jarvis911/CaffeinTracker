<script lang="ts">
	import { _ } from 'svelte-i18n';
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
		if (h < 12) return $_('greeting.morning');
		if (h < 17) return $_('greeting.afternoon');
		return $_('greeting.evening');
	});
</script>

<MascotHeader
	title="{greeting}, {app.profile.name}"
	subtitle={app.hasFitnessData
		? $_('home.subtitle_tuned')
		: $_('home.subtitle_connect')}
/>

<section class="card-panel fade-in ring-panel">
	<CaffeineRing percent={caffeine.percent} consumed={caffeine.consumed} limit={caffeine.limit} />
</section>

<section class="fade-in">
	<DrinkToyBox items={toyItems} />
</section>

{#if app.hasFitnessData}
	<section class="fade-in" style="animation-delay: 0.05s">
		<h2 class="section-title">{$_('home.wellness')}</h2>
		<div class="chip-row">
			<HealthChip icon="😴" label={$_('health.sleep')} value={`${app.health.sleepHours.toFixed(1)}h`} />
			<HealthChip icon="💓" label={$_('health.resting_hr')} value={`${app.health.restingHeartRate} bpm`} />
			<HealthChip icon="👟" label={$_('health.steps')} value={app.health.steps.toLocaleString()} />
			<HealthChip icon="💧" label={$_('health.water')} value={`${Math.round(app.health.hydrationMl / 100) / 10}L`} />
		</div>
	</section>

	<section class="fade-in" style="animation-delay: 0.1s">
		<h2 class="section-title">{$_('home.picked_for_you')}</h2>
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
		<p>{$_('home.connect_prompt')}</p>
		<a href="/connect" class="btn-primary">{$_('home.connect_btn')}</a>
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
