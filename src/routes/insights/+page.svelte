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
