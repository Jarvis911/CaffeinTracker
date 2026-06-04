<script lang="ts">
	import type { Snippet } from 'svelte';

	let {
		tail = 'bottom-left', // 'bottom-left', 'bottom-right', 'left', 'right'
		style = '',
		onclick,
		children
	}: {
		tail?: 'bottom-left' | 'bottom-right' | 'left' | 'right';
		style?: string;
		onclick?: () => void;
		children?: Snippet;
	} = $props();
</script>

<!-- svelte-ignore a11y_click_events_have_key_events -->
<!-- svelte-ignore a11y_no_static_element_interactions -->
<div 
	class="pixel-speech-bubble tail-{tail}" 
	{style} 
	class:interactive={!!onclick}
	{onclick}
>
	<div class="bubble-content">
		{@render children?.()}
	</div>
	<div class="bubble-tail"></div>
</div>

<style>
	.pixel-speech-bubble {
		position: relative;
		background-color: #ffffff;
		border: 3px solid #3d2c2a;
		border-radius: 12px;
		padding: 0.5rem 0.75rem;
		box-shadow: 
			inset -2px -2px 0 0 #eed4b5,
			0 4px 0 rgba(0, 0, 0, 0.15),
			0 4px 0 #3d2c2a;
		font-family: 'Quicksand', system-ui, sans-serif;
		font-size: 0.78rem;
		font-weight: 700;
		color: #3d2c2a;
		line-height: 1.3;
		z-index: 10;
		display: inline-block;
	}

	.pixel-speech-bubble.interactive {
		cursor: pointer;
		transition: transform 0.1s ease;
	}

	.pixel-speech-bubble.interactive:hover {
		transform: scale(1.03);
		background-color: #fffdfa;
	}

	.pixel-speech-bubble.interactive:active {
		transform: scale(0.97) translateY(2px);
	}

	.bubble-tail {
		position: absolute;
		width: 10px;
		height: 10px;
		background-color: #ffffff;
		border: 3px solid #3d2c2a;
		transform: rotate(45deg);
		z-index: -1;
	}

	/* Tail positionings */
	.pixel-speech-bubble.tail-bottom-left {
		background-image: url('/images/bubble-chat.png');
		background-size: 100% 100%;
		background-color: transparent;
		border: none;
		box-shadow: none;
		padding: 0.65rem 0.85rem 1rem 0.85rem;
	}

	.pixel-speech-bubble.tail-bottom-left .bubble-tail {
		display: none;
	}

	.pixel-speech-bubble.tail-bottom-left.interactive:hover {
		background-color: transparent;
		filter: brightness(0.97);
	}

	.pixel-speech-bubble.tail-bottom-left.interactive:active {
		background-color: transparent;
	}

	.tail-bottom-right .bubble-tail {
		bottom: -7px;
		right: 20px;
		border-top: none;
		border-left: none;
		box-shadow: 2px 2px 0 rgba(0, 0, 0, 0.05);
	}

	.tail-left .bubble-tail {
		left: -7px;
		top: 50%;
		transform: translateY(-50%) rotate(45deg);
		border-top: none;
		border-right: none;
	}

	.tail-right .bubble-tail {
		right: -7px;
		top: 50%;
		transform: translateY(-50%) rotate(45deg);
		border-bottom: none;
		border-left: none;
	}

	.bubble-content {
		position: relative;
		z-index: 2;
	}
</style>
