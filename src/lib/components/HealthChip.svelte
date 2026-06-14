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
		gap: 0.5rem;
		padding: 0.5rem 0.75rem;
		border-radius: var(--radius-xl);
		border: 1px solid rgba(28, 46, 36, 0.12);
		background: var(--color-surface-container-lowest);
		box-shadow: var(--shadow-card);
	}

	.chip-icon {
		font-size: 1.1rem;
		line-height: 1;
	}

	.chip-text {
		display: flex;
		flex-direction: column;
		line-height: 1.2;
	}

	.chip-label {
		font-family: var(--font-body);
		font-size: 0.62rem;
		font-weight: 600;
		text-transform: uppercase;
		letter-spacing: 0.06em;
		color: var(--color-outline);
	}

	.chip-value {
		font-family: var(--font-body);
		font-size: 0.85rem;
		font-weight: 700;
		color: var(--color-on-surface);
	}
</style>
