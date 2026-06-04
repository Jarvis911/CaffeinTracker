<script lang="ts">
	import { app } from '$lib/state/app.svelte';
	import { getCaffeineStatus, getDailySugarCap } from '$lib/personalization/recommendations';
	import { DRINK_CATALOG } from '$lib/drinks/catalog';
	import SpeechBubble from '$lib/components/SpeechBubble.svelte';
	import { fade } from 'svelte/transition';

	const caffeine = $derived(getCaffeineStatus(app.profile, app.logs));
	const sugarCap = $derived(getDailySugarCap(app.profile.sugarSensitivity));

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
	let showQuickAddDropdown = $state(false);

	let drinkWaterChecked = $state(false);
	let sleepHoursChecked = $state(false);
	let stepsChecked = $state(false);

	$effect(() => {
		drinkWaterChecked = app.health.hydrationMl >= 1500;
		sleepHoursChecked = app.health.sleepHours >= 7;
		stepsChecked = app.health.steps >= 6000;
	});

	function randomizeDialogue() {
		if (caffeine.percent >= 90) {
			const idx = Math.floor(Math.random() * limitWarningPool.length);
			currentDialog = limitWarningPool[idx];
		} else {
			let idx = Math.floor(Math.random() * greetingsPool.length);
			while (idx === lastDialogIdx && greetingsPool.length > 1) {
				idx = Math.floor(Math.random() * greetingsPool.length);
			}
			lastDialogIdx = idx;
			currentDialog = greetingsPool[idx];
		}
	}

	$effect(() => {
		if (caffeine.percent >= 90) {
			currentDialog = limitWarningPool[0];
		}
	});

	function logDrink(drinkId: string) {
		const drink = DRINK_CATALOG.find((d) => d.id === drinkId);
		if (drink) {
			app.logDrink(drinkId);
			loggedDrinkName = drink.name;
			showQuickAddDropdown = false;
			randomizeDialogue();
			setTimeout(() => {
				loggedDrinkName = null;
			}, 2000);
		}
	}

	function toggleHydration() {
		drinkWaterChecked = !drinkWaterChecked;
		app.setHealth({
			...app.health,
			hydrationMl: drinkWaterChecked ? 1500 : 800
		});
	}

	function toggleSleep() {
		sleepHoursChecked = !sleepHoursChecked;
		app.setHealth({
			...app.health,
			sleepHours: sleepHoursChecked ? 7.5 : 5.5
		});
	}

	function toggleSteps() {
		stepsChecked = !stepsChecked;
		app.setHealth({
			...app.health,
			steps: stepsChecked ? 6500 : 3200
		});
	}
</script>

<svelte:head>
	<link rel="preconnect" href="https://fonts.googleapis.com" />
	<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
	<link href="https://fonts.googleapis.com/css2?family=DotGothic16&family=VT323&display=swap" rel="stylesheet" />
	<title>Cozy Home — Caffein Tracker</title>
</svelte:head>

