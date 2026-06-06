<script lang="ts">
	import { app } from '$lib/state/app.svelte';
	import { getCaffeineStatus } from '$lib/personalization/recommendations';
	import { DRINK_CATALOG } from '$lib/drinks/catalog';
	import SpeechBubble from '$lib/components/SpeechBubble.svelte';
	import SceneLayer from '$lib/components/cozy/SceneLayer.svelte';
	import SceneHotspot from '$lib/components/cozy/SceneHotspot.svelte';
	import WoodenSignpost from '$lib/components/cozy/WoodenSignpost.svelte';
	import PixelToast from '$lib/components/cozy/PixelToast.svelte';
	import { COZY_SCENE, QUICK_DRINKS, SIGNPOST_LINKS } from '$lib/components/cozy/scene-config';

	const caffeine = $derived(getCaffeineStatus(app.profile, app.logs));

	const greetingsPool = [
		'Làm tí cafe hong?',
		'Cần nạp chút caffeine cho tỉnh táo chưa bạn?',
		'Hôm nay bạn thấy thế nào? Khỏe khoắn chứ?',
		'Đừng quên uống nước lọc nữa nha!',
		'Hôm nay bạn đã uống mấy ly rồi?',
		'Caffeine sẽ giúp bạn tỉnh táo học tập và làm việc đó!',
		'Nhâm nhi một tách trà ấm cũng tuyệt lắm á.'
	];

	const limitWarningPool = [
		'Nạp hơi nhiều caffeine rồi đó, uống nước lọc thôi bạn ơi!',
		'Giới hạn hôm nay sắp hết rồi nha! Nghỉ ngơi thui.',
		'Hôm nay uống nhiều quá rồi, để mai uống tiếp nhé!',
		'Dừng lại thôi! Tim đang đập thình thịch rồi nè.',
		'Nước lọc là chân á lúc này nha bạn yêu!'
	];

	let currentDialog = $state('Làm tí cafe hong?');
	let lastDialogIdx = -1;
	let loggedDrinkName = $state<string | null>(null);

	function randomizeDialogue() {
		if (caffeine.percent >= 90) {
			currentDialog = limitWarningPool[Math.floor(Math.random() * limitWarningPool.length)];
			return;
		}

		let idx = Math.floor(Math.random() * greetingsPool.length);
		while (idx === lastDialogIdx && greetingsPool.length > 1) {
			idx = Math.floor(Math.random() * greetingsPool.length);
		}
		lastDialogIdx = idx;
		currentDialog = greetingsPool[idx];
	}

	$effect(() => {
		if (caffeine.percent >= 90) {
			currentDialog = limitWarningPool[0];
		}
	});

	function logDrink(drinkId: string) {
		const drink = DRINK_CATALOG.find((d) => d.id === drinkId);
		if (!drink) return;

		app.logDrink(drinkId);
		loggedDrinkName = drink.name;
		randomizeDialogue();
		setTimeout(() => {
			loggedDrinkName = null;
		}, 2000);
	}
</script>

<svelte:head>
	<title>Cozy Home — Caffein Tracker</title>
</svelte:head>

<div class="home-cozy-page fade-in">
	<SceneLayer>
		<SceneHotspot
			anchor={COZY_SCENE.character}
			label="Bấm vào tôi để trò chuyện!"
			onclick={randomizeDialogue}
		/>

		<div class="scene-slot dialog-slot" style:max-width={COZY_SCENE.dialog.maxWidth}>
			<SpeechBubble tail="bottom-left" onclick={randomizeDialogue}>
				{currentDialog}
			</SpeechBubble>
		</div>

		{#each QUICK_DRINKS as drink (drink.id)}
			<div
				class="scene-slot quick-slot"
				style:bottom={COZY_SCENE[drink.anchor].bottom}
				style:right={COZY_SCENE[drink.anchor].right}
			>
				<SpeechBubble tail={drink.tail} onclick={() => logDrink(drink.id)}>
					{drink.label}
				</SpeechBubble>
			</div>
		{/each}

		<WoodenSignpost links={SIGNPOST_LINKS} anchor={COZY_SCENE.signpost} />
	</SceneLayer>

	{#if loggedDrinkName}
		<PixelToast>
			Đã ghi nhận <strong>{loggedDrinkName}</strong>! 🥤✅
		</PixelToast>
	{/if}
</div>

<style>
	.home-cozy-page {
		flex: 1;
		min-height: 0;
		width: 100%;
		overflow: hidden;
	}

	.scene-slot {
		position: absolute;
		z-index: 10;
	}

	.dialog-slot {
		top: 15%;
		left: 10%;
		max-width: 55%;
	}

	.quick-slot {
		touch-action: manipulation;
	}

	@media (max-height: 700px) {
		.dialog-slot {
			top: 10%;
			max-width: 50%;
		}
	}

	@media (max-height: 600px) {
		.dialog-slot {
			top: 8%;
			max-width: 48%;
		}
	}
</style>
