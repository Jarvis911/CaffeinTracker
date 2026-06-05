<script lang="ts">
	let { icon, label, value }: { icon: string; label: string; value: string } = $props();
</script>

<div class="chip">
	<span class="chip-icon" aria-hidden="true">{icon}</span>
	<div class="chip-text">
		<span class="chip-label">{label}</span>
		<span class="chip-value">{value}</span>
	</div>
</div>

<style>
	.chip {
		display: flex;
		align-items: center;
		gap: 0.55rem;
		padding: 0.45rem 0.65rem;
		border-radius: 14px;
		border: 1.75px solid var(--color-border);
		background: 
			linear-gradient(rgba(250, 240, 221, 0.85), rgba(250, 240, 221, 0.85)),
			url('/images/minecraft_green_planks.png');
		background-size: auto, 96px;
		box-shadow:
			inset 0 2px 0 rgba(255, 255, 255, 0.5),
			inset 0 -2px 0 rgba(0, 0, 0, 0.05),
			0 2.5px 0 var(--color-border);
	}

	.chip-icon {
		font-size: 1.1rem;
	}

	.chip-text {
		display: flex;
		flex-direction: column;
		line-height: 1.1;
	}

	.chip-label {
		font-size: 0.65rem;
		color: var(--color-text-muted);
	}

	.chip-value {
		font-size: 0.8rem;
		font-weight: 700;
		color: var(--color-text);
	}
</style>