<div class="home-cozy-container fade-in">
	<div class="scene-wrapper">
		<div class="scene-bg" style="background-image: url('/images/cozy_home_bg.png');">
			<!-- svelte-ignore a11y_click_events_have_key_events -->
			<!-- svelte-ignore a11y_no_static_element_interactions -->
			<div class="character-click-area" onclick={randomizeDialogue} title="Bấm vào tôi để trò chuyện!"></div>

			<div class="speech-bubble-position">
				<SpeechBubble tail="bottom-left" onclick={randomizeDialogue}>
					{currentDialog}
				</SpeechBubble>
			</div>

			<div class="quick-bubble tea-bubble">
				<SpeechBubble tail="bottom-right" onclick={() => logDrink('chai')}>
					TRÀ (50mg) 🫖
				</SpeechBubble>
			</div>
			<div class="quick-bubble coffee-bubble">
				<SpeechBubble tail="left" onclick={() => logDrink('latte')}>
					CAFE (75mg) ☕
				</SpeechBubble>
			</div>

			<div class="wooden-signpost">
				<div class="pole"></div>
				<a href="/insights" class="sign-plank stats-plank">
					<span>STATS 📊</span>
				</a>
				<a href="/connect" class="sign-plank goals-plank">
					<span>GOALS 💗</span>
				</a>
				<a href="/log" class="sign-plank drinks-plank">
					<span>LOG ☕</span>
				</a>
			</div>
		</div>
	</div>

	{#if loggedDrinkName}
		<div class="pixel-toast" transition:fade={{ duration: 150 }}>
			<div class="toast-pixel-box">
				<span>Đã ghi nhận <strong>{loggedDrinkName}</strong>! 🥤✅</span>
			</div>
		</div>
	{/if}
</div>

<style>
	:global(body) {
		overflow: hidden !important;
		height: 100dvh !important;
		margin: 0 !important;
		padding: 0 !important;
	}

	:global(.app-shell) {
		height: 100dvh !important;
		display: flex !important;
		flex-direction: column !important;
		padding: 0 !important;
		box-sizing: border-box !important;
		overflow: hidden !important;
		max-width: 28rem;
		margin-inline: auto;
	}

	:global(.home-cozy-container *) {
		image-rendering: pixelated;
	}

	.home-cozy-container {
		display: flex;
		flex-direction: column;
		height: 100%;
		width: 100%;
		overflow: hidden;
		margin-bottom: 0;
	}

	.scene-wrapper {
		position: relative;
		overflow: hidden;
		flex-grow: 1;
		height: 100%;
		width: 100%;
	}

	.scene-bg {
		position: relative;
		width: 100%;
		height: 100%;
		background-size: cover;
		background-position: center;
		background-repeat: no-repeat;
	}

	.character-click-area {
		position: absolute;
		bottom: 15%;
		left: 25%;
		width: 30%;
		height: 35%;
		cursor: pointer;
		z-index: 5;
	}

	.speech-bubble-position {
		position: absolute;
		top: 15%;
		left: 10%;
		max-width: 55%;
		z-index: 10;
	}

	.quick-bubble {
		position: absolute;
		z-index: 10;
	}

	.tea-bubble {
		bottom: 35%;
		right: 32%;
	}

	.coffee-bubble {
		bottom: 15%;
		right: 5%;
	}

	.wooden-signpost {
		position: absolute;
		top: 25px;
		right: 15px;
		display: flex;
		flex-direction: column;
		align-items: center;
		z-index: 8;
	}

	.wooden-signpost .pole {
		width: 6px;
		height: 120px;
		background-color: #795238;
		border: 2px solid #3d2c2a;
		position: absolute;
		top: 0;
		z-index: -1;
	}

	.sign-plank {
		display: block;
		background-color: #d1a179;
		border: 2.5px solid #3d2c2a;
		padding: 0.15rem 0.55rem;
		margin-bottom: 0.35rem;
		color: #3d2c2a;
		font-family: 'Quicksand', system-ui, sans-serif;
		font-size: 0.75rem;
		font-weight: bold;
		text-decoration: none;
		text-align: center;
		box-shadow:
			inset -2px -2px 0 0 #b37f58,
			inset 2px 2px 0 0 #fbe2cd,
			0 2px 0 rgba(0, 0, 0, 0.15);
		transition: transform 0.1s ease;
		min-width: 65px;
	}

	.sign-plank:hover {
		transform: scale(1.05) rotate(1deg);
		background-color: #fbe2cd;
	}

	.stats-plank {
		transform: rotate(-3deg) translateX(-4px);
	}
	.goals-plank {
		transform: rotate(2deg) translateX(4px);
	}
	.drinks-plank {
		transform: rotate(-1deg) translateX(-2px);
	}

	.pixel-toast {
		position: fixed;
		bottom: 85px;
		left: 50%;
		transform: translateX(-50%);
		z-index: 100;
	}

	.toast-pixel-box {
		background-color: #faf0dd;
		border: 3px solid #3d2c2a;
		padding: 0.5rem 1rem;
		box-shadow:
			inset -2px -2px 0 0 #eed4b5,
			0 4px 0 #3d2c2a;
		font-family: 'Quicksand', system-ui, sans-serif;
		font-size: 0.78rem;
		font-weight: 700;
		color: #3d2c2a;
		white-space: nowrap;
	}
</style>
