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
		padding: 0.55rem 0.75rem;
		border-radius: 999px;
		background: var(--color-surface);
		border: 1px solid var(--color-border);
		box-shadow: var(--shadow-soft);
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
