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
		padding: 0.625rem 1rem calc(0.625rem + env(safe-area-inset-bottom));
		background: var(--color-surface);
		border-top: 1px solid rgba(28, 46, 36, 0.1);
		box-shadow: var(--shadow-nav);
		z-index: 50;
	}

	a {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		gap: 0.25rem;
		padding: 0.4rem 0.75rem;
		color: var(--color-outline);
		text-decoration: none;
		font-family: var(--font-body);
		font-size: 0.72rem;
		font-weight: 500;
		letter-spacing: 0.05em;
		text-transform: uppercase;
		transition: color 0.2s ease, transform 0.15s ease;
		min-width: 4.5rem;
		position: relative;
	}

	a::after {
		content: '';
		position: absolute;
		bottom: 2px;
		left: 50%;
		transform: translateX(-50%);
		width: 0;
		height: 2px;
		background: var(--color-primary);
		transition: width 0.25s cubic-bezier(0.16, 1, 0.3, 1);
	}

	a:hover {
		color: var(--color-primary);
	}

	a.active {
		color: var(--color-primary);
		font-weight: 700;
	}

	a.active::after {
		width: 1.5rem;
	}

	.icon {
		font-size: 1.375rem;
		font-variation-settings: 'FILL' 0, 'wght' 300, 'GRAD' 0, 'opsz' 24;
		transition: font-variation-settings 0.2s ease, color 0.2s ease;
	}

	.icon.fill {
		font-variation-settings: 'FILL' 1, 'wght' 400, 'GRAD' 0, 'opsz' 24;
	}

	.label {
		font-size: 0.65rem;
		line-height: 1;
	}
</style>
