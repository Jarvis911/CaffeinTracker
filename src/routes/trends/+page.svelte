<script lang="ts">
	import { app } from '$lib/state/app.svelte';
	import { DRINK_CATALOG } from '$lib/drinks/catalog';
	import {
		checkAchievements,
		getTotalCaffeine,
		getDaysLogged
	} from '$lib/personalization/achievements';

	// ── Weekly chart data ────────────────────────────────────
	const weeklyData = $derived.by(() => {
		const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
		const shortNames = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
		const limit = app.profile.dailyCaffeineLimitMg || 400;
		const days = [];
		for (let i = 6; i >= 0; i--) {
			const date = new Date();
			date.setDate(date.getDate() - i);
			const dateStr = date.toDateString();
			const dayLogs = app.logs.filter((l) => new Date(l.at).toDateString() === dateStr);
			const caffeine = dayLogs.reduce((sum, log) => {
				const drink = DRINK_CATALOG.find((d) => d.id === log.drinkId);
				return sum + (drink ? drink.caffeineMg * log.amount : 0);
			}, 0);
			days.push({
				day: shortNames[date.getDay()],
				fullDay: dayNames[date.getDay()],
				caffeine,
				isToday: i === 0,
				isPast: i > 0,
				heightPercent: caffeine > 0 ? Math.min(100, (caffeine / limit) * 100) : 0
			});
		}
		return days;
	});

	const weeklyAvg = $derived.by(() => {
		const pastDays = weeklyData.filter((d) => d.isPast || d.isToday);
		const total = pastDays.reduce((s, d) => s + d.caffeine, 0);
		const count = pastDays.filter((d) => d.caffeine > 0).length;
		return count > 0 ? Math.round(total / count) : 0;
	});

	// ── Mindful summary ──────────────────────────────────────
	const daysUnderLimit = $derived.by(() => {
		const limit = app.profile.dailyCaffeineLimitMg;
		let streak = 0;
		for (let i = 0; i < 7; i++) {
			const date = new Date();
			date.setDate(date.getDate() - i);
			const dateStr = date.toDateString();
			const dayLogs = app.logs.filter((l) => new Date(l.at).toDateString() === dateStr);
			const caffeine = dayLogs.reduce((sum, log) => {
				const drink = DRINK_CATALOG.find((d) => d.id === log.drinkId);
				return sum + (drink ? drink.caffeineMg * log.amount : 0);
			}, 0);
			if (caffeine === 0 || caffeine <= limit) {
				streak++;
			} else {
				break;
			}
		}
		return streak;
	});

	const achievementsList = $derived(checkAchievements(app.logs, app.profile, app.connectedProviders));
	const unlockedCount = $derived(achievementsList.filter((a) => a.unlocked).length);
	const totalCaffeine = $derived(getTotalCaffeine(app.logs));
	const daysLogged = $derived(getDaysLogged(app.logs));

	// ── Log History ──────────────────────────────────────────
	interface HistoryEntry {
		id: string;
		drinkName: string;
		emoji: string;
		caffeineMg: number;
		time: string;
		dateLabel: string;
		category: string;
	}

	const logHistory = $derived.by(() => {
		const today = new Date().toDateString();
		const yesterday = new Date(Date.now() - 86400000).toDateString();
		const entries: HistoryEntry[] = [];

		for (const log of app.logs.slice(0, 20)) {
			const drink = DRINK_CATALOG.find((d) => d.id === log.drinkId);
			if (!drink) continue;
			const logDate = new Date(log.at);
			const logDateStr = logDate.toDateString();
			const time = logDate.toLocaleTimeString('en-US', {
				hour: '2-digit',
				minute: '2-digit'
			});
			const dateLabel =
				logDateStr === today ? 'Today' : logDateStr === yesterday ? 'Yesterday' : logDate.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });

			entries.push({
				id: log.id,
				drinkName: drink.name,
				emoji: drink.emoji,
				caffeineMg: drink.caffeineMg * log.amount,
				time,
				dateLabel,
				category: drink.category
			});
		}
		return entries;
	});

	// Group log history by date
	const groupedHistory = $derived.by(() => {
		const groups: Record<string, HistoryEntry[]> = {};
		for (const entry of logHistory) {
			if (!groups[entry.dateLabel]) groups[entry.dateLabel] = [];
			groups[entry.dateLabel].push(entry);
		}
		return Object.entries(groups);
	});

	function getCategoryColor(category: string): string {
		switch (category) {
			case 'coffee': return 'color: var(--color-secondary)';
			case 'tea': return 'color: var(--color-primary)';
			case 'energy': return 'color: #e97700';
			default: return 'color: var(--color-tertiary)';
		}
	}

	function exportHistory() {
		const lines = [
			'Date,Time,Drink,Caffeine (mg)',
			...logHistory.map((e) => `${e.dateLabel},${e.time},${e.drinkName},${e.caffeineMg}`)
		];
		const blob = new Blob([lines.join('\n')], { type: 'text/csv' });
		const url = URL.createObjectURL(blob);
		const a = document.createElement('a');
		a.href = url;
		a.download = 'caffeine-log.csv';
		a.click();
		URL.revokeObjectURL(url);
	}
