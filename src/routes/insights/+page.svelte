<script lang="ts">
	import MascotHeader from '$lib/components/MascotHeader.svelte';
	import { getDailySugarCap } from '$lib/personalization/recommendations';
	import { app } from '$lib/state/app.svelte';
	import type { UserProfile } from '$lib/types';
	import { _, locale } from 'svelte-i18n';

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

	function toggleLanguage(newLocale: string) {
		$locale = newLocale;
		if (typeof window !== 'undefined') {
			window.localStorage.setItem('locale', newLocale);
		}
	}
</script>

<MascotHeader title={$_('profile.title')} subtitle={$_('profile.subtitle')} />

<section class="card-panel fade-in">
	<label class="field">
		<span>{$_('profile.display_name')}</span>
		<input type="text" value={app.profile.name} oninput={(e) => setName(e.currentTarget.value)} />
	</label>

	<label class="field">
		<span>{$_('profile.caffeine_limit')}</span>
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
		<span>{$_('profile.sugar_sensitivity')}</span>
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
		<p class="hint">{$_('profile.sugar_guidance', { values: { cap: sugarCap } })}</p>
	</fieldset>

	<fieldset class="field" style="margin-top: 1rem;">
		<span>{$_('profile.language')}</span>
		<div class="radio-row">
			<button
				type="button"
				class:active={$locale === 'en'}
				onclick={() => toggleLanguage('en')}
			>
				{$_('profile.lang_en')}
			</button>
			<button
				type="button"
				class:active={$locale === 'vi'}
				onclick={() => toggleLanguage('vi')}
			>
				{$_('profile.lang_vi')}
			</button>
		</div>
	</fieldset>
</section>

{#if app.hasFitnessData}
	<section class="card-panel fade-in">
		<h2 class="section-title">{$_('profile.how_we_personalize')}</h2>
		<ul class="tips">
			<li>{$_('profile.tip_sleep')}</li>
			<li>{$_('profile.tip_hr')}</li>
			<li>{$_('profile.tip_afternoon')}</li>
			<li>{$_('profile.tip_active')}</li>
		</ul>
	</section>
{:else}
	<section class="card-panel fade-in">
		<p class="hint">{$_('profile.connect_hint')}</p>
		<a href="/connect" class="btn-primary">{$_('profile.go_to_sync')}</a>
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

	output {
		font-family: var(--font-display);
		font-weight: 700;
		font-size: 0.95rem;
		color: var(--color-text);
		text-shadow: 1px 1px 0 rgba(255, 255, 255, 0.5);
	}

	.radio-row {
		display: flex;
		gap: 0.5rem;
	}

	.radio-row button {
		flex: 1;
		font-family: var(--font-display);
		font-weight: 600;
		color: #ffffff;
		text-shadow: 1.5px 1.5px 0 var(--color-border);
		background-image: url('/images/minecraft_green_planks.png');
		background-size: 80px;
		border: 3px solid var(--color-border);
		border-radius: 8px;
		padding: 0.45rem;
		cursor: pointer;
		box-shadow:
			inset 0 2.5px 0 rgba(255, 255, 255, 0.85),
			inset 0 -3.5px 0 rgba(0, 0, 0, 0.3),
			0 4px 0 var(--color-border);
		font-size: 0.72rem;
		text-transform: uppercase;
		transition: transform 0.1s ease, box-shadow 0.1s ease, filter 0.15s ease;
	}

	.radio-row button:hover {
		filter: brightness(1.15);
	}

	.radio-row button:active {
		transform: translateY(4px);
		box-shadow:
			inset 0 2px 0 rgba(255, 255, 255, 0.85),
			inset 0 -2px 0 rgba(0, 0, 0, 0.3),
			0 0px 0 var(--color-border);
	}

	.radio-row button.active {
		background: 
			linear-gradient(rgba(250, 240, 221, 0.9), rgba(250, 240, 221, 0.9)),
			url('/images/minecraft_green_planks.png');
		background-size: auto, 80px;
		color: var(--color-text);
		text-shadow: none;
		box-shadow:
			inset 0 2.5px 0 rgba(255, 255, 255, 0.85),
			inset 0 -3.5px 0 rgba(0, 0, 0, 0.25),
			0 4px 0 var(--color-border);
		filter: brightness(1.1);
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
