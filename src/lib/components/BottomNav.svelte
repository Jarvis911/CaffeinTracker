<script lang="ts">
	import { page } from '$app/state';
	import { _ } from 'svelte-i18n';

	const links = $derived([
		{ href: '/', label: $_('nav.home'), icon: '🏠' },
		{ href: '/log', label: $_('nav.log'), icon: '☕' },
		{ href: '/connect', label: $_('nav.sync'), icon: '💗' },
		{ href: '/insights', label: $_('nav.you'), icon: '✨' }
	]);
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
		align-items: center;
		padding: 0.65rem 0.5rem calc(0.65rem + env(safe-area-inset-bottom));
		background: 
			linear-gradient(rgba(250, 240, 221, 0.9), rgba(250, 240, 221, 0.9)),
			url('/images/minecraft_green_planks.png');
		background-size: auto, 120px;
		border-top: 4px solid var(--color-border);
		border-left: 4px solid var(--color-border);
		border-right: 4px solid var(--color-border);
		border-top-left-radius: 16px;
		border-top-right-radius: 16px;
		box-shadow:
			inset 0 4px 0 rgba(255, 255, 255, 0.25),
			inset 0 -4px 0 rgba(0, 0, 0, 0.2),
			0 -4px 12px rgba(61, 44, 42, 0.15);
		z-index: 50;
	}

	a {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		gap: 0.1rem;
		padding: 0.4rem 0.55rem;
		border-radius: 10px;
		border: 3px solid var(--color-border);
		background-image: url('/images/minecraft_green_planks.png');
		background-size: 80px;
		color: #ffffff;
		text-shadow: 1.5px 1.5px 0 var(--color-border);
		text-decoration: none;
		font-size: 0.62rem;
		font-weight: 700;
		box-shadow:
			inset 0 3px 0 rgba(255, 255, 255, 0.85),
			inset 0 -3px 0 rgba(0, 0, 0, 0.3),
			0 4px 0 var(--color-border);
		transition:
			transform 0.1s ease,
			box-shadow 0.1s ease,
			filter 0.15s ease;
		min-width: 4.8rem;
		height: 2.75rem;
	}

	a:hover {
		filter: brightness(1.15);
	}

	a.active {
		background: 
			linear-gradient(rgba(250, 240, 221, 0.9), rgba(250, 240, 221, 0.9)),
			url('/images/minecraft_green_planks.png');
		background-size: auto, 80px;
		color: var(--color-text);
		text-shadow: none;
		transform: translateY(4px);
		box-shadow:
			inset 0 2px 0 rgba(255, 255, 255, 0.85),
			inset 0 -2px 0 rgba(0, 0, 0, 0.2),
			0 0px 0 var(--color-border);
	}

	.icon {
		font-size: 1.15rem;
		line-height: 1;
	}

	.label {
		font-family: var(--font-body);
		font-weight: 700;
		text-transform: uppercase;
		font-size: 0.55rem;
		letter-spacing: 0.02em;
	}
</style>
