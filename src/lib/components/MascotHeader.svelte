<script lang="ts">
	let { title, subtitle }: { title: string; subtitle?: string } = $props();
</script>

<header class="retro-window">
	<div class="title-bar">
		<span class="title-text">DESKTOP.EXE</span>
		<div class="window-controls">
			<span class="control-btn min" aria-hidden="true">_</span>
			<span class="control-btn max" aria-hidden="true">⛶</span>
			<span class="control-btn close" aria-hidden="true">X</span>
		</div>
	</div>
	<div class="window-body">
		<div class="crt-monitor" aria-hidden="true">
			<div class="crt-screen">
				<span class="cup">☕</span>
				<div class="crt-glare"></div>
			</div>
			<div class="monitor-stand"></div>
			<div class="monitor-base"></div>
		</div>
		<div class="header-text">
			<h1>{title}</h1>
			{#if subtitle}
				<p class="subtitle">{subtitle}</p>
			{/if}
		</div>
	</div>
</header>

<style>
	.retro-window {
		border: 3.5px solid var(--color-border);
		background: var(--color-surface);
		border-radius: 14px;
		overflow: hidden;
		box-shadow: 0 6px 0 var(--color-border);
		margin-bottom: 1.5rem;
	}

	.title-bar {
		background: #0b5fb4; /* Retro OS Blue */
		color: #ffffff;
		padding: 0.45rem 0.65rem;
		display: flex;
		justify-content: space-between;
		align-items: center;
		border-bottom: 3.5px solid var(--color-border);
		font-family: var(--font-display);
		font-size: 0.65rem;
		font-weight: 700;
		letter-spacing: 0.05em;
	}

	.window-controls {
		display: flex;
		gap: 0.25rem;
	}

	.control-btn {
		width: 1.15rem;
		height: 1.15rem;
		background: #eed4b5;
		border: 2px solid var(--color-border);
		box-shadow: 0 1.5px 0 var(--color-border);
		border-radius: 4px;
		display: grid;
		place-items: center;
		font-size: 0.55rem;
		font-weight: 700;
		color: #3d2c2a;
		cursor: pointer;
	}

	.window-body {
		padding: 0.85rem;
		display: flex;
		align-items: center;
		gap: 0.85rem;
		background-image: url('/images/minecraft_cozy_lakeside.png');
		background-size: cover;
		background-position: center;
		position: relative;
	}

	/* CRT Monitor Styling */
	.crt-monitor {
		display: flex;
		flex-direction: column;
		align-items: center;
		flex-shrink: 0;
		filter: drop-shadow(0 3px 0 var(--color-border));
	}

	.crt-screen {
		width: 3.5rem;
		height: 3.1rem;
		background: #2e5844; /* screen color */
		border: 3.5px solid var(--color-border);
		border-radius: 8px;
		position: relative;
		display: grid;
		place-items: center;
		box-shadow: inset 0 3px 6px rgba(0, 0, 0, 0.45);
		overflow: hidden;
	}

	.cup {
		font-size: 1.6rem;
		animation: float 3s ease-in-out infinite;
		z-index: 2;
	}

	.crt-glare {
		position: absolute;
		inset: 0;
		background: linear-gradient(135deg, rgba(255, 255, 255, 0.18) 0%, transparent 50%);
		pointer-events: none;
	}

	.monitor-stand {
		width: 0.75rem;
		height: 0.35rem;
		background: #eed4b5;
		border-left: 3px solid var(--color-border);
		border-right: 3px solid var(--color-border);
	}

	.monitor-base {
		width: 1.85rem;
		height: 0.25rem;
		background: #eed4b5;
		border: 3px solid var(--color-border);
		border-top: none;
		border-radius: 4px;
	}

	.header-text {
		display: flex;
		flex-direction: column;
		gap: 0.15rem;
		background: rgba(250, 240, 221, 0.95);
		border: 3px solid var(--color-border);
		box-shadow: 0 4px 0 var(--color-border);
		border-radius: 10px;
		padding: 0.45rem 0.65rem;
		backdrop-filter: blur(2px);
		flex-grow: 1;
	}

	h1 {
		margin: 0;
		font-size: 0.78rem;
		font-weight: 700;
		line-height: 1.25;
		color: var(--color-text);
	}

	.subtitle {
		margin: 0;
		font-family: var(--font-body);
		font-size: 0.68rem;
		font-weight: 700;
		color: var(--color-text-muted);
		line-height: 1.35;
	}

	@keyframes float {
		0%,
		100% {
			transform: translateY(0);
		}
		50% {
			transform: translateY(-3px);
		}
	}
</style>
