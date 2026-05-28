<script lang="ts">
	import MascotHeader from '$lib/components/MascotHeader.svelte';
	import { getDailySugarCap } from '$lib/personalization/recommendations';
	import { app } from '$lib/state/app.svelte';
	import type { UserProfile } from '$lib/types';

	const sugarCap = $derived(getDailySugarCap(app.profile.sugarSensitivity));

	function setSensitivity(value: UserProfile['sugarSensitivity']) {
		app.updateProfile({ sugarSensitivity: value });
	}

	function setLimit(value: number) {
		app.updateProfile({ dailyCaffeineLimitMg: value });
	}

	function setName(value: string) {
		app.updateProfile({ name: value || 'Friend' });
	}
</script>

<MascotHeader title="Your profile" subtitle="Tune limits — we adapt recommendations automatically" />

<section class="card-panel fade-in">
	<label class="field">
		<span>Display name</span>
		<input type="text" value={app.profile.name} oninput={(e) => setName(e.currentTarget.value)} />
	</label>

	<label class="field">
		<span>Daily caffeine limit (mg)</span>
		<input
			type="range"
			min="100"
			max="600"
			step="25"
			value={app.profile.dailyCaffeineLimitMg}
			oninput={(e) => setLimit(Number(e.currentTarget.value))}
		/>
		<output>{app.profile.dailyCaffeineLimitMg} mg</output>
	</label>

	<fieldset class="field">
		<span>Sugar sensitivity</span>
		<div class="radio-row">
			{#each ['low', 'medium', 'high'] as level}
				<button
					type="button"
					class:active={app.profile.sugarSensitivity === level}
					onclick={() => setSensitivity(level as UserProfile['sugarSensitivity'])}
				>
					{level}
				</button>
			{/each}
		</div>
		<p class="hint">Daily sugar guidance cap: ~{sugarCap}g</p>
	</fieldset>
</section>

{#if app.hasFitnessData}
	<section class="card-panel fade-in">
		<h2 class="section-title">How we personalize</h2>
		<ul class="tips">
			<li>Short sleep lowers high-caffeine drink scores</li>
			<li>Elevated resting HR favors gentler options</li>
			<li>Afternoon logs trigger sleep-friendly suggestions</li>
			<li>Active days can support a modest caffeine boost</li>
		</ul>
	</section>
{:else}
	<section class="card-panel fade-in">
		<p class="hint">Connect a fitness app on the Sync tab to unlock health-aware tips.</p>
		<a href="/connect" class="btn-primary">Go to Sync</a>
	</section>
{/if}

<style>
	.field {
		display: flex;
		flex-direction: column;
		gap: 0.4rem;
		margin-bottom: 1rem;
		border: none;
		padding: 0;
	}

	.field span {
		font-size: 0.8rem;
		font-weight: 700;
		color: var(--color-text-muted);
	}

	input[type='text'] {
		padding: 0.65rem 0.85rem;
		border-radius: 0.85rem;
		border: 1px solid var(--color-border);
		font: inherit;
	}

	output {
		font-weight: 700;
		font-size: 0.9rem;
	}

	.radio-row {
		display: flex;
		gap: 0.5rem;
	}

	.radio-row button {
		flex: 1;
		padding: 0.5rem;
		border-radius: 999px;
		border: 1px solid var(--color-border);
		background: white;
		font-weight: 600;
		font-size: 0.8rem;
		text-transform: capitalize;
		cursor: pointer;
	}

	.radio-row button.active {
		background: var(--color-accent-soft);
		border-color: var(--color-accent);
		color: var(--color-accent-deep);
	}

	.hint {
		margin: 0.35rem 0 0;
		font-size: 0.8rem;
		color: var(--color-text-muted);
	}

	.tips {
		margin: 0;
		padding-left: 1.1rem;
		font-size: 0.85rem;
		line-height: 1.5;
		color: var(--color-text-muted);
	}

	a.btn-primary {
		display: inline-flex;
		margin-top: 0.75rem;
		text-decoration: none;
	}
</style>
