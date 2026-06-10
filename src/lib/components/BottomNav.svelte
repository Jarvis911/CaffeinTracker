<script lang="ts">
	import { page } from '$app/state';
	import { _ } from 'svelte-i18n';

	const links = [
		{ href: '/home-cozy', label: 'Ritual', icon: 'spa' },
		{ href: '/log', label: 'Log', icon: 'add_circle' },
		{ href: '/trends', label: 'Trends', icon: 'analytics' },
		{ href: '/insights', label: 'Profile', icon: 'manage_accounts' }
	];

	function isActive(href: string, pathname: string): boolean {
		if (href === '/home-cozy') {
			return pathname === '/home-cozy' || pathname === '/' || pathname === '/home-pixel';
		}
		return pathname === href;
	}
</script>

<nav class="nav" aria-label="Main navigation">
	{#each links as link}
		{@const active = isActive(link.href, page.url.pathname)}
		<a href={link.href} class:active aria-current={active ? 'page' : undefined}>
			<span class="material-symbols-outlined icon" class:fill={active}>{link.icon}</span>
			<span class="label">{link.label}</span>
		</a>
	{/each}
</nav>

<style>
	.nav {
		position: fixed;
		bottom: 0;
		left: 50%;
		transform: translateX(-50%);
		width: min(100%, 768px);
		display: flex;
		justify-content: space-around;
		align-items: center;
		padding: 0.5rem 1rem calc(0.5rem + env(safe-area-inset-bottom));
		background: var(--color-surface);
		border-top: 1px solid rgba(197, 200, 187, 0.3);
		border-top-left-radius: 0.75rem;
		border-top-right-radius: 0.75rem;
		box-shadow: var(--shadow-nav);
		z-index: 50;
	}

	a {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		gap: 0.2rem;
		padding: 0.35rem 1rem 0.25rem;
		border-radius: var(--radius-full);
		color: var(--color-on-surface-variant);
		text-decoration: none;
		font-family: var(--font-body);
		font-size: 0.75rem;
		font-weight: 600;
		letter-spacing: 0.02em;
		transition: color 0.2s ease, background 0.2s ease, transform 0.15s ease;
		min-width: 4rem;
	}

	a:hover {
		color: var(--color-primary);
	}

	a.active {
		background: var(--color-primary-container);
		color: var(--color-on-primary-container);
	}

	.icon {
		font-size: 1.5rem;
		font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
		transition: font-variation-settings 0.2s ease;
	}

	.icon.fill {
		font-variation-settings: 'FILL' 1, 'wght' 400, 'GRAD' 0, 'opsz' 24;
	}

	.label {
		font-size: 0.7rem;
		line-height: 1;
	}
</style>
