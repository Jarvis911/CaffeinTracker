<script lang="ts">
	import { page } from '$app/state';
	import { _ } from 'svelte-i18n';

	const links = $derived([
		{ href: '/home-cozy', label: $_('nav.home_cozy'), icon: '/images/home.png' },
		{ href: '/log', label: $_('nav.log'), icon: '/images/cafe.png' },
		{ href: '/connect', label: $_('nav.sync'), icon: '/images/stats.png' },
		{ href: '/insights', label: $_('nav.you'), icon: '/images/profile.png' }
	]);
</script>

<nav class="nav" aria-label="Main">
	{#each links as link}
		<a
			href={link.href}
			class:active={page.url.pathname === link.href ||
				(link.href === '/home-cozy' &&
					(page.url.pathname === '/' || page.url.pathname === '/home-pixel'))}
		>
			<img src={link.icon} alt="" class="nav-icon-img" aria-hidden="true" />
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
		align-items: center;
		padding: 0.65rem 0.5rem calc(0.65rem + env(safe-area-inset-bottom));
		background-color: #f7cbd2; /* Soft pink matching mockup */
		border-top: 3px solid #3d2c2a;
		border-left: 3px solid #3d2c2a;
		border-right: 3px solid #3d2c2a;
		border-top-left-radius: 24px;
		border-top-right-radius: 24px;
		box-shadow: 0 -3px 10px rgba(61, 44, 42, 0.1);
		z-index: 50;
	}

	a {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		gap: 0.2rem;
		padding: 0.45rem 0.55rem;
		border-radius: 16px;
		color: #3d2c2a;
		text-decoration: none;
		font-family: var(--font-body);
		font-size: 0.68rem;
		font-weight: 700;
		transition: transform 0.1s ease, background-color 0.2s ease;
		min-width: 4.4rem;
		flex: 1;
		max-width: 5.8rem;
		height: auto;
		border: none;
		background: transparent;
		box-shadow: none;
	}

	a:hover {
		background-color: rgba(255, 255, 255, 0.25);
	}

	a.active {
		background-color: #f0a2b5; /* Highlight pink color for active tab */
		transform: none;
		box-shadow: none;
	}

	.nav-icon-img {
		width: 2.6rem;
		height: 2.6rem;
		object-fit: contain;
		image-rendering: pixelated;
	}

	.label {
		font-family: var(--font-body);
		font-weight: 700;
		font-size: 0.64rem;
		letter-spacing: 0.01em;
	}
</style>
