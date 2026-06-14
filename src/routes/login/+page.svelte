<script lang="ts">
	import GoogleSignInButton from '$lib/components/auth/GoogleSignInButton.svelte';
	import { isSupabaseConfigured } from '$lib/supabase/config';
	import { _ } from 'svelte-i18n';
	import { page } from '$app/state';

	const redirectTo = $derived(page.url.searchParams.get('next') ?? '/home-cozy');
	const authError = $derived(page.url.searchParams.get('error') === 'auth');
</script>

<svelte:head>
	<title>{$_('auth.login_title')} | Caffein Tracker</title>
</svelte:head>

<div class="login-page fade-in">
	<div class="login-card card-panel">
		<p class="emoji" aria-hidden="true">☕</p>
		<h1>{$_('auth.login_title')}</h1>
		<p class="subtitle">{$_('auth.login_subtitle')}</p>

		{#if authError}
			<p class="banner-error" role="alert">{$_('auth.sign_in_failed')}</p>
		{/if}

		{#if isSupabaseConfigured()}
			<GoogleSignInButton {redirectTo} />
			<p class="fine-print">{$_('auth.login_fine_print')}</p>
		{:else}
			<p class="banner-error">{$_('auth.not_configured')}</p>
			<a href="/home-cozy" class="skip-link">{$_('auth.continue_without_account')}</a>
		{/if}
	</div>
</div>

<style>
	.login-page {
		display: flex;
		align-items: center;
		justify-content: center;
		min-height: calc(100dvh - 8rem);
		padding: 1rem 0;
	}

	.login-card {
		width: 100%;
		text-align: center;
	}

	.emoji {
		margin: 0;
		font-size: 3rem;
		line-height: 1;
	}

	h1 {
		margin: 0.75rem 0 0.35rem;
		font-size: 1.35rem;
	}

	.subtitle {
		margin: 0 0 1.25rem;
		color: var(--color-text-muted);
		font-size: 0.88rem;
		line-height: 1.45;
	}

	.fine-print {
		margin: 1rem 0 0;
		color: var(--color-text-muted);
		font-size: 0.75rem;
		line-height: 1.4;
	}

	.banner-error {
		margin: 0 0 1rem;
		padding: 0.55rem 0.75rem;
		border-radius: 12px;
		background: #fde8ec;
		border: 2px solid #e88ba0;
		color: #8b3045;
		font-size: 0.82rem;
		font-weight: 600;
	}

	.skip-link {
		display: inline-block;
		margin-top: 0.75rem;
		color: var(--color-mint-deep);
		font-weight: 700;
		text-decoration: none;
	}
</style>
