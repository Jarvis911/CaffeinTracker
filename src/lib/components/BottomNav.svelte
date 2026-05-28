<script lang="ts">
	import { page } from '$app/state';

	const links = [
		{ href: '/', label: 'Home', icon: '🏠' },
		{ href: '/log', label: 'Log', icon: '☕' },
		{ href: '/connect', label: 'Sync', icon: '💗' },
		{ href: '/insights', label: 'You', icon: '✨' }
	];
</script>

<nav class="nav" aria-label="Main">
	{#each links as link}
		<a href={link.href} class:active={page.url.pathname === link.href}>
			<span class="icon" aria-hidden="true">{link.icon}</span>
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
		width: min(100%, 28rem);
		display: flex;
		justify-content: space-around;
		padding: 0.5rem 0.75rem calc(0.5rem + env(safe-area-inset-bottom));
		background: color-mix(in srgb, var(--color-surface) 88%, transparent);
		backdrop-filter: blur(12px);
		border-top: 1px solid var(--color-border);
		z-index: 50;
	}

	a {
		display: flex;
		flex-direction: column;
		align-items: center;
		gap: 0.15rem;
		padding: 0.35rem 0.65rem;
		border-radius: 1rem;
		color: var(--color-text-muted);
		text-decoration: none;
		font-size: 0.65rem;
		font-weight: 600;
		transition:
			color 0.2s ease,
			background 0.2s ease;
	}

	a.active {
		color: var(--color-accent-deep);
		background: var(--color-accent-soft);
	}

	.icon {
		font-size: 1.25rem;
	}
</style>