</script>

<svelte:head>
	<title>Trends | Zakka Caffeine</title>
</svelte:head>

<!-- Top App Bar -->
<header class="top-bar">
	<div class="top-bar-inner">
		<div>
			<span class="overline">Weekly Ritual</span>
			<h1 class="page-headline">Caffeine Trends</h1>
		</div>
		<div class="avg-badge">
			<span class="avg-value">{weeklyAvg}</span>
			<span class="avg-unit">mg avg</span>
		</div>
	</div>
</header>

<main class="trends-page fade-in">

	<!-- ── Weekly Bar Chart ───────────────────────────────────── -->
	<section class="chart-section section-gap">
		<div class="chart-card">
			<div class="chart-bars">
				{#each weeklyData as day (day.day + day.isToday)}
					<div class="bar-col" class:today={day.isToday} title="{day.fullDay}: {day.caffeine}mg">
						<div class="bar-track">
							<div
								class="bar-fill"
								class:today-fill={day.isToday}
								style:height="{day.heightPercent}%"
								aria-label="{day.fullDay} {day.caffeine}mg"
							></div>
						</div>
						<span class="bar-label" class:today-label={day.isToday}>{day.day}</span>
					</div>
				{/each}
			</div>
			<div class="chart-footer">
				<span class="chart-foot-note">Daily limit: {app.profile.dailyCaffeineLimitMg}mg</span>
			</div>
		</div>
	</section>

	<!-- ── Mindful Summary ───────────────────────────────────── -->
	<section class="summary-section section-gap">
		<h2 class="section-heading">Mindful Summary</h2>
		<div class="summary-grid">
			<div class="summary-card streak-card">
				<div class="summary-icon-wrap primary-wrap">
					<span class="material-symbols-outlined fill">light_mode</span>
				</div>
				<div>
					<p class="summary-label">Calm Streak</p>
					<p class="summary-value">{daysUnderLimit} days under limit</p>
				</div>
			</div>
			<div class="summary-card">
				<div class="summary-icon-wrap tertiary-wrap">
					<span class="material-symbols-outlined fill">workspace_premium</span>
				</div>
				<div>
					<p class="summary-label">Achievements</p>
					<p class="summary-value">{unlockedCount} / {achievementsList.length} unlocked</p>
				</div>
			</div>
			<div class="summary-card">
				<div class="summary-icon-wrap">
					<span class="material-symbols-outlined">calendar_today</span>
				</div>
				<div>
					<p class="summary-label">Days Logged</p>
					<p class="summary-value">{daysLogged} total days</p>
				</div>
			</div>
			<div class="summary-card">
				<div class="summary-icon-wrap secondary-wrap">
					<span class="material-symbols-outlined fill">bolt</span>
				</div>
				<div>
					<p class="summary-label">All-time Total</p>
					<p class="summary-value">{totalCaffeine}mg lifetime</p>
				</div>
			</div>
		</div>

		<!-- Insight quote -->
		{#if daysUnderLimit >= 3}
			<div class="insight-quote">
				"You've had {daysUnderLimit} mindful days in a row. Your evening rest thanks you."
			</div>
		{:else if weeklyAvg > 0}
			<div class="insight-quote">
				"Your weekly average is {weeklyAvg}mg. Mindful tracking builds better habits over time."
			</div>
		{/if}
	</section>

	<!-- ── Log History ────────────────────────────────────────── -->
	<section class="history-section">
		<div class="history-header">
			<h2 class="section-heading">Log History</h2>
			{#if logHistory.length > 0}
				<button type="button" class="export-btn" onclick={exportHistory}>
					Export <span class="material-symbols-outlined">download</span>
				</button>
			{/if}
		</div>

		{#if groupedHistory.length === 0}
			<div class="history-empty">
				<span class="material-symbols-outlined empty-icon">local_cafe</span>
				<p>No logs yet. Start your ritual from the Log tab.</p>
			</div>
		{:else}
			<div class="history-list">
				{#each groupedHistory as [dateLabel, entries] (dateLabel)}
					<div class="history-group">
						<div class="date-divider">
							<div class="divider-line"></div>
							<span class="divider-label">{dateLabel}</span>
							<div class="divider-line"></div>
						</div>

						{#each entries as entry (entry.id)}
							<div class="history-item">
								<div class="history-icon" style={getCategoryColor(entry.category)}>
									<span class="history-emoji" aria-hidden="true">{entry.emoji}</span>
								</div>
								<div class="history-info">
									<div class="history-row">
										<span class="history-name">{entry.drinkName}</span>
										<span class="history-time">{entry.time}</span>
									</div>
									<span class="history-category">{entry.category}</span>
								</div>
								<div class="history-mg">
									<span style={getCategoryColor(entry.category)}>{entry.caffeineMg}mg</span>
								</div>
							</div>
						{/each}
					</div>
				{/each}
			</div>
		{/if}
	</section>
</main>

<style>
	/* ── Top Bar ──────────────────────────────────────────── */
	.top-bar {
		background: var(--color-surface);
		border-bottom: 1px solid rgba(197, 200, 187, 0.2);
		padding: 1.25rem var(--space-container) 1rem;
	}

	.top-bar-inner {
		display: flex;
		justify-content: space-between;
		align-items: flex-end;
		max-width: 768px;
		margin-inline: auto;
	}

	.overline {
		display: block;
		font-family: var(--font-body);
		font-size: 0.7rem;
		font-weight: 600;
		letter-spacing: 0.1em;
		text-transform: uppercase;
		color: var(--color-outline);
		margin-bottom: 0.2rem;
	}

	.page-headline {
		font-family: var(--font-display);
		font-size: 1.625rem;
		font-weight: 600;
		color: var(--color-on-surface);
		margin: 0;
		letter-spacing: -0.01em;
	}

	.avg-badge {
		text-align: right;
	}

	.avg-value {
		font-family: var(--font-display);
		font-size: 1.375rem;
		font-weight: 600;
		color: var(--color-primary);
	}

	.avg-unit {
		font-family: var(--font-body);
		font-size: 0.75rem;
		font-weight: 500;
		color: var(--color-outline);
		margin-left: 0.2rem;
	}

	/* ── Trends Page ─────────────────────────────────────── */
	.trends-page {
		max-width: 768px;
		margin-inline: auto;
		padding: var(--space-gutter) var(--space-container) var(--space-section);
	}

	.section-gap {
		margin-bottom: var(--space-section);
	}

	.section-heading {
		font-family: var(--font-display);
		font-size: 1.25rem;
		font-weight: 500;
		color: var(--color-on-surface);
		margin: 0 0 0.875rem;
		padding: 0 0.25rem;
	}

	/* ── Chart ───────────────────────────────────────────── */
	.chart-card {
		background: var(--color-surface-container-lowest);
		border-radius: var(--radius-lg);
		box-shadow: var(--shadow-card);
		border: 1px solid rgba(28, 46, 36, 0.12);
		padding: var(--space-gutter);
		background-image: radial-gradient(circle at 20% 30%, rgba(28, 46, 36, 0.02) 0%, transparent 60%);
	}

	.chart-bars {
		height: 10rem;
		display: flex;
		align-items: flex-end;
		gap: 0.5rem;
		padding-bottom: 0.5rem;
	}

	.bar-col {
		flex: 1;
		display: flex;
		flex-direction: column;
		align-items: center;
		gap: 0.375rem;
		height: 100%;
		justify-content: flex-end;
		cursor: pointer;
	}

	.bar-track {
		flex: 1;
		width: 100%;
		display: flex;
		align-items: flex-end;
		background: rgba(28, 46, 36, 0.05);
		border-radius: var(--radius-sm) var(--radius-sm) 0 0;
		overflow: hidden;
		min-height: 100%;
	}

	.bar-fill {
		width: 100%;
		background: var(--color-primary);
		border-radius: var(--radius-sm) var(--radius-sm) 0 0;
		transition: height 0.6s cubic-bezier(0.16, 1, 0.3, 1);
		opacity: 0.8;
	}

	.bar-col:hover .bar-fill {
		opacity: 1;
	}

	.bar-fill.today-fill {
		opacity: 1;
		background: var(--color-primary);
	}

	.bar-col:hover .bar-track {
		background: rgba(28, 46, 36, 0.1);
	}

	.bar-label {
		font-family: var(--font-body);
		font-size: 0.65rem;
		font-weight: 500;
		color: var(--color-on-surface-variant);
	}

	.bar-label.today-label {
		font-weight: 700;
		color: var(--color-primary);
	}

	.chart-footer {
		padding-top: 0.5rem;
		border-top: 1px solid rgba(28, 46, 36, 0.1);
		margin-top: 0.25rem;
	}

	.chart-foot-note {
		font-family: var(--font-body);
		font-size: 0.7rem;
		color: var(--color-outline);
	}

	/* ── Summary Grid ────────────────────────────────────── */
	.summary-grid {
		display: grid;
		grid-template-columns: repeat(2, 1fr);
		gap: 0.75rem;
		margin-bottom: 0.875rem;
	}

	.summary-card {
		display: flex;
		align-items: center;
		gap: 0.75rem;
		background: var(--color-surface-container-lowest);
		border-radius: var(--radius-lg);
		box-shadow: var(--shadow-card);
		padding: 0.875rem;
		border: 1px solid rgba(28, 46, 36, 0.12);
	}

	.streak-card {
		background: rgba(186, 109, 86, 0.04);
		border-color: rgba(186, 109, 86, 0.3);
	}

	.summary-icon-wrap {
		width: 2.75rem;
		height: 2.75rem;
		border-radius: 50%;
		display: flex;
		align-items: center;
		justify-content: center;
		flex-shrink: 0;
		background: rgba(28, 46, 36, 0.05);
		color: var(--color-outline);
	}

	.primary-wrap {
		background: rgba(28, 46, 36, 0.08);
		color: var(--color-primary);
	}

	.secondary-wrap {
		background: rgba(186, 109, 86, 0.08);
		color: var(--color-secondary);
	}

	.summary-icon-wrap .material-symbols-outlined {
		font-size: 1.375rem;
	}

	.summary-icon-wrap .fill {
		font-variation-settings: 'FILL' 1;
	}

	.summary-label {
		font-family: var(--font-body);
		font-size: 0.65rem;
		font-weight: 600;
		text-transform: uppercase;
		letter-spacing: 0.05em;
		color: var(--color-on-surface-variant);
		margin: 0 0 0.15rem;
	}

	.summary-value {
		font-family: var(--font-body);
		font-size: 0.825rem;
		font-weight: 700;
		color: var(--color-on-surface);
		margin: 0;
	}

	.insight-quote {
		padding: 1rem 1.25rem;
		border-left: 2px solid var(--color-primary);
		background: rgba(28, 46, 36, 0.03);
		border-radius: var(--radius-sm);
		font-family: var(--font-display);
		font-size: 1.05rem;
		font-style: italic;
		color: var(--color-on-surface-variant);
		line-height: 1.5;
	}

	/* ── History ─────────────────────────────────────────── */
	.history-header {
		display: flex;
		justify-content: space-between;
		align-items: center;
		margin-bottom: 0.875rem;
	}

	.history-header .section-heading {
		margin: 0;
	}

	.export-btn {
		display: inline-flex;
		align-items: center;
		gap: 0.25rem;
		padding: 0.4rem 0.875rem;
		border-radius: var(--radius-full);
		border: 1px solid var(--color-primary);
		background: transparent;
		color: var(--color-primary);
		font-family: var(--font-body);
		font-size: 0.72rem;
		font-weight: 600;
		text-transform: uppercase;
		letter-spacing: 0.05em;
		cursor: pointer;
		transition: background 0.2s ease, color 0.2s ease;
	}

	.export-btn:hover {
		background: var(--color-primary);
		color: #ffffff;
	}

	.export-btn .material-symbols-outlined {
		font-size: 1rem;
	}

	.history-empty {
		display: flex;
		flex-direction: column;
		align-items: center;
		gap: 0.625rem;
		padding: 3rem 1.5rem;
		border-radius: var(--radius-lg);
		border: 1px dashed rgba(28, 46, 36, 0.2);
		background: var(--color-surface-container-lowest);
		text-align: center;
		color: var(--color-outline);
	}

	.empty-icon {
		font-size: 2.5rem;
	}

	.history-empty p {
		font-family: var(--font-body);
		font-size: 0.875rem;
		margin: 0;
	}

	.history-list {
		display: flex;
		flex-direction: column;
		gap: 0.5rem;
	}

	.history-group {
		display: flex;
		flex-direction: column;
		gap: 0.5rem;
	}

	.date-divider {
		display: flex;
		align-items: center;
		gap: 0.75rem;
		padding: 0.5rem 0;
	}

	.divider-line {
		flex: 1;
		height: 1px;
		background: rgba(28, 46, 36, 0.1);
	}

	.divider-label {
		font-family: var(--font-body);
		font-size: 0.65rem;
		font-weight: 600;
		text-transform: uppercase;
		letter-spacing: 0.08em;
		color: var(--color-outline);
	}

	.history-item {
		display: flex;
		align-items: center;
		gap: 0.875rem;
		background: var(--color-surface-container-lowest);
		border-radius: var(--radius-lg);
		padding: 0.875rem;
		box-shadow: var(--shadow-card);
		border: 1px solid rgba(28, 46, 36, 0.1);
		cursor: pointer;
		transition: background 0.2s ease, box-shadow 0.15s ease;
	}

	.history-item:hover {
		background: rgba(28, 46, 36, 0.02);
	}

	.history-icon {
		width: 3rem;
		height: 3rem;
		border-radius: var(--radius-md);
		background: rgba(28, 46, 36, 0.04);
		display: flex;
		align-items: center;
		justify-content: center;
		color: var(--color-primary);
		flex-shrink: 0;
	}

	.history-emoji {
		font-size: 1.5rem;
		line-height: 1;
	}

	.history-info {
		flex: 1;
		min-width: 0;
	}

	.history-row {
		display: flex;
		justify-content: space-between;
		align-items: baseline;
		gap: 0.5rem;
	}

	.history-name {
		font-family: var(--font-display);
		font-size: 1.15rem;
		font-weight: 500;
		color: var(--color-on-surface);
		white-space: nowrap;
		overflow: hidden;
		text-overflow: ellipsis;
	}

	.history-time {
		font-family: var(--font-body);
		font-size: 0.72rem;
		color: var(--color-outline);
		flex-shrink: 0;
	}

	.history-category {
		font-family: var(--font-body);
		font-size: 0.72rem;
		color: var(--color-on-surface-variant);
		text-transform: capitalize;
	}

	.history-mg {
		font-family: var(--font-body);
		font-size: 0.875rem;
		font-weight: 700;
		color: var(--color-primary);
		flex-shrink: 0;
	}
</style>
