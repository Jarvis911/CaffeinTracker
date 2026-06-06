<script lang="ts">
	import type { User } from '@supabase/supabase-js';
	import { invalidateAll } from '$app/navigation';
	import { getSupabaseBrowserClient } from '$lib/supabase/client';
	import { isSupabaseConfigured } from '$lib/supabase/config';
	import { app } from '$lib/state/app.svelte';
	import GoogleSignInButton from './GoogleSignInButton.svelte';
	import { _ } from 'svelte-i18n';

	let {
		user
	}: {
		user: User | null;
	} = $props();

	let signingOut = $state(false);

	const displayName = $derived(
		user?.user_metadata?.full_name ??
			user?.user_metadata?.name ??
			user?.email?.split('@')[0] ??
			''
	);

	const avatarUrl = $derived(user?.user_metadata?.avatar_url as string | undefined);

	$effect(() => {
		if (displayName && user) {
			app.updateProfile({ name: displayName });
		}
	});

	async function signOut() {
		if (!isSupabaseConfigured()) return;

		signingOut = true;
		try {
			const supabase = getSupabaseBrowserClient();
			await supabase.auth.signOut();
			await invalidateAll();
		} finally {
			signingOut = false;
		}
	}
</script>

{#if !isSupabaseConfigured()}
	<section class="auth-panel card-panel">
		<h2 class="section-title">{$_('auth.title')}</h2>
		<p class="hint">{$_('auth.not_configured')}</p>
	</section>
{:else if user}
	<section class="auth-panel card-panel signed-in">
		<h2 class="section-title">{$_('auth.title')}</h2>
		<div class="user-row">
			{#if avatarUrl}
				<img src={avatarUrl} alt="" class="avatar" width="40" height="40" />
			{:else}
				<span class="avatar-fallback" aria-hidden="true">☕</span>
			{/if}
			<div class="user-info">
				<strong>{displayName}</strong>
				<span class="email">{user.email}</span>
			</div>
		</div>
		<p class="hint">{$_('auth.signed_in_hint')}</p>
		<button type="button" class="btn-primary sign-out-btn" disabled={signingOut} onclick={signOut}>
			{signingOut ? $_('auth.signing_out') : $_('auth.sign_out')}
		</button>
	</section>
{:else}
	<section class="auth-panel card-panel">
		<h2 class="section-title">{$_('auth.title')}</h2>
		<p class="hint">{$_('auth.sign_in_hint')}</p>
		<GoogleSignInButton />
	</section>
{/if}

<style>
	.auth-panel {
		margin-bottom: 1rem;
	}

	.hint {
		margin: 0 0 0.85rem;
		color: var(--color-text-muted);
		font-size: 0.82rem;
		line-height: 1.45;
	}

	.user-row {
		display: flex;
		align-items: center;
		gap: 0.75rem;
		margin-bottom: 0.65rem;
	}

	.avatar,
	.avatar-fallback {
		width: 40px;
		height: 40px;
		border-radius: 50%;
		border: 2px solid var(--color-border);
		flex-shrink: 0;
	}

	.avatar-fallback {
		display: flex;
		align-items: center;
		justify-content: center;
		background: var(--color-surface);
		font-size: 1.2rem;
	}

	.user-info {
		display: flex;
		flex-direction: column;
		gap: 0.1rem;
		min-width: 0;
	}

	.user-info strong {
		font-size: 0.95rem;
	}

	.email {
		color: var(--color-text-muted);
		font-size: 0.78rem;
		overflow: hidden;
		text-overflow: ellipsis;
		white-space: nowrap;
	}

	.sign-out-btn {
		width: 100%;
	}
</style>
